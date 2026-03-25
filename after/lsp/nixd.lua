local flake_expr = "builtins.getFlake (toString ./.)"
return {
  settings = {
    nixd = {
      nixpkgs = {
        expr = string.format("import (%s).inputs.nixpkgs { }", flake_expr),
      },
      formatting = { command = { "alejandra" } },
      options = {
        nixos = {
          expr = string.format("(%s).nixosConfigurations.hostname.options", flake_expr),
        },
        home_manager = {
          expr = string.format('(%s).homeConfigurations."user@hostname".options', flake_expr),
        },
        flake_parts = {
          expr = string.format("let flake = %s; in flake.debug.options // flake.currentSystem.options", flake_expr),
        },
      },
    },
  },
}
