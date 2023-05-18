# Neovim settings

{ config, lib, pkgs, ... }:
let
   pkgsu = import <nixpkgsu> {};
in {
  programs.neovim = {
    enable = false;
    # package = pkgsu.neovim;
    # Sets alias vim=nvim
    vimAlias = true;

    withPython3 = false;
    withRuby = false;
    withNodeJs = false;

#    extraConfig = ''
#      :imap jk <Esc>
#      :set number
#    '';

    # Neovim plugins
    plugins = with pkgs.vimPlugins; [
      # Syntax / Language Support ##########################
      # (nvim-treesitter.withPlugins (p: 
      #   [ 
      #     p.c 
      #     p.java 
      #     p.toml 
      #     p.go 
      #     p.gomod 
      #     p.lua 
      #     p.jsonc 
      #     p.vim 
      #     p.bash 
      #     p.markdown
      #   ])
      # )
      # vim-nix
      # pkgsu.vimPlugins.LazyVim
      # # vim-ruby # ruby
      # vim-go # go
      # # vim-fish # fish
      # vim-toml           # toml
      # # vim-gvpr           # gvpr
      # rust-vim # rust
      # zig-vim
      # vim-pandoc # pandoc (1/2)
      # vim-pandoc-syntax # pandoc (2/2)
      # yajs.vim           # JS syntax
      # es.next.syntax.vim # ES7 syntax
      # vim-elixir
      # vim-markdown

      # UI #################################################
      # gruvbox # colorscheme
      # # vim-gitgutter # status in gutter
      # vim-devicons
      # vim-airline

      # # Editor Features ####################################
      # vim-abolish
      # vim-surround # cs"'
      # vim-repeat # cs"'...
      # vim-commentary # gcap
      # # vim-ripgrep
      # vim-indent-object # >aI
      # vim-easy-align # vipga
      # vim-eunuch # :Rename foo.rb
      # vim-sneak
      # supertab
      # vim-endwise        # add end, } after opening block
      # # gitv
      # # tabnine-vim
      # # ale # linting
      # nerdtree
      # # vim-toggle-quickfix
      # # neosnippet.vim
      # # neosnippet-snippets
      # # splitjoin.vim
      # nerdtree
      # tabular
      # ctrlp
      # editorconfig-vim

      # Buffer / Pane / File Management ####################
      # fzf-vim # all the things

      # Panes / Larger features ############################
      # tagbar # <leader>5
      # vim-fugitive # Gblame

    ];
  };
}
