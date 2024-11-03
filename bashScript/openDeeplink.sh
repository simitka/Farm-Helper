#!/bin/zsh

# Функция для вывода сообщения и выполнения команды farmx
function finalize() {
    echo
    echo "Чтобы продолжить, нажмите любую кнопку..."
    stty -icanon
    dd bs=1 count=1 >/dev/null 2>&1
    stty icanon
    farmx
}

# Проверка наличия аргументов
if [ "$#" -eq 0 ]; then
    echo "Ошибка: в аргументе должно быть передано название устройства из ADB"
    finalize
    exit 1
fi

# Запрос ввода DeepLink
echo -n "Введите DeepLink, которую нужно открыть: "
read deeplink_input
echo

# Перебираем все аргументы
for device in "$@"; do
    # Пропускаем первый аргумент с индексом 0 (там $settings_file)
    if ((index > 0)); then
        echo "Открываем DeepLink $deeplink_input на устройстве $device..."
        adb -s "$device" shell am start -a android.intent.action.VIEW -d "$deeplink_input" farm.parking.game

    fi
    ((index++))
done

echo "DeepLink открыта."
finalize
exit 0
