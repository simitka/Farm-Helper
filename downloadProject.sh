#!/bin/zsh

# Проверка наличия файла settings.conf
if [[ ! -f settings.conf ]]; then
    echo "Что-то пошло не так. Скачай актуальный firststart.sh скрипт по ссылке https://farm.simitka.io/farmjam-helper-installer"
    exit 1
fi

# Установка переменных
REPO_OWNER="Simitka"
REPO_NAME="FarmJam-Helper"
API_URL="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/latest"
ARCHIVE_NAME="farmjam-helper-latest.tar.gz"

# Генерация уникального параметра для URL
UNIQUE_PARAM=$(date +%s)

# Получение информации о последнем релизе с помощью GitHub API
RELEASE_INFO=$(curl -sL "$API_URL")

# Извлечение ссылки на архив последнего релиза
DOWNLOAD_URL=$(echo "$RELEASE_INFO" | grep -oE '"browser_download_url": "[^"]*"' | grep -Eo '"browser_download_url": "[^"]*"' | grep -Eo '"[^"]*"' | sed 's/"//g' | grep 'tar.gz' | head -1)

# Проверка на наличие ссылки на архив
if [[ -z "$DOWNLOAD_URL" ]]; then
    echo "Не удалось найти последний релиз."
    exit 1
fi

# Формирование уникальной ссылки для скачивания
DOWNLOAD_URL="${DOWNLOAD_URL}?t=${UNIQUE_PARAM}"

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
