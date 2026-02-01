inputs: {
  config,
  wlib,
  lib,
  pkgs,
  ...
}: {
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
    springJars = "${pkgs.spring-boot-tools}/share/vscode/extensions/extension/jars";
  };

  config.specs = let
    nolazy = plugin: {
      data = plugin;
      lazy = false;
    };
  in {
    startup-plugins = with pkgs.vimPlugins; [
      lze
      lzextras
      snacks-nvim
      mini-nvim
      nvim-treesitter.withAllGrammars
      tokyonight-nvim
    ];
    general = {
      after = ["startup-plugins"];
      extraPackages = with pkgs; [
        lazygit
        tree-sitter
      ];
      lazy = true;
      data = with pkgs.vimPlugins; [
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
        nvim-lspconfig
        nvim-jdtls
        spring-boot-nvim
        rustaceanvim
        crates-nvim
        typescript-tools-nvim
      ];
      extraPackages = with pkgs; [
        rust-analyzer
        gopls
        jdt-language-server
        spring-boot-tools
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
    base16 = {
      # install a plugin to handle the colors
      data = pkgs.vimPlugins.mini-base16;
      # run before the main init.lua
      before = ["INIT_MAIN"];

      # get the colors from your system and pass it
      info =
        pkgs.lib.filterAttrs (
          k: v: builtins.match "base0[0-9A-F]" k != null
        )
        config.lib.stylix.colors.withHashtag;

      # call the plugin with the colors
      enable = config.stylix.enable or false;
      config =
        /*
        lua
        */
        ''
          local info, pname, lazy = ...
          require("mini.base16").setup({
            palette = info,
          })
        '';
    };
  };

  # These are from the tips and tricks section of the neovim wrapper docs!
  # https://birdeehub.github.io/nix-wrapper-modules/neovim.html#tips-and-tricks
  # We could put these in another module and import them here instead!

  # This submodule modifies both levels of your specs
  config.specMods = {
    # When this module is ran in an inner list,
    # this will contain `config` of the parent spec
    parentSpec ? null,
    # and this will contain `options`
    # otherwise they will be `null`
    parentOpts ? null,
    parentName ? null,
    # and then config from this one, as normal
    config,
    # and the other module arguments.
    ...
  }: {
    # you could use this to change defaults for the specs
    # config.collateGrammars = lib.mkDefault (parentSpec.collateGrammars or false);
    # config.autoconfig = lib.mkDefault (parentSpec.autoconfig or false);
    # config.runtimeDeps = lib.mkDefault (parentSpec.runtimeDeps or false);
    # config.pluginDeps = lib.mkDefault (parentSpec.pluginDeps or false);
    # or something more interesting like:
    # add an extraPackages field to the specs themselves
    options.extraPackages = lib.mkOption {
      type = lib.types.listOf wlib.types.stringable;
      default = [];
      description = "a extraPackages spec field to put packages to suffix to the PATH";
    };
    # You could do this too
    # config.before = lib.mkDefault [ "INIT_MAIN" ];
  };
  config.extraPackages = config.specCollect (acc: v: acc ++ (v.extraPackages or [])) [];

  # Inform our lua of which top level specs are enabled
  options.settings.cats = lib.mkOption {
    readOnly = true;
    type = lib.types.attrsOf lib.types.bool;
    default = builtins.mapAttrs (_: v: v.enable) config.specs;
  };
  # build plugins from inputs set
  options.nvim-lib.pluginsFromPrefix = lib.mkOption {
    type = lib.types.raw;
    readOnly = true;
    default = prefix: inputs:
      lib.pipe inputs [
        builtins.attrNames
        (builtins.filter (s: lib.hasPrefix prefix s))
        (map (
          input: let
            name = lib.removePrefix prefix input;
          in {
            inherit name;
            value = config.nvim-lib.mkPlugin name inputs.${input};
          }
        ))
        builtins.listToAttrs
      ];
  };
}
