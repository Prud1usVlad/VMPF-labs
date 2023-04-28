#! /bin/bash

declare -r MY_CYTHON_PROJECT='task1'

# Очистимо екран
#
clear

# Допоміжна функція для цього скрипта на Bash
#
continue_running() {
  echo
  read -p 'Щоб продовжити натисни [Enter]: '
  echo -e "\n\n"
}

# Допоміжна функція для цього скрипта на Bash
#
show_file() {
  echo
  echo 'Вміст файла:'
  echo
  echo '=== Початок файла ==='
  cat $1
  echo '=== Кінець файла ==='
  continue_running
}


#  Видалимо директорію старого проєкту із усім її вмістом
#
rm -rf ${MY_CYTHON_PROJECT}

# Створимо директорію для нового проєкту
#
mkdir ${MY_CYTHON_PROJECT} || exit

# Перейдемо у створену директорію та запам'ятаємо поточну
#
pushd ${MY_CYTHON_PROJECT} >/dev/null || exit

# Створимо файл, який містить код на Cython (розширення .pyx)
# нашого модуля hello
#
echo 'Створимо файл hello.pyx з кодом на Cython нашого модуля hello'

cat >hello.pyx <<'EOF'
import string

cpdef find_longest_word(filename) : 
  # Open the text file
  with open(filename, 'r') as file:
    # Initialize variables
    max_length = 0
    longest_text = ''
    # Loop through each line of the file
    for line in file:
      # Split the line into words
      words = line.split()
      # Loop through each word in the line
      for word in words:
        # Check if the word is longer than the current longest text
        if len(word) > max_length:
          max_length = len(word)
          longest_text = word
    # Display the first word of the longest text with it's length
    print(longest_text + " - " + str(max_length))

EOF


# Переглянемо створений файл hello.pyx
#
show_file hello.pyx

# Створимо файл, який містить код на Python (розширення .py)
# для перевірки роботи нашого модуля hello
#
echo 'Створимо файл test.py з кодом на Python для перевірки нашого модуля hello'

cat >test.py <<'EOF'
#! /usr/bin/python3

# Import the extension module hello.
import hello


# Call the print_result method
hello.find_longest_word("../input.txt")

EOF

# Зробимо файл test.py виконуваним
#
chmod +x test.py


# Переглянемо створений файл test.py
#
show_file test.py


# Приклади компіляції Cython файла з командного рядка
#
cat <<'EOF'
Файл можна скомпілювати з допомогою утиліт.
Існує два способи компіляції з командного рядка:
* Команда cython бере файл .py або .pyx та компілює його у файл C/C++
  Потім компілятор gcc компілює файл C/C++ у бінарну бібліотеку
  ( ключ -fPIC та ключ -shared вказують, що потрібно створити
    позиційно-незалежний код та бібліотеку )
  Приклад: cython -3 hello.pyx && \
           gcc -fPIC -shared -o hello2.so hello.c -I /usr/include/python3.7m/
* Команда cythonize бере файл .py або .pyx та компілює його у файл C/C++
  Далі вона компілює файл C/C++ у модуль розширення, який можна
  безпосередньо імпортувати з Python.
EOF
continue_running


# Створимо файл, який містить код на Python
# для збирання нашого проєкту
#
echo 'Файл також можна скомпілювати з допомогою програми на Python.'
echo 'Створимо файл setup.py з кодом на Python для збирання нашого модуля hello'

cat >setup.py <<'EOF'
#! /usr/bin/python3

from distutils.core import Extension, setup
from Cython.Build import cythonize


# define an extension that will be cythonized and compiled
ext = Extension(name="hello", sources=["hello.pyx"])
setup(ext_modules=cythonize(ext))

EOF


# Зробимо файл setup.py виконуваним
#
chmod +x setup.py

# Переглянемо створений файл setup.py
#
show_file setup.py


# Зберемо наш проєкт скриптом setup.py
#
echo 'Зберемо наш проєкт скриптом setup.py'
echo
echo '=== Початок роботи скрипта setup.py ==='
./setup.py build_ext --inplace || exit
echo
echo '=== Кінець роботи скрипта setup.py ==='
continue_running


# Переглянемо вміст поточної директорії
#
echo 'Вміст кореневої директорії проєкту:'
echo
ls -F
echo -e "\n\n"
echo 'Дерево проєкту:'
echo
tree ./
continue_running


# Перевіримо роботу нашого модуля
#
echo 'Виконаємо скрипт test.py'
echo
./test.py
echo ' === Кінець роботи скрипта test.py ==='
continue_running

# Повернемось у попередню директорію і завершимо роботу
#
popd >/dev/null

# EOF