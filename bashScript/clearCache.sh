#!/bin/zsh

# Очищаем консоль
clear

# Функция для вывода сообщения и выполнения команды farmx
function finalize() {
  echo "Чтобы продолжить, нажмите любую кнопку..."
  stty -icanon
  dd bs=1 count=1 >/dev/null 2>&1
  stty icanon
  farmx
}

# Получаем список подключенных устройств, исключая пустые строки и строки "unauthorized", "offline" и т.д.
devices=($(adb devices | awk 'NR>1 && $2=="device" {print $1}'))
device_count=${#devices[@]}

if [[ $device_count -eq 0 ]]; then
  echo "Нет подключенных adb устройств."
  finalize
  exit 1
fi

if [[ $device_count -eq 1 ]]; then
  # Если одно устройство
  device=${devices[1]}
  echo "Очищаем кэш приложения farm.parking.game для устройства $device..."
  adb -s "$device" shell pm clear farm.parking.game
  finalize
  exit 0
fi

# Если несколько устройств
echo "Подключено несколько устройств. Введи номер нужного:"
echo "    [0] Почистить кэш для всех устройств"

for ((i = 0; i < device_count; i++)); do
  echo "    [$((i + 1))] ${devices[i+1]}"
done

echo -n "Введите номер устройства для очистки кэша: "
read device_choice

# Проверка корректности ввода
if ! [[ $device_choice =~ ^[0-9]+$ ]] || [[ $device_choice -lt 0 ]] || [[ $device_choice -gt $device_count ]]; then
  echo
  echo "Некорректный выбор устройства."
  finalize
  exit 1
fi

if [[ $device_choice -eq 0 ]]; then
  # Очистка кэша для всех устройств
  for device in "${devices[@]}"; do
    echo "Очищаем кэш приложения farm.parking.game для устройства $device..."
    adb -s "$device" shell pm clear farm.parking.game
  done
else
  # Получаем выбранное устройство
  selected_device=${devices[$((device_choice))]}
  echo
  echo "Очищаем кэш приложения farm.parking.game для устройства $selected_device..."
  adb -s "$selected_device" shell pm clear farm.parking.game
fi

finalize
exit 0
