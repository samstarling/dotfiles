# dotfiles

Configuration for my computer, managed by [mise], [chezmoi] and [homebrew].

## Fresh machine setup

### 1. Xcode command-line tools

Provides `git`, which everything else depends on.

```sh
xcode-select --install
```

### 2. Bootstrap mise

```sh
curl https://mise.run | sh
```

### 3. Install gh, chezmoi and fish via mise

All three are pinned in `dot_config/mise/config.toml`, but we need them before
chezmoi can apply that config. Fish is required so the `run_onchange` script
that installs fisher + hydro can run during `chezmoi apply`.

```sh
mise use --global gh@latest chezmoi@latest fish@latest
```

### 4. Authenticate with GitHub

`gh auth login` will offer to generate an SSH key and upload it to GitHub.
Pick SSH so we can clone (and push to) this dotfiles repo over SSH.

```sh
gh auth login
```

### 5. Apply chezmoi

```sh
chezmoi init --apply samstarling --ssh
```

When prompted for a GPG signing key, enter anything — we'll regenerate it in
step 9 and update the value.

### 6. Install remaining mise tools

The applied `~/.config/mise/config.toml` pins everything else (delta, fzf, jq,
ripgrep, zoxide, fd, etc).

```sh
mise install
```

### 7. Install homebrew and the Brewfile

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew bundle --file ~/.local/share/chezmoi/Brewfile
```

The chezmoi `run_onchange_after_brewfile.sh` script will keep this in sync on
future applies.

### 8. Set fish as the default shell

Fish is installed via mise; we point `chsh` at the mise shim (stable across
fish version upgrades).

```sh
FISH_SHIM="$HOME/.local/share/mise/shims/fish"
echo "$FISH_SHIM" | sudo tee -a /etc/shells
chsh -s "$FISH_SHIM"
```

### 9. Generate a GPG signing key

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
