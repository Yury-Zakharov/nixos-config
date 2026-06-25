{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, wrapGAppsHook
, gtk3
, webkitgtk_4_1
, glib
, libsecret
, gsettings-desktop-schemas
, at-spi2-core
, dbus
}:

let
  version = "1.6.1";
  src = fetchurl {
    url = "https://github.com/rmitchellscott/reManager/releases/download/v${version}/reManager-linux-amd64.tar.gz";
    hash = "sha256-1v20xl5nm98vwl91bgr54vispxcsdkfgpxpfb9sq8hmdwj4fq05f";
  };
  icon = fetchurl {
    url = "https://raw.githubusercontent.com/rmitchellscott/reManager/v${version}/assets/icon.svg";
    hash = "sha256-1v20xl5nm98vwl91bgr54vispxcsdkfgpxpfb9sq8hmdwj4fq05f";
  };
in
stdenv.mkDerivation {
  pname = "remanager";
  inherit version src;

  nativeBuildInputs = [ autoPatchelfHook wrapGAppsHook ];
  buildInputs = [
    gtk3
    webkitgtk_4_1
    glib
    libsecret
    gsettings-desktop-schemas
    at-spi2-core
    dbus
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/share/applications $out/share/icons/hicolor/scalable/apps

    # Tarball layout is usually flat with binary named reManager.
    # If this fails on first build, inspect with: tar -tzf $src
    tar -xzf $src -C $out/bin
    mv $out/bin/reManager $out/bin/remanager 2>/dev/null || true
    chmod +x $out/bin/remanager || true

    cat > $out/share/applications/remanager.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=reManager
Comment=Manage mods on reMarkable tablets
Exec=remanager
Icon=remanager
Categories=Utility;
StartupNotify=true
EOF

    cp ${icon} $out/share/icons/hicolor/scalable/apps/remanager.svg
    runHook postInstall
  '';

  meta = {
    description = "Desktop app for managing mods on reMarkable tablets";
    homepage = "https://github.com/rmitchellscott/reManager";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "remanager";
  };
}
