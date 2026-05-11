{ ... }:

{
  outputs.nixosModules =
    { ... }:
    [
      (

        { pkgs, ... }:

        let
          opencart-mcp-pkg = pkgs.callPackage ./package.nix { };

          pythonEnv = pkgs.python3.withPackages (ps: [ opencart-mcp-pkg ]);
        in
        {
          environment.systemPackages = [
            (pkgs.writeShellScriptBin "opencart-mcp" ''
              exec ${pythonEnv}/bin/python -m opencart_mcp.server "$@"
            '')
          ];
        }
      )
    ];

  meta.name = "opencart-mcp";
}
