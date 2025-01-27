#!/bin/zsh

# 1. Очищаем консоль
clear

# 2. Выводим текст с выделением жирным шрифтом
echo "\033[1m⏳ Проверка наличия обновлений FarmJam\033[0m"
echo

# 3. Определяем файл настроек
settings_file="settings.conf"

# 4. Проверяем существование файла настроек
if [[ ! -f $settings_file ]]; then
  echo "❌ Ошибка: Файл $settings_file не найден"
  exit 1
fi

# 5. Читаем параметры из файла настроек
actual_path=$(grep '^actualPath:' $settings_file | cut -d':' -f2)
auto_update=$(grep '^autoUpdate:' $settings_file | cut -d':' -f2)
last_update_check=$(grep '^lastUpdateCheck:' $settings_file | cut -d':' -f2)
actual_tag_version=$(grep '^actualTagVersion:' $settings_file | cut -d':' -f2)

# 6. Проверяем наличие необходимых данных в файле настроек
if [[ -z $last_update_check || -z $actual_tag_version ]]; then
  echo "❌ Ошибка: Не удалось получить данные из $settings_file"
  exit 1
fi

# Проверка значения auto_update
if [[ "$auto_update" == "false" ]]; then
  # Если auto_update = false, сразу запускаем главное меню и выходим
  ./bashScript/menu.sh "$settings_file" "$actual_tag_version"
  exit 0
fi

# 7. Преобразуем значение lastUpdateCheck в секунды
last_update_check_sec=$(date -j -f "%s" "$last_update_check" "+%s")

# 8. Получаем текущее время в секундах
current_time_sec=$(date "+%s")

# 9. Вычисляем разницу во времени в часах
time_diff=$(((current_time_sec - last_update_check_sec) / 3600))

# Если auto_update = true и прошло менее 24 часов с последней проверки, запускаем меню
if [[ "$auto_update" == "true" && $time_diff -lt 24 ]]; then
  ./bashScript/menu.sh "$settings_file" "$actual_tag_version"
  exit 0
fi

# 11. Получаем тег последнего релиза из GitHub
repo="simitka/Farm-Helper"
latest_tag=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | jq -r .tag_name)

# 12. Проверяем, удалось ли получить последний тег релиза
if [[ -z $latest_tag ]]; then
  echo "❌ Ошибка: Не удалось получить последний тег релиза"
  exit 1
fi

# Проверка необходимости обновления
if [[ "$auto_update" == "force" || "$latest_tag" != "$actual_tag_version" ]]; then
  # 14. Скачиваем архив с новым релизом
  echo "⏳ Найдено обновление. Текущая версия = $actual_tag_version, новая версия = $latest_tag"
  echo "⏳ Обновление..."
  echo
  archive_url="https://api.github.com/repos/$repo/zipball/$latest_tag"
  archive_name="release-$latest_tag.zip"

  curl -L $archive_url -o $archive_name

  # 15. Проверка наличия файлов $settings_file и $archive_name в папке farmx
  cd $actual_path

  if [[ ! -f "$settings_file" ]]; then
    echo "❌ Ошибка: файл '$settings_file' не найден"
    exit 1
  fi

  if [[ ! -f "$archive_name" ]]; then
    echo "❌ Ошибка: файл '$archive_name' не найден"
    exit 1
  fi

  # Удаление всех файлов и папок, кроме указанных
  for item in *; do
    if [[ "$item" != "$settings_file" && "$item" != "$archive_name" && "$item" != "farmBuilds" ]]; then
      rm -rf "$item" # Удаляет файлы и папки рекурсивно
    fi
  done

  # 17. Распаковываем архив в временную директорию
  unzip -o $archive_name -d temp_dir

  # 18. Перемещаем файлы из временной директории в текущую папку
  mv temp_dir/*/* . && mv temp_dir/*/.[!.]* .

  # 19. Удаляем временные файлы и папки
  rm -r temp_dir
  rm $archive_name

  # 20. Обновляем файл настроек с новым тегом и меткой времени
  sed -i '' "s/^lastUpdateCheck:.*/lastUpdateCheck:$(date +%s)/" $settings_file
  sed -i '' "s/^actualTagVersion:.*/actualTagVersion:$latest_tag/" $settings_file
  actual_tag_version=$latest_tag
fi

# 21. Запускаем главное меню
./bashScript/menu.sh "$settings_file" "$actual_tag_version"
