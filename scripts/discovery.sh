#!/usr/bin/env bash
set -euo pipefail

err() {
  echo "$*" >&2
}

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    err "Required command not found: $cmd"
    err "Tip: run ./scripts/selfcheck.sh for installation hints."
    exit 1
  fi
}

usage() {
  local out_fd="${1:-1}"
  cat >&"$out_fd" <<'USAGE'
Usage:
  discovery.sh files <pattern> [path] [-- <extra fd args...>]
  discovery.sh text <pattern> [path] [--type <type>] [-- <extra rg args...>]
  discovery.sh fuzzy <pattern> [path] [--errors <N>] [-- <extra ug args...>]
  discovery.sh ast <pattern> --lang <lang> [path] [-- <extra sg args...>]

Examples:
  discovery.sh files "service" src/
  discovery.sh text "TODO" --type py src/ -- -C 3 --count
  discovery.sh fuzzy "intialize" src/ --errors 2 -- --heading
  discovery.sh ast 'print($X)' --lang python src/ -- --strictness smart
USAGE
}

if [[ $# -lt 2 ]]; then
  usage 2
  exit 1
fi

cmd="$1"
shift
pattern="$1"
shift

case "$cmd" in
  files) require_cmd fd ;;
  text) require_cmd rg ;;
  fuzzy) require_cmd ug ;;
  ast) require_cmd sg ;;
  *)
    usage 2
    exit 1
    ;;
esac

case "$cmd" in
  files)
    path="."
    extra_args=()
    path_set=0
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --)
          shift
          extra_args=("$@")
          break
          ;;
        -*)
          err "files mode unknown option: $1 (use '--' for extra fd args)"
          usage 2
          exit 1
          ;;
        *)
          if [[ $path_set -eq 1 ]]; then
            err "files mode accepts at most one path"
            usage 2
            exit 1
          fi
          path="$1"
          path_set=1
          shift
          ;;
      esac
    done
    if [[ ${#extra_args[@]} -gt 0 ]]; then
      fd "${extra_args[@]}" -- "$pattern" "$path"
    else
      fd -- "$pattern" "$path"
    fi
    ;;
  text)
    path="."
    type_arg=""
    extra_args=()
    path_set=0
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --type)
          if [[ -z "${2:-}" ]]; then
            err "text mode requires a value for --type"
            usage 2
            exit 1
          fi
          type_arg="$2"
          shift 2
          ;;
        --)
          shift
          extra_args=("$@")
          break
          ;;
        -*)
          err "text mode unknown option: $1 (use '--' for extra rg args)"
          usage 2
          exit 1
          ;;
        *)
          if [[ $path_set -eq 1 ]]; then
            err "text mode accepts at most one path"
            usage 2
            exit 1
          fi
          path="$1"
          path_set=1
          shift
          ;;
      esac
    done
    rg_args=(-n)
    if [[ -n "$type_arg" ]]; then
      rg_args+=(--type "$type_arg")
    fi
    if [[ ${#extra_args[@]} -gt 0 ]]; then
      rg "${rg_args[@]}" "${extra_args[@]}" -- "$pattern" "$path"
    else
      rg "${rg_args[@]}" -- "$pattern" "$path"
    fi
    ;;
  fuzzy)
    path="."
    errors="2"
    extra_args=()
    path_set=0
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --errors)
          if [[ -z "${2:-}" ]]; then
            err "fuzzy mode requires a value for --errors"
            usage 2
            exit 1
          fi
          errors="$2"
          shift 2
          ;;
        --)
          shift
          extra_args=("$@")
          break
          ;;
        -*)
          err "fuzzy mode unknown option: $1 (use '--' for extra ug args)"
          usage 2
          exit 1
          ;;
        *)
          if [[ $path_set -eq 1 ]]; then
            err "fuzzy mode accepts at most one path"
            usage 2
            exit 1
          fi
          path="$1"
          path_set=1
          shift
          ;;
      esac
    done
    if [[ ${#extra_args[@]} -gt 0 ]]; then
      ug -n "-Z${errors}" "${extra_args[@]}" -- "$pattern" "$path"
    else
      ug -n "-Z${errors}" -- "$pattern" "$path"
    fi
    ;;
  ast)
    path="."
    lang=""
    extra_args=()
    path_set=0
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --lang)
          if [[ -z "${2:-}" ]]; then
            err "ast mode requires a value for --lang"
            usage 2
            exit 1
          fi
          lang="$2"
          shift 2
          ;;
        --)
          shift
          extra_args=("$@")
          break
          ;;
        -*)
          err "ast mode unknown option: $1 (use '--' for extra sg args)"
          usage 2
          exit 1
          ;;
        *)
          if [[ $path_set -eq 1 ]]; then
            err "ast mode accepts at most one path"
            usage 2
            exit 1
          fi
          path="$1"
          path_set=1
          shift
          ;;
      esac
    done
    if [[ -z "$lang" ]]; then
      err "ast mode requires: --lang <lang>"
      usage 2
      exit 1
    fi
    if [[ ${#extra_args[@]} -gt 0 ]]; then
      sg run -p "$pattern" --lang "$lang" "${extra_args[@]}" "$path"
    else
      sg run -p "$pattern" --lang "$lang" "$path"
    fi
    ;;
  *)
    usage 2
    exit 1
    ;;
esac
