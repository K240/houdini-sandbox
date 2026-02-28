# houdini-sandbox

Houdini Sandbox. Python 環境を `uv` で同期するためのローカル環境セットです。

## 起動方法

事前に `uv` をインストールし、`uv --version` が実行できる状態にしてください（インストール手順: https://docs.astral.sh/uv/getting-started/installation/）。

1. `.env.example` をコピーして `.env` を作成

```powershell
Copy-Item .env.example .env
```

2. 各 OS に応じて起動

### Windows (PowerShell)

```powershell
.\hou.ps1
```

### Windows (Batch)

```bat
.\hou.bat
```

### macOS (bash/zsh)

```bash
./hou.sh
```

## 詳細ドキュメント

- `HSITE + uv` の起動環境仕様: [docs/hsite-uv-environment.md](docs/hsite-uv-environment.md)

## 免責事項

- 本リポジトリは非公式の個人用サンプルであり、SideFX の公式サポート対象ではありません。
- 本ツールの利用により生じたいかなる損害（データ損失・業務停止・環境破損等）についても、作成者は責任を負いません。
- 本番環境で利用する前に、必ず検証環境で十分に動作確認し、必要なバックアップを取得してください。
