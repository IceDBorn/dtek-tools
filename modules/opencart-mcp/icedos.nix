{ ... }:

{
  inputs.opencart-mcp = {
    url = "github:chrisbray85/opencart-mcp";
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
