#!/bin/zsh

# Путь к файлу settings.conf
settings_file="$HOME/Documents/farmx/settings.conf"

# Функция для получения текущей даты и времени в формате ISO 8601
get_current_datetime() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# Функция для получения даты и времени из файла settings.conf
get_last_update() {
    grep '^lastUpdate:' "$settings_file" | cut -d':' -f2 | xargs
}

# Создание файла settings.conf, если его нет
if [[ ! -f "$settings_file" ]]; then
    echo "Файл settings.conf не найден. Создаем..."
    echo "lastUpdate:0000-01-01T00:00:00" > "$settings_file"
fi

# Получение последнего обновления
last_update=$(get_last_update)

# Получение текущего времени
current_time=$(get_current_datetime)

# Проверка, если lastUpdate отсутствует или имеет некорректное значение
if [[ -z "$last_update" || "$last_update" == "0000-01-01T00:00:00" ]]; then
    echo "lastUpdate не найден или имеет некорректное значение. Устанавливаем начальное значение..."
    last_update="0000-01-01T00:00:00"
fi

# Конвертация даты и времени в секунды с начала эпохи Unix для сравнения
last_update_seconds=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$last_update" "+%s")
current_time_seconds=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$current_time" "+%s")

# Проверка, прошло ли больше 24 часов с последнего обновления
let elapsed_time_seconds=current_time_seconds-last_update_seconds
let one_day_seconds=24*60*60

if [[ $elapsed_time_seconds -gt $one_day_seconds ]]; then
    echo "Прошло больше 24 часов с последнего обновления. Запускаем updateProject.sh..."
    echo "Для продолжения нажми любую кнопку..."
    read -r -n 1
    ./updateProject.sh
else
    echo "Прошло меньше 24 часов с последнего обновления. Запускаем menu.sh..."
    echo "Для продолжения нажми любую кнопку..."
    read -r -n 1
    ./bashScript/menu.sh
fi

# Обновление значения lastUpdate в settings.conf
echo "lastUpdate:$current_time" > "$settings_file"
