#!/usr/bin/env bash

set -euo pipefail

usage() {
  echo "Usage:"
  echo "  $0 <Major> <Minor> <Patch> <PythonVersion>"
  echo "  $0  # load HOUDINI_VERSION and PYTHON_VERSION from .env"
  echo "Example:"
  echo "  $0 22 0 631 3.13"
}

load_dotenv() {
  local env_file="$1"
  if [[ -f "$env_file" ]]; then
    set -a
    # shellcheck disable=SC1090
    source "$env_file"
    set +a
  fi
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
load_dotenv "${SCRIPT_DIR}/.env"

if [[ $# -eq 4 ]]; then
  MAJOR="$1"
  MINOR="$2"
  PATCH="$3"
  PYTHON_VERSION="$4"
elif [[ $# -eq 0 ]]; then
  HOUDINI_VERSION="${HOUDINI_VERSION:-${HOU_FULLVER:-}}"
  PYTHON_VERSION="${PYTHON_VERSION:-${PY_VERSION:-}}"

  if [[ -z "${HOUDINI_VERSION}" || -z "${PYTHON_VERSION}" ]]; then
    echo "When no arguments are provided, .env must define HOUDINI_VERSION and PYTHON_VERSION."
    usage
    exit 1
  fi

  if [[ ! "$HOUDINI_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "HOUDINI_VERSION must be in major.minor.patch format (e.g. 22.0.631)"
    exit 1
  fi

  IFS='.' read -r MAJOR MINOR PATCH <<< "$HOUDINI_VERSION"
else
  usage
  exit 1
fi

if [[ ! "$PYTHON_VERSION" =~ ^3\.[0-9]+$ ]]; then
  echo "PythonVersion must be in major.minor format (e.g. 3.11 or 3.13)"
  exit 1
fi

export HSITE="$SCRIPT_DIR"
export HOU_VER="${MAJOR}.${MINOR}"
export HOU_FULLVER="${MAJOR}.${MINOR}.${PATCH}"
export PY_VERSION="${PYTHON_VERSION}"
export PY_UV_VERSION="python${PYTHON_VERSION}"

UV_DIR="${HSITE}/uv/${PY_UV_VERSION}"
if [[ ! -d "$UV_DIR" ]]; then
  echo "uv directory not found: $UV_DIR"
  exit 1
fi

uv sync --directory "$UV_DIR"

CANDIDATES=(
  "/Applications/Houdini/Houdini${HOU_FULLVER}/Houdini FX ${HOU_FULLVER}.app/Contents/MacOS/houdini"
  "/Applications/Houdini/Houdini${HOU_FULLVER}/Houdini Core ${HOU_FULLVER}.app/Contents/MacOS/houdini"
  "/Applications/Houdini/Houdini${HOU_FULLVER}/Houdini Indie ${HOU_FULLVER}.app/Contents/MacOS/houdini"
  "/Applications/Houdini/Houdini${HOU_FULLVER}/Houdini Apprentice ${HOU_FULLVER}.app/Contents/MacOS/houdini"
  "/Applications/Houdini/Houdini${HOU_FULLVER}/Frameworks/Houdini.framework/Versions/${HOU_FULLVER}/Resources/bin/houdini"
  "/Applications/Houdini/Houdini${HOU_FULLVER}/Frameworks/Houdini.framework/Versions/Current/Resources/bin/houdini"
)

HOUDINI_EXE=""
for candidate in "${CANDIDATES[@]}"; do
  if [[ -x "$candidate" ]]; then
    HOUDINI_EXE="$candidate"
    break
  fi
done

if [[ -z "$HOUDINI_EXE" ]]; then
  echo "Houdini executable not found for version ${HOU_FULLVER}. Checked:"
  for candidate in "${CANDIDATES[@]}"; do
    echo "  - $candidate"
  done
  exit 1
fi

nohup "$HOUDINI_EXE" >/dev/null 2>&1 &
