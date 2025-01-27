#!/bin/zsh

# Функция для вывода сообщения и выполнения команды farmx
function finalize() {
    echo
    echo "Чтобы продолжить, нажмите любую кнопку..."
    stty -icanon
    dd bs=1 count=1 >/dev/null 2>&1
    stty icanon
    farmx
}

# Проверка количества аргументов
if [ "$#" -gt 2 ]; then
    echo "❌ Ошибка: Нужно выбрать только 1 устройство"
    finalize
    exit 1
fi

# Проверка наличия аргументов
if [ "$#" -eq 0 ]; then
    echo "❌ Ошибка: в аргументе должно быть передано название устройства из ADB (сообщите разработчику скрипта)"
    finalize
    exit 1
fi

# Записываем названия девайса из аргументов в переменную
device=$2

# Спрашиваем путь для сохранения файла (только папку)
echo "📝 Введите путь к папке для сохранения логов с устройства $device:"
echo "\033[3mИли нажмите Enter↵ чтобы сохранить в папку ~/Downloads\033[0m"
read -r user_dir

# Устанавливаем путь по умолчанию, если пользователь ничего не ввел
if [[ -z "$user_dir" ]]; then
    user_dir=~/Downloads
    echo "📂Использую путь по умолчанию: $user_dir"
else
    echo "📂Использую пользовательский путь: $user_dir"
fi

# Разворачиваем путь с ~ в полный путь
user_dir=$(eval echo "$user_dir")

# Создаем папку, если она не существует
mkdir -p "$user_dir"

# Преобразуем путь в абсолютный
user_dir=$(realpath "$user_dir")

# Формируем полный путь к файлу с добавлением имени устройства
file_name="logs_$device.txt"
user_path="${user_dir%/}/$file_name" # Убираем возможный слеш в конце пути

# Запускаем adb logcat и записываем логи в файл
echo "⏳ Отчищаю logcat логи на девайсе $device..."
adb -s "$device" logcat -c
echo "✅ Начинаю запись логов в файл $user_path..."
echo "\033[1mЧтобы остановить запись нажмите Control⌃ + C\033[0m"
adb -s "$device" logcat >"${user_path}"

finalize
exit 0
