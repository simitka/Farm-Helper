#!/bin/zsh

# Очистка консоли
clear

# Вывод текста
echo "\033[1mПервый запуск \033[4mFarm Helper\033[0m"
echo "вопросы – https://simitka.io"
echo
echo "Запускаю помощник по настройке."
echo "Проверяю что все нужные пакеты установлены"
echo "============================================================"

# Функция проверки и установки пакетов
check_and_install() {
    local package_number="$1"
    local package="$2"
    local install_command="$3"
    local version_command="$4"
    
    if ! command -v "$package" &> /dev/null; then
        echo "Ошибка: $package не установлен."
        echo "Для установки $package используйте команду:"
        echo "$install_command"
        exit 1
    else
        echo "[$package_number] $package установлен: $(eval $version_command)"
    fi
}

# Проверка установленных пакетов
check_and_install "*" "brew" "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"" "brew --version"
check_and_install "*" "dotnet" "brew install --cask dotnet-sdk" "dotnet --version"
check_and_install "*" "jq" "brew install jq" "jq --version"
check_and_install "*" "adb" "brew install android-platform-tools" "adb --version"

# Запрос пути к папке для скачивания файлов
echo "============================================================"
echo
echo
echo "\033[1mВведи путь к папке, куда будет установлен Farm Helper:\033[0m"
echo "(оставь пустым и нажми Enter, чтобы установить в $HOME/Documents/farmx)"

# Установка пути по умолчанию
default_path="$HOME/Documents/farmx"
read -r user_path

# Определение фактического пути
if [[ -z "$user_path" ]]; then
    actual_path="$default_path"
else
    actual_path="$user_path"
fi

# Создание папки
mkdir -p "$actual_path"
cd "$actual_path" || exit

# Скачивание файла start.sh
curl -O https://raw.githubusercontent.com/Simitka/Farm-Helper/main/start.sh

# Создание файла settings.conf
cat <<EOL > settings.conf
actualPath:$actual_path
lastUpdateCheck:0
actualTagVersion:0.0
EOL

# Создание консольной команды farmx
echo
echo
echo "\033[1mСоздаю консольную команду 'farmx', которая будет запускать Farm Helper\033[0m"
echo "(введи пароль своего пользователя MacOS. При вводе пароль не отображается)"

# Проверка и создание директории /usr/local/bin, если необходимо
if [[ ! -d "/usr/local/bin" ]]; then
    echo "Директория /usr/local/bin не существует. Создаю её..."
    sudo mkdir -p /usr/local/bin
fi

# Создание скрипта для запуска start.sh из любого каталога
temp_script="$HOME/farmx_temp"
echo '#!/bin/zsh' > "$temp_script"
echo "cd $actual_path && ./start.sh" >> "$temp_script"
chmod +x "$temp_script"

# Перемещение скрипта в /usr/local/bin и установка прав
sudo mv "$temp_script" /usr/local/bin/farmx
sudo chmod +x /usr/local/bin/farmx

# Запуск скрипта start.sh
chmod +x start.sh
farmx
