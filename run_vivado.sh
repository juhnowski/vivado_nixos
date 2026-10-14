#!/usr/bin/env bash
# File: /home/ilya/vivado_distr/run_vivado.sh

# Скрипт автоматического запуска Xilinx Vivado в среде NixOS FHS
# Автор: Илья

set -e

# --- КОНФИГУРАЦИЯ ---
VIVADO_FHS_DIR="/home/ilya/vivado_distr"
VIVADO_LIB_DIR="/home/ilya/Xilinx/2026.1.1/Vivado/lib/lnx64.o"

echo "=== Проверка окружения Vivado ==="

# 1. Проверяем, существует ли файл конфигурации оболочки
if [ ! -f "$VIVADO_FHS_DIR/vivado.nix" ]; then
    echo "Ошибка: Конфигурационный файл $VIVADO_FHS_DIR/vivado.nix не найден!"
    exit 1
fi

# 2. Проверяем и при необходимости восстанавливаем символические ссылки для Tcl/ncurses
# Это защитит от сбоев, если папка Xilinx или Nix-хранилище обновятся
if [ -d "$VIVADO_LIB_DIR" ]; then
    echo "Проверка совместимости библиотек (ncurses/tinfo)..."
    
    # Ссылка на libncurses.so.5
    if [ ! -L "$VIVADO_LIB_DIR/libncurses.so.5" ]; then
        ln -sf /usr/lib64/libncursesw.so.5 "$VIVADO_LIB_DIR/libncurses.so.5"
        echo " Восстановлена ссылка на libncurses.so.5"
    fi
    
    # Ссылка на libtinfo.so.5
    if [ ! -L "$VIVADO_LIB_DIR/libtinfo.so.5" ]; then
        ln -sf /usr/lib64/libncursesw.so.5 "$VIVADO_LIB_DIR/libtinfo.so.5"
        echo " Восстановлена ссылка на libtinfo.so.5"
    fi
    
    # Ссылка на libtinfo.so.6
    if [ ! -L "$VIVADO_LIB_DIR/libtinfo.so.6" ]; then
        ln -sf "$VIVADO_LIB_DIR/libtinfo.so.5" "$VIVADO_LIB_DIR/libtinfo.so.6"
        echo " Восстановлена ссылка на libtinfo.so.6"
    fi
else
    echo "Внимание: Родная папка библиотек Vivado не найдена по пути $VIVADO_LIB_DIR."
    echo "Убедитесь, что путь установки указан верно."
fi

echo "Запуск оболочки Nix FHS и инициализация Vivado..."
echo "---------------------------------------------------"

# 3. Переходим в рабочую папку и запускаем Vivado напрямую внутри изолированного окружения
cd "$VIVADO_FHS_DIR"
nix-shell vivado.nix --run "vivado"

