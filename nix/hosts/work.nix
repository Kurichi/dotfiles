{ pkgs, ... }:
{
  hostname = "Work-Mac";
  username = "kurichi";
  passwordManager = "bitwarden";
  git = {
    email = null;
    signingKey = "~/.ssh/github.pub";
  };
  extraCasks = [
    "datagrip"
    "postman-agent"
    "slack"
    "zoom"
  ];
  extraPackages = with pkgs; [
    awscli2
    ssm-session-manager-plugin
    terraform
  ];
}
