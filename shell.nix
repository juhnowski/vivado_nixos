{ pkgs ? import <nixpkgs> {} }:

(pkgs.buildFHSEnv {
  name = "vivado-installer-fhs";
  targetPkgs = pkgs: (with pkgs; [
    glibc
    zlib
    
    # Графическое окружение X11
    libx11
    libxext
    libxi
    libxrender
    libxtst
    libxt
    libXxf86vm
    
    # Шрифты и графика
    libGL
    alsa-lib
    freetype
    fontconfig
    
    # Базовые шрифты для Java
    dejavu_fonts
     liberation_ttf
    
    # Системные утилиты
    coreutils
    bash
    patchelf
    which
    procps
    jetbrains.jdk
  ]);
  
  # Пробрасываем пути к конфигурации шрифтов системы
  profileExtra = ''
    export FONTCONFIG_FILE=/etc/fonts/fonts.conf
    export FONTCONFIG_PATH=/etc/fonts
  '';
  
  runScript = "bash";
}).env
