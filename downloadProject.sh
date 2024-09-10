#!/bin/zsh

# Проверка наличия файла settings.conf
if [[ ! -f settings.conf ]]; then
    echo "Что-то пошло не так. Скачай актуальный firststart.sh скрипт по ссылке https://farm.simitka.io/farmjam-helper-installer"
    exit 1
fi

# Получение информации о последнем релизе из GitHub
echo "Получение информации о последнем релизе..."
latest_release_url=$(curl -s https://api.github.com/repos/Simitka/FarmJam-Helper/releases/latest | jq -r '.tarball_url')

# Проверка на успешное получение URL
if [[ -z "$latest_release_url" ]]; then
    echo "Не удалось получить информацию о последнем релизе. Попробуй позже."
    exit 1
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

# Распаковка архива
echo "Распаковка архива..."
tar -xzf latest_release.tar.gz

# Проверка успешности распаковки
if [[ $? -ne 0 ]]; then
    echo "Ошибка при распаковке архива."
    exit 1
fi

# Удаление архива
rm latest_release.tar.gz

# Запуск скрипта update.sh
if [[ -f update.sh ]]; then
    echo "Запуск скрипта update.sh..."
    ./update.sh
else
    echo "Скрипт update.sh не найден."
    exit 1
fi
