{ pkgs, ... }:
let
  direnvPackage =
    if pkgs.direnv.version == "2.37.1" then
      pkgs.direnv.overrideAttrs (_old: {
        doCheck = false;
      })
    else
      throw "Remove direnv doCheck workaround: direnv is ${pkgs.direnv.version}, expected 2.37.1.";
in
{
  programs.direnv = {
    enable = true;
    # nixpkgs 01fbdeef の direnv-2.37.1 は Darwin sandbox 内で test-zsh が
    # 停止するため、runtime package の build check だけを無効化する。
    package = direnvPackage;
    nix-direnv.enable = true;
  };
}
