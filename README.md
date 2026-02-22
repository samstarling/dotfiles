# dotfiles

Configuration for my computer, managed by [mise], [chezmoi] and [zerobrew].

## GitHub

The first goal is to be able to talk to GitHub. We'll use `mise` for this:

```sh
curl https://mise.run | sh
mise use --global gh@latest
gh auth login
```

## Chezmoi

Now we can access this `dotfiles` repo, and initialize `chezmoi`. This will
put all of our configuration in place:

```
mise use --global gh@latest
chezmoi init --apply samstarling --ssh
```

For now, give a dummy value for the GPG signing key.

## Tools

We already installed `mise`, and `chezmoi` gave us a `~/.mise.toml`. Install
those dependencies by running:

```
mise install
```

Then, install [zerobrew] and install our other dependencies:

```sh
curl -fsSL https://zerobrew.rs/install | bash
zb bundle --file ~/.local/share/chezmoi/Brewfile
```

## GPG

Generate a GPG key for signing `git` commits. Choose ECC with ED25519:

```
gpgconf --kill gpg-agent
gpg --full-generate-key
```

Take the key ID (after the slash in the `sec` line), and add the GitHub
no-reply email as a UID:

```
gpg --edit-key KEY_ID
adduid
save
```

Update the signing key in `~/.config/chezmoi/chezmoi.toml` and apply it:

```
chezmoi apply ~/.gitconfig
```

Finally, copy the key, and [add it to GitHub](https://github.com/settings/keys):

```
gpg --armor --export KEY_ID | pbcopy
```

[mise]: https://mise.jdx.dev
[chezmoi]: https://www.chezmoi.io/
[zerobrew]: https://github.com/lucasgelfond/zerobrew
