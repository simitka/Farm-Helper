#!/bin/zsh

# Подсключаем utils.sh
source ./bashScript/utils.sh

# Проверка наличия аргументов
if [ "$#" -eq 0 ]; then
    echo "❌ Ошибка: в аргументе должно быть передано название устройства из ADB (сообщите разработчику скрипта)"
    finalize
    exit 1
fi

# Перебираем все аргументы
index=0
for device in "$@"; do
    # Пропускаем первый аргумент с индексом 0 (там $settings_file)
    if ((index > 0)); then

        # Спрашиваем путь для сохранения файла (только папку)
        echo "📝 Введите путь к папке для сохранения логов с устройства $device:"
        echo "\033[3mИли нажмите Enter↵ чтобы сохранить в папку ~/Downloads\033[0m"
        read -r user_dir

        # Устанавливаем путь по умолчанию, если пользователь ничего не ввел
        if [[ -z "$user_dir" ]]; then
            user_dir=~/Downloads
            echo "📂 Использую путь по умолчанию: $user_dir"
        else
            echo "📂 Использую пользовательский путь: $user_dir"
        fi

        # Разворачиваем путь с ~ в полный путь
        user_dir=$(eval echo "$user_dir")

        # Создаем папку, если она не существует
        mkdir -p "$user_dir"

        # Преобразуем путь в абсолютный
        user_dir=$(realpath "$user_dir")

        # Формируем полный путь к файлу с добавлением имени устройства
        file_name="dumpLogs_$(basename "$device").txt"
        user_path="${user_dir%/}/$file_name" # Убираем возможный слеш в конце пути

        # Функция для скачивания дампа логов
        echo "⏳ Скачиваю логи с устройства $device..."
        # Запускаем adb logcat и сохраняем в файл
        adb -s "$device" logcat -d >"${user_path}" && echo "✅ Логи успешно сохранены в: ${user_path}" || echo "❌ Ошибка: Не удалось скачать логи"
        echo

    fi
    ((index++))
done

finalize
exit 0
