#!/bin/zsh

#Для примера выхова функции в функции – bold_text "$(red_text 'Красный жирный текст')"

# Функция для вывода текста жирным
bold_text() {
    echo "$(tput bold)$1$(tput sgr0)"
}

# Функция для вывода тусклого текста
dim_text() {
    echo "$(tput dim)$1$(tput sgr0)"
}

# Функция для вывода подчеркнутого текста
underline_text() {
    echo "$(tput smul)$1$(tput sgr0)"
}

# Функция для инверсии цветов (фон ↔ текст)
reverse_text() {
    echo "$(tput rev)$1$(tput sgr0)"
}

# Функция для мигающего текста (не всегда работает)
blink_text() {
    echo "$(tput blink)$1$(tput sgr0)"
}

# Функция для невидимого текста (его можно скопировать и вставить)
invisible_text() {
    echo "$(tput invis)$1$(tput sgr0)"
}

#
#
#

# Функция для вывода текста красным цветом
red_text() {
    echo "$(tput setaf 1)$1$(tput sgr0)"
}

# Функция для вывода текста зеленым цветом
green_text() {
    echo "$(tput setaf 2)$1$(tput sgr0)"
}

# Функция для вывода текста желтым цветом
yellow_text() {
    echo "$(tput setaf 3)$1$(tput sgr0)"
}

# Функция для вывода текста синим цветом
blue_text() {
    echo "$(tput setaf 4)$1$(tput sgr0)"
}

# Функция для вывода текста пурпурным (фиолетовым) цветом
magenta_text() {
    echo "$(tput setaf 5)$1$(tput sgr0)"
}

# Функция для вывода текста бирюзовым (циановым) цветом
cyan_text() {
    echo "$(tput setaf 6)$1$(tput sgr0)"
}

# Функция для вывода текста белым цветом
white_text() {
    echo "$(tput setaf 7)$1$(tput sgr0)"
}

# Функция для вывода текста черным цветом (может быть невидимым в темных темах)
black_text() {
    echo "$(tput setaf 0)$1$(tput sgr0)"
}

#
#
#

# Функция для чёрного фона
black_bg() {
    echo "$(tput setab 0)$1$(tput sgr0)"
}

# Функция для красного фона
red_bg() {
    echo "$(tput setab 1)$1$(tput sgr0)"
}

# Функция для зелёного фона
green_bg() {
    echo "$(tput setab 2)$1$(tput sgr0)"
}

# Функция для жёлтого фона
yellow_bg() {
    echo "$(tput setab 3)$1$(tput sgr0)"
}

# Функция для синего фона
blue_bg() {
    echo "$(tput setab 4)$1$(tput sgr0)"
}

# Функция для пурпурного (фиолетового) фона
magenta_bg() {
    echo "$(tput setab 5)$1$(tput sgr0)"
}

# Функция для голубого (цианового) фона
cyan_bg() {
    echo "$(tput setab 6)$1$(tput sgr0)"
}

# Функция для белого фона
white_bg() {
    echo "$(tput setab 7)$1$(tput sgr0)"
}

#
#
#

# Функция для вывода сообщения и выполнения команды farmx
function finalize() {
    echo
    echo "Чтобы продолжить, нажмите любую кнопку..."
    stty -icanon
    dd bs=1 count=1 >/dev/null 2>&1
    stty icanon
    farmx
}

function choose_adb() {
    local script_name="$1"

    # Очищаем консоль
    clear

    # Получаем список подключенных устройств, исключая пустые строки и строки "unauthorized", "offline" и т.д.
    devices=($(adb devices | awk 'NR>1 && $2=="device" {print $1}'))
    device_count=${#devices[@]}

    if [[ $device_count -eq 0 ]]; then
        echo "❌ Ошибка: Нет подключенных к ADB устройств."
        finalize
        exit 1
    fi

    # Если одно устройство
    if [[ $device_count -eq 1 ]]; then
        device=${devices[1]}
        eval $script_name "$settings_file" "$device"
        exit 0
    fi

    # Если несколько устройств
    echo "-------------------------------"
    echo "К adb подключено несколько устройств"
    echo "-------------------------------"
    echo "    [0] Применить команду для всех устройст из списка ниже"

    for ((i = 0; i < device_count; i++)); do
        echo "    [$((i + 1))] ${devices[i + 1]}"
    done

    echo -n "📝 Введите номер устройства из списка выше: "
    read device_choice
    echo

    # Проверка корректности ввода
    if ! [[ $device_choice =~ ^[0-9]+$ ]] || [[ $device_choice -lt 0 ]] || [[ $device_choice -gt $device_count ]]; then
        echo "❌ Ошибка: Некорректный выбор устройства"
        finalize
        exit 1
    fi

    if [[ $device_choice -eq 0 ]]; then
        # Очистка кэша для всех устройств
        for device in "${devices[@]}"; do
            eval $script_name "$settings_file" "$devices"
        done
    else
        # Получаем выбранное устройство
        selected_device=${devices[$((device_choice))]}
        eval $script_name "$settings_file" "$selected_device"
    fi

    finalize
    exit 0
}
