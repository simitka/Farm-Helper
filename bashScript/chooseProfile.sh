#!/bin/zsh

# Получение значения actualPath из файла настроек
actual_path=$(grep '^actualPath:' "settings.conf" | cut -d':' -f2 | xargs)

# Путь к директории на устройстве Android
DIRECTORY="/sdcard/Android/data/farm.parking.game/files/profiles"

# Проверка, существует ли директория
if ! adb shell "[ -d $DIRECTORY ]"; then
    echo "Ошибка: Директория $DIRECTORY не существует."
    exit 1
fi

# Получение списка файлов с помощью adb
files=$(adb shell "ls -1 $DIRECTORY | grep '.json$'")

# Проверка, что в директории есть .json файлы
if [[ -z "$files" ]]; then
    echo "Ошибка: В директории $DIRECTORY нет .json файлов."
    exit 1
fi

# Преобразование списка файлов в массив
files_array=(${(f)files})

# Инициализация счетчика
counter=1

# Вывод текста перед перечислением файлов
echo "-------------------------------"
echo "Введи номер профайла, который нужно прочитать"
echo "-------------------------------"

# Вывод списка файлов с нумерацией
for file in $files_array; do
    echo "[$counter] $file"
    counter=$((counter + 1))
done

# Вывод разделителя и приглашения на одной строке
echo "-------------------------------"
printf "Введите номер профайла: "
read -r profile_number

# Проверка, что введенное значение является числом и находится в допустимом диапазоне
if [[ "$profile_number" =~ '^[0-9]+$' ]] && (( profile_number >= 1 && profile_number <= ${#files_array[@]} )); then
    # Получение имени выбранного файла
    selected_file=${files_array[profile_number]}
    
    # Запуск скрипта readProfile.sh с параметром выбранного файла
    echo $selected_file
    ./bashScript/readProfile.sh "$selected_file"
else
    echo "Неверный номер профайла."
    exit 1
fi
