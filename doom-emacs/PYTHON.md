# Python IDE with Nix development shells

The Doom configuration enables the Python language module, Pyright LSP, Ruff
format-on-save, pytest integration, and the existing debugger. Emacs uses
project-local environments through Doom's `:tools direnv` module (`envrc`).
Home Manager installs `direnv` + `nix-direnv` and enables the Zsh hook.

## Set up a project

At the root of a project that provides a `devShell` in `flake.nix`, add
`.envrc` containing:

```sh
use flake
```

Then approve it (first use, and after editing `.envrc`):

```sh
direnv allow
```

You may alternatively use `M-x envrc-allow` in Emacs. For a named
development shell, use e.g. `use flake .#myShell`.

**A `flake.nix` alone does not activate direnv**: the project must contain
an approved `.envrc`. If a project already has an `.envrc`, extend it rather
than overwriting it. Use only trusted project environment configurations.

When a file is opened, `envrc` gives its buffer the project-specific `PATH`
and other variables, without changing environments of other Emacs buffers.
This also works with the user Emacs daemon. Commands started from the Python
buffer (LSP, REPL, tests, debugger) should resolve the project's executables.

## Development-shell dependencies

A project's `devShell` should provide its Python interpreter, application
dependencies, and the tools you want to run inside that environment:

- `pytest` for tests.
- `debugpy` installed **for that Python interpreter** for Dape debugging.
- `pyright` and `ruff` optionally, if project-specific versions are needed.

Pyright and Ruff are also installed by Home Manager as fallbacks. Installing
`debugpy` in a different Python environment is not sufficient for Dape: the
interpreter used for the debug adapter must import `debugpy.adapter`.

For example, one way to supply test/debug dependencies in a `devShell` is:

```nix
packages = [
  (pkgs.python3.withPackages (ps: with ps; [ pytest debugpy ]))
  pkgs.ruff
];
```

After `direnv allow`, check your project in a **new terminal** inside the
project directory:

```sh
command -v python
command -v pyright-langserver
command -v ruff
python -m pytest --version
python -c 'import debugpy.adapter'
```

Adapt the shell-specific dependencies as needed. A separate Nix Python
environment may require additional Pyright import-resolution configuration
if its imports do not resolve as expected.

## In Emacs

- Open a Python file; Pyright starts through Doom's `:lang python +lsp +pyright`.
- `M-x lsp-describe-session`: check the connected language server.
- `M-x python-pytest` or `SPC m t a`: run project tests; `SPC m t f`: current file;
  `SPC m t t`: test at point.
- `M-x +python/open-repl`: Python REPL using the buffer environment.
- `M-x +debugger/start`: start debugging (the current Doom debugger module
  uses Dape; select `debugpy` for a file or `debugpy-module` for a module).
- Saving a Python buffer formats it with Ruff, if Ruff is available.

When `flake.nix` or `flake.lock` changes, use `M-x envrc-reload` to refresh
the environment **inside Emacs**. Doom's direnv module reconnects associated
LSP clients after successful updates. Zsh's hook reloads direnv as you use
your shell. Initial Nix evaluation can block Emacs because `envrc` loads
synchronously by default; `nix-direnv` caches subsequent evaluations.

## Apply the dotfiles change

After merging:

```sh
sudo nixos-rebuild switch --flake ~/.dotfiles#idea
~/.emacs.d/bin/doom sync
systemctl --user restart emacs.service
```

Open a new Zsh session (or start a new terminal) to activate the direnv shell
hook. The Doom configuration is a literate `config.org`; no hand-edited
generated `config.el` is required.

This PR does not change the existing Java IDE / `dap-java` setup. The actual
installed Doom revision determines whether it still uses the older
`dap-mode` integration or the newer Dape implementation; verify Java
debugging separately if you use it.
