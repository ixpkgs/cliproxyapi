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
          tag = "v7.2.45";
          version = "7.2.45";
          commit = "c22795af80ec6b3f14028c16bd4350d76e47174d";
        in
        {
          default = pkgs.buildGoModule {
            pname = "cliproxyapi";
            inherit version;

            src = builtins.fetchGit {
              url = "https://github.com/router-for-me/CLIProxyAPI";
              rev = commit;
            };

            vendorHash = "sha256-vQU3hLDga5PMUwH4KSB3T5sZ1uPUgHQHeyQGJTKHIYs=";
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
