# Touch ID for sudo via nix-darwin's managed /etc/pam.d/sudo_local.
# pam_tid.so is "sufficient", so the password prompt remains as fallback.
{ ... }:

{
  security.pam.services.sudo_local.touchIdAuth = true;
}
