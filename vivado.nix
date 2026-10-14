{ pkgs ? import <nixpkgs> {} }:

(pkgs.buildFHSEnv {
  name = "vivado-fhs";
  targetPkgs = pkgs: (with pkgs; [
    glibc
    zlib
    ncurses5
    pixman
    libpng
    bash
    coreutils
    procps
    which
    util-linux
    stdenv.cc.cc.lib

    # Графика X11 и OpenGL
    libx11
    libxext
    libxi
    libxrender
    libxtst
    libxt
    libXxf86vm
    libxcb
    dbus
    libGL

    # Шрифты и рендеринг текста
    freetype
    fontconfig
    dejavu_fonts
    liberation_ttf
  ]);

  profileExtra = ''
    export FONTCONFIG_FILE=/etc/fonts/fonts.conf
    export FONTCONFIG_PATH=/etc/fonts
    export LD_LIBRARY_PATH=/lib:/lib64:/usr/lib:/usr/lib64:$LD_LIBRARY_PATH
  '';

  # Заставляем bash при старте принудительно выполнить инициализацию и оставить нам интерактивную консоль
  runScript = "bash --init-file <(echo 'source /home/ilya/Xilinx/2026.1.1/Vivado/settings64.sh && echo \"--- Окружение загружено! ---\"')";
}).env
