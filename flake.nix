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
          tag = "v7.2.135";
          version = "7.2.135";
          commit = "856ddd8df746a38a6033dbbf6c140974bf5aea0f";
        in
        {
          default = pkgs.buildGoModule {
            pname = "cliproxyapi";
            inherit version;

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
