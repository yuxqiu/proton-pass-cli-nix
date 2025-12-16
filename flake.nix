{
  description = "Proton Pass CLI - command line interface for Proton Pass";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; };

  outputs = { self, nixpkgs }:
    let
      supportedSystems =
        [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      manifest = builtins.fromJSON (builtins.readFile ./versions.json);

      version = manifest.passCliVersions.version;

      urls = manifest.passCliVersions.urls;

      platformMap = {
        "x86_64-linux" = urls.linux.x86_64;
        "aarch64-linux" = urls.linux.aarch64;
        "x86_64-darwin" = urls.macos.x86_64;
        "aarch64-darwin" = urls.macos.aarch64;
      };
    in {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };

          info =
            platformMap.${system} or (throw "Unsupported system: ${system}");

          nixHash = info.hash;

          proton-pass-cli = pkgs.callPackage ./package.nix {
            inherit version nixHash;
            url = info.url;
          };
        in {
          default = proton-pass-cli;
          proton-pass-cli = proton-pass-cli;
        });

      overlays.default = final: prev:
        let
          sys = final.stdenv.hostPlatform.system;
          platformInfo = platformMap.${sys} or (throw
            "Unsupported system for proton-pass-cli overlay: ${sys}");
        in {
          proton-pass-cli = final.callPackage ./package.nix {
            inherit version;
            url = platformInfo.url;
            nixHash = platformInfo.hash;
          };
        };
    };
}
