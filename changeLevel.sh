#!/bin/zsh

echo "Выбери как установить прогресс:"
echo "[1] Логика восстановления прогресса через Deeplink | FAR-4168"
echo "[2] (Android Only) Прописать уровень в common профайл"

read -r choice

if [ "$choice" = "1" ]; then
  dotnet run
elif [ "$choice" = "2" ]; then
  adb shell am force-stop farm.parking.game
  
  printf "Какой уровень установить: "
  read -r level

  # Считываем содержимое файла
  content=$(adb shell cat /sdcard/Android/data/farm.parking.game/files/profiles/Common.json)

  # Изменяем значение PassedLevels в JSON
  updated_content=$(echo "$content" | jq --argjson newLevel "$level" '.LevelsInfo.common.PassedLevels.Value = $newLevel')

  # Записываем обратно в файл
  adb shell "echo '$updated_content' > /sdcard/Android/data/farm.parking.game/files/profiles/Common.json"

  echo "Уровень $level успешно установлен."
else
  echo "Некорректный выбор. Попробуйте снова."
fi
