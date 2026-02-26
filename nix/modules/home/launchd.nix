_: {
  # Startup apps (launchd)
  launchd.enable = true;
  launchd.agents = {
    raycast = {
      enable = true;
      config = {
        ProgramArguments = [ "/Applications/Raycast.app/Contents/MacOS/Raycast" ];
        RunAtLoad = true;
        KeepAlive = false;
      };
    };
    homerow = {
      enable = true;
      config = {
        ProgramArguments = [ "/Applications/Homerow.app/Contents/MacOS/Homerow" ];
        RunAtLoad = true;
        KeepAlive = false;
      };
    };
  };
}
