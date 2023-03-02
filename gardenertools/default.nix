{ pkgs ? import <nixpkgs> {} }:
let
  gardenertools = with pkgs; rec {
    gardenctl = callPackage ./gardenctl.nix { };
    gardenlogin = callPackage ./gardenlogin.nix { };
    kubeswitch = callPackage ./kubeswitch.nix { };
    ocmcli = callPackage ./ocmcli.nix { };
  };
in 
  gardenertools
