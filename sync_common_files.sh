#!/bin/bash

# Mostly developing on `main`... to keep the orphan updated, we find the
# intersection of file names in the main branch and the orphan, then overwrite
# the orphan's files...

if ! git diff-index --quiet HEAD --; then
    echo "Error: there are uncommitted changes on the current branch"
    exit 1
fi

SOURCE_BRANCH="main"

comm -12 \
    <(git ls-tree -r --name-only "$SOURCE_BRANCH" | sort) \
    <(git ls-tree -r --name-only HEAD | sort) | while IFS= read -r file; do
        if [ -n "$file" ]; then
            git show "$SOURCE_BRANCH":"$file" > "$file"
        fi
    done

