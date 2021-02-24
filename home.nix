user: { config, ... }:
let
  sources = import ./nix/sources.nix;
  hm = import sources.home-manager { };
  pkgs = import sources.nixpkgs { };
in
with builtins; {
  nixpkgs.config.allowUnfree = true;

  home = {
    username = "${user}";

    homeDirectory = "/Users/${user}";

    packages = with pkgs.lib;
      map (n: getAttrFromPath (splitString "." n) pkgs) (fromJSON (readFile ./pkgs.json));

    file = {
    };

    # FIXME: OSX does not pick these up if symlinked hence real copy
    # FIXME: Don't hardcode ~/nix-home
    extraProfileCommands = ''
      find "${config.home.homeDirectory}/nix-home/fonts/" -name "FiraCode*" -exec ls {} + | xargs -I % cp -p % "${config.home.homeDirectory}/Library/Fonts/"
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
        export PATH="$HOME/.emacs.d/bin:$PATH"

        # NOTE: where haskell installs stuff:
        export PATH="$HOME/.local/bin:$PATH"
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
        branch.autosetuprebasea = "always";
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
        core.pager = "diff-so-fancy | less --tabs=4 -RFX";
        icdiff.options = "--highlight --line-numbers";
        icdiff.pager = "less --tabs=4 -RFX";
        interactive.diffFilter = "diff-so-fancy --patch";
        push.recurseSubmodules = "no";
        submodule.recurse = "true";
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
      };
    };

    htop.enable = true;

    jq.enable = true;

  };
}
