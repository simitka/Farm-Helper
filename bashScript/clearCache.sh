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

# Проверка наличия аргументов
if [ "$#" -eq 0 ]; then
  echo "Ошибка: в аргументе должно быть передано название устройства из ADB"
  finalize
  exit 1
fi

# Очистка кэша для каждого устройства, переданного в аргументах
for device in "$@"; do
  echo "Очищаем кэш приложения farm.parking.game для устройства $device..."
  adb -s "$device" shell pm clear farm.parking.game
done

echo "Очистка кэша приложения завершена."
finalize
exit 0
