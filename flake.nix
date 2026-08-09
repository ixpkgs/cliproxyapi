{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          tag = "v7.2.127";
          commit = "ecc9aa72b32f34b680d03b0724b531a21ae74472";
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
        });
    };
}
