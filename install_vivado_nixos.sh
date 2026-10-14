#!/usr/bin/env bash

# Скрипт автоматизации развертывания Xilinx Vivado 2026.1.1 на NixOS
# Автор: Илья

set -e # Останавливать скрипт при любой ошибке

# --- НАСТРОЙКИ ---
ISO_NAME="Xilinx_Unified_2026_1_1_0904_0832.iso" # Имя вашего рабочего ISO-образа
VIVADO_DIR="/home/ilya/Xilinx"                 # Куда установлена среда
DISTR_DIR="/home/ilya/vivado_distr"             # Папка для распаковки инсталлятора
MOUNT_DIR="/home/ilya/vivado-iso"               # Временная папка монтирования

echo "=== Шаг 1: Подготовка окружения и распаковка дистрибутива ==="
if [ ! -f "$ISO_NAME" ]; then
    echo "Ошибка: Файл $ISO_NAME не найден в текущей папке!"
    exit 1
fi

mkdir -p "$MOUNT_DIR"
mkdir -p "$DISTR_DIR"

echo "Монтирование ISO-образа..."
sudo mount -o loop "$ISO_NAME" "$MOUNT_DIR"

echo "Копирование файлов на жесткий диск во избежание ошибок ввода-вывода..."
cp -r "$MOUNT_DIR"/* "$DISTR_DIR/"
chmod -R +w "$DISTR_DIR/"

echo "Размонтирование ISO..."
sudo umount "$MOUNT_DIR"
rmdir "$MOUNT_DIR"

echo "Выставление прав на исполнение для встроенной Java и скриптов..."
chmod -R +x "$DISTR_DIR"

echo "=== Шаг 2: Создание shell.nix для графического установщика ==="
cat << 'EOF' > "$DISTR_DIR/shell.nix"
{ pkgs ? import <nixpkgs> {} }:

(pkgs.buildFHSEnv {
  name = "vivado-installer-fhs";
  targetPkgs = pkgs: (with pkgs; [
    glibc zlib libx11 libxext libxi libxrender libxtst libxt libXxf86vm
    libGL alsa-lib freetype fontconfig dejavu_fonts liberation_ttf
    coreutils bash patchelf which procps jetbrains.jdk
  ]);
  profileExtra = ''
    export FONTCONFIG_FILE=/etc/fonts/fonts.conf
    export FONTCONFIG_PATH=/etc/fonts
  '';
  runScript = "bash";
}).env
EOF

echo "=== Шаг 3: Создание постоянного скрипта запуска vivado.nix ==="
cat << EOF > "$DISTR_DIR/vivado.nix"
{ pkgs ? import <nixpkgs> {} }:

(pkgs.buildFHSEnv {
  name = "vivado-fhs";
  targetPkgs = pkgs: (with pkgs; [
    glibc zlib ncurses5 pixman libpng bash coreutils procps which util-linux stdenv.cc.cc.lib
    libx11 libxext libxi libxrender libxtst libxt libXxf86vm libxcb dbus libGL
    freetype fontconfig dejavu_fonts liberation_ttf
  ]);

  profileExtra = ''
    export FONTCONFIG_FILE=/etc/fonts/fonts.conf
    export FONTCONFIG_PATH=/etc/fonts
    export LD_LIBRARY_PATH=/lib:/lib64:/usr/lib:/usr/lib64:\$LD_LIBRARY_PATH
  '';

  runScript = "bash --init-file <(echo 'source $VIVADO_DIR/2026.1.1/Vivado/settings64.sh && echo \"--- Окружение загружено! ---\"')";
}).env
EOF

echo "=== Шаг 4: Вывод правил udev для программатора JTAG ==="
echo "Для того чтобы Vivado видела вашу плату SPR2801, добавьте следующие строки в /etc/nixos/configuration.nix:"
echo "------------------------------------------------------------"
echo "services.udev.extraRules = ''"
echo "  ATTRS{idVendor}==\"03fd\", ATTRS{idProduct}==\"0008\", MODE=\"666\""
echo "  ATTRS{idVendor}==\"03fd\", ATTRS{idProduct}==\"000d\", MODE=\"666\""
echo "  ATTRS{idVendor}==\"03fd\", ATTRS{idProduct}==\"000f\", MODE=\"666\""
echo "  ATTRS{idVendor}==\"03fd\", ATTRS{idProduct}==\"0013\", MODE=\"666\""
echo "  ATTRS{idVendor}==\"03fd\", ATTRS{idProduct}==\"0015\", MODE=\"666\""
echo "  ATTRS{idVendor}==\"0403\", ATTRS{idProduct}==\"6010\", MODE=\"666\""
echo "  ATTRS{idVendor}==\"0403\", ATTRS{idProduct}==\"6014\", MODE=\"666\""
echo "';"
echo "------------------------------------------------------------"

echo "=== Шаг 5: Инструкция по фиксации tcl-зависимостей ==="
echo "После того как графический установщик завершит работу, зайдите в папку"
echo "$DISTR_DIR, запустите 'nix-shell vivado.nix' и выполните команды привязки ncurses:"
echo "ln -sf /usr/lib64/libncursesw.so.5 $VIVADO_DIR/2026.1.1/Vivado/lib/lnx64.o/libncurses.so.5"
echo "ln -sf /usr/lib64/libncursesw.so.5 $VIVADO_DIR/2026.1.1/Vivado/lib/lnx64.o/libtinfo.so.5"
echo "ln -sf $VIVADO_DIR/2026.1.1/Vivado/lib/lnx64.o/libtinfo.so.5 $VIVADO_DIR/2026.1.1/Vivado/lib/lnx64.o/libtinfo.so.6"
echo "------------------------------------------------------------"

echo "Подготовка завершена! Для запуска графического установщика введите:"
echo "cd $DISTR_DIR && nix-shell shell.nix"
echo "А затем внутри шелла выполните: ./xsetup"

