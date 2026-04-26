{
  description = "Kurichi's dotfiles managed by nix-darwin and home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NOTE: 6545e91e (2026-04-23) の "treewide: drop vendored prefetch-npm-deps,
    # use upstream fetcherVersion=2" 以降、gemini-cli を含む複数パッケージで
    # npmDepsHash と source の package-lock.json が整合せず ENOTCACHED を起こす。
    # 暫定として直前の commit 6ff92d21 (gemini-cli 0.39.0 + 旧 fetcher) に pin。
    # upstream で修正されたらこの pin を外して `github:numtide/llm-agents.nix` に戻す。
    llm-agents = {
      url = "github:numtide/llm-agents.nix/8d4a16ea18c24d0e00ff9c786c55ac258cc24983";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-code-overlay = {
      url = "github:ryoppippi/claude-code-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, llm-agents, claude-code-overlay }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;
      llmPkgs = llm-agents.packages.${system};

      # Profile names
      profileNames = [ "personal" "work" ];

      # Load profiles and inject profileName
      profiles = builtins.listToAttrs (map (name: {
        inherit name;
        value = (import (./nix/hosts + "/${name}.nix")) // { profileName = name; };
      }) profileNames);

      # hostname -> profileName mapping (also serves as uniqueness check)
      profilesByHost = builtins.listToAttrs (
        map (name: { name = profiles.${name}.hostname; value = name; }) profileNames
      );

      # Auto-generate shell case branches from profile data
      hostnameCaseBranches = lib.concatStringsSep "\n" (
        lib.mapAttrsToList (hostname: profileName:
          "    ${hostname}) PROFILE=\"${profileName}\" ;;"
        ) profilesByHost
      );

      mkDarwinSystem = profile:
        let
          inherit (profile) username hostname;
        in
        nix-darwin.lib.darwinSystem {
          inherit system;
          modules = [
            ./nix/modules/darwin
            {
              nixpkgs.overlays = [
                claude-code-overlay.overlays.default
                (import ./nix/overlays/default.nix)
              ];
            }
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = {
                inherit username llmPkgs profile;
                claudeCodePkg = claude-code-overlay.packages.${system}.default;
              };
              home-manager.users.${username} = import ./nix/modules/home;
            }
          ];
          specialArgs = {
            inherit inputs username hostname llmPkgs profile;
            claudeCodePkg = claude-code-overlay.packages.${system}.default;
          };
        };
    in
    assert lib.assertMsg
      (builtins.length profileNames == builtins.length (builtins.attrNames profilesByHost))
      "Duplicate hostname found in nix/hosts/*.nix";
    {
      darwinConfigurations = builtins.mapAttrs (_: mkDarwinSystem) profiles;

      # Convenience apps
      apps.${system} = {
        switch = {
          type = "app";
          program = toString (pkgs.writeShellScript "switch" ''
            HOSTNAME=$(/bin/hostname -s)
            case "$HOSTNAME" in
            ${hostnameCaseBranches}
              *) echo "Unknown hostname: $HOSTNAME" >&2; exit 1 ;;
            esac
            echo "Detected: $HOSTNAME -> $PROFILE"
            sudo darwin-rebuild switch --flake ${self}#"$PROFILE"
          '');
        };
        build = {
          type = "app";
          program = toString (pkgs.writeShellScript "build" ''
            HOSTNAME=$(/bin/hostname -s)
            case "$HOSTNAME" in
            ${hostnameCaseBranches}
              *) echo "Unknown hostname: $HOSTNAME" >&2; exit 1 ;;
            esac
            echo "Detected: $HOSTNAME -> $PROFILE"
            darwin-rebuild build --flake ${self}#"$PROFILE"
          '');
        };
        update = {
          type = "app";
          program = toString (pkgs.writeShellScript "update" ''
            nix flake update
          '');
        };
      };
    };
}
