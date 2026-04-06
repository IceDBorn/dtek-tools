{ ... }:

{
  outputs.nixosModules =
    { ... }:
    [
      (
        {
          config,
          lib,
          pkgs,
          ...
        }:

        {
          environment.systemPackages = with pkgs; [
            ddev
            docker-buildx
          ];

          systemd.tmpfiles.rules = [
            "L+ /usr/local/lib/docker/cli-plugins/docker-buildx - - - - ${pkgs.docker-buildx}/libexec/docker/cli-plugins/docker-buildx"
          ];

          virtualisation.docker.enable = true;

          icedos.applications.toolset.commands = [
            (
              let
                inherit (lib) concatMapStrings sort;
                ddev = "${pkgs.ddev}/bin/ddev";

                colorBashHeader = ''
                  NC='\033[0m'
                  PURPLE='\033[0;35m'
                  RED='\033[0;31m'
                '';

                helpFlags = ''"$1" == "" || "$1" == "--help" || "$1" == "-h" || "$1" == "help" || "$1" == "h"'';
                purpleString = string: "\${PURPLE}${string}\${NC}";
                redString = string: "\${RED}${string}\${NC}";

                commands = [
                  (
                    let
                      command = "start";
                    in
                    {
                      inherit command;

                      bin = "${pkgs.writeShellScript command ''
                        ${ddev} poweroff
                        ${ddev} start
                        ${ddev} mailpit
                      ''}";

                      help = "start development server";
                    }
                  )
                  (
                    let
                      command = "stop";
                    in
                    {
                      inherit command;
                      bin = "${pkgs.writeShellScript command "${ddev} poweroff"}";
                      help = "stop development server";
                    }
                  )
                  (
                    let
                      command = "delete";
                    in
                    {
                      inherit command;
                      bin = "${pkgs.writeShellScript command "${ddev} delete --omit-snapshot"}";
                      help = "delete project from ddev";
                    }
                  )
                  (
                    let
                      command = "db";
                    in
                    {
                      inherit command;

                      bin = "${pkgs.writeShellScript command ''
                        ${colorBashHeader}

                        if [[ ${helpFlags} ]]; then
                          echo "Available commands:"
                          echo -e "> ${purpleString "import"}: import database from file"
                          echo -e "> ${purpleString "info"}: print database info"
                          exit 0
                        fi

                        case "$1" in
                          import)
                            ${ddev} import-db --file="$2"
                            exit 0
                            ;;
                          info)
                            ${ddev} describe | grep --color=never db
                            exit 0
                            ;;
                          *|-*|--*)
                            echo -e "${redString "Unknown arg"}: $1" >&2
                            exit 1
                            ;;
                        esac
                      ''}";

                      help = "database related commands";
                    }
                  )
                ];

                command = "ddev";
              in
              {
                inherit command;

                bin = "${pkgs.writeShellScript command ''
                  ${colorBashHeader}

                  if [[ ${helpFlags} ]]; then
                    echo "Available commands:"

                    ${concatMapStrings (tool: ''
                      echo -e "> ${purpleString tool.command}: ${tool.help} "
                    '') (sort (a: b: a.command < b.command) commands)}

                    exit 0
                  fi

                  case "$1" in
                    ${concatMapStrings (tool: ''
                      ${tool.command})
                        shift
                        exec ${tool.bin} "$@"
                        ;;
                    '') commands}
                    *|-*|--*)
                      echo -e "${redString "Unknown arg"}: $1" >&2
                      exit 1
                      ;;
                  esac
                ''}";

                help = "print ddev related commands";
              }
            )
          ];

          users.users =
            let
              inherit (lib) mapAttrs;
            in
            mapAttrs (user: _: {
              extraGroups = [ "docker" ];
            }) config.icedos.users;
        }
      )
    ];

  meta.name = "ddev";
}
