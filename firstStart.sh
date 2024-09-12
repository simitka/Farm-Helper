#!/bin/zsh

# Очистка консоли
clear

# Вывод текста
echo "Это первый запуск инструмента \033[1mFarmJam Helper\033[0m."
echo "Я помощник по настройке"
echo
echo "Проверяю что все нужные пакеты установлены"

# Функция для проверки наличия пакета
check_package() {
    local package_name="$1"
    local check_command="$2"
    local install_command="$3"

    if ! command -v "$check_command" &> /dev/null; then
        echo "Пакет \033[1m$package_name\033[0m не установлен! Для установки выполни команду: \033[1m$install_command\033[0m, а после перезапусти скрипт firstStart.sh"
        exit 1
    fi
}

# Функция для проверки доступности команды из любого места
check_command_in_path() {
    local command_name="$1"

    if ! which "$command_name" &> /dev/null; then
        echo "Команда \033[1m$command_name\033[0m не доступна из любого места консоли! Убедитесь, что путь к исполняемому файлу добавлен в переменную окружения PATH. Для исправления добавьте путь к $command_name в PATH."
        exit 1
    fi
}

# Проверка наличия Homebrew
if ! command -v brew &> /dev/null; then
    echo "Пакет Homebrew не установлен! Для установки выполни команду: \033[1m/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"\033[0m, а после перезапусти скрипт firstStart.sh"
    exit 1
fi

# Проверка наличия adb
check_package "adb" "adb" "brew install android-platform-tools"

# Проверка доступности adb из любого места
check_command_in_path "adb"

# Проверка наличия .NET SDK
check_package ".NET SDK" "dotnet" "brew install --cask dotnet-sdk"

# Проверка наличия jq
check_package "jq" "jq" "brew install jq"

echo "Все необходимые пакеты установлены!"

# Запрос пути к папке
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

    # Скачивание файла с добавлением уникального параметра к URL для избежания кэширования
    if curl -L -O "https://raw.githubusercontent.com/Simitka/Farm-Helper/main/updateProject.sh?t=$(date +%s)"; then
        echo "Файл updateProject.sh успешно скачан."

        # Сделать файл исполняемым
        chmod +x updateProject.sh

        # Создание файла settings.conf и запись в него параметров
        echo "actual_path:$actual_path" > settings.conf

        # Запрос на продолжение
        echo "Для продолжения нажми любую кнопку..."
        read -rsn1  # Ожидание нажатия любой кнопки

        # Запуск файла
        ./updateProject.sh        
    else
        echo "Произошла ошибка при скачивании файла updateProject.sh. Проверьте интернет-соединение и URL."
    fi
else
    echo "Произошла ошибка при создании папки \033[1m$actual_path\033[0m. Проверь указанный путь."
fi
