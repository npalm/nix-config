# Use the upstream CLI until nixpkgs catches up with the 0.1 series.
{
  lib,
  stdenvNoCC,
  fetchurl,
  versionCheckHook,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "openshell";
  version = "0.1.9";

  src = fetchurl {
    url = "https://github.com/NVIDIA/OpenShell/releases/download/v${finalAttrs.version}/openshell-aarch64-apple-darwin.tar.gz";
    hash = "sha256-NVv2EhWeqgxTdfrNjydTbZy1TlrwMDKOqDmpJ6eQHaU=";
  };

  sourceRoot = ".";
  dontConfigure = true;
  dontBuild = true;
  # Preserve the upstream binary and its code signature.
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 openshell "$out/bin/openshell"
    runHook postInstall
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = "${placeholder "out"}/bin/openshell";
  doInstallCheck = true;

  meta = {
    description = "OpenShell CLI for sandboxed AI agents";
    homepage = "https://docs.nvidia.com/openshell/";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "openshell";
    platforms = [ "aarch64-darwin" ];
  };
})
