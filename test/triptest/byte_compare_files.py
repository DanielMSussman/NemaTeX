import sys
import os

# really just to be used from trip.dvi... the magic numbers
# 27 and 2878 have to do with how the dvi would change if you
# use a date other than July 4, 1776, etc.
# For the etex trip I switched to dvi-to-typ and then normalized
# the date... that would probably be smarter here, too, but I'm lazy

def analyze_diff(path1, path2):
    try:
        with open(path1, 'rb') as f1, open(path2, 'rb') as f2:
            b1 = f1.read()
            b2 = f2.read()
    except FileNotFoundError as e:
        print(f"Error: {e}")
        sys.exit(1)

    if len(b1) != len(b2):
        print(f"Size Mismatch: {len(b1)} vs {len(b2)} bytes")
        min_len = min(len(b1), len(b2))
        b1, b2 = b1[:min_len], b2[:min_len]

    prefix_n = 0
    for x, y in zip(b1, b2):
        if x != y:
            break
        prefix_n += 1

    suffix_m = 0
    for x, y in zip(reversed(b1), reversed(b2)):
        if x != y:
            break
        suffix_m += 1
        
    print(f"First {prefix_n} bytes are identical.")
    print(f"Last {suffix_m} bytes are identical.")
    
    if len(b1)==2920 and prefix_n == 2920 and suffix_m == 2920:
        sys.exit(0)
    if len(b1)==2920 and prefix_n >= 27 and suffix_m >= 2878:
        sys.exit(0) 
    sys.exit(1)
if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python compare_bytes.py <file1> <file2>")
        sys.exit(1)
    
    analyze_diff(sys.argv[1], sys.argv[2])
