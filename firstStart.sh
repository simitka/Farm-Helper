#!/bin/bash

# 1. Чистим консоль
clear

# 2. Выводим текст
echo "Первый запуск \033[1mFarmJam Helper\033[0m."
echo "Запускаю помощник по настройке"
echo
echo "Проверяю что все нужные пакеты установлены:"

# 3. Проверяем наличие пакетов
check_package() {
    command -v "$1" >/dev/null 2>&1
}

install_homebrew() {
    echo "Homebrew не установлен. Для установки выполните:"
    echo "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
}

install_adb() {
    echo "adb не установлен. Для установки выполните:"
    echo "brew install android-platform-tools"
    echo "Чтобы adb был доступен из любого каталога, добавьте путь к adb в переменную PATH."
    echo "Выполните следующие команды для добавления пути в PATH:"
    echo "1. Откройте файл ~/.zshrc в текстовом редакторе:"
    echo "   nano ~/.zshrc"
    echo "2. Добавьте следующую строку в конец файла:"
    echo "   export PATH=\"$(brew --prefix android-platform-tools)/bin:\$PATH\""
    echo "3. Сохраните изменения и закройте редактор (Ctrl+X, затем Y, затем Enter)."
    echo "4. Примените изменения командой:"
    echo "   source ~/.zshrc"
}

install_dotnet_sdk() {
    echo "Для установки .NET SDK выполните:"
    echo "brew install --cask dotnet-sdk"
}

install_jq() {
    echo "jq не установлен. Для установки выполните:"
    echo "brew install jq"
}

if ! check_package brew; then
    install_homebrew
fi

if ! check_package adb; then
    install_adb
fi

if ! check_package dotnet; then
    install_dotnet_sdk
fi

if ! check_package jq; then
    install_jq
fi

# 5. Запрашиваем путь к папке
echo
echo "Введи путь к папке, куда будут скачены нужные bash скрипты"
echo "(если оставить пустым и нажать Enter, установка произойдет в $HOME/Documents/farmx):"

# 6. Определяем путь и создаем папку
default_path="$HOME/Documents/farmx"
read -r user_path

if [[ -z "$user_path" ]]; then
    actual_path="$default_path"
else
    actual_path="$user_path"
fi

mkdir -p "$actual_path"

# 7. Переходим в созданную папку
cd "$actual_path" || { echo "Не удалось перейти в папку $actual_path"; exit 1; }

# 8. Скачиваем файл
curl -O https://raw.githubusercontent.com/Simitka/Farm-Helper/main/start.sh

# 9. Создаем settings.conf
cat <<EOF > settings.conf
actualPath:$actual_path
lastUpdateCheck:0000-01-01T00:00:00
actualTagVersion:0.0
EOF

# 10. Запускаем start.sh
chmod +x start.sh
./start.sh
