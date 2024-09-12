#!/bin/zsh

# Путь к файлу settings.conf в текущей папке
settings_file="./settings.conf"

# Функция для получения текущей даты и времени в формате ISO 8601
get_current_datetime() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# Функция для получения значения из settings.conf по ключу
get_value_from_settings() {
    local key=$1
    grep "^$key:" "$settings_file" | cut -d':' -f2 | xargs
}

# Получение пути к текущей директории
current_directory=$(pwd)

# Создание файла settings.conf, если его нет
if [[ ! -f "$settings_file" ]]; then
    echo "Файл settings.conf не найден. Создаем..."
    echo "lastUpdateCheck:0000-01-01T00:00:00" > "$settings_file"
    echo "tagVersion:0.0" >> "$settings_file"
    echo "actual_path:$current_directory" >> "$settings_file"
fi

# Получение значения tagVersion из settings.conf
tag_version=$(get_value_from_settings "tagVersion")

# Проверка и установка значения tagVersion, если его нет
if [[ -z "$tag_version" ]]; then
    echo "tagVersion не найден. Устанавливаем начальное значение..."
    tag_version="0.0"
    echo "tagVersion:$tag_version" >> "$settings_file"
fi

# Функция для получения тега последнего релиза или пререлиза
get_latest_tag() {
    local release_url="https://api.github.com/repos/Simitka/Farm-Helper/releases/latest"
    local prerelease_url="https://api.github.com/repos/Simitka/Farm-Helper/releases?per_page=100"
    
    # Получение последнего релиза
    latest_release_tag=$(curl -s "$release_url" | jq -r '.tag_name // empty')
    
    # Получение пререлизов и выбор самого нового
    latest_prerelease_tag=$(curl -s "$prerelease_url" | jq -r '.[] | select(.prerelease == true) | .tag_name' | sort -V | tail -n 1)
    
    # Сравнение тега релиза и пререлиза
    if [[ -n "$latest_prerelease_tag" && ( -z "$latest_release_tag" || "$latest_prerelease_tag" > "$latest_release_tag" ) ]]; then
        echo "$latest_prerelease_tag"
    else
        echo "$latest_release_tag"
    fi
}

# Получение тега последнего релиза или пререлиза
latest_tag=$(get_latest_tag)

# Сравнение тегов и выполнение соответствующего скрипта
if [[ "$latest_tag" == "$tag_version" || "$latest_tag" < "$tag_version" ]]; then
    echo "Тег в файле больше или равен тегу последнего релиза/пререлиза. Запускаем menu.sh..."
    echo "Для продолжения нажми любую кнопку..."
    read -r -n 1
    ./bashScript/menu.sh
else
    echo "Тег в файле меньше тега последнего релиза/пререлиза. Запускаем updateProject.sh..."
    echo "Для продолжения нажми любую кнопку..."
    read -r -n 1
    ./updateProject.sh
fi
