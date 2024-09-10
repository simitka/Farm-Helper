#!/bin/zsh

# Очистка консоли
clear

# Проверка наличия файла settings.conf
if [[ ! -f settings.conf ]]; then
    echo "Что-то пошло не так. Скачай актуальный firststart.sh скрипт по ссылке https://farm.simitka.io/farmjam-helper-installer"
    exit 1
fi

# Получение списка релизов из GitHub
echo "Получение списка релизов..."
releases=$(curl -s https://api.github.com/repos/Simitka/FarmJam-Helper/releases)

# Поиск последнего релиза или pre-release
latest_release=$(echo "$releases" | jq -r 'sort_by(.published_at) | reverse | .[] | select(.prerelease == false) | .tarball_url' | head -n 1)
latest_pre_release=$(echo "$releases" | jq -r 'sort_by(.published_at) | reverse | .[] | select(.prerelease == true) | .tarball_url' | head -n 1)

# Проверка на успешное получение URL
if [[ -z "$latest_release" && -z "$latest_pre_release" ]]; then
    echo "Не удалось получить информацию о релизах. Попробуй позже."
    exit 1
fi

# Выбор новейшего релиза
if [[ -n "$latest_release" && -n "$latest_pre_release" ]]; then
    latest_release_date=$(curl -s $(echo "$releases" | jq -r --arg url "$latest_release" '.[] | select(.tarball_url == $url) | .published_at'))
    latest_pre_release_date=$(curl -s $(echo "$releases" | jq -r --arg url "$latest_pre_release" '.[] | select(.tarball_url == $url) | .published_at'))

    if [[ "$latest_pre_release_date" > "$latest_release_date" ]]; then
        latest_release_url="$latest_pre_release"
    else
        latest_release_url="$latest_release"
    fi
else
    latest_release_url="$latest_release"
    [[ -z "$latest_release_url" ]] && latest_release_url="$latest_pre_release"
fi

# Добавление уникального тега к ссылке
latest_release_url="${latest_release_url}?t=$(date +%s)"

# Вывод ссылки для отладки
echo "Ссылка для скачивания архива: $latest_release_url"

# Скачивание архива
echo "Скачивание архива последнего релиза..."
curl -L -o latest_release.tar.gz "$latest_release_url"

# Проверка успешности скачивания
if [[ $? -ne 0 ]]; then
    echo "Ошибка при скачивании архива. Попробуй позже."
    exit 1
fi

# Распаковка архива в текущий каталог
echo "Распаковка архива..."
tar -xzf latest_release.tar.gz --strip-components=1

# Проверка успешности распаковки
if [[ $? -ne 0 ]]; then
    echo "Ошибка при распаковке архива."
    exit 1
fi

# Удаление архива
rm latest_release.tar.gz

# Запрос нажатия любой кнопки перед запуском update.sh
echo "Для продолжения нажми любую кнопку..."
read -n 1 -s

# Запуск скрипта update.sh
if [[ -f update.sh ]]; then
    echo "Запуск скрипта update.sh..."
    ./update.sh
else
    echo "Скрипт update.sh не найден."
    exit 1
fi
