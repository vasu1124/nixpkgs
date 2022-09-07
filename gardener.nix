{ nixpkgs }:
let
  allPkgs = nixpkgs // pkgs;
  callP = path: overrides:
    let f = import path;
    in f ((builtins.intersectAttrs (builtins.functionArgs f) allPkgs) // overrides);
  makeOverridable = f: origArgs:
    let origRes = f origArgs;
    in origRes // { override = newArgs: makeOverridable f (origArgs // newArgs); };
  callPackage = path: makeOverridable (callP path);
  pkgs = with nixpkgs; rec {
    gardenctl = callPackage ./gardenctl.nix { };
    gardenlogin = callPackage ./gardenlogin.nix { };
    kubeswitch = callPackage ./kubeswitch.nix { };
  };
in pkgs