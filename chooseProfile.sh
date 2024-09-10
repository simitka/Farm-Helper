#!/bin/zsh

# Путь к директории на устройстве Android
DIRECTORY="/sdcard/Android/data/farm.parking.game/files/profiles"

# Проверка, существует ли директория
if ! adb shell ls $DIRECTORY >/dev/null 2>&1; then
    echo "Ошибка: Директория $DIRECTORY не существует."
    exit 1
fi

# Получение списка файлов с помощью adb
files=$(adb shell ls -1 $DIRECTORY | grep '.json$')

# Проверка, что в директории есть .json файлы
if [[ -z "$files" ]]; then
    echo "Ошибка: В директории $DIRECTORY нет .json файлов."
    exit 1
fi

# Инициализация счетчика
counter=1

# Вывод текста перед перечислением файлов
echo "-------------------------------"
echo "Введи номер профайла, который нужно прочитать"
echo "-------------------------------"

# Вывод списка файлов с нумерацией
for file in $files; do
    echo "[$counter] $file"
    counter=$((counter + 1))
done

# Вывод разделителя и приглашения на одной строке
echo "-------------------------------"
printf "Введите номер профайла: "
read -r profile_number

# Проверка, что введенное значение является числом и находится в допустимом диапазоне
if [[ "$profile_number" =~ ^[0-9]+$ ]] && (( profile_number >= 1 && profile_number < counter )); then
    # Получение имени выбранного файла
    selected_file=$(echo "$files" | sed -n "${profile_number}p")
    
    # Запуск скрипта readProfile.sh с параметром выбранного файла
    sh readProfile.sh "$selected_file"
else
    echo "Неверный номер профайла."
fi
