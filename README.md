# macOS dotfiles

Apple Silicon Macのシェル、Neovim、tmux、Homebrewアプリ、開発ランタイムを復元するための設定です。

## リセット前に行うこと

このリポジトリには、公開してよい設定だけを保存します。次のデータはdotfilesでは復元できないため、暗号化した外部媒体、Time Machine、または会社指定の方法で別途退避してください。

- `~/.ssh`（秘密鍵、公開鍵、`allowed_signers`）
- `~/.gitconfig`（会社メールアドレスと署名鍵の指定を含む）
- `~/.p10k.zsh`（現在のPowerlevel10k表示を完全に引き継ぐ場合）
- `~/.config/gh`、各種CLI・ブラウザ・IDEのログイン情報
- `.env`、`.envrc`、APIキー、証明書、VPN設定
- MySQL、Redis、Docker/Podman/Colimaのうち残す必要があるローカルデータ
- `~/Music/Music`、`~/Music/iTunes`など、クラウド同期されていない音楽ライブラリ
- GitHubへpushしていない作業リポジトリと、iCloud/OneDrive対象外のファイル

会社管理アプリ（Company Portal、Microsoft 365、Defender、VPNなど）はMDMまたは社内手順から再導入します。認証情報はこの公開リポジトリへ追加しません。

リセット直前の確認:

```sh
cd ~/dotfiles
git status
git log --oneline origin/main..HEAD
git ls-remote origin HEAD
```

`git status`がcleanで、最後のコマンドが成功し、GitHub上に最新コミットが見えることを確認します。

## 新しいMacへの復元

1. macOSの初期設定、OS更新、会社のMDM登録を完了します。
2. Command Line Toolsを導入します。

   ```sh
   xcode-select --install
   ```

3. リポジトリをcloneし、インストーラを実行します。

   ```sh
   git clone https://github.com/koshi-y6/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ./install.sh
   ```

4. ターミナルを再起動し、必要ならPowerlevel10kを再設定します。

   ```sh
   p10k configure
   ```

5. 暗号化バックアップからSSH鍵などを戻し、権限を設定します。

   ```sh
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/id_* 2>/dev/null || true
   gh auth login
   ```

6. Gitの名前・メール・SSH署名を再設定します。値は会社の最新ルールに合わせます。

   ```sh
   git config --global user.name "YOUR_NAME"
   git config --global user.email "YOUR_EMAIL"
   git config --global gpg.format ssh
   git config --global user.signingkey ~/.ssh/id_ed25519.pub
   git config --global commit.gpgsign true
   ```

7. アプリへ再ログインし、必要ならTeX LiveやOrbStackなどHomebrew外のソフトを個別に導入します。

## 復元されるもの

- `Brewfile`: CLI、フォント、主要GUIアプリ
- `.config/mise/config.toml`: Node.js 22.21.1、Python 3.13、Rust stable
- `install.sh`: Homebrew、Neovim 0.12.0、Prezto、Powerlevel10k、tmuxプラグインと各symlink
- zsh、Neovim、IdeaVim、tmux、WezTerm、Hammerspoon設定

tmuxプラグイン本体はリポジトリに含めず、`.config/tmux/plugins.conf`を元にTPMが再取得します。Homebrewのサービスはインストール後に必要なものだけ起動してください（例: `brew services start redis`）。

## 更新方法

Homebrew環境を変更したら、`brew leaves`と`brew list --cask`を確認し、復元したいものを`Brewfile`へ反映します。秘密情報がないことを確認してからcommit/pushします。
