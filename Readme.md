# Установка
```bash
chmod +x install_vivado_nixos.sh
```

Положите рядом рабочий ISO-образ от 9 июня (Xilinx_Unified_2026_1_1_0904_0832.iso) и запустите скрипт:

```bash
./install_vivado_nixos.sh
```
# Запуск
1. Сделайте скрипт исполняемым:
```bash
chmod +x run_vivado.sh
```
2. Сделайте команду глобальной (по желанию):
Чтобы запускать Vivado из абсолютно любого терминала простым вводом слова vivado, добавьте псевдоним (alias) в настройки вашего пользователя.Если вы используете стандартный Bash, добавьте строку в файл `~/.bashrc`:
```bash
alias vivado='/home/ilya/vivado_distr/run_vivado.sh'
```

# Без скриптов
1. Скопировать с iso в vivado_distr
2. Скопировать nix файлы в vivado_distr
3. Перейти в vivado_distr
4. Выполнить
```bash
nix-shell vivado.nix
vivado
```
