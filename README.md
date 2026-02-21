a flake for sonic-DE on nixOS.

BE AWARE THE FLAKE CONTAINS HARDCODED PATHS THAT WILL NOT BE VALID ON YOUR SYSTEM. this is because the sonic repo does not have a flake.nix yet

first, you must clone both sonic-win and sonic-workspace onto your system

on my system, I cloned them to /home/implicit/sonic-DE/

YOU WILL HAVE TO CHANGE THIS PATH EVERYWHERE IT IS MENTIONED IN THE FLAKES

here's the tree after I cloned them:

/home/implict/
 -sonic-DE/
   -sonic-win/
      ...
   -sonic-workspace/
      ...

copy swo.nix to flake.nix in sonic-workspace, and swi.nix to flake.nix in sonic-win


here are the lines I used to add it to my config.nix

```
let
  sonicKWin = config._module.args.sonic-win.packages.${pkgs.system}.default or
             (builtins.getFlake "path:/home/implicit/sonic-DE/sonic-win").packages.${pkgs.system}.default;

  sonicWorkspace = config._module.args.sonic-workspace.packages.${pkgs.system}.default or
                   (builtins.getFlake "path:/home/implicit/sonic-DE/sonic-workspace").packages.${pkgs.system}.default;

  startSonic = pkgs.writeShellScriptBin "start-sonic" ''
    #!/usr/bin/env bash
    set -euo pipefail

    export KWIN_COMPOSE=X
    export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

    # Launch your custom kwin and plasmashell
    "${sonicKWin}/bin/kwin_x11" --replace &
    sleep 3
    "${sonicWorkspace}/bin/plasmashell" --replace &

    # Keep session alive
    wait
  '';

in
```

...

```
  environment.systemPackages = with pkgs; [

  sonicKWin
  sonicWorkspace
  startSonic

  ];
```

fyi, start-sonic doesn't seem to work in a vtty, so I made it so that it will show up in sddm. this is mostly me, and not grok, but real credit goes to @therealimpersonator on the nixOS discord for showing me the relevant option. TYSM!!!!

```
  services.xserver.displayManager.session = [
    { manage = "desktop";
      name = "xterm";
      start = ''
        ${pkgs.xterm}/bin/xterm -ls &
        waitPID=$!
      '';
    }
    { manage = "desktop";
      name = "sonic-de";
      start = ''
        ${sonicWorkspace}/bin/startplasma-x11 \
          --kwin "${sonicKWin}/bin/kwin_x11" \
          --plasmashell "${sonicWorkspace}/bin/plasmashell"
      '';
    }
  ];
```






