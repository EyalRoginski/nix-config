# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is Eyal Roginski's personal NixOS + home-manager flake configuration for a single desktop machine (hostname `nixos`, user `roginski`). It is a flake with two outputs:

- `nixosConfigurations.nixos` — system-level config, built from `nixos/configuration.nix` (imports `nixos/hardware-configuration.nix`).
- `homeConfigurations."roginski@nixos"` — user-level config, built from `home-manager/home.nix`.

Inputs are pinned in `flake.nix`: `nixpkgs` (nixos-25.11), `nixpkgs-unstable` (for packages that need newer versions — see `unstable` below), `home-manager` (release-25.11, follows nixpkgs), `nixvim`, and a personal `dotfiles` flake (non-flake input, used for dotfiles like `.p10k.zsh`).

## Commands

Rebuild the system (applies `nixos/configuration.nix`):
```
sudo nixos-rebuild switch --flake .#nixos
```

Rebuild the home-manager profile (applies `home-manager/home.nix`):
```
home-manager switch --flake .#roginski@nixos
```

Check the flake for evaluation errors without building:
```
nix flake check
```

Format Nix files (formatter used by both this repo's conventions and the nixvim `conform-nvim` setup for `*.nix` files):
```
alejandra .
```

Update flake inputs:
```
nix flake update
```

There are no tests, CI, or lint pipeline in this repo — correctness is verified by `nix flake check` and by actually rebuilding.

## Architecture notes

- **Two-branch workflow**: `main` and `desktop` are both real branches on `origin`, not just local scratch — this repo may be used across more than one machine profile. Check `git branch`/`git status` context before assuming which branch is "the" config.
- **`unstable` overlay pattern** (`home-manager/home.nix`): rather than overlaying unstable globally, `nixpkgs-unstable` is imported directly as a separate `pkgs` instance (`unstable = import inputs.nixpkgs-unstable { system = pkgs.system; config.allowUnfree = true; }`) and referenced package-by-package (e.g. `unstable.claude-code`, `unstable.antigravity-cli`, `unstable.godot-mono`). Use this pattern when a package needs a newer version than the pinned stable channel provides, rather than bumping the whole `nixpkgs` input.
- **nixvim, not plain neovim**: Neovim is configured declaratively through the `nixvim` flake module (imported in `home-manager/home.nix`), not through a traditional `init.lua`/plugin-manager setup. All keymaps, LSP servers, treesitter config, completion (`cmp`), and formatting-on-save (`conform-nvim`) live inline in `programs.nixvim` inside `home.nix` — there's no separate Lua config to look for.
- **Dotfiles come from a separate flake input**: files like `~/.p10k.zsh` are pulled from the `dotfiles` input (`github:EyalRoginski/dotfiles`) via `home.file` rather than being stored in this repo. If a referenced dotfile doesn't exist in this repo, check that flake, not this one.
- **Desktop environment**: KDE Plasma 6 via SDDM, Wayland, NVIDIA proprietary driver (`hardware.nvidia.open = false`). Prior commits show churn between X11/Wayland/Xfce before settling here — don't re-introduce those without reason.
- **Hebrew/English locale split**: `i18n.extraLocaleSettings` sets most `LC_*` categories to `he_IL.UTF-8` while `LC_TIME` stays `en_US.UTF-8`; keyboard layout is `il,us` toggled with `grp:lalt_lshift_toggle`. Keep this split when touching locale/keyboard settings.
- Package additions almost always belong in one of two places: `nixos/configuration.nix`'s `environment.systemPackages` (system-wide, no user config needed) or `home-manager/home.nix`'s `home.packages` (user-scoped, preferred for CLI tools/dev tooling). Prefer a dedicated `programs.<name>` module over a raw package entry when home-manager provides one (as already done for `alacritty`, `tmux`, `git`, `mangohud`, `obsidian`), since it gets you declarative config instead of just the binary.
