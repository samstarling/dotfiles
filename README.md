# dotfiles

Configuration for my computer, managed by `chezmoi`. To set up a new laptop,
install [mise-en-place][mise], install [chezmoi][chezmoi], and then initialize
the config:

```
curl https://mise.run | sh
mise use --global chezmoi@latest
chezmoi init --apply samstarling
```

[mise]: https://mise.jdx.dev/getting-started.html
[chezmoi]: https://www.chezmoi.io/
