#!/bin/zsh

# Подсключаем utils.sh
source ./bashScript/utils.sh

# Очищаем консоль
clear

# Удаляем папку ~/Library/Application Support/Liftapp
echo "⏳ Удаляю папку ~/Library/Application Support/Liftapp"
rm -rf ~/Library/Application\ Support/Liftapp
echo "✅ Кэш farm.parking.game в Unity Editor'е удален"
finalize
exit 0
