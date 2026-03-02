# Doom Emacs Config

Personal Doom Emacs setup focused on creative writing (long-form fiction in Org-mode) with workspace isolation, visual tabs, and automatic word counting.

## Setup

```bash
git clone https://github.com/TU_USUARIO/doom-config.git ~/.doom.d
doom sync
```


## Key Features

### Workspaces

Doom uses `persp-mode` under the hood. Each project lives in its own isolated workspace.


| Action | Keybinding |
| :-- | :-- |
| New workspace | `SPC TAB n` |
| Switch workspace | `SPC TAB [1-9]` |
| Rename workspace | `SPC TAB r` |
| Delete workspace | `SPC TAB d` |

### Tabs (centaur-tabs)

Tabs are scoped per workspace — buffers from other workspaces won't bleed in.


| Action | Keybinding |
| :-- | :-- |
| Next tab | `g t` |
| Previous tab | `g T` |

### Org-mode: Novel Structure

Each novel lives in a single `.org` file. Structure:

```
* Novel Title         ← level 1, root
** Capítulo 1         ← level 2, each chapter
   :PROPERTIES:
   :PALABRAS: 1194    ← auto-updated on save
   :CUSTOM_ID: ...
   :END:

   Chapter prose here...
```

**Word count** in `:PALABRAS:` updates automatically every time you save (`:w`). It counts only prose, ignoring the properties drawer.

### Writing Workflow

- Open your `.org` file and assign it a workspace (`SPC TAB r` to name it)
- Navigate chapters by folding/unfolding headings with `TAB`
- Word count updates silently on every `:w`
- `wc-mode` shows a live word count in the header line


## Files

| File | Purpose |
| :-- | :-- |
| `init.el` | Enabled Doom modules |
| `config.el` | All customization |
| `packages.el` | Extra packages |

## Doom Cheatsheet

```bash
doom sync          # after changing init.el or packages.el
doom upgrade       # update Doom + packages
doom doctor        # diagnose issues
```

Inside Emacs, `SPC h` opens the help system. `SPC :` evaluates any Elisp expression on the fly.

