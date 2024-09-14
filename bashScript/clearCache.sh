#!/bin/zsh

# Очищаем консоль
clear

# Функция для вывода сообщения и выполнения команды farmx
function finalize() {
  echo "Чтобы продолжить нажмите любую кнопку..."
  read -n 1
  farmx
  exit $1
}

# Получаем список подключенных устройств
devices=$(adb devices | awk 'NR>1 && $2=="device" {print $1}')
device_count=$(echo "$devices" | wc -l)

if [[ $device_count -eq 0 ]]; then
  echo "Нет подключенных adb устройств."
  finalize 1
fi

if [[ $device_count -eq 1 ]]; then
  # Если одно устройство
  device=$(echo "$devices" | head -n 1)
  echo "Очищаем кэш приложения farm.parking.game для устройства $device..."
  adb -s $device shell pm clear farm.parking.game
  finalize 0
fi

# Если несколько устройств
echo "Подключено несколько устройств. Введи номер нужного:"
i=1
while IFS= read -r device; do
  echo "    [$i] $device"
  ((i++))
done <<< "$devices"

echo -n "Введите номер устройства для очистки кэша: "
read device_choice

# Проверка корректности ввода
if ! [[ $device_choice =~ ^[0-9]+$ ]] || [[ $device_choice -lt 1 ]] || [[ $device_choice -gt $((i-1)) ]]; then
  echo
  echo "Некорректный выбор устройства."
  finalize 1
fi

# Получаем выбранное устройство
selected_device=$(echo "$devices" | sed -n "${device_choice}p")
echo
echo "Очищаем кэш приложения farm.parking.game для устройства $selected_device..."
adb -s $selected_device shell pm clear farm.parking.game
finalize 0
