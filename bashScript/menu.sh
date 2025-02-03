#!/bin/zsh

# Выдаем всем .sh файлам в папке права на выполнение
find . -type f -name "*.sh" -exec chmod +x {} \;

# Подсключаем utils.sh
source ./bashScript/utils.sh

# Проверка наличия аргумента
if [[ $# -ne 2 ]]; then
  echo "❌ Ошибка: Во время вызова скрипта переданы не все необходимые аргументы (сообщите разработчику скрипта)"
  exit 1
fi

# Получение пути к файлу настроек из аргумента
settings_file="$1"
actual_tag_version="$2"

# Очищаем консоль
clear

# Выводим меню выбора
while true; do
  echo "Farm Helper v$actual_tag_version"

  dim_text "Чтобы закрыть скрипт нажмите Control⌃ + C"
  dim_text "Чтобы запустить скрипт введите 'farmx' в Терминале"
  echo
  bold_text "Выберите нужную функцию и введите соответствующую цифру:"
  echo "    [1] Почистить кэш приложения"
  echo "    [2] Установить приложение"
  echo "    [3] Удалить приложение"
  echo "    [4] Переход по DeepLink"
  echo "    [5] Переключение настроек Proxy на устройстве"
  echo "    [6] Восстановление уровня с помощью DeepLink (FAR-4168)"
  echo "    [7] Чтение профайлов подключенного по ADB устройства"
  echo "    [8] Скачать дамп logcat логов с устройства"
  echo "    [9] Почистить logcat логи и начать запись в файл"
  echo "    [10] Удалить кэш приложения в Unity Editor"

  # Ожидание ввода пользователя
  echo -n "📝 Введите цифру: "
  read choice

  # Проверяем, является ли ввод числом и находится ли он в допустимом диапазоне
  if [[ "$choice" =~ ^[0-9]+$ && "$choice" -ge 1 && "$choice" -le 10 ]]; then
    # Обработка выбора пользователя
    case "$choice" in
    1)
      choose_adb "./bashScript/clearCache.sh"
      ;;
    2)
      choose_adb "./bashScript/installApp.sh"
      ;;
    3)
      choose_adb "./bashScript/uninstallApp.sh"
      ;;
    4)
      choose_adb "./bashScript/openDeeplink.sh"
      ;;
    5)
      choose_adb "./bashScript/setGlobalProxy.sh"
      ;;
    6)
      echo "⏳ Запускаю скрипт changeLevel.sh..."
      #./changeLevel.sh
      dotnet script dotnetScript/changeLevelDeeplink.csx --no-cache

      ;;
    7)
      clear
      ./bashScript/chooseProfile.sh
      ;;
    8)
      choose_adb "./bashScript/logcatDump.sh"
      ;;
    9)
      choose_adb "./bashScript/logcatReader.sh"
      ;;
    10)
      ./bashScript/deleteUnityCache.sh
      ;;
    esac
    break # Выход из цикла после успешного выбора
  else
    # Обработка неверного ввода
    clear
    red_bg "$(bold_text '❌ Ошибка: Введите число от 1 до 10 и нажмите Enter↵ ')"
    red_bg "$(bold_text '==============================================================')"
    echo
    echo
  fi
done
