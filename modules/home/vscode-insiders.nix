# Settings for the Homebrew-installed VS Code Insiders app.
{ pkgs, ... }:

let
  # Local extensions are pinned by flake.lock. Add further host extensions here;
  # container language tools belong in each project's devcontainer.json.
  extensions = with pkgs.vscode-extensions; [
    ms-vscode-remote.remote-containers
    jnoortheen.nix-ide
    eamodio.gitlens
    redhat.vscode-yaml
    editorconfig.editorconfig
    esbenp.prettier-vscode
    ms-azuretools.vscode-containers
  ];
  extensionBundle = pkgs.buildEnv {
    name = "vscode-insiders-extensions";
    paths = extensions ++ [
      (pkgs.writeTextDir "share/vscode/extensions/extensions.json" (
        pkgs.vscode-utils.toExtensionJson extensions
      ))
    ];
  };
in
{
  home.file."Library/Application Support/Code - Insiders/User/settings.json".source =
    ./vscode-insiders/settings.json;

  home.file.".vscode-insiders/extensions".source = "${extensionBundle}/share/vscode/extensions";
}
