---
name: repo-sleuth
description: |
  Use this skill whenever you need to search, navigate, audit, or understand a codebase.
  It provides ultra-fast file discovery, fuzzy text retrieval, and syntax-aware structural search to map architecture, audit code patterns, and locate logic instantly across complex projects.
  It returns file paths, matching code snippets with line numbers, and optional surrounding context.
  Do not use for simple file reads or when the user only wants to browse a single known file.
allowed-tools: Bash(fd:*), Bash(rg:*), Bash(sg:*), Bash(ug:*)
compatibility: |
  Requires fd, rg(ripgrep), ug(ugrep), sg(ast-grep).
  Install via `brew install fd ripgrep ugrep`.
metadata:
  author: JackaL
  version: "1.0.0"
  emoji: 🧐
---




<role>：角色與視角
<decision_boundary>：何時用 / 不用 / 成功輸出
<workflow>：步驟、分支、handoff
<output_contract>：固定格式與完成定義
<tool_rules>：何時用哪個工具、哪些工具不能亂用
<default_follow_through_policy>：是否主動執行、何時先問
<examples>：few-shot / worked examples
<model_notes>：模型差異與 reasoning 策略



<role>
  Act as a codebase search specialist helping Claude efficiently locate files, search content, and analyze syntax structures.
</role>

<inner-monologue>

</inner-monologue>

<decision_boundary>
  Use when:
  - The user needs to search, navigate, audit, or understand a codebase
  - The user needs file discovery (fd), text search (rg), fuzzy search (ug), or syntax search (sg)
  - The user needs to map architecture or locate logic across projects

  Do not use when:
  - The user only wants to read a single known file (use Read tool instead)
  - The task is simple browsing without search needs
  - The user needs semantic code understanding with symbol resolution (use serena skill instead)

  Inputs:
  - Search patterns, file patterns, target directories
  - Programming language or file type constraints

  Successful output:
  - Search results with file paths and line numbers
  - Structured findings that directly answer the query
  - Context snippets for relevance verification
</decision_boundary>

<output_contract>
  Return search results in this format:
  1. Summary of findings (brief overview)
  2. File paths with line numbers (exact matches)
  3. Relevant context snippets (for verification)
  4. Suggestions for next steps (if applicable)
</output_contract>

<default_follow_through_policy>
  Direct actions:
  - Running read-only search commands (fd, rg, ug, sg)
  - Displaying search results
  - Filtering and formatting output

  Ask before:
  - Modifying any files based on search results
  - Running destructive operations
  - Searching in very large directories without filters

  Stop and report:
  - Required tools (fd, rg, ug, sg) are not installed
  - Search patterns are too broad and would return excessive results
  - Target directory does not exist or is inaccessible
</default_follow_through_policy>

---

# Repo Sleuth

<overview>
  This toolkit provides a set of high-performance CLI utilities for locating files, searching content, and analyzing syntax structures within a codebase. Prefer using `fd` for file discovery, `rg` for precise text searches, `ug` when the exact spelling is uncertain, and `sg` for syntax-aware queries, rather than the standard `find` or `grep`. This ensures better performance and proper compatibility with `.gitignore`.
</overview>


## Quick Start
- 先選任務類型：
  - 找檔名 / 路徑模式 -> `fd`
  - 找精準字串 / regex -> `rg`
  - 不確定拼字、可能打錯字 -> `ug`
  - 找語法結構（例如 function call、import pattern）-> `sg`
- 先縮小範圍再放大：
  - 先限定語言或檔案類型 e.g. `--type py`, `--lang python`
  - 先指定目錄 e.g. `apps/`
  - 如果找不到，代表關鍵字可能在別的地方，或拼法不同，這時才開始放寬指定條件

## Decision Tree
1. 你是要找「檔案」還是「內容」？
   - 檔案 -> `fd`
   - 內容 -> 到第 2 步
2. 你是否知道關鍵字的精準拼法？
   - 是 -> `rg`
   - 否 -> `ug`
3. 你要找的是語法結構而不是純文字嗎？
   - 是 -> `sg`
   - 否 -> 保持 `rg` / `ug`

常見例子：
- 找 `service` 相關檔案：`fd service src/`
- 找 Python 的 TODO：`rg -n --type py "TODO" src/`
- 找可能拼錯的 `initialize`：`ug -n -Z2 intialize src/`
- 找 Python import pattern：`sg run -p 'import $A' --lang python apps/`


## Tools Index

> 程式碼檢索與導航

<tool_definitions>
  - `fd`: 找檔案，比 `find` 更高速的替代品，會忽略 gitignore 中的檔案。例如 `fd .py`。
  - `rg`: 找字，即 `ripgrep`，會忽略 gitignore 的檔案遞迴搜尋。例如 `rg TODO --type py`。
  - `ug`: 模糊找字，即 `ugrep`，支援模糊搜尋。例如 `ug -Z2 functoin` 容許 2 個字母拼錯。
  - `sg`: 找語法，即 `ast-grep`，基於 AST 的語法層程式碼搜尋工具。例如 `sg run -p 'print($X)' --lang python src/`。
</tool_definitions>


## Best Practices
<strategy>
  1. Start Narrow (由窄入寬)
    - 始終指定文件類型 (e.g., `--type py`, `--lang python`)。
    - 始終指定目錄範圍 (e.g., `src/`)。
    - *Bad*: `rg "user"` (Too many results)
    - *Good*: `rg "class.*User" --type py src/models`
  2. Check Volume (確認數量):
    - 在執行大規模搜尋前，先使用 `--count` 或 `| head` 確認結果數量。
  3. Context Aware (上下文意識):
    - 使用 `-C` (Context) 查看前後文，但要注意 Token 限制。
</strategy>


## Reference Manuals
- File Operations: [FD Reference](./references/fd.md)
- Text Search: [Ripgrep Reference](./references/ripgrep.md)
- Fuzzy Search: [Ugrep Reference](./references/ugrep.md)
- Structural Search: [AST-Grep Reference](./references/ast-grep.md)


## Scripts
- Unified Wrapper: `./scripts/discovery.sh`
  - `files`: `discovery.sh files <pattern> [path] [-- <fd args...>]`
  - `text`: `discovery.sh text <pattern> [path] [--type <type>] [-- <rg args...>]`
  - `fuzzy`: `discovery.sh fuzzy <pattern> [path] [--errors <N>] [-- <ug args...>]`
  - `ast`: `discovery.sh ast <pattern> --lang <lang> [path] [-- <sg args...>]`
  - 規則：`--` 之後的參數會原樣傳給底層工具。
  - 例子：`discovery.sh text "TODO" src/ -- --count -C 3`
  - 例子：`discovery.sh ast 'import $A' --lang python apps/ -- --strictness ast`
- Tool Self-check: `./scripts/selfcheck.sh [target_dir]`
  - 驗證 `fd` / `rg` / `ug` / `sg` 是否可用，並執行 smoke tests。
  - 缺工具時會提供 Homebrew 安裝提示。



## Examples
### Example 1: Find Python files with TODO comments
**User**: "搜尋所有 Python 檔案中的 TODO"
**Action**: `rg --type py "TODO" --line-number`
**Output**:
```text
src/utils/helpers.py:42: # TODO: Add error handling
src/models/user.py:15: # TODO: Implement validation
```

### Example 2: Fuzzy search for misspelled function name
**User**: "找出可能拼錯的 'initialize' 函數"
**Action**: `ug -Z2 "intialize" --type py`
**Output**:
```text
src/services/auth.py:78: def intialize_session():
```

### Example 3: Syntax-aware search for function calls
**User**: "找出所有 print 函數呼叫"
**Action**: `sg run -p 'print($X)' --lang python`
**Output**:
```text
src/main.py:10: print("Hello, World!")
src/debug.py:25: print(debug_info)
```

### Example 4: File discovery by pattern
**User**: "找到所有 service 相關的檔案"
**Action**: `fd service src/`
**Output**:
```text
src/services/user_service.py
src/services/auth_service.py
src/api/service_controller.py
```

### Example 5: Scoped search with context
**User**: "在 models 目錄中找出所有 class User 的定義"
**Action**: `rg "class User" --type py src/models -C 3`
**Output**:
```text
src/models/user.py
5-  class User(BaseModel):
6-      """User model definition"""
7-      id: int
```



##  Hybrid Workflows
### 程式碼調查
> 場景：調查登入失敗的原因
1. repo-sleuth: 尋找登入相關檔案 (`fd login`, `rg "login"`)
2. serena: 追蹤符號關係，尋找登入函式的所有呼叫
3. repo-sleuth: 搜尋錯誤處理模式 (`rg "error"`)

### 重構支援
> 場景：尋找並更新所有已棄用的函式
1. repo-sleuth: 搜尋棄用模式 (`rg "deprecated"`)
2. serena: 尋找所有對已棄用符號的引用
3. repo-sleuth: 搜尋使用範例 (`sg run -p 'deprecated_func($X)'`)
4. repo-sleuth: 定位所有受影響的檔案 (`fd -e py`)

### 架構映射
> 場景：映射身分驗證流程
1. repo-sleuth: 尋找身分驗證相關檔案 (`fd auth`, `rg "auth"`)
2. serena: 理解符號關係（類別、匯入）
3. repo-sleuth: 在驗證程式碼中尋找模式 (`sg run -p 'import.*auth'`)
4. repo-sleuth: 搜尋身分驗證相關配置 (`rg "auth" config/`)
