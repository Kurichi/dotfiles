{ pkgs, ... }:
{
  hostname = "Kurichi-MacBook-Pro";
  username = "kurichi";
  passwordManager = "1password";
  git = {
    email = null;
    signingKey = "~/.ssh/github.pub";
  };
  extraCasks = [
    "datagrip"
    "discord"
    "postman-agent"
    "slack"
    "steam"
    "zoom"
  ];
  extraMasApps = { LINE = 539883307; };
  extraPackages = with pkgs; [
    awscli2
    ssm-session-manager-plugin
    terraform
  ];
}
