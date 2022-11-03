{ config, lib, ... }:

let
  pkgs = import <nixpkgs> {}
         //
         import ./gardenertools {};

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

  # rubyPackages = with pkgs.rubyPackages_3_1; [
  #   jsonpath
  #   vault
  #   jwt
  #   huhalala
  # ];

  # pythonPackages = with pkgs.python38Packages; [
  #   bpython
  #   openapi-spec-validator
  #   pip
  #   requests
  #   setuptools
  # ];

  gitTools = with pkgs.gitAndTools; [
    delta
    diff-so-fancy
    git-codeowners
    gitflow
    git-lfs
    gh
  ];

in {
  inherit imports;

  # Allow non-free (as in beer) packages
  # nixpkgs.config = {
  #  allowUnfree = true;
  #  allowUnsupportedSystem = true;
  # };

  home = {
    username = builtins.getEnv "USER";
    homeDirectory = builtins.getEnv "HOME";
    stateVersion = "22.05";
  };

  home.sessionVariables = {
    NIX_SSL_CERT_FILE = ~/.ssl/my-ca-bundle;
    EDITOR = "nvim";
    TERMINAL = "alacritty";
  };

  home.sessionPath = [
    "$HOME/go/bin"
    "$HOME/.krew/bin"
    "$HOME/bin"
  ];

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
    cacert
    cachix # Nix build cache
    civo
    # cargo-edit # Easy Rust dependency management
    # cargo-graph # Rust dependency graphs
    # cargo-watch # Watch a Rust project and execute custom commands upon change
    cue # Experimental configuration language
    curl # An old classic
    colorls
    comma
    coreutils
    cpulimit
    # dhall # Exotic, Nix-like configuration language
    delve
    direnv # Per-directory environment variables
    dive
    exercism
    # docker # World's #1 container tool
    # docker-compose # Local multi-container Docker environments
    # docker-machine # Docker daemon for macOS
    fluxcd 
    # fluxctl # GitOps operator
    fzf
    fzy
    gardenctl
    gardenlogin
    kubeswitch
    google-cloud-sdk # Google Cloud Platform CLI
    graphviz # dot
    findutils
    gnupg # gpg
    gnused
    gnutar
    htop # Resource monitoring
    httpie # Like curl but more user friendly
    jq # JSON parsing for the CLI
    jsonnet # Easy config language
    k9s
    kind # Easy Kubernetes installation
    # kompose
    # kubectl # Kubernetes CLI tool, use docker
    krew
    kubebuilder
    kubectx # kubectl context switching
    kubelogin-oidc
    kubernetes-helm # Kubernetes package manager
    kustomize
    # lorri # Easy Nix shell
    minikube # Local Kubernetes
    niv # Nix dependency management
    nix-serve
    nixos-generators
    # nodejs # node and npm
    # nodePackages.semver
    openssl
    # podman # Docker alternative
    #prometheus # Monitoring system
    protobuf # Protocol Buffers
    # python3 # Have you upgraded yet???
    # ruby_3_1
    skaffold # Local Kubernetes dev tool
    sops
    # starship # Fancy shell that works with zsh
    temporal-cli
    terraform # Declarative infrastructure management
    tilt # Fast-paced Kubernetes development
    tree # Should be included in macOS but it's not
    python310Packages.wakeonlan
    vagrant # Virtualization made easy
    vault # Secret management
    vscode # My fav text editor if I'm being honest
    wget
    zsh-powerlevel10k

    # grype
    # syft

    # nerdfonts # not needed anymore with zsh-powerlevel10k

  ] 
  ++ gitTools 
  ++ scripts 
  ++ lib.optionals stdenv.isDarwin [
    pinentry_mac # Necessary for GPG
  ];
  
  
  home.file.".gnupg/gpg-agent.conf".text = ''
    disable-scdaemon
    grab
  '' +
  lib.optionals pkgs.stdenv.isDarwin "pinentry-program ${builtins.getEnv "HOME"}/.nix-profile/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac";

  #home.file.".ssl/internal.crt".source = ./internal.crt;

  home.activation = {
    cacerts = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD cat ~/.nix-profile/etc/ssl/certs/ca-bundle.crt ~/.ssl/*.crt >~/.ssl/my-ca-bundle
    '';
  };

  # Home Manager
  programs.home-manager.enable = true;
  # nix-index for comma
  programs.nix-index.enable = true;
  # Dircolors
  programs.dircolors.enable = true;
  # Golang
  programs.go = {
    enable = true;
    package = pkgs.go_1_19;
  };
  # GPG
  programs.gpg.enable = true;
  
  # security.pki.certificateFiles = [ "/usr/local/share/ca-certificates/internal.crt" ];

  # temporary fix https://github.com/NixOS/nixpkgs/issues/196651
  manual.manpages.enable = false;
}
