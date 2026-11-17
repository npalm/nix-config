# Home Manager integration. Users are attached per host (see hosts/<name>/).
{
  inputs,
  host,
  pkgs-unstable,
  private,
  ...
}:

{
  imports = [ inputs.home-manager.darwinModules.home-manager ];

  home-manager = {
    useGlobalPkgs = true; # `pkgs` in Home Manager = stable system nixpkgs
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    extraSpecialArgs = { inherit host pkgs-unstable private; };
  };
}
