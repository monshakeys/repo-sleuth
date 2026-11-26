# ripgrep (rg) - Advanced Reference

`rg` is a line-oriented search tool that recursively searches the current directory for a regex pattern.

```sh
rg [OPTIONS] PATTERN [PATH...]
```

## 1. Scope Limiting Strategies (範圍限縮策略)

**CRITICAL**: Always limit scope to prevent overwhelming output.

```sh
# Filter by File Type
rg "pattern" --type py
rg "pattern" --type js --type ts

# Filter by Directory
rg "pattern" src/services/

# Exclude Directories
rg "pattern" --glob '!tests' --glob '!vendor'

# Count matches first (Do this before full output)
rg "pattern" --count
```

## 2. Advanced Matching (進階匹配)

```sh
# Multiline Matching (Match across newlines)
rg -U "class.*\n.*def __init__"

# Word boundaries (Exact word match)
rg -w "import"

# Fixed strings (No regex interpretation, faster)
rg -F "print(x)"

# Show only matching part
rg -o "import \w+"
```

## 3. Context & Output Control (上下文與輸出)

```sh
# Context (Lines before/after)
rg -C 3 "error"      # 3 lines context
rg -A 5 "class"      # 5 lines after
rg -B 2 "return"     # 2 lines before

# File names only (Useful for piping)
rg -l "pattern"

# Files WITHOUT match
rg --files-without-match "pattern"
```

## 4. Statistics (統計)

```sh
# Show detailed stats
rg --stats "pattern"

# Sort files by match count
rg -c "pattern" | sort -t: -k2 -rn
```
