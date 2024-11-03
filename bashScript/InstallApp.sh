#!/bin/zsh

# Включаем опцию nullglob для предотвращения ошибок при отсутствии файлов в папке $target_dir
setopt nullglob

# Функция для вывода сообщения и выполнения команды farmx
function finalize() {
    echo
    echo "Чтобы продолжить, нажмите любую кнопку..."
    stty -icanon
    dd bs=1 count=1 >/dev/null 2>&1
    stty icanon
    farmx
}

# Функция установки приложения через adb для массива устройств
function adbAppInstall() {
    for device in "$@"; do
        # Пропускаем первый аргумент с индексом 0 (там $settings_file)
        if ((index > 0)); then
            echo "Устанавливаем $install_file для устройства $device..."
            adb -s "$device" install "$install_file"
        fi
        ((index++))
    done

    echo "Установка приложения завершена."
    finalize
    exit 0
}

# Проверка наличия переданных аргументов в момент вызова скрипта
if [[ $# -lt 2 ]]; then
    echo "Ошибка: Во время вызова скрипта переданы не все необходимые аргументы"
    exit 1
fi

# Получение пути к файлу настроек из аргумента
settings_file="$1"

# Получение значения actualPath из файла настроек
actual_path=$(grep '^actualPath:' "$settings_file" | cut -d':' -f2 | xargs)

# Проверка, что actual_path не пустой
if [[ -z $actual_path ]]; then
    echo "Ошибка: Значение actualPath не найдено в $settings_file!"
    exit 1
fi

# Очищаем консоль
clear

# Переход в каталог actual_path/farmBuilds
target_dir="$actual_path/farmBuilds"
if [[ ! -d $target_dir ]]; then
    echo "Ошибка: Каталог $target_dir не существует!"
    exit 1
fi
cd "$target_dir"

# Получение списка файлов с расширением .apk и .apks
file_list=(*.apk *.apks)

# Проверка на наличие файлов и вывод в формате [1] файл1
if [[ ${#file_list[@]} -eq 0 ]]; then
    echo "Нет файлов с расширением .apk или .apks в папке $target_dir!"
    echo -n "Добавьте .apk файлы в указанную выше папку, или "
else
    echo "Список .apk файлов в папке $target_dir:"
    for i in {1..${#file_list[@]}}; do
        echo "  [$i] ${file_list[$i]}" # Индексация массива
    done
    echo "Введите цифру, указанную напротив билда который вы хотите установить."
    echo -n "Или "
fi

# Запрос ввода номера билда или пути к .apk файлу
echo -n "введите путь к .apk файлу: "
read user_input
echo

# Проверка, является ли ввод числом и в пределах допустимого диапазона
if [[ "$user_input" =~ ^[0-9]+$ ]] && [[ $user_input -ge 1 && $user_input -le ${#file_list[@]} ]]; then
    # Выполнение команды установки для выбранного файла
    install_file=${file_list[$((user_input))]}
    adbAppInstall "$@"
elif [[ -n $user_input ]]; then
    # Удаление возможных кавычек из начала и конца строки
    user_input=${user_input#\"} # Удалить начальные кавычки
    user_input=${user_input#\'} # Удалить начальные одинарные кавычки
    user_input=${user_input%\"} # Удалить конечные кавычки
    user_input=${user_input%\'} # Удалить конечные одинарные кавычки

    # Проверка, существует ли указанный файл и выполнение команды установки
    if [[ -f $user_input ]]; then
        install_file=$user_input
        adbAppInstall "$@"
    else
        echo "Ошибка: Указанный файл не существует: $user_input"
        exit 1
    fi
else
    echo "Ошибка: Неверный ввод. Убедитесь, что вы ввели номер из списка или корректный путь к .apk файлу."
    exit 1
fi
