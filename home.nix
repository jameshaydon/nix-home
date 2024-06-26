user: { config, ... }:
let
  sources = import ./nix/sources.nix;
  hm = import sources.home-manager { };
  # We default to apple silicon
  pkgs = import sources.nixpkgs {
    localSystem = "aarch64-darwin";
    overlays = [(import sources.emacs-overlay)];
  };
  # But sometimes we fallback to this:
  pkgs_x86_64 = import sources.nixpkgs { localSystem = "x86_64-darwin"; };
  myaspell = pkgs.aspellWithDicts (d: [d.en d.en-computers d.en-science d.fr]);
  myEmacs = ((pkgs.emacsPackagesFor pkgs.emacs-unstable).emacsWithPackages (epkgs: [epkgs.vterm]));
in
with builtins; {

  nixpkgs.config.allowUnfree = true;

  home = {

    stateVersion = "22.11";

    username = "${user}";

    homeDirectory = "/Users/${user}";

    packages = with pkgs.lib;
      [ # myaspell
        # myEmacs
        pkgs.nix # pkgs.nixUnstable
        pkgs.gitAndTools.delta
        pkgs.z3
        # pkgs.graphviz
        # pkgs.pandoc
        # pkgs.cabal2nix
        # pkgs_x86_64.idris2

        # Once in a while you can see if the following packages now work with
        # `pkgs` instead of `pkgs_x86_64` (i.e. Rosetta emulation).

        # pkgs_x86_64.nix-du
        pkgs.nodejs
        pkgs.nodePackages.pnpm
        # pkgs.nodePackages.typescript-language-server
        # pkgs.deno
        # pkgs.python39Full

        pkgs.cmake
        # pkgs.exa
        pkgs.fd
        pkgs.fontconfig
        pkgs.just
        pkgs.ripgrep
        pkgs.wget
        pkgs.gnupg
        pkgs.niv
        # pkgs.idris2
      ];

    # Source the Nix profile
    sessionVariablesExtra = ''
      . "${pkgs.nix}/etc/profile.d/nix.sh"
    '';
  };

  programs = {

    home-manager.enable = true;

    # bat.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
      # nix-direnv.enableFlakes = true;
    };

    bash.enable = true;

    zsh = {
      enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      shellAliases = {
        hm = "run home-manager";
        # ls = "exa";
        si = "stack install --fast --ghc-options \"-j4 +RTS -A128m -n2m -qg -RTS\"";
        cf = "cabal --ghc-options=\"-j4 +RTS -A128m -n2m -qg -RTS\" --disable-optimization --disable-library-vanilla --enable-executable-dynamic";
        cnf = "cabal --enable-nix --ghc-options=\"-j4 +RTS -A128m -n2m -qg -RTS\" --disable-optimization --disable-library-vanilla --enable-executable-dynamic";
      };
      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
        plugins=["git" "macos" "brew" "fzf" "direnv"];
      };
      initExtra =
        ''
        # NOTE: the 'run' scipt in _this_ repo:
        export PATH="$PATH:$HOME/nix-home/bin"

        # NOTE: this is used by vterm in emacs:
        vterm_printf(){
            if [ -n "$TMUX" ]; then
                # Tell tmux to pass the escape sequences through
                # (Source: http://permalink.gmane.org/gmane.comp.terminal-emulators.tmux.user/1324)
                printf "\ePtmux;\e\e]%s\007\e\\" "$1"
            elif [ "''${TERM%%-*}" = "screen" ]; then
                # GNU screen (screen, screen-256color, screen-256color-bce)
                printf "\eP\e]%s\007\e\\" "$1"
            else
                printf "\e]%s\e\\" "$1"
            fi
        }

        # NOTE: Doom scripts:
        export PATH="$PATH:$HOME/.emacs.d/bin"

        # NOTE: where haskell installs stuff:
        export PATH="$PATH:$HOME/.local/bin"

        # NOTE: locally installed npm modules
        export PATH="$PATH:./node_modules/.bin"

        # NOTE: where brew cask installs latex
        export PATH="$PATH:/Library/TeX/texbin"

        # NOTE: ghcup:
        export PATH="$PATH:$HOME/.ghcup/bin"

        # NOTE: lean (elan):
        export PATH="$PATH:$HOME/.elan/bin"

        export NIX_PATH="nixpkgs=${sources.nixpkgs.url}":$NIX_PATH

        # function anki_prompt_fun() { anki-prompt-exe james "Library/Application Support/Anki2" }

        # add-zsh-hook precmd anki_prompt_fun

        export DTK_PROGRAM=~/dev/emacspeak/servers/speech-server

        # random executables
        export PATH="$PATH:~/downloaded_bin"
        '';
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    git = {
      enable = true;
      userName = "James Henri Haydon";
      userEmail = "james.haydon@gmail.com";
      ignores = [
        ".DS_Store"
        "**/.DS_Store"
        ".AppleDouble"
        ".LSOverride"
        "*.niu"
        ".local"
      ];
      aliases = {};
      extraConfig = {
        color.diff-highlight.oldNormal = "red bold";
        color.diff-highlight.oldHighlight = "red bold 52";
        color.diff-highlight.newNormal = "green bold";
        color.diff-highlight.newHighlight = "green bold 22";
        color.diff.meta = "11";
        color.diff.frag = "magenta bold";
        color.diff.func = "146 bold";
        color.diff.commit = "yellow bold";
        color.diff.old = "red bold";
        color.diff.new = "green bold";
        color.diff.whitespace = "red reverse";
        color.ui = "true";
        color.branch = "auto";
        color.status = "auto";
        color.interactive = "auto";
        log.decorate = "full";
        diff.algorithm = "minimal";
        diff.mnemonicprefix = "true";
        merge.statue = "true";
        merge.summary = "true";
        merge.conflictStyle = "diff3";
        github.user = "jameshaydon";
        rerere.enabled = "true";
        rerere.autoupdate = "true";
        credential.helper = "cache --timeout=604800";
        branch.autosetuprebase = "always";
        push.recurseSubmodules = "no";
        rebase.autosquash = "true";
        submodule.recurse = "true";
        delta.features = "side-by-side line-numbers";
        delta.whitespace-error-style = "22 reverse";
        core.pager = "delta";
        interactive.diffFilter = "delta --color-only";
      };
    };

    # htop.enable = true;

    # jq.enable = true;

  };
}
