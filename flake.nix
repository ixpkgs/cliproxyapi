{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          tag = "v7.3.1";
          commit = "44e62bc8acc2f224bff9c62d222717d3f6723dea";
        in
        {
          default = pkgs.buildGoModule {
            pname = "cliproxyapi";
            version = nixpkgs.lib.removePrefix "v" tag;

            src = builtins.fetchGit {
              url = "https://github.com/router-for-me/CLIProxyAPI";
              rev = commit;
            };

            vendorHash = "sha256-CrDp7MOr+AwJUhTovklXx3F1yaktQlvD7VYhYSY6VvY=";
            subPackages = [ "cmd/server" ];

            ldflags = [
              "-s"
              "-w"
              "-X=main.Version=${tag}"
              "-X=main.Commit=${commit}"
            ];

            postInstall = ''
              mv "$out/bin/server" "$out/bin/cli-proxy-api"
            '';

            meta = {
              description = "Proxy server providing OpenAI-compatible APIs for CLI clients";
              homepage = "https://github.com/router-for-me/CLIProxyAPI";
              license = nixpkgs.lib.licenses.mit;
              mainProgram = "cli-proxy-api";
            };
          };
        }
      );
    };
}
