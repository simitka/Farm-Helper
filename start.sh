#!/bin/zsh

# 1. Отчищаем консоль
clear

# 2. Выводим текст
echo "\033[1mПроверка наличия обновлений FarmJam\033[0m"

# 3. Читаем файл settings.conf
settings_file="settings.conf"

if [[ ! -f $settings_file ]]; then
  echo "Файл settings.conf не найден!"
  exit 1
fi

last_update_check=$(grep '^lastUpdateCheck:' $settings_file | cut -d':' -f2)
actual_tag_version=$(grep '^actualTagVersion:' $settings_file | cut -d':' -f2)

if [[ -z $last_update_check || -z $actual_tag_version ]]; then
  echo "Не удалось получить данные из settings.conf"
  exit 1
fi

# Преобразуем timestamp в секунды
last_update_check_sec=$(date -j -f "%s" "$last_update_check" "+%s")
current_time_sec=$(date "+%s")
time_diff=$(( (current_time_sec - last_update_check_sec) / 3600 ))

# 4. Проверяем, прошло ли менее 24 часов
if (( time_diff < 24 )); then
  bash bashScript/menu.sh
  exit 0
fi

# 6. Получаем тег последнего релиза из GitHub
repo="Simitka/Farm-Helper"
latest_tag=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | jq -r .tag_name)

if [[ -z $latest_tag ]]; then
  echo "Не удалось получить последний тег релиза"
  exit 1
fi

# 7. Сравниваем теги
if [[ "$latest_tag" == "$actual_tag_version" || "$(echo -e "$latest_tag\n$actual_tag_version" | sort -V | head -n1)" == "$latest_tag" ]]; then
  bash bashScript/menu.sh
  exit 0
fi

# 9. Скачиваем архив
archive_url="https://api.github.com/repos/$repo/zipball/$latest_tag"
archive_name="archive.zip"

curl -L $archive_url -o $archive_name

# 10. Удаляем все файлы кроме settings.conf и архива
find . -maxdepth 1 -type f ! -name "$settings_file" ! -name "$archive_name" -exec rm {} \;

# 11. Распаковываем архив
unzip -o $archive_name -d temp_dir

# 12. Перемещаем файлы из распакованной папки в текущую директорию
mv temp_dir/*/* .

# 13. Удаляем временные папки и архив
rm -r temp_dir
rm $archive_name

# 14. Обновляем настройки
echo "actualPath:/Users/simitka/Documents/farmx" > $settings_file
echo "lastUpdateCheck:$(date +%s)" >> $settings_file
echo "actualTagVersion:$latest_tag" >> $settings_file

# 15. Запускаем скрипт
bash bashScript/menu.sh
