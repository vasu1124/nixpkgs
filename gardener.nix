let
  # nixpkgs = import <nixpkgs> {};
  nigpkgsRev = "nixpkgs-unstable";
  nixpkgs = import (fetchTarball "https://github.com/nixos/nixpkgs/archive/${nigpkgsRev}.tar.gz") {};

  allPkgs = nixpkgs // pkgs;
  callPackage = path: overrides:
    let f = import path;
    in f ((builtins.intersectAttrs (builtins.functionArgs f) allPkgs) // overrides);
  pkgs = with nixpkgs; {
    gardenctl = callPackage ./gardenctl.nix { };
    gardenlogin = callPackage ./gardenlogin.nix { };
    kubeswitch = callPackage ./kubeswitch.nix { };
  };
in pkgs


# let
#   pkgs = import <nixpkgs> {};
# in with pkgs; {
#   gardenctl = import ./gardenctl.nix { inherit stdenv lib fetchurl; };
#   gardenlogin = import ./gardenlogin.nix { inherit stdenv lib fetchurl; };
# }
