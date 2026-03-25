inputs
: {
  config,
  wlib,
  lib,
  pkgs,
  ...
}: let
  mypkgs = inputs.my-packages.packages.${pkgs.stdenv.hostPlatform.system};
in {
  imports = [wlib.wrapperModules.neovim];
  options.nvim-lib.neovimPlugins = lib.mkOption {
    readOnly = true;
    type = lib.types.attrsOf wlib.types.stringable;
    default = config.nvim-lib.pluginsFromPrefix "plugins-" inputs;
  };

  config.settings.config_directory = ./.;
  config.binName = "nvim";
  config.settings.aliases = ["vim" "vi"];

  config.info = {
    springJars = "${mypkgs.spring-boot-tools}/share/vscode/extensions/extension/jars";
  };

  options.settings = {
    colorscheme = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "tokyonight-night";
        description = "colorscheme";
      };
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.vimPlugins.tokyonight-nvim;
        description = "package that contain the colorscheme";
      };
    };
  };

  config.specs = {
    startup-plugins = with pkgs.vimPlugins; [
      lze
      lzextras
      mini-nvim
      nvim-treesitter.withAllGrammars
      nvim-lspconfig
    ];
    colorscheme = {
      data = config.settings.colorscheme.package;
      before = ["INIT_MAIN"];
      config =
        /*
        lua
        */
        ''
          vim.cmd.colorscheme("${config.settings.colorscheme.name}")
        '';
    };
    general = {
      after = ["startup-plugins"];
      extraPackages = with pkgs; [
        lazygit
        tree-sitter
      ];
      lazy = true;
      data = with pkgs.vimPlugins; [
        snacks-nvim
        oklch-color-picker-nvim
        project-nvim
        vim-tmux-navigator
        blink-cmp
        friendly-snippets
        colorful-menu-nvim
        ultimate-autopair-nvim
        vim-startuptime
        heirline-nvim
        noice-nvim
        dropbar-nvim
        markview-nvim
        vim-table-mode
        snacks-nvim
        trouble-nvim
        vim-illuminate
        rainbow-delimiters-nvim
        nvim-ts-autotag
        nvim-ts-context-commentstring
        which-key-nvim
      ];
    };
    lsp = {
      lazy = true;
      data = with pkgs.vimPlugins; [
        nvim-jdtls
        mypkgs.vimPlugins.spring-boot-nvim
        rustaceanvim
        crates-nvim
        typescript-tools-nvim
      ];
      extraPackages = with pkgs; [
        rust-analyzer
        gopls
        jdt-language-server
        mypkgs.spring-boot-tools
        clang-tools
        emmet-language-server
        typescript
        vscode-json-languageserver
        vscode-css-languageserver
        yaml-language-server
        nil
        nixd
        kdePackages.qtdeclarative
      ];
    };
    format = {
      data = with pkgs.vimPlugins; [
        conform-nvim
      ];
      lazy = true;
      extraPackages = with pkgs; [
        stylua
        alejandra
        prettierd
        google-java-format
        go
        taplo
      ];
    };
    lint = {
      lazy = true;
      data = with pkgs.vimPlugins; [
        nvim-lint
      ];
      extraPackages = with pkgs; [
        ruff
        selene
        clippy
        eslint
        checkstyle
      ];
    };
    lua = {
      after = ["general"];
      lazy = true;
      data = with pkgs.vimPlugins; [
        lazydev-nvim
      ];
      extraPackages = with pkgs; [
        lua-language-server
        stylua
        selene
      ];
    };
    nix = {
      data = null;
      extraPackages = with pkgs; [
        nixd
        nixfmt
      ];
    };
    ai = {
      lazy = true;
      data = with pkgs.vimPlugins; [
        codecompanion-nvim
        codecompanion-spinner-nvim
        codecompanion-history-nvim
        copilot-lua
        mcphub-nvim
      ];
      extraPackages = [
        inputs.mcp-hub.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
  };

  config.specMods = {
    options.extraPackages = lib.mkOption {
      type = lib.types.listOf wlib.types.stringable;
      default = [];
      description = "a extraPackages spec field to put packages to suffix to the PATH";
    };
  };
  config.extraPackages = config.specCollect (acc: v: acc ++ (v.extraPackages or [])) [];
}
