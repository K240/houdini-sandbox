# houdini-environment

Houdini を指定バージョンで起動し、対応する Python 環境を `uv` で同期するためのローカル環境セットです。

## 使い方

### 1. `.env` を作成

`.env.example` をコピーして `.env` を作成し、利用するバージョンを設定します。

```bash
cp .env.example .env
```

`.env` 例:

```dotenv
HOUDINI_VERSION=22.0.631
PYTHON_VERSION=3.13
```

### 2. スクリプトを実行

### PowerShell

```powershell
.\hou.ps1
```

### Batch

```bat
.\hou.bat
```

### macOS (bash/zsh)

```bash
./hou.sh
```

## 既存の引数指定（後方互換）

引数指定もこれまで通り利用できます。

1. Major（例: `21`）
2. Minor（例: `0`）
3. Patch（例: `631`）
4. PythonVersion（例: `3.11` / `3.13`）

例:

```bash
./hou.sh 22 0 631 3.13
```

## 動作概要

- `HSITE` をスクリプト配置ディレクトリに設定
- `HOU_VER` / `HOU_FULLVER` / `PY_VERSION` / `PY_UV_VERSION` を設定
- `uv sync --directory ./uv/python3.11` のように実行
- Houdini 実行ファイルを起動

## 前提

- Windows
- Houdini が `C:\Program Files\Side Effects Software\Houdini <major>.<minor>.<patch>` にインストール済み
- `uv` コマンドが利用可能

### macOS 前提

- macOS
- Houdini が `/Applications/Houdini/Houdini<major>.<minor>.<patch>/` 配下にインストール済み
- `uv` コマンドが利用可能
