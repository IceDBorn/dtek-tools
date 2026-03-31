{ ... }:

{
  outputs.nixosModules =
    { ... }:
    [
      (

        { pkgs, ... }:

        let
          opencart-mcp-pkg = pkgs.python3Packages.buildPythonPackage {
            pname = "opencart-mcp";
            version = "0.3.0";

            src = pkgs.fetchFromGitHub {
              owner = "chrisbray85";
              repo = "opencart-mcp";
              rev = "c2179df";
              sha256 = "0jlrd9b0n3zvciydc75y6lb6fkpmrhazvw3pa2bygr8cy9051lgg";
            };

            patches = [ ./ddev-support.patch ];

            format = "pyproject";
            nativeBuildInputs = [ pkgs.python3Packages.setuptools ];

            propagatedBuildInputs = with pkgs.python3Packages; [
              fastmcp
              paramiko
              python-dotenv
            ];

            doCheck = false;
          };

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
