#!/bin/zsh

# 1. Очищаем консоль
clear

# 2. Выводим текст с выделением жирным шрифтом
echo "\033[1mПроверка наличия обновлений FarmJam\033[0m"
echo

# 3. Определяем файл настроек
settings_file="settings.conf"

# 4. Проверяем существование файла настроек
if [[ ! -f $settings_file ]]; then
  echo "Файл $settings_file не найден!"
  exit 1
fi

# 5. Читаем параметры из файла настроек
last_update_check=$(grep '^lastUpdateCheck:' $settings_file | cut -d':' -f2)
actual_tag_version=$(grep '^actualTagVersion:' $settings_file | cut -d':' -f2)

# 6. Проверяем наличие необходимых данных в файле настроек
if [[ -z $last_update_check || -z $actual_tag_version ]]; then
  echo "Не удалось получить данные из $settings_file"
  exit 1
fi

# 7. Преобразуем значение lastUpdateCheck в секунды
last_update_check_sec=$(date -j -f "%s" "$last_update_check" "+%s")

# 8. Получаем текущее время в секундах
current_time_sec=$(date "+%s")

# 9. Вычисляем разницу во времени в часах
time_diff=$(( (current_time_sec - last_update_check_sec) / 3600 ))

# 10. Проверяем, прошло ли менее 24 часов с момента последней проверки
if (( time_diff < 24 )); then
  # Если проверка уже была в течение последних 24 часов, запускаем главное меню и выходим
  ./bashScript/menu.sh
  exit 0
fi

# 11. Получаем тег последнего релиза из GitHub
repo="Simitka/Farm-Helper"
latest_tag=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | jq -r .tag_name)

# 12. Проверяем, удалось ли получить последний тег релиза
if [[ -z $latest_tag ]]; then
  echo "Не удалось получить последний тег релиза"
  exit 1
fi

# 13. Сравниваем текущий тег и тег последнего релиза
if [[ "$latest_tag" == "$actual_tag_version" || "$(echo -e "$latest_tag\n$actual_tag_version" | sort -V | head -n1)" == "$latest_tag" ]]; then
  # Если обновление не требуется, обновляем lastUpdateCheck и запускаем главное меню
  sed -i '' "s/^lastUpdateCheck:.*/lastUpdateCheck:$(date +%s)/" $settings_file
  ./bashScript/menu.sh
  exit 0
fi

# 14. Скачиваем архив с новым релизом
echo "Найдено обновление. Текущая версия = $actual_tag_version, новая версия = $latest_tag"
echo "Обновление..."
echo
archive_url="https://api.github.com/repos/$repo/zipball/$latest_tag"
archive_name="release-$latest_tag.zip"

curl -L $archive_url -o $archive_name

# 15. Удаляем все файлы, кроме settings.conf и архива
find . -maxdepth 1 -type f ! -name "$settings_file" ! -name "$archive_name" -exec rm {} \;

# 16. Распаковываем архив в временную директорию
unzip -o $archive_name -d temp_dir

# 17. Перемещаем файлы из временной директории в текущую папку
mv temp_dir/*/* .

# 18. Удаляем временные файлы и папки
rm -r temp_dir
rm $archive_name

# 19. Обновляем файл настроек с новым тегом и меткой времени
sed -i '' "s/^actualTagVersion:.*/actualTagVersion:$latest_tag/" $settings_file
sed -i '' "s/^lastUpdateCheck:.*/lastUpdateCheck:$(date +%s)/" $settings_file

# 20. Запускаем главное меню
./bashScript/menu.sh
