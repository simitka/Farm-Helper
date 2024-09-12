#!/bin/zsh

# Функция для вывода текста жирным шрифтом
bold_text() {
  local text="$1"
  echo "\033[1m$text\033[0m"
}

while true; do
  # Выводим меню выбора
  bold_text "Выбери функцию помогалки:"
  echo "[1] Установка нужного уровня в приложении | Deeplink/Prfile"
  echo "[2] Чтение профайлов подключенного по ADB устройства"
  echo "[3] Удалить кэш приложения в Unity Editor"
  echo "[4] Установить приложение"
  echo "[5] Почистить кэш приложения"
  echo "[6] Удалить приложение"

  # Ожидание ввода пользователя
  echo -n "Введите цифру: "
  read choice

  # Проверяем, является ли ввод числом и находится ли он в допустимом диапазоне
  if [[ "$choice" =~ ^[1-6]$ ]]; then
    # Обработка выбора пользователя
    case "$choice" in
      1)
        echo "Запуск скрипта changeLevel.sh..."
        sh changeLevel.sh
        ;;
      2)
        echo "Запуск скрипта chooseProfile.sh..."
        sh chooseProfile.sh
        ;;
      3)
        echo "Удаление папки ~/Library/Application Support/Liftapp"
        rm -rf ~/Library/Application\ Support/Liftapp
        ;;
      4)
        echo "Перетащи в окно Терминала apk файл и нажми Enter"
        read file_path

        # Убираем лишние пробелы в начале и в конце
        file_path="${file_path#"${file_path%%[![:space:]]*}"}"  # Удаляем пробелы в начале
        file_path="${file_path%"${file_path##*[![:space:]]}"}"  # Удаляем пробелы в конце

        # Убираем экранирование
        file_path="${file_path//\\ / }"  # Убираем экранированные пробелы

        # Выполняем команду adb install
        if [ -n "$file_path" ]; then
          adb install "$file_path"
        else
          echo "Путь к файлу не был указан."
        fi
        ;;
      5)
        echo "Выполнение команды adb shell pm clear farm.parking.game"
        adb shell pm clear farm.parking.game
        ;;    
      6)
        echo "Выполнение команды adb uninstall farm.parking.game"
        adb uninstall farm.parking.game
        ;;            
    esac
    break  # Выход из цикла после успешного выбора
  else
    echo ""
    echo "Ошибка! Для навигации введи число и нажми Enter. Чтобы закрыть скрипт нажми Command+C"
    echo "-------------------------------"
  fi
done
