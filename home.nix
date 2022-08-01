{ config, lib, ... }:

let
  nigpkgsRev = "nixpkgs-unstable";
  pkgs = import (fetchTarball "https://github.com/nixos/nixpkgs/archive/${nigpkgsRev}.tar.gz") {};

  # Import other Nix files
  imports = [
    ./git.nix
    ./neovim.nix
    ./shell.nix
    ./tmux.nix
    ./vscode.nix
  ];

  # Handly shell command to view the dependency tree of Nix packages
  depends = pkgs.writeScriptBin "depends" ''
    dep=$1
    nix-store --query --requisites $(which $dep)
  '';


  git-hash = pkgs.writeScriptBin "git-hash" ''
    nix-prefetch-url --unpack https://github.com/$1/$2/archive/$3.tar.gz
  '';

  wo = pkgs.writeScriptBin "wo" ''
    readlink $(which $1)
  '';

  run = pkgs.writeScriptBin "run" ''
    nix-shell --pure --run "$@"
  '';

  scripts = [
    depends
    git-hash
    run
    wo
  ];

#  pythonPackages = with pkgs.python38Packages; [
#    bpython
#    openapi-spec-validator
#    pip
#    requests
#    setuptools
#  ];

  gitTools = with pkgs.gitAndTools; [
    delta
    diff-so-fancy
    git-codeowners
    gitflow
    gh
  ];

in {
  inherit imports;

  # Allow non-free (as in beer) packages
  nixpkgs.config = {
    allowUnfree = true;
    allowUnsupportedSystem = true;
  };

  # Enable Home Manager
  programs.home-manager.enable = true;

  home = {
    username = "vca";
    homeDirectory = "/Users/vca";
    stateVersion = "22.05";
  };

  # Golang
  programs.go.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    TERMINAL = "alacritty";
  };

  # Miscellaneous packages (in alphabetical order)
  home.packages = with pkgs; [
    adoptopenjdk-bin # Java
    autoconf # Broadly used tool, no clue what it does
    awscli # Amazon Web Services CLI
    azure-cli
    bash # /bin/bash
    bat # cat replacement written in Rust
    buildpack # Cloud Native buildpacks
    # buildkit # Fancy Docker
    cachix # Nix build cache
    # cargo-edit # Easy Rust dependency management
    # cargo-graph # Rust dependency graphs
    # cargo-watch # Watch a Rust project and execute custom commands upon change
    cue # Experimental configuration language
    curl # An old classic
    colorls
    coreutils
    # dhall # Exotic, Nix-like configuration language
    direnv # Per-directory environment variables
    # docker # World's #1 container tool
    # docker-compose # Local multi-container Docker environments
    # docker-machine # Docker daemon for macOS
    fluxctl # GitOps operator
    fzf
    google-cloud-sdk # Google Cloud Platform CLI
    graphviz # dot
    gnupg # gpg
    gnused
    gnutar
    htop # Resource monitoring
    httpie # Like curl but more user friendly
    jq # JSON parsing for the CLI
    jsonnet # Easy config language
    kind # Easy Kubernetes installation
    k9s
    # kompose
    # kubectl # Kubernetes CLI tool
    # kubectx # kubectl context switching
    kubernetes-helm # Kubernetes package manager
    kustomize
    # lorri # Easy Nix shell
    minikube # Local Kubernetes
    niv # Nix dependency management
    nix-serve
    nixos-generators
    nodejs # node and npm
    podman # Docker alternative
    #prometheus # Monitoring system
    protobuf # Protocol Buffers
    # python3 # Have you upgraded yet???
    skaffold # Local Kubernetes dev tool
    # starship # Fancy shell that works with zsh
    terraform # Declarative infrastructure management
    tilt # Fast-paced Kubernetes development
    tree # Should be included in macOS but it's not
    vagrant # Virtualization made easy
    vault # Secret management
    vscode # My fav text editor if I'm being honest
    wget

    # fonts
    nerdfonts

  ] ++ gitTools ++ scripts ++ lib.optionals stdenv.isDarwin [
    pinentry_mac # Necessary for GPG
  ];
     


}
