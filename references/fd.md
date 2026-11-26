# fd (Find) - Advanced Reference

`fd` is a program to find entries in your filesystem. It is a simple, fast and user-friendly alternative to `find`.

```sh
fd [FLAGS/OPTIONS] [<pattern>] [<path>...]
```

## 1. Basic Filtering (基礎過濾)

```sh
# Find files by extension
fd -e py
fd -e ts -e tsx

# Find in specific directory
fd pattern src/

# Case sensitivity (Smart case is default)
fd -s "Pattern"   # Case-sensitive
fd -i "pattern"   # Case-insensitive

# Exclude patterns
fd -E node_modules -E ".git"
```

## 2. Advanced Filtering (進階過濾)

```sh
# Time-based (Modified within...)
fd --changed-within 1h    # Last hour
fd --changed-before 1w    # Older than 1 week

# Size-based
fd --size +1m             # Larger than 1MB
fd --size -10k            # Smaller than 10KB

# Type-based
fd -t f                   # Files only
fd -t d                   # Directories only
fd -t x                   # Executables
```

## 3. Execution Patterns (執行指令)

Use `-x` (execute per file) or `-X` (execute batch) to perform actions on found files.

```sh
# Line count per file (Execute once per file)
fd -e py -x wc -l {}

# Format files (Parallel execution)
fd -e ts -x prettier --write {}

# Convert format
fd -e csv -x csvtojson {} > {.}.json

# Batch processing (All files as arguments to one command)
fd -e py -X wc -l
```
