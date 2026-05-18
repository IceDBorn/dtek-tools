{ ... }:

{
  inputs.opencart-mcp = {
    url = "github:icedborn/opencart-mcp/feat/nix-flake";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs.nixosModules =
    { inputs, ... }:
    [
      (

        { pkgs, ... }:

        {
          environment.systemPackages = [
            inputs.opencart-mcp.packages.${pkgs.stdenv.system}.default
          ];
        }
      )
    ];

  meta.name = "opencart-mcp";
}
