#!/bin/zsh

# Очищаем консоль
clear

# Функция для вывода сообщения и выполнения команды farmx
function finalize() {
    echo
    echo "Чтобы продолжить, нажмите любую кнопку..."
    stty -icanon
    dd bs=1 count=1 >/dev/null 2>&1
    stty icanon
    farmx
}

# Удаляем папку ~/Library/Application Support/Liftapp
echo "⏳ Удаляю папку ~/Library/Application Support/Liftapp"
rm -rf ~/Library/Application\ Support/Liftapp
echo "✅ Кэш farm.parking.game в Unity Editor'е удален"
finalize
exit 0
