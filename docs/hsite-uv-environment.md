# HSITE + uv 起動環境仕様

このドキュメントは、`hou.ps1` / `hou.sh` が起動時に行う環境設定の詳細を説明します。

## 概要

ランチャーは次の順序で処理します。

1. `.env` の読み込み（存在する場合）
2. Houdini / Python バージョンの決定
3. `HSITE` と関連環境変数の設定
4. `uv sync` 実行
5. Houdini 実行ファイルの探索と起動

## .env 変数

- `HOUDINI_VERSION`
  - 形式: `major.minor.patch`（例: `21.0.631`）
- `PYTHON_VERSION`
  - 形式: `3.minor`（例: `3.11`）
- `HOUDINI_INSTALL_ROOT_WINDOWS`（任意）
  - Windows の Houdini インストールルート
  - 既定値: `C:/Program Files/Side Effects Software`
- `HOUDINI_INSTALL_ROOT_MAC`（任意）
  - macOS の Houdini インストールルート
  - 既定値: `/Applications/Houdini`

## 引数指定（後方互換）

`hou.ps1` / `hou.sh` は、次の 4 引数指定にも対応しています。

1. `Major`
2. `Minor`
3. `Patch`
4. `PythonVersion`

例:

```bash
./hou.sh 21 0 631 3.11
```

4 引数モードでは、引数値が優先されます。引数なしモードでは `.env` の値を使用します。

## 設定される環境変数

- `HSITE`
  - ランチャースクリプト配置ディレクトリ
- `HOU_VER`
  - `major.minor`
- `HOU_FULLVER`
  - `major.minor.patch`
- `PY_VERSION`
  - `3.minor`
- `PY_UV_VERSION`
  - `python<major.minor>`（例: `python3.11`）

## uv 同期ディレクトリ

`uv sync` は次のディレクトリで実行されます。

- `./uv/python<major.minor>`
- 例: `./uv/python3.11`

## uv に関する補足

- 初回利用時は、対象ディレクトリ（例: `uv/python3.11`）に `pyproject.toml` が必要です。
- 依存関係は `uv.lock` があれば lock 内容を優先して同期されます。
- Python バージョンを切り替える場合は、対応する `uv/python<major.minor>` ディレクトリを用意してください。
- `uv` コマンド自体が見つからない場合は、`uv --version` でインストールと PATH を確認してください。
- 依存解決エラーが出る場合は、対象ディレクトリで `uv lock` を実行して lockfile を更新してから再実行してください。

## Houdini 実行ファイル探索

### Windows

- ルート: `HOUDINI_INSTALL_ROOT_WINDOWS`（未指定時は既定値）
- 実行パス: `<root>/Houdini <HOU_FULLVER>/bin/houdini.exe`

### macOS

- ルート: `HOUDINI_INSTALL_ROOT_MAC`（未指定時は既定値）
- 次の候補を順に探索して最初に見つかったものを起動:
  - `Houdini FX`
  - `Houdini Core`
  - `Houdini Indie`
  - `Houdini Apprentice`
  - Framework 配下の `bin/houdini`

## 失敗時の挙動

- バージョン形式が不正な場合はエラー終了
- `uv` 対象ディレクトリが存在しない場合はエラー終了
- Houdini 実行ファイルが見つからない場合はエラー終了
