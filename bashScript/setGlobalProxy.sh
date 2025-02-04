#!/bin/zsh

# Подсключаем utils.sh
source ./bashScript/utils.sh

clear

function setPortInSettings() {
    if grep -q "^proxyPortNumber:" "$settings_file"; then
        clear
        echo "Настройка порта для Proxy"
        dim_text "При подключении устройства к снифферу трафика (например Proxyman) вы указываете ip:port в настройках WiFi на устройстве. Ниже нужно выбрать тот порт, который вы указывали"
        echo
        bold_text "$(reverse_text 'Укажите порт, который используется для подключения снифферу трафика:')"
        echo "    [1] ip:9090 (стандартный порт для Proxyman)"
        echo "    [2] ip:8888 (стандартный порт для Charles)"
        echo -n "📝 Введите цифру из списка выше или кастомное значение порта: "
        read choice

        case $choice in
        1)
            port=9090
            echo "Вы выбрали Proxyman. Используем порт $port."
            ;;
        2)
            port=8080
            echo "Вы выбрали Charles. Используем порт $port."
            ;;
        # Проверка на четырехзначное число
        [0-9][0-9][0-9][0-9])
            port=$choice
            echo "Вы указали кастомный порт: $port"
            ;;
        *)
            echo "❌ Некорректный ввод. Введите число из списка или кастомный порт (например 9876)"
            exit 1
            ;;
        esac

        # Запись порта в файл
        sed -i '' "s/^proxyPortNumber:.*/proxyPortNumber:$port/" "$settings_file"

        # Сброс глобальных настроек Proxy
        adb shell settings put global http_proxy :0
    else
        echo "❌ Ошибка: В файле $settings_file нет переменной proxyPortNumber"
        exit 1
    fi
}

# Проверка наличия аргументов
if [ "$#" -eq 0 ]; then
    echo "❌ Ошибка: в аргументе должно быть передано название устройства из ADB (сообщите разработчику скрипта)"
    finalize
    exit 1
fi

# Определяем файл настроек
settings_file="settings.conf"

# Проверяем существование файла настроек
if [[ ! -f $settings_file ]]; then
    echo "❌ Ошибка: Файл $settings_file не найден"
    exit 1
fi

# Проверка на то, что в файле settings_file есть переменная proxyPortNumber
if ! grep -q "^proxyPortNumber:" "$settings_file"; then
    echo "proxyPortNumber:" >>"$settings_file"
    setPortInSettings
elif grep -q "^proxyPortNumber:[[:space:]]*$" "$settings_file"; then
    setPortInSettings
fi

# Читаем значение только если строка существует
proxy_port_number=$(grep '^proxyPortNumber:' "$settings_file" | cut -d':' -f2- | tr -d ' ')
status_proxy=$(adb shell settings get global http_proxy)
if [[ "$status_proxy" == ":0" ]]; then
    switcher_state="false"
else
    switcher_state="true"
fi
clear
echo "Текущие состояние Global Proxy на устройстве $2:"
if [[ "$switcher_state" == "true" ]]; then
    bold_text "$(green_text 'Прокси включен') | $(dim_text $status_proxy)"
else
    bold_text "$(red_text 'Прокси выключен')"
fi
echo
bold_text "$(reverse_text 'Выберите нужную функцию и введите соответствующую цифру:')"
echo "    [1] $([[ "$switcher_state" == true ]] && red_text 'Выключить' || green_text 'Включить') прокси"
echo "    [2] Изменить :порт"
echo "    [3] Выйти в Меню"
echo -n "📝 Введите цифру: "
read choice

case $choice in
1)
    if [[ "$switcher_state" == "false" ]]; then
        adb shell settings put global http_proxy $(ipconfig getifaddr en0):$proxy_port_number
    else
        adb shell settings put global http_proxy :0
    fi
    finalize
    ;;
2)
    setPortInSettings
    finalize
    ;;
3)
    farmx
    ;;
*)
    echo "❌ Некорректный ввод. Введите число из списка или кастомный порт (например 9876)"
    exit 1
    ;;
esac
