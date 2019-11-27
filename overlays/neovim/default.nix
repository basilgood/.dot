self: super:
with super;
let
  customPlugins = import ./plugins.nix { inherit self super; };
  allPlugins = vimPlugins // customPlugins;
  init = builtins.readFile ./config/init.vim;
  coc = builtins.readFile ./config/coc.vim;
  plugins = builtins.readFile ./config/plugins.vim;
  options = builtins.readFile ./config/options.vim;
  mappings = builtins.readFile ./config/mappings.vim;
  commands = builtins.readFile ./config/commands.vim;
  autocmds = builtins.readFile ./config/autocmds.vim;
in {
  neovim-unwrapped = (neovim-unwrapped).overrideAttrs (old: rec {
    name = "neovim-unwrapped-${version}";
    version = "0.4.3-dev";
    src = fetchFromGitHub {
      owner = "neovim";
      repo = "neovim";
      rev = "b99dad7b4c6418978a21977262809021fab8d356";
      sha256 = "03p7pic7hw9yxxv7fbgls1f42apx3lik2k6mpaz1a109ngyc5kaj";
    };
    NIX_CFLAGS_COMPILE = "-O3 -march=native";
  });
  neovim = neovim.override {
    withNodeJs = true;

    configure = {
      packages.myVimPackage = with allPlugins; {

        start = [
          allfunc
          vim-javascript
          yats
          vim-coffee-script
          vim-jinja
          vim-markdown
          vim-json
          twig
          jsx
          jsonc
          vim-nix
          neomake
        ];

        opt = [
          vinegar
          renamer
          coc-nvim
          actionmenu
          surround
          repeat
          tcomment_vim
          vim-html-template-literals
          undotree
          vim-indent-object
          quickfix-reflector-vim
          vim-easy-align
          multiple-cursors
          auto-git-diff
          ferret
          skim
          skim-vim
          vim-fugitive
          vim-dispatch
          targets
          wildfire
          conflicted
          vim-mergetool
          vcs-jump
          conflict-marker
          vim-edgemotion
          cool
          vim-editorconfig
          vim-parenmatch
          cmdline
          nordish
        ];
      };

      customRC = ''
        ${init}
        ${coc}
        ${plugins}
        ${options}
        ${mappings}
        ${commands}
        ${autocmds}
      '';
    };
  };
}
