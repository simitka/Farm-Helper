#!/bin/zsh

# Очистка консоли
clear

# Получение информации о последнем релизе из GitHub
echo "Получение информации о последнем релизе..."
release_info=$(curl -s https://api.github.com/repos/Simitka/FarmJam-Helper/releases)

# Извлечение URL для последнего релиза и тега
latest_release_url=$(echo "$release_info" | grep -o '"tarball_url": *"[^"]*' | head -1 | sed 's/"tarball_url": *"//')
tag_name=$(echo "$release_info" | grep -o '"tag_name": *"[^"]*' | head -1 | sed 's/"tag_name": *"//')

# Проверка на успешность получения URL и тега
if [[ -z "$latest_release_url" || -z "$tag_name" ]]; then
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

# Распаковка архива в корень текущей директории
echo "Распаковка архива..."
tar -xzf latest_release.tar.gz --strip-components=1

# Проверка успешности распаковки
if [[ $? -ne 0 ]]; then
    echo "Ошибка при распаковке архива."
    exit 1
fi

# Удаление архива
echo "Удаление архива..."
if [[ -f latest_release.tar.gz ]]; then
    rm latest_release.tar.gz
    echo "Архив latest_release.tar.gz удален."
else
    echo "Архив latest_release.tar.gz не найден."
fi

# Обновление файла settings.conf
echo "Обновление файла settings.conf..."
settings_file="settings.conf"
if [[ -f $settings_file ]]; then
    # Обновление существующего параметра
    if grep -q "^tagVersion=" $settings_file; then
        # Обновление параметра
        sed -i '' "s/^tagVersion=.*/tagVersion=$tag_name/" $settings_file
        if [[ $? -ne 0 ]]; then
            echo "Ошибка при обновлении параметра tagVersion в $settings_file."
            exit 1
        fi
    else
        # Добавление нового параметра
        echo "tagVersion=$tag_name" >> $settings_file
        if [[ $? -ne 0 ]]; then
            echo "Ошибка при добавлении параметра tagVersion в $settings_file."
            exit 1
        fi
    fi
else
    # Создание нового файла и добавление параметра
    echo "tagVersion=$tag_name" > $settings_file
    if [[ $? -ne 0 ]]; then
        echo "Ошибка при создании файла $settings_file."
        exit 1
    fi
fi

# Ожидание нажатия кнопки перед запуском update.sh
echo "Для продолжения нажми любую кнопку..."
read -n1 -s

# Переход в папку с bash скриптами
cd bashScript

# Запуск скрипта menu.sh
if [[ -f menu.sh ]]; then
    echo "Запуск скрипта menu.sh..."
    ./menu.sh
else
    echo "Скрипт menu.sh не найден."
    exit 1
fi

