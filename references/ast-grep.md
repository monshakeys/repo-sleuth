# ast-grep (sg) - Advanced Reference

`sg` is a structural code search tool that matches patterns in the Abstract Syntax Tree (AST). It finds code based on *structure*, not just text.

```sh
sg run -p 'PATTERN' --lang LANGUAGE [PATH]
```

## 1. Pattern Syntax (語法結構)

- `$VAR`: Matches any single AST node (variable, literal, etc.).
- `$$$`: Matches zero or more AST nodes (arguments, statements).

## 2. Common Patterns (常用範例)

```sh
# Find all class definitions
sg run -p 'class $NAME { $$$ }' --lang python

# Find function calls with specific arguments
sg run -p 'print($A, $B)' --lang python

# Find try-catch blocks
sg run -p 'try { $$$ } catch ($E) { $$$ }' --lang js

# Find React components
sg run -p 'function $NAME(props) { return <$TAG>$$$</$TAG> }' --lang tsx
```

## 3. Refactoring & Analysis (重構與分析)

```sh
# Find console.log usage in src/
sg run -p 'console.log($$$)' --lang js src/

# Find specific import structure
sg run -p 'import { $A } from "react"' --lang ts

# Check for empty blocks
sg run -p 'if ($COND) { }' --lang java
```
