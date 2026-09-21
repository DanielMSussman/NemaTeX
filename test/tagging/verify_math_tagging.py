#!/usr/bin/env python3
"""
Verification script for math tagging in nematex PDF output.
Extracts the PDF structure tree (StructTreeRoot -> StructElem) and compares
each <math> formula against reference MathML structure trees defined in JSON.
It relies on somewhat brittle regexes that work on plain text -- so, the script
100% assumes that it will act on an uncompressed pdf

I have very little interest in parsing either pdfs or json files, so, very 
unusually for this project: This file was written by gemini 3.7 flash
"""

import sys
import os
import re
import json


def unescape_pdf_string(s):
    """Decode PDF string literal (parentheses) or hex string (<hex>)."""
    s = s.strip()
    if s.startswith("<") and s.endswith(">"):
        hex_str = s[1:-1].strip()
        try:
            raw_bytes = bytes.fromhex(hex_str)
            if raw_bytes.startswith(b"\xfe\xff"):
                return raw_bytes[2:].decode("utf-16-be", errors="replace")
            return raw_bytes.decode("utf-8", errors="replace")
        except Exception:
            return hex_str
    elif s.startswith("(") and s.endswith(")"):
        inner = s[1:-1]
        out = []
        i = 0
        while i < len(inner):
            if inner[i] == "\\" and i + 1 < len(inner):
                nxt = inner[i + 1]
                if nxt == "n":
                    out.append("\n")
                elif nxt == "r":
                    out.append("\r")
                elif nxt == "t":
                    out.append("\t")
                elif nxt in "()\\":
                    out.append(nxt)
                elif nxt.isdigit():
                    oct_digits = inner[i + 1:i + 4]
                    try:
                        out.append(chr(int(oct_digits, 8)))
                        i += len(oct_digits)
                        continue
                    except ValueError:
                        out.append(nxt)
                else:
                    out.append(nxt)
                i += 2
            else:
                out.append(inner[i])
                i += 1
        res = "".join(out)
        if res.startswith("\xfe\xff"):
            return res[2:].encode("latin1", errors="replace").decode("utf-16-be", errors="replace")
        return res
    return s


def normalize_math_text(s):
    """Normalize Mathematical Alphanumeric Unicode symbols (SMP U+1D400+) to standard ASCII."""
    if not s:
        return s
    res = []
    for ch in s:
        cp = ord(ch)
        # Mathematical Italic small (a-z)
        if 0x1D44E <= cp <= 0x1D467:
            res.append(chr(ord('a') + (cp - 0x1D44E)))
        # Mathematical Italic capital (A-Z)
        elif 0x1D434 <= cp <= 0x1D44D:
            res.append(chr(ord('A') + (cp - 0x1D434)))
        # Mathematical Bold small (a-z)
        elif 0x1D41A <= cp <= 0x1D433:
            res.append(chr(ord('a') + (cp - 0x1D41A)))
        # Mathematical Bold capital (A-Z)
        elif 0x1D400 <= cp <= 0x1D419:
            res.append(chr(ord('A') + (cp - 0x1D400)))
        # Mathematical Bold Italic small (a-z)
        elif 0x1D482 <= cp <= 0x1D49B:
            res.append(chr(ord('a') + (cp - 0x1D482)))
        # Mathematical Bold Italic capital (A-Z)
        elif 0x1D468 <= cp <= 0x1D481:
            res.append(chr(ord('A') + (cp - 0x1D468)))
        else:
            res.append(ch)
    return "".join(res)


def parse_pdf_objects(pdf_path):
    """Parse uncompressed PDF objects into a dictionary {obj_id: body_string}."""
    with open(pdf_path, "rb") as f:
        content = f.read().decode("latin1", errors="replace")

    objects = {}
    obj_pattern = re.compile(r"(\d+)\s+0\s+obj\s*(.*?)\s*endobj", re.DOTALL)
    for match in obj_pattern.finditer(content):
        obj_id = int(match.group(1))
        obj_body = match.group(2)
        objects[obj_id] = obj_body

    return objects


def parse_struct_element(obj_id, objects, parsed_nodes, parent_id=None):
    """Recursively parse a StructElem object and its children."""
    if obj_id in parsed_nodes:
        return parsed_nodes[obj_id]

    body = objects.get(obj_id, "")
    
    # Extract structure type /S /<tag>
    type_match = re.search(r"/S\s+/([A-Za-z0-9_-]+)", body)
    tag_name = type_match.group(1) if type_match else "Unknown"

    # Extract /ActualText
    actual_text = None
    act_match = re.search(r"/ActualText\s+(\([^\)]*\)|<[^>]*>)", body)
    if act_match:
        actual_text = normalize_math_text(unescape_pdf_string(act_match.group(1)))

    # Extract /Alt
    alt_text = None
    alt_match = re.search(r"/Alt\s+(\([^\)]*\)|<[^>]*>)", body)
    if alt_match:
        alt_text = normalize_math_text(unescape_pdf_string(alt_match.group(1)))

    node = {
        "obj_id": obj_id,
        "tag": tag_name,
        "parent_id": parent_id,
        "children": []
    }
    if actual_text is not None:
        node["text"] = actual_text
    elif alt_text is not None:
        node["text"] = alt_text

    parsed_nodes[obj_id] = node

    # Extract /K children
    # Strip marked content inline dictionary references << ... >> before extracting StructElem refs
    k_match = re.search(r"/K\s+\[(.*?)\]", body, re.DOTALL)
    if k_match:
        k_content = k_match.group(1)
        k_clean = re.sub(r"<<.*?>>", "", k_content, flags=re.DOTALL)
        ref_matches = re.findall(r"(\d+)\s+0\s+R", k_clean)
        for ref_id_str in ref_matches:
            child_id = int(ref_id_str)
            child_body = objects.get(child_id, "")
            # Skip Artifact elements in the logical structure tree
            if "/S /Artifact" in child_body:
                continue
            child_node = parse_struct_element(child_id, objects, parsed_nodes, parent_id=obj_id)
            node["children"].append(child_node)
    else:
        # Check single direct reference (excluding MCR dictionaries)
        single_k = re.search(r"/K\s+(\d+)\s+0\s+R", body)
        if single_k:
            child_id = int(single_k.group(1))
            child_body = objects.get(child_id, "")
            if "/S /Artifact" not in child_body and "/Type /StructElem" in child_body:
                child_node = parse_struct_element(child_id, objects, parsed_nodes, parent_id=obj_id)
                node["children"].append(child_node)

    return node


def extract_math_formulas(objects):
    """Find StructTreeRoot, parse all nodes, and return list of <math> formulas with parent & container context."""
    root_id = None
    for obj_id, body in objects.items():
        if "/Type /StructTreeRoot" in body:
            root_id = obj_id
            break

    if root_id is None:
        raise ValueError("Could not find /Type /StructTreeRoot in PDF.")

    root_body = objects[root_id]
    k_match = re.search(r"/K\s+\[(.*?)\]", root_body, re.DOTALL)
    if k_match:
        k_content = k_match.group(1)
        k_clean = re.sub(r"<<.*?>>", "", k_content, flags=re.DOTALL)
        k_refs = re.findall(r"(\d+)\s+0\s+R", k_clean)
    else:
        single_k = re.search(r"/K\s+(\d+)\s+0\s+R", root_body)
        k_refs = [single_k.group(1)] if single_k else []
    
    parsed_nodes = {}
    root_children = []
    for ref_str in k_refs:
        child_id = int(ref_str)
        child_node = parse_struct_element(child_id, objects, parsed_nodes, parent_id=0)
        root_children.append(child_node)

    # Collect all <math> elements
    math_nodes = []

    def find_math_nodes(n, parent_tag="Document", grand_parent_tag="Document"):
        if n["tag"] == "math":
            math_nodes.append((n, parent_tag, grand_parent_tag))
            return
        
        current_tag = n["tag"]
        for ch in n.get("children", []):
            find_math_nodes(ch, current_tag, parent_tag)

    for r_child in root_children:
        find_math_nodes(r_child, "Document", "Document")

    return math_nodes


def clean_tree_for_comparison(node):
    """Strip internal fields like obj_id and parent_id, leaving pure tag and children hierarchy."""
    clean = {"tag": node["tag"]}
    if "text" in node and node["text"]:
        clean["text"] = node["text"]
    if node.get("children"):
        clean["children"] = [clean_tree_for_comparison(ch) for ch in node["children"]]
    return clean


def trees_equal(t1, t2):
    """Compare two normalized structure trees."""
    if t1.get("tag") != t2.get("tag"):
        return False
    
    if "text" in t1 or "text" in t2:
        if t1.get("text") != t2.get("text"):
            return False

    c1 = t1.get("children", [])
    c2 = t2.get("children", [])
    if len(c1) != len(c2):
        return False

    for child1, child2 in zip(c1, c2):
        if not trees_equal(child1, child2):
            return False

    return True


def main():
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <generated.pdf> <reference.json> [output_log.out]")
        sys.exit(1)

    pdf_path = sys.argv[1]
    ref_path = sys.argv[2]
    out_log_path = sys.argv[3] if len(sys.argv) >= 4 else None

    log_lines = []

    def log(msg=""):
        print(msg)
        log_lines.append(str(msg))

    if not os.path.isfile(pdf_path):
        log(f"Error: PDF file '{pdf_path}' does not exist.")
        sys.exit(1)

    if not os.path.isfile(ref_path):
        log(f"Error: Reference JSON '{ref_path}' does not exist.")
        sys.exit(1)

    with open(ref_path, "r", encoding="utf-8") as f:
        references = json.load(f)

    objects = parse_pdf_objects(pdf_path)
    math_formulas = extract_math_formulas(objects)

    log(f"Extracted {len(math_formulas)} <math> formulas from {pdf_path}.")
    log(f"Loaded {len(references)} reference test cases from {ref_path}.\n")

    passed = 0
    failed = 0

    num_cases = max(len(math_formulas), len(references))

    for i in range(num_cases):
        if i >= len(references):
            log(f"[FAIL] Extra formula {i + 1} found in PDF but not in reference JSON:")
            log(json.dumps(clean_tree_for_comparison(math_formulas[i][0]), indent=2))
            failed += 1
            continue

        if i >= len(math_formulas):
            log(f"[FAIL] Missing formula {i + 1} ({references[i]['id']}) in PDF.")
            failed += 1
            continue

        ref = references[i]
        extracted_node, parent_tag, grand_parent_tag = math_formulas[i]
        extracted_clean = clean_tree_for_comparison(extracted_node)
        expected_tree = ref["expected_tree"]

        # Check parent / container match
        expected_parent = ref["parent_tag"]
        parent_ok = False
        if expected_parent == "P":
            parent_ok = (parent_tag == "P" or grand_parent_tag == "P")
        elif expected_parent == "Formula":
            parent_ok = (parent_tag == "Formula")
        else:
            parent_ok = (parent_tag == expected_parent or grand_parent_tag == expected_parent)

        tree_ok = trees_equal(extracted_clean, expected_tree)

        if parent_ok and tree_ok:
            container_str = f"<{grand_parent_tag}> -> <{parent_tag}>" if parent_tag == "Formula" else f"<{parent_tag}>"
            log(f"[PASS] Case {i + 1:2d} ({ref['id']}) - Container: {container_str}")
            passed += 1
        else:
            log(f"[FAIL] Case {i + 1:2d} ({ref['id']})")
            if not parent_ok:
                log(f"  Container mismatch: Expected <{expected_parent}>, Got <{grand_parent_tag}> -> <{parent_tag}>")
            if not tree_ok:
                log("  Expected tree:")
                log("   " + json.dumps(expected_tree))
                log("  Extracted tree:")
                log("   " + json.dumps(extracted_clean))
            failed += 1

    log(f"\nSummary: {passed} passed, {failed} failed out of {num_cases} test cases.")

    if out_log_path:
        os.makedirs(os.path.dirname(os.path.abspath(out_log_path)), exist_ok=True)
        with open(out_log_path, "w", encoding="utf-8") as f:
            f.write("\n".join(log_lines) + "\n")

    if failed > 0:
        sys.exit(1)
    sys.exit(0)


if __name__ == "__main__":
    main()
