#!/bin/zsh

# Подсключаем utils.sh
source ./bashScript/utils.sh

# Проверка наличия аргументов
if [ "$#" -eq 0 ]; then
    echo "❌ Ошибка: в аргументе должно быть передано название устройства из ADB (сообщите разработчику скрипта)"
    finalize
    exit 1
fi

# Запрос ввода DeepLink
echo -n "📝 Введите DeepLink, которую нужно открыть: "
read deeplink_input
echo

# Перебираем все аргументы
for device in "$@"; do
    # Пропускаем первый аргумент с индексом 0 (там $settings_file)
    if ((index > 0)); then
        echo "⏳ Открываю DeepLink $deeplink_input на устройстве $device..."
        adb -s "$device" shell am start -a android.intent.action.VIEW -d "$deeplink_input" farm.parking.game

    fi
    ((index++))
done

echo "✅ DeepLink открыта"
finalize
exit 0
