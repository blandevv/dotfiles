<div align="center">

<br>

# <samp>dotfiles</samp>

<samp>a quiet, terminal-first macos environment</samp>

<br>

![macos](https://img.shields.io/badge/macos-000000?style=flat-square&logo=apple&logoColor=white)
![fish](https://img.shields.io/badge/fish-000000?style=flat-square&logo=gnubash&logoColor=white)
![neovim](https://img.shields.io/badge/neovim-000000?style=flat-square&logo=neovim&logoColor=white)
![ghostty](https://img.shields.io/badge/ghostty-000000?style=flat-square&logo=gnometerminal&logoColor=white)
![starship](https://img.shields.io/badge/starship-000000?style=flat-square&logo=starship&logoColor=white)

<br>

<a href="#stack"><kbd>&nbsp;stack&nbsp;</kbd></a>&ensp;
<a href="#structure"><kbd>&nbsp;structure&nbsp;</kbd></a>&ensp;
<a href="#install"><kbd>&nbsp;install&nbsp;</kbd></a>&ensp;
<a href="#after-installing"><kbd>&nbsp;post-install&nbsp;</kbd></a>

<br>
<br>

![preview](./assets/preview.png)

</div>

<br>

## stack

one window, everything nested inside it:

```
ghostty ····················· terminal · frosted glass, dual dark/light themes
└── zellij ·················· multiplexer · persistent sessions, floating panes
    └── fish + starship ····· shell · vi mode, context-aware prompt
        ├── nvim ············ editor · LazyVim, LSP, Copilot, lazygit inside
        ├── ranger ·········· files · vim keys, image previews
        ├── btop ············ system monitor
        ├── posting ········· http client, terminal-native postman
        └── fzf · zoxide · atuin · television — find anything, instantly
```

<details>
<summary><samp>terminal & shell</samp></summary>
<br>

| tool                                                        | role                       | highlights                                                                           |
| ----------------------------------------------------------- | -------------------------- | ------------------------------------------------------------------------------------ |
| [**ghostty**](https://ghostty.org/)                         | terminal emulator          | frosted glass background, dual dark/light themes, native split panes, Dank Mono font |
| [**fish**](https://fishshell.com/)                          | shell                      | vi key bindings, curated aliases, smart tab completion out of the box                |
| [**zellij**](https://zellij.dev/)                           | terminal multiplexer       | persistent sessions, custom pane/tab keybindings, floating panes                     |
| [**tmux**](https://github.com/tmux/tmux)                    | terminal multiplexer (alt) | alternative multiplexer config with TPM-managed plugins                              |
| [**starship**](https://starship.rs/)                        | prompt                     | fast, context-aware, shows git, language runtime, and more at a glance               |
| [**fastfetch**](https://github.com/fastfetch-cli/fastfetch) | system info                | minimal boxed info panel with custom logo, shown on shell startup                    |

</details>

<details>
<summary><samp>navigation & productivity</samp></summary>
<br>

| tool                                                           | role           | highlights                                                                  |
| -------------------------------------------------------------- | -------------- | --------------------------------------------------------------------------- |
| [**fzf**](https://github.com/junegunn/fzf)                     | fuzzy finder   | wired into the fish shell for history, file, and process searching          |
| [**zoxide**](https://github.com/ajeetdsouza/zoxide)            | smart `cd`     | remembers your most visited directories and jumps to them instantly         |
| [**atuin**](https://atuin.sh/)                                 | shell history  | encrypted, synced history across machines with fuzzy search and statistics  |
| [**carapace**](https://carapace.sh/)                           | completions    | multi-shell completion for hundreds of CLI tools                            |
| [**television**](https://github.com/alexpasmantier/television) | fuzzy launcher | blazing-fast general-purpose fuzzy finder TUI with custom channels          |
| [**ranger**](https://ranger.github.io/)                        | file manager   | vim-inspired TUI file browser with image preview support                    |
| [**posting**](https://posting.sh/)                             | http client    | terminal-based alternative to Postman — great for API development           |

</details>

<details>
<summary><samp>cli replacements</samp></summary>
<br>

| tool                                      | replaces | aliases                                                                            |
| ----------------------------------------- | -------- | ---------------------------------------------------------------------------------- |
| [**eza**](https://eza.rocks/)             | `ls`     | `ls` → icons + colors · `ll` → long view with git status · `tree` → directory tree |
| [**bat**](https://github.com/sharkdp/bat) | `cat`    | `cat` → syntax-highlighted output with line numbers                                |

</details>

<details>
<summary><samp>editor</samp></summary>
<br>

| tool                                                                   | role        | highlights                                                                                   |
| ---------------------------------------------------------------------- | ----------- | -------------------------------------------------------------------------------------------- |
| [**neovim**](https://neovim.io/) + [**lazyvim**](https://lazyvim.org/) | code editor | full IDE experience: LSP, completions, Copilot, CodeCompanion, fuzzy search, git integration |
| [**lazygit**](https://github.com/jesseduffield/lazygit)                | git TUI     | integrated inside neovim — stage hunks, rebase, resolve conflicts visually                   |

</details>

<details>
<summary><samp>system & runtimes</samp></summary>
<br>

| tool                                             | role                   | notes                                                   |
| ------------------------------------------------ | ---------------------- | ------------------------------------------------------- |
| [**btop**](https://github.com/aristocratos/btop) | process monitor        | beautiful real-time resource monitor with responsive UI |
| [**pyenv**](https://github.com/pyenv/pyenv)      | python version manager | per-project python versions                             |
| **node.js**                                      | javascript runtime     | required by LSP servers, Copilot, Angular               |
| **pipx**                                         | python CLI installer   | isolated installs — used for posting                    |

</details>

<br>

## structure

each directory is symlinked into `~/.config/<name>` by the installer.

```
dotfiles/
├── atuin/          # shell history sync
├── btop/           # process monitor + themes
├── fastfetch/      # system info panel + custom logos
├── fish/           # shell config, aliases, functions, themes
├── ghostty/        # terminal config, shaders, themes
├── git/            # global gitignore
├── nvim/           # neovim (LazyVim) — plugins, lsp, keymaps
├── posting/        # http client
├── ranger/         # file manager + plugins
├── television/     # fuzzy launcher channels
├── tmux/           # tmux config + TPM plugins
├── wallpapers/     # wallpaper pack → ~/Pictures/Wallpapers
├── zellij/         # multiplexer layouts + keybindings
├── starship.toml   # prompt → ~/.config/starship.toml
├── .gitconfig      # git → ~/.gitconfig
└── install.sh      # automated installer (macos)
```

<br>

## install

> [!WARNING]
> the automated installer currently supports macos only.

```bash
git clone https://github.com/blandevv/dotfiles.git
cd dotfiles
./install.sh
```

idempotent — safe to re-run anytime. existing configs are backed up to `~/.dotfiles_backup/<timestamp>/` before anything is touched.

<samp>flags:</samp>&ensp;`--skip-packages` skip homebrew installs&ensp;·&ensp;`--skip-shell` keep your current shell

<details>
<summary><samp>what the script does</samp></summary>
<br>

1. **system check** — verifies you're on macos
2. **homebrew** — installs it if missing, updates it otherwise
3. **cli tools** — fish, neovim, starship, fzf, zoxide, atuin, eza, bat, zellij, btop, lazygit, and friends — plus the ghostty cask and a nerd font fallback
4. **symlinks** — links every config into `~/.config`, backing up whatever was there
5. **plugins** — TPM for tmux, devicons for ranger, headless `lazy.nvim` sync for neovim
6. **wallpapers** — copied to `~/Pictures/Wallpapers`
7. **default shell** — sets fish (asks for sudo to register it in `/etc/shells`)

</details>

<br>

## after installing

| step                  | how                                                                              |
| --------------------- | -------------------------------------------------------------------------------- |
| authenticate copilot  | `:Copilot auth` inside neovim                                                    |
| sync shell history    | `atuin login` · `atuin sync`                                                     |
| install a python      | `pyenv install 3.12` · `pyenv global 3.12`                                       |
| dank mono *(optional)* | purchase at [dank.sh](https://dank.sh) — falls back to JetBrainsMono Nerd Font  |

<br>

## linux

no installer yet — copy the configuration files manually or adapt them to your distribution and package manager.

<br>

---

<div align="center">
<sub>based on <a href="https://github.com/Gentleman-Programming/Gentleman.Dots">Gentleman.Dots</a> by <a href="https://github.com/Gentleman-Programming">@Gentleman-Programming</a></sub>
</div>
