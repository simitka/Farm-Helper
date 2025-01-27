#!/bin/zsh

# Выдаем всем .sh файлам в папке права на выполнение
find . -type f -name "*.sh" -exec chmod +x {} \;

# Проверка наличия аргумента
if [[ $# -ne 2 ]]; then
  echo "❌ Ошибка: Во время вызова скрипта переданы не все необходимые аргументы (сообщите разработчику скрипта)"
  exit 1
fi

# Получение пути к файлу настроек из аргумента
settings_file="$1"
actual_tag_version="$2"

# Функция для вывода текста жирным шрифтом
bold_text() {
  local text="$1"
  echo "\033[1m$text\033[0m"
}

# Функция для вывода сообщения и выполнения команды farmx
function finalize() {
  echo
  echo "Чтобы продолжить, нажмите любую кнопку..."
  stty -icanon
  dd bs=1 count=1 >/dev/null 2>&1
  stty icanon
  farmx
}

function choose_adb() {
  local script_name="$1"

  # Очищаем консоль
  clear

  # Получаем список подключенных устройств, исключая пустые строки и строки "unauthorized", "offline" и т.д.
  devices=($(adb devices | awk 'NR>1 && $2=="device" {print $1}'))
  device_count=${#devices[@]}

  if [[ $device_count -eq 0 ]]; then
    echo "❌ Ошибка: Нет подключенных к ADB устройств."
    finalize
    exit 1
  fi

  # Если одно устройство
  if [[ $device_count -eq 1 ]]; then
    device=${devices[1]}
    eval $script_name "$settings_file" "$device"
    exit 0
  fi

  # Если несколько устройств
  echo "-------------------------------"
  echo "К adb подключено несколько устройств"
  echo "-------------------------------"
  echo "    [0] Применить команду для всех устройст из списка ниже"

  for ((i = 0; i < device_count; i++)); do
    echo "    [$((i + 1))] ${devices[i + 1]}"
  done

  echo -n "📝 Введите номер устройства из списка выше: "
  read device_choice
  echo

  # Проверка корректности ввода
  if ! [[ $device_choice =~ ^[0-9]+$ ]] || [[ $device_choice -lt 0 ]] || [[ $device_choice -gt $device_count ]]; then
    echo "❌ Ошибка: Некорректный выбор устройства"
    finalize
    exit 1
  fi

  if [[ $device_choice -eq 0 ]]; then
    # Очистка кэша для всех устройств
    for device in "${devices[@]}"; do
      eval $script_name "$settings_file" "$devices"
    done
  else
    # Получаем выбранное устройство
    selected_device=${devices[$((device_choice))]}
    eval $script_name "$settings_file" "$selected_device"
  fi

  finalize
  exit 0
}

#
#
#

# Очищаем консоль
clear

# Выводим меню выбора
while true; do
  bold_text "Farm Helper v$actual_tag_version"

  echo "Чтобы закрыть скрипт нажмите Control⌃ + C"
  echo "Чтобы запустить скрипт введите 'farmx' в Терминале"
  echo
  bold_text "Выберите нужную функцию и введите соответствующую цифру:"
  echo "    [1] Почистить кэш приложения"
  echo "    [2] Установить приложение"
  echo "    [3] Удалить приложение"
  echo "    [4] Переход по DeepLink"
  echo "    [5] Восстановление уровня с помощью DeepLink (FAR-4168)"
  echo "    [6] Чтение профайлов подключенного по ADB устройства"
  echo "    [7] Удалить кэш приложения в Unity Editor"
  echo "    [8] Скачать дамп logcat логов с устройства"
  echo "    [9] (todo) Почистить logcat логи и начать запись в файл"

  # Ожидание ввода пользователя
  echo -n "📝 Введите цифру: "
  read choice

  # Проверяем, является ли ввод числом и находится ли он в допустимом диапазоне
  if [[ "$choice" =~ ^[1-9]$ ]]; then
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
      echo "⏳ Запускаю скрипт changeLevel.sh..."
      #./changeLevel.sh
      dotnet script dotnetScript/changeLevelDeeplink.csx --no-cache

      ;;
    6)
      clear
      ./bashScript/chooseProfile.sh
      ;;
    7)
      ./bashScript/deleteUnityCache.sh
      ;;
    8)
      choose_adb "./bashScript/logcatDump.sh"
      ;;
    9)
      clear
      echo "⏳ Функционал пока что в разработке:)"
      finalize
      ;;
    esac
    break # Выход из цикла после успешного выбора
  else
    # Обработка неверного ввода
    clear
    bold_text "❌ Ошибка: Введите число от 1 до 9 и нажмите Enter"
    echo "============================================================"
    echo
    echo
  fi
done
