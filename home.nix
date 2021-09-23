user: { config, ... }:
let
  sources = import ./nix/sources.nix;
  hm = import sources.home-manager { };
  pkgs = import sources.nixpkgs { overlays = [ (import (builtins.fetchTarball {  url = https://github.com/nix-community/emacs-overlay/archive/1ae3c888f0cbb328f9e4e61e12e8c0eaaa3e95d4.tar.gz; })) ]; };
  myaspell = pkgs.aspellWithDicts (d: [d.en d.en-computers d.en-science d.fr]);
  myEmacs = (pkgs.emacsPackagesGen pkgs.emacsGcc).emacsWithPackages (epkgs: [epkgs.vterm]);
in
with builtins; {

  nixpkgs.config.allowUnfree = true;
  # experimental-features = nix-command flakes;

  home = {
    username = "${user}";

    homeDirectory = "/Users/${user}";

    packages = with pkgs.lib;
      map (n: getAttrFromPath (splitString "." n) pkgs) (fromJSON (readFile ./pkgs.json)) ++ [myaspell myEmacs pkgs.nixUnstable];

    file = {
    };

    # NOTE: make a gls (GNU ls) for emacs-doom to use.
    extraProfileCommands = ''
      if [ ! -f ${config.home.homeDirectory}/.local/bin/gls ]
      then
        ln -s ${config.home.homeDirectory}/.nix-profile/bin/ls ${config.home.homeDirectory}/.local/bin/gls
      fi
    '';

    # Source the Nix profile
    sessionVariablesExtra = ''
      . "${pkgs.nix}/etc/profile.d/nix.sh"
    '';
  };

  programs = {
    home-manager.enable = true;

    bat.enable = true;

    direnv.enable = true;
    #direnv.enableNixDirenvIntegration = true;

    zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      shellAliases = {
        hm = "run home-manager";
        ls = "exa";
        si = "stack install --fast --ghc-options \"-j4 +RTS -A128m -n2m -qg -RTS\"";
        cf = "cabal --ghc-options=\"-j4 +RTS -A128m -n2m -qg -RTS\" --disable-optimization --disable-library-vanilla --enable-executable-dynamic";
        cnf = "cabal --enable-nix --ghc-options=\"-j4 +RTS -A128m -n2m -qg -RTS\" --disable-optimization --disable-library-vanilla --enable-executable-dynamic";
      };
      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
        plugins=["git" "osx" "brew" "fzf" "direnv"];
      };
      initExtra =
        ''
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

        # NOTE: the 'run' scipt in _this_ repo:
        export PATH="$PATH:$HOME/nix-home/bin"

        # NOTE: locally installed npm modules
        export PATH="$PATH:./node_modules/.bin"

        # NOTE: where brew cask installs latex
        export PATH="$PATH:/Library/TeX/texbin"

        # NOTE: idris 2 executable when building from source
        export PATH="$PATH:$HOME/.idris2/bin"

        # NOTE: ghcup:
        export PATH="$PATH:$HOME/.ghcup/bin"

        # NOTE: idris2: so that the system knows where to look for library support code
        export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:$HOME/.idris2/lib
        '';
    };

    fzf = {
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

    htop.enable = true;

    jq.enable = true;

  };
}
