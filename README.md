# dotfiles

Configuration for my computer, managed by [mise], [chezmoi] and [homebrew].

## Xcode

First, you'll need Xcode command line tools:

```sh
xcode-select --install
```

## GitHub

Next, we need to be able to talk to GitHub. We'll use `mise` for this:

```sh
curl https://mise.run | sh
mise use --global gh@latest
gh auth login
```

## Chezmoi

Now we can access this `dotfiles` repo, and initialize `chezmoi`. This will
put all of our configuration in place:

```sh
mise use --global chezmoi@latest
chezmoi init --apply samstarling --ssh
```

For now, give a dummy value for the GPG signing key.

## Tools

We already installed `mise`, and `chezmoi` gave us a `~/.mise.toml`. Install
those dependencies by running:

```sh
mise install
```

Then, install [homebrew] and install our other dependencies:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew bundle --file ~/.local/share/chezmoi/Brewfile
```

Set fish as the default shell:

```sh
echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/fish
```

## GPG

Generate a GPG key for signing `git` commits. Choose ECC with ED25519:

```sh
gpgconf --kill gpg-agent
gpg --full-generate-key
```

Take the key ID (after the slash in the `sec` line), and add the GitHub
no-reply email as a UID:

```sh
gpg --edit-key KEY_ID
adduid
save
```

Update the signing key in `~/.config/chezmoi/chezmoi.toml` and apply it:

```sh
chezmoi apply ~/.gitconfig
```

Finally, copy the key, and [add it to GitHub](https://github.com/settings/keys):

```sh
gpg --armor --export KEY_ID | pbcopy
```

[mise]: https://mise.jdx.dev
[chezmoi]: https://www.chezmoi.io/
[homebrew]: https://brew.sh
