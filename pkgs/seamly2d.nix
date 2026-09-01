{ lib
, stdenv
, fetchFromGitHub
, qt6
, xercesc
, poppler-utils
, libglvnd
, git
, fontconfig
, freetype
, libxrender
, libxi
, libxcb
, addDriverRunpath
, gtk3
, gsettings-desktop-schemas
, wrapGAppsHook3
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "seamly2d";
  version = "2026.8.31.143";

  src = fetchFromGitHub {
    owner = "FashionFreedom";
    repo = "Seamly2D";
    rev = "v2026.8.31.143";
    sha256 = "0xfm657hqkwhbzk9y5nc61sip91r015km2nzfp9ri8d6dbzzc55q"; # filled by update script
  };

  nativeBuildInputs = with qt6; [
    qmake
    wrapQtAppsHook
    qttools
    addDriverRunpath
    git
    wrapGAppsHook3
  ];

  buildInputs = with qt6; [
    qtbase
    qtsvg
    qtmultimedia
  ] ++ [
    xercesc
    poppler-utils
    libglvnd
    fontconfig
    freetype
    libxrender
    libxi
    libxcb
    gtk3
    gsettings-desktop-schemas
  ];

  postPatch = ''
    substituteInPlace src/app/seamly2d/mainwindowsnogui.cpp \
      --replace-fail 'define PDFTOPS "pdftops"' \
                     'define PDFTOPS "${lib.getBin poppler-utils}/bin/pdftops"'
    substituteInPlace src/libs/vwidgets/export_format_combobox.cpp \
      --replace-fail 'define PDFTOPS "pdftops"' \
                     'define PDFTOPS "${lib.getBin poppler-utils}/bin/pdftops"'
  '';

  qmakeFlags = [
    "PREFIX=/"
    "PREFIX_LIB=/lib"
    "Seamly2D.pro"
    "-r"
    "CONFIG+=noDebugSymbols"
    "CONFIG+=noTests"
    "CONFIG+=no_ccache"
    # https://github.com/NixOS/nixpkgs/issues/214765
    "QT_TOOL.lrelease.binary=${lib.getDev qt6.qttools}/bin/lrelease"
  ];

  installFlags = [ "INSTALL_ROOT=$(out)" ];

dontWrapGApps = true;

preFixup = ''
  qtWrapperArgs+=(
    "''${gappsWrapperArgs[@]}"
    --prefix XDG_DATA_DIRS : "${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}"
    --prefix XDG_DATA_DIRS : "${gtk3}/share/gsettings-schemas/${gtk3.name}"
  )
'';

  postInstall = ''
    if [ -d $out/share/seamly2d ]; then
      mv $out/share/seamly2d/* $out/share/ || true
      rmdir $out/share/seamly2d || true
    fi

    mkdir -p $out/share/mime/packages
    cp dist/debian/seamly2d.sharedmimeinfo $out/share/mime/packages/seamly2d.xml
  '';

  meta = {
    description = "Open source patternmaking software";
    homepage = "https://seamly.io/";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "seamly2d";
  };
})
