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
      default = final: prev: {neovim = wrapper.config.wrap {pkgs = final;};};
      neovim = self.overlays.default;
    };
    wrapperModules = {
      default = module;
      neovim = self.wrapperModules.default;
    };
    wrappers = {
      default = wrapper.config;
      neovim = self.wrappers.default;
    };
    packages = forAllSystems (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };
      in {
        default = wrapper.config.wrap {inherit pkgs;};
        neovim = self.packages.${system}.default;
      }
    );
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
      neovim = wrappers.lib.mkInstallModule {
        name = "neovim";
        value = module;
        loc = [
          "home"
          "packages"
        ];
      };
    };
  };
}
