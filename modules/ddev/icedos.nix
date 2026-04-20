{ ... }:

{
  outputs.nixosModules =
    { ... }:
    [
      (
        { pkgs, ... }:

        let
          ddevBin = "${pkgs.ddev}/bin/ddev";
        in
        {
          environment.systemPackages = with pkgs; [
            ddev
            docker-buildx
          ];

          systemd.tmpfiles.rules = [
            "L+ /usr/local/lib/docker/cli-plugins/docker-buildx - - - - ${pkgs.docker-buildx}/libexec/docker/cli-plugins/docker-buildx"
          ];

          icedos.applications.toolset.commands = [
            {
              command = "ddev";
              help = "print ddev related commands";
              commands = [
                {
                  command = "start";
                  help = "start development server";
                  script = ''
                    ${ddevBin} poweroff
                    ${ddevBin} start
                    ${ddevBin} mailpit
                  '';
                }
                {
                  command = "stop";
                  help = "stop development server";
                  script = "${ddevBin} poweroff";
                }
                {
                  command = "delete";
                  help = "delete project from ddev";
                  script = "${ddevBin} delete --omit-snapshot";
                }
                {
                  command = "db";
                  help = "database related commands";
                  commands = [
                    {
                      command = "import";
                      help = "import database from file";
                      script = ''${ddevBin} import-db --file="$1"'';
                    }
                    {
                      command = "info";
                      help = "print database info";
                      script = "${ddevBin} describe | grep --color=never db";
                    }
                  ];
                }
              ];
            }
          ];
        }
      )
    ];

  meta = {
    name = "ddev";

    dependencies = [{
      url = "github:icedos/apps";
      modules = ["docker"];
    }];
  };
}
