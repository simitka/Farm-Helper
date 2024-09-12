#!/bin/zsh

# Функция для проверки успешности команды и вывода сообщения об ошибке
check_success() {
    if ! "$1"; then
        echo "Ошибка: не удалось выполнить команду '$2'."
        exit 1
    fi
}

# Функция для вывода текста жирным шрифтом
bold_text() {
  local text="$1"
  echo "\033[1m$text\033[0m"
}

# Очищаем консоль
clear

# Вывод версии
bold_text "FarmJam Helper v1.1"
echo "все вопросы сюда https://simitka.io"
echo ""

# Проверяем, установлен ли brew
if ! command -v brew &> /dev/null; then
    echo "Homebrew не установлен. Устанавливаю Homebrew..."

    # Установка Homebrew
    check_success "/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"" "установка Homebrew"

    echo "Homebrew успешно установлен!"
else
    echo "Homebrew уже установлен."
    echo "-------------------------------"
fi

# Проверяем, установлен ли jq
if ! command -v jq &> /dev/null; then
    echo "jq не установлен. Устанавливаю jq..."

    # Установка jq через Homebrew
    check_success "brew install jq" "установка jq"

    echo "jq успешно установлен!"
else
    echo "jq уже установлен."
    echo "-------------------------------"
fi

# Проверяем, установлен ли .NET SDK
if ! command -v dotnet &> /dev/null; then
    echo ".NET SDK не установлен. Устанавливаю .NET SDK..."

    # Установка .NET SDK через Homebrew
    check_success "brew install --cask dotnet-sdk" "установка .NET SDK"

    echo ".NET SDK успешно установлен!"
else
    echo ".NET SDK уже установлен."
    echo "-------------------------------"
fi

# Проверяем, установлен ли adb
if ! command -v adb &> /dev/null; then
    echo "adb не установлен. Устанавливаю adb..."

    # Установка adb через Homebrew
    check_success "brew install android-platform-tools" "установка adb"

    echo "adb успешно установлен!"
else
    echo "adb уже установлен."
    echo "-------------------------------"
fi

# Добавляем adb в PATH (если требуется)
# Вы можете настроить это в соответствии с вашим окружением
if ! echo $PATH | grep -q "/usr/local/bin"; then
    echo "Добавляю /usr/local/bin в PATH..."
    export PATH="/usr/local/bin:$PATH"
    echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.zshrc
    source ~/.zshrc
fi

# Запуск скрипта menu.sh, если все проверки прошли успешно
if [ -f "./menu.sh" ]; then
#   echo "Запускаю script menu.sh..."
    echo ""
    ./menu.sh
else
    echo "Ошибка: скрипт menu.sh не найден в текущей директории."
    exit 1
fi
