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
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "seamly2d";
  version = "2026.8.24.201";

  src = fetchFromGitHub {
    owner = "FashionFreedom";
    repo = "Seamly2D";
    rev = "v2026.8.24.201";
    sha256 = "1ah9j25rhnjvf48xpx11nszsj4kr2k5689pgrzrdfij20maqr5fn"; # filled by update script
  };

  nativeBuildInputs = with qt6; [
    qmake
    wrapQtAppsHook
    qttools
    addDriverRunpath
    git
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
