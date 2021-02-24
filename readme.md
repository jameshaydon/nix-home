# nix-home

My home environment.

Packages are pinned using [niv](https://github.com/nmattia/niv), which generates/updates the content of the `nix` directory.

### Prereq

- [Nix](https://nixos.org/nix/manual/#sect-macos-installation)
- [Home Manager](https://github.com/rycee/home-manager#installation)

### Install

I'm using my user `pwm` in the 2nd command, replace it with yours for your setup :)

```
$ nix-shell -p git --run 'git@github.com:pwm/nix-home.git ~/nix-home'
$ echo "import ~/nix-home/home.nix \"pwm\"" > ~/.config/nixpkgs/home.nix
$ home-manager switch
```

### Update

```
$ cd ~/nix-home
$ niv update
$ hm switch
```

Note:
`hm` is alias for `run home-manager` where `run` is a small wrapper script to pass
home-manager the updated `NIX_PATH` after a `niv update`.

### Missing from nixpkgs:

- assume-role
- saw

### JAMES TODO:

- Shouldn't install clojure/clojure-lsp/leinengen globally, make nix setup for projects that need it.
- clojure-lsp not working
