# dotfiles

Configuration for my computer, managed by [mise], [chezmoi] and [homebrew].

## Fresh machine setup

### 1. Xcode command-line tools

Provides `git`, which everything else depends on.

```sh
xcode-select --install
```

### 2. Bootstrap mise

Install the binary and activate it for the current session.

```sh
curl https://mise.run | sh
eval "$(~/.local/bin/mise activate zsh)"
```

We'll `chsh` to `fish` later on: this is just here for bootstrapping.

### 3. Install prerequisites

We need `gh` and `chezmoi` so that we can fetch and apply the dotfiles from
this repo:

```sh
mise use --global gh@latest chezmoi@latest
```

### 4. Authenticate with GitHub

`gh auth login` will offer to generate an SSH key and upload it to GitHub.
Pick SSH so we can clone (and push to) this dotfiles repo over SSH.

```sh
gh auth login
```

### 5. Clone the dotfiles

`init` without `--apply` clones the repo to `~/.local/share/chezmoi` but
doesn't run any scripts — we need fish (from homebrew) installed first so
the `run_onchange` fisher/hydro script can fire on the eventual `apply`.

```sh
chezmoi init samstarling --ssh
```

When prompted for a GPG signing key, enter anything — we'll regenerate it
in step 10.

### 6. Install homebrew and the Brewfile

Provides `fish`, `gnupg`, `pinentry-mac`.

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew bundle --file ~/.local/share/chezmoi/Brewfile
```

### 7. Apply chezmoi

```sh
chezmoi apply
```

### 8. Install remaining mise tools

The applied `~/.config/mise/config.toml` pins everything else (bat, btop,
delta, eza, fzf, helix, jq, ripgrep, zoxide, fd, etc).

```sh
mise install
```

### 9. Set fish as the default shell

```sh
echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/fish
```

### 10. Generate a GPG signing key

ECC / ED25519:

```sh
gpgconf --kill gpg-agent
gpg --full-generate-key
```

Take the key ID (after the slash in the `sec` line) and add the GitHub
no-reply email as a UID:

```sh
gpg --edit-key KEY_ID
adduid
save
```

Tell chezmoi the new key ID and re-apply the gitconfig:

```sh
chezmoi edit-config        # update signingKey
chezmoi apply ~/.gitconfig
```

Then copy the public key and [add it to GitHub](https://github.com/settings/keys):

```sh
gpg --armor --export KEY_ID | pbcopy
```

[mise]: https://mise.jdx.dev
[chezmoi]: https://www.chezmoi.io/
[homebrew]: https://brew.sh
