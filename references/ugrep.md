# ugrep (ug) - Advanced Reference

`ug` is a file pattern searcher that supports fuzzy search (approximate matching), useful when you are unsure of the exact spelling.

```sh
ug [OPTIONS] PATTERN [PATH...]
```

## 1. Fuzzy Search (模糊搜尋)

Use `-Z` to enable fuzzy matching.

```sh
# Best match (approximate)
ug -Z "function"

# Allow up to 2 errors (insertions, deletions, substitutions)
ug -Z2 "function"

# Fuzzy search specific file types
ug -Z -t py "def intialize"  # Finds "def initialize"
```

## 2. Boolean Search (布林搜尋)

ugrep supports AND/OR/NOT logic effectively.

```sh
# Match lines containing "error" AND "critical"
ug "error" --and "critical"

# Match lines containing "login" but NOT "test"
ug "login" --not "test"
```

## 3. Interactive & Output

```sh
# Output with line numbers and headers
ug -n --heading "pattern"

# Search in compressed files (zip, gz)
ug -z "pattern"
```
