# Shell configuration for zsh (frequently used) and fish (used just for fun)

{ config, lib, pkgs, ... }:

let
  # Set all shell aliases programatically
  shellAliases = {
    # Aliases for commonly used tools
    grep = "grep --color=auto";
    diff = "diff --color=auto";
    # cat = "bat";
    ls = "colorls";
    ll = "ls -lh";
    k = "kubectl";
    vi = "vim";
    hms = "home-manager --extra-experimental-features 'nix-command flakes' switch";

    # Reload zsh
    szsh = "source ~/.zshrc";

    # Reload home manager and zsh
    reload = "home-manager --extra-experimental-features 'nix-command flakes' switch && source ~/.zshrc";

    # Nix garbage collection
    garbage = "nix-collect-garbage -d && docker image prune --force";

    # See which Nix packages are installed
    installed = "nix-env --query --installed";
  };
in {
  # Fancy filesystem navigator
  programs.broot = {
    enable = true;
    # enableFishIntegration = true;
    enableZshIntegration = true;
  };

  # fish shell settings
  # programs.fish = {
  #   inherit shellAliases;
  #   enable = true;
  # };

  #programs.fzf = {
  #  enable = true;
  #  enableBashIntegration = true;
  #  defaultCommand = "${pkgs.ripgrep}/bin/rg --files";
  #};

  # zsh settings
  programs.zsh = {
    enable = true;
    inherit shellAliases;
    enableAutosuggestions = true;
    enableCompletion = true;
    history.extended = true;

    # Called whenever zsh is initialized
    initExtra = ''
      autoload -U compinit && compinit
      autoload bashcompinit && bashcompinit

      export SHELL=${pkgs.zsh}/bin/zsh
      export LC_ALL=en_US.UTF-8
      export TERM="xterm-256color"
      export PATH=/usr/local/bin:$PATH

      # Nix setup (environment variables, etc.)
      if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then
        . ~/.nix-profile/etc/profile.d/nix.sh
      fi

      bindkey -e

      # autoload -Uz promptinit
      # promptinit
      # zsh-mime-setup
      autoload colors
      colors
      autoload -Uz zmv # move function
      autoload -Uz zed # edit functions within zle
      zle_highlight=(isearch:underline)

      # Enable ..<TAB> -> ../
      zstyle ':completion:*' special-dirs true
      zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,comm'
      zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'

      # iterm2 shell integration
      if [ -e ~/.iterm2_shell_integration.zsh ]; then
        . ~/.iterm2_shell_integration.zsh
      fi

      # Load environment variables from a file; this approach allows me to not
      # commit secrets like API keys to Git
      if [ -e ~/.env ]; then
        . ~/.env
      fi

      # Start up Starship shell
      # eval "$(starship init zsh)"

      # Autocomplete for various utilities
      # source <(helm completion zsh)
      # source <(kubectl completion zsh)
      # source <(minikube completion zsh)
      # source <(gh completion --shell zsh)
      # rustup completions zsh > ~/.zfunc/_rustup
      # source <(cue completion zsh)
      # source <(npm completion zsh)

      # Start up Docker daemon if not running
      # if [ $(docker-machine status default) != "Running" ]; then
      #   docker-machine start default
      # fi

      # Docker env
      # eval "$(docker-machine env default)"

      # Load asdf
      # . $HOME/.asdf/asdf.sh

      # direnv hook
      eval "$(direnv hook zsh)"

      function iterm2_print_user_vars() {
        iterm2_set_user_var kubecontext $(kubectx)
      }

      # https://github.com/danielfoehrKn/kubeswitch/blob/master/docs/installation.md
      # INSTALLATION_PATH=$(brew --prefix switch) && source $INSTALLATION_PATH/switch.sh
      source ~/.nix-profile/share/bash-completion/completions/switch.sh
    '';

    initExtraBeforeCompInit = ''
      if [[ -f "$HOME/.p10k.zsh" ]]; then
        source "$HOME/.p10k.zsh"
      fi
    '';

    zplug = {
      enable = true;
      plugins = [
        { name = "zsh-users/zsh-autosuggestions"; } 
        { name = "zsh-users/zsh-syntax-highlighting"; }
      ];
    };

    oh-my-zsh = {
      enable = true;
      plugins = [
        "kubectl"
        "docker"
        "docker-compose"
        "dotenv"
        "git"
        "helm"
        "sudo"
      ];
      # theme = "agnoster";
    };

    plugins = with pkgs; [
      {
        file = "powerlevel10k.zsh-theme";
        name = "powerlevel10k";
        src = "${zsh-powerlevel10k}/share/zsh-powerlevel10k";
      }
    ];

    # sessionVariables = rec {
    #   NIX_SSL_CERT_FILE = ~/.ssl/my-ca-bundle;
    # };
  };

  home.file.".p10k.zsh".source = ./p10k.zsh;
}
