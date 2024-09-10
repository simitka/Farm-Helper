#!/bin/zsh

# Проверка наличия файла settings.conf
if [[ ! -f settings.conf ]]; then
    echo "Что-то пошло не так. Скачай актуальный firststart.sh скрипт по ссылке https://farm.simitka.io/farmjam-helper-installer"
    exit 1
fi

# Установка переменной для хранения пути к Github репозиторию и URL для скачивания
REPO_URL="https://github.com/Simitka/FarmJam-Helper"
RELEASES_URL="https://github.com/Simitka/FarmJam-Helper/releases/latest"
ARCHIVE_NAME="farmjam-helper-latest.tar.gz"

# Генерация уникального параметра для URL
UNIQUE_PARAM=$(date +%s)

# Скачивание URL страницы с последним релизом
LATEST_RELEASE=$(curl -sL "$RELEASES_URL" | grep -oE 'href="[^"]*"' | grep -Eo 'href="[^"]*"' | head -1 | sed 's/href="//' | sed 's/"//')

# Проверка на наличие ссылки на архив
if [[ -z "$LATEST_RELEASE" ]]; then
    echo "Не удалось найти последний релиз."
    exit 1
fi

# Формирование уникальной ссылки для скачивания
DOWNLOAD_URL="${LATEST_RELEASE}?t=${UNIQUE_PARAM}"

# Скачивание архива
echo "Скачиваю архив с последним релизом: $DOWNLOAD_URL"
curl -LO "$DOWNLOAD_URL"

# Распаковка архива
echo "Распаковываю архив..."
tar -xzvf "$ARCHIVE_NAME" -C .

# Запуск скрипта update.sh
if [[ -f update.sh ]]; then
    echo "Запускаю update.sh..."
    chmod +x update.sh
    ./update.sh
else
    echo "Файл update.sh не найден."
    exit 1
fi
