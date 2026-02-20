{
  description = "sonic-win – Lightweight X11-only KWin fork";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        kde = pkgs.kdePackages;
        qt6 = pkgs.qt6;

      in rec {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "sonic-win";
          version = "unstable-2026-02";

          src = ./.;

          nativeBuildInputs = with pkgs; [
            cmake
            extra-cmake-modules
            pkg-config
            ninja
            kde.wrapQtAppsHook
            python3
          ];

          postPatch = ''
            patchShebangs src/plugins/strip-effect-metadata.py
          '';

          buildInputs = with kde; [
            qtbase
            qtdeclarative
            qtsvg
            qtwayland
            qt5compat
            qttools
            qtsensors

            kconfig
            kcoreaddons
            kcrash
            kdbusaddons
            kglobalaccel
            ki18n
            kiconthemes
            kwindowsystem
            kxmlgui
            kcmutils
            kdeclarative
            knewstuff
            plasma-activities
            kconfigwidgets
            kwidgetsaddons
            kservice

            # ── newly added to fix current error ──
            kde.kauth
            kidletime
            ksvg

            knighttime
            kdecoration

            kde.kscreenlocker

          ] ++ (with qt6; [
            #qtquickcontrols2
            qtshadertools
          ]) ++ (with pkgs; [
            libX11
            libXcomposite
            libXdamage
            libXfixes
            libXrender
            libXrandr
            libXcursor
            libXinerama
            libxkbcommon
            #xcb-util
            #xcb-util-keysyms
            #xcb-util-wm
            #xcb-util-image
            #xcb-util-cursor
            #epoxy
            libdrm
            mesa
            wayland
            wayland-protocols
            libinput
            udev

            libcanberra
            libdisplay-info
            lcms2

          ]);

          cmakeFlags = [
            "-DBUILD_TESTING=OFF"
            "-DCMAKE_INSTALL_LIBEXECDIR=libexec"
            "-DKDE_INSTALL_USE_QT_SYS_PATHS=ON"
            # "-DWITH_WAYLAND=OFF"
          ];

          meta = with pkgs.lib; {
            description = "Lightweight X11-only window manager / compositor (KWin fork)";
            homepage = "https://github.com/Sonic-DE/sonic-win";
            license = licenses.gpl2Plus;
            platforms = platforms.linux;
            mainProgram = "kwin_x11";
          };
        };

        apps.default = {
          type = "app";
          program = "${packages.default}/bin/kwin_x11";
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [ packages.default ];
          packages = with pkgs; [
            kde.qtcreator
            gdb
            renderdoc
            nix-output-monitor
            just
          ];
          shellHook = ''
            echo "sonic-win dev shell (X11-focused Plasma 6 build env)"
          '';
        };
      }
    );
}
