# Git settings

{ config, lib, pkgs, ... }:

let
  vscode = pkgs.vscode;
in {
  programs.git = {
    package = pkgs.gitAndTools.gitFull;
    enable = true;
    userName = "vasu1124";
    userEmail = "vasu1124@actvirtual.com";
    signing = { 
      signByDefault = true;
      key = "47C0A040A4920EAC";
    };

    # Replaces ~/.gitignore
    ignores = [
      ".cache/"
      ".DS_Store"
      ".idea/"
      "*.swp"
      "built-in-stubs.jar"
      "dumb.rdb"
      ".elixir_ls/"
      ".vscode/"
      "npm-debug.log"
      "shell.nix"
    ];

    # Replaces aliases in ~/.gitconfig
    aliases = {
      ba = "branch -a";
      bd = "branch -D";
      br = "branch";
      cam = "commit -am";
      co = "checkout";
      cob = "checkout -b";
      ci = "commit";
      cm = "commit -m";
      cp = "commit -p";
      d = "diff";
      dco = "commit -S --amend";
      s = "status";
      pr = "pull --rebase";
      st = "status";
      l = "log --graph --pretty='%Cred%h%Creset - %C(bold blue)<%an>%Creset %s%C(yellow)%d%Creset %Cgreen(%cr)' --abbrev-commit --date=relative";
      whoops = "reset --hard";
      wipe = "commit -s";
      fix = "rebase --exec 'git commit --amend --no-edit -S' -i origin/develop";
    };

    # Global Git config
    extraConfig = {
      core = {
        editor = "vim";
        pager = "delta --dark";
        whitespace = "trailing-space,space-before-tab";
      };

      commit.gpgsign = "true";
      # gpg.program = "gpg2";

      protocol.keybase.allow = "always";
      credential.helper = if pkgs.stdenv.isDarwin then "osxkeychain" else "";
      pull.rebase = "false";
      init.defaultBranch = "main";
    };
  };
}
