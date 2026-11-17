{
  description = "Niek's macOS configuration (nix-darwin + Home Manager)";

  inputs = {
    # Stable: operating system, Home Manager and general tooling.
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

    # Unstable: only for fast-moving AI tools (see modules/home/ai-tools.nix).
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Private values (e.g. email addresses) kept outside this public repo: a
    # local file, see ci/private-example/default.nix for its format.
    # After editing it: nix flake update private
    private = {
      url = "path:/etc/nix-private/default.nix";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-darwin,
      nixpkgs-unstable,
      ...
    }:
    let
      private = import inputs.private;

      # Build one macOS host. `name` is the configuration alias, not the hostname.
      mkDarwinHost =
        {
          name,
          system,
          username,
          homeDirectory,
        }:
        let
          host = {
            inherit
              name
              system
              username
              homeDirectory
              ;
          };

          pkgs-unstable = import nixpkgs-unstable {
            inherit system;
            # Only unfree package taken from unstable.
            config.allowUnfreePredicate =
              pkg: builtins.elem (nixpkgs-unstable.lib.getName pkg) [ "github-copilot-cli" ];
          };
        in
        nix-darwin.lib.darwinSystem {
          specialArgs = {
            inherit
              self
              inputs
              host
              pkgs-unstable
              private
              ;
          };
          modules = [ ./hosts/${name} ];
        };
    in
    {
      # Build:    darwin-rebuild build --flake ~/.config/nix-darwin#m5pro
      # Activate: sudo darwin-rebuild switch --flake ~/.config/nix-darwin#m5pro
      darwinConfigurations.m5pro = mkDarwinHost {
        name = "m5pro";
        system = "aarch64-darwin";
        inherit (private.hosts.m5pro) username homeDirectory;
      };

      # Dev shell for working on this repository (direnv: .envrc).
      # x86_64-linux is used by CI (.github/workflows/ci.yml).
      devShells =
        nixpkgs.lib.genAttrs
          [
            "aarch64-darwin"
            "x86_64-linux"
          ]
          (system: {
            default = import ./devshell.nix {
              pkgs = nixpkgs.legacyPackages.${system};
              pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
            };
          });
    };
}
