#!/bin/zsh

# Очистка консоли
clear

# Вывод текста
echo "Это первый запуск инструмента \033[1mFarmJam Helper\033[0m."
echo "Я помощник по настройке"
echo
echo "Введи путь к папке, куда будут скачены нужные bash скрипты"
echo "(если оставить пустым и нажать Enter, установка произойдет в $HOME/Documents/farmx):"

# Установка пути по умолчанию
default_path="$HOME/Documents/farmx"

# Чтение пути от пользователя
read -r user_path

# Определение фактического пути
if [[ -z "$user_path" ]]; then
    actual_path="$default_path"
else
    actual_path="$user_path"
fi

# Проверка и создание папки
if mkdir -p "$actual_path"; then
    echo "Папка \033[1m$actual_path\033[0m готова!"
    
    # Переход в созданную папку
    cd "$actual_path" || {
        echo "Не удалось перейти в папку \033[1m$actual_path\033[0m."
        exit 1
    }

    # Удаление старого файла, если он существует
    if [[ -f "downloadProject.sh" ]]; then
        rm "downloadProject.sh"
    fi

    # Скачивание файла с добавлением уникального параметра к URL для избежания кэширования
    if curl -L -O "https://raw.githubusercontent.com/Simitka/FarmJam-Helper/main/downloadProject.sh?t=$(date +%s)"; then
        echo "Файл downloadProject.sh успешно скачан."

        # Сделать файл исполняемым
        chmod +x downloadProject.sh

        # Создание файла settings.conf и запись в него параметров
        echo "actual_path:$actual_path" > settings.conf

        # Запрос на продолжение
        echo "Для продолжения нажми любую кнопку..."
        read -rsn1  # Ожидание нажатия любой кнопки

        # Запуск файла
        ./downloadProject.sh        
    else
        echo "Произошла ошибка при скачивании файла downloadProject.sh. Проверьте интернет-соединение и URL."
    fi
else
    echo "Произошла ошибка при создании папки \033[1m$actual_path\033[0m. Проверь указанный путь."
fi
