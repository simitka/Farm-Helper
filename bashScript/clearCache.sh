#!/bin/zsh

# Подсключаем utils.sh
source ./bashScript/utils.sh

# Проверка наличия аргументов
if [ "$#" -eq 0 ]; then
  echo "❌ Ошибка: в аргументе должно быть передано название устройства из ADB (сообщите разработчику скрипта)"
  finalize
  exit 1
fi

# Перебираем все аргументы
for device in "$@"; do
  # Пропускаем первый аргумент с индексом 0 (там $settings_file)
  if ((index > 0)); then
    echo "⏳ Очищаю кэш приложения farm.parking.game для устройства $device..."
    adb -s "$device" shell pm clear farm.parking.game
  fi
  ((index++))
done

echo "✅ Очистка кэша приложения завершена"
finalize
exit 0
