{
  description = "Flake exporting a configured neovim package";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    wrappers.url = "github:BirdeeHub/nix-wrapper-modules";
    wrappers.inputs.nixpkgs.follows = "nixpkgs";
    my-packages.url = "path:./pkgs";
    my-packages.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = {
    self,
    nixpkgs,
    wrappers,
    ...
  } @ inputs: let
    forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.platforms.all;
    module = nixpkgs.lib.modules.importApply ./module.nix inputs;
    wrapper = wrappers.lib.evalModule module;
  in {
    overlays = {
      neovim = final: prev: {neovim = wrapper.config.wrap {pkgs = final;};};
      default = self.overlays.neovim;
    };
    wrapperModules = {
      neovim = module;
      default = self.wrapperModules.neovim;
    };
    wrappers = {
      neovim = wrapper.config;
      default = self.wrappers.neovim;
    };
    packages = forAllSystems (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        neovim = wrapper.config.wrap {inherit pkgs;};
        default = self.packages.${system}.neovim;
      }
    );
    # `wrappers.neovim.enable = true`
    nixosModules = {
      default = self.nixosModules.neovim;
      neovim = wrappers.lib.mkInstallModule {
        name = "neovim";
        value = module;
      };
    };
    # `wrappers.neovim.enable = true`
    # You can set any of the options.
    # But that is how you enable it.
    homeModules = {
      default = self.homeModules.neovim;
      neovim = {
        config,
        pkgs,
        lib,
        ...
      }: {
        imports = [
          (wrappers.lib.mkInstallModule
            {
              name = "neovim";
              value = module;
              loc = [
                "home"
                "packages"
              ];
            })
        ];
        wrappers.neovim =
          lib.mkIf
          (config.stylix.enable or false && config.stylix.targets.neovim.enable or false) {
            specs.colorscheme =
              lib.mkForce
              {
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
      };
    };
  };
}
