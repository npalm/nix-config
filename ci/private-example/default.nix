# Dummy private values used by CI instead of ~/.config/nix-private, e.g.:
#   nix eval .#... --override-input private path:./ci/private-example
# Also the template for a new machine's private directory.
{
  hosts.m5pro = {
    username = "example";
    homeDirectory = "/Users/example";
  };
  git = {
    personalEmail = "personal@example.com";
    workEmail = "work@example.com";
  };
  # Public keys of the Secure Enclave keys (`ssh-add -L`), see README.
  ssh = {
    signingKey = "sk-ecdsa-sha2-nistp256@openssh.com AAAAexample-signing";
    authKey = "sk-ecdsa-sha2-nistp256@openssh.com AAAAexample-auth";
  };
}
