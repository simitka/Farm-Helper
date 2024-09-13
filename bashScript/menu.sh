#!/bin/zsh

# Очищаем консоль
clear

# Функция для вывода текста жирным шрифтом
bold_text() {
  local text="$1"
  echo "\033[1m$text\033[0m"
}

while true; do
  # Выводим меню выбора
  bold_text "Farm Helper"
  
  echo "Чтобы закрыть скрипт нажмите Control⌃ + C"
  echo "Чтобы запустить скрипт введите 'farmx' в Терминале"
  echo
  bold_text "Выберите нужную функцию и введите соответствующую цифру:"
  echo "    [1] Почистить кэш приложения"
  echo "    [2] Установить приложение"
  echo "    [3] Удалить приложение"
  echo "    [4] Создание/Переход по DeepLink"
  echo "    [5] Установка нужного уровня в приложении | Deeplink/Profile"
  echo "    [6] Чтение профайлов подключенного по ADB устройства"
  echo "    [7] Удалить кэш приложения в Unity Editor"

  # Ожидание ввода пользователя
  echo -n "Введите цифру: "
  read choice

  # Проверяем, является ли ввод числом и находится ли он в допустимом диапазоне
  if [[ "$choice" =~ ^[1-7]$ ]]; then
    # Обработка выбора пользователя
    case "$choice" in
      1)
        echo "Запуск скрипта clearCache.sh..."
        ./bashScript/clearCache.sh
        ;;
      2)
        echo "Запуск скрипта installApp.sh..."
        ./installApp.sh
        ;;
      3)
        echo "Запуск скрипта deleteApp.sh..."
        ./deleteApp.sh
        ;;    
      4)
        echo "Запуск скрипта deepLink.sh..."
        ./deepLink.sh
        ;;            
      5)
        echo "Запуск скрипта changeLevel.sh..."
        ./changeLevel.sh
        ;;
      6)
        echo "Запуск скрипта readProfile.sh..."
        ./readProfile.sh
        ;;      
      7)
        echo "Запуск скрипта clearUnityCache.sh..."
        ./clearUnityCache.sh
        ;;                  
    esac
    break  # Выход из цикла после успешного выбора
  else
    # Обработка неверного ввода
    clear
    bold_text "Ошибка! Введите число от 1 до 7 и нажмите Enter"
    echo "============================================================"
    echo
    echo
  fi
done
