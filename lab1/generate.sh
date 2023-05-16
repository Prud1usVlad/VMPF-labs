#! /bin/bash
# Copyright (C)2023 Ihor Sokorchuk, ihor.sokorchuk@nure.ua - All rights reserved

#############################################################
# Створення простого блогу на Django 3
#############################################################

# У цьому скрипті розглядається приклад створення блогу на Django.
# Цей блог дозволить користувачам створювати, редагувати та видаляти дописи.
# На домашній сторінці сайту відображається список усіх дописів блогу.
# Для кожного окремого допису в блозі передбачена окрема детальна сторінка.
# Також розглянуто, як застосовувати CSS стилі та налаштовувати роботу Django
# зі статичними файлами, наприклад, такими як: css, js, jpg, png.

# ХІД РОБОТИ
# 1.  Початкове налаштування блогу на Django
# 2.  Створення моделі (Model) Post для роботи із дописами блогу
# 3.  Створення адміністратора блогу та панелі адміністратора
# 4.  Налаштування URL маршрутів для блогу
# 5.  Створення Вигляду (View) BlogListView для відображення дописів блогу
# 6.  Створення Шаблону (Template) для блогу
# 7.  Налаштування роботи зі статичними файлами у Django
# 8.  Створення окремої сторінкі DetailView для допису
# 9.  Створення TestCase для блогу на Django та тестування
# 10. Завантаження файлів блогу на Github


#############################################################
# Загальна підготовка до роботи
# Зітремо старий проєкт (при потребі)
# Виберемо режим роботи цього скрипта
#############################################################

SERVER_HOSTNAME="localhost"
SERVER_PORT=$((8000 + (UID - 1000)))
# echo "[${SERVER_HOSTNAME}:${SERVER_PORT}]"; exit

function run_django_web_server() {
  echo
  echo 'Запускаю Django Web сервер'
  echo "Сторінка адміністрування: http://${SERVER_HOSTNAME}:${SERVER_PORT}/admin/ "
  echo
  ./manage.py runserver ${SERVER_HOSTNAME}:${SERVER_PORT}
  echo
}

if [ -d MyDjangoBlog ]; then
  echo 'Проєкт MyDjangoBlog вже існує.'
  read -p 'Видалити цей проєкт MyDjangoBlog? [y/N]: ' remove_project
  if [ "$remove_project" == 'y' ]; then
    rm -r ./MyDjangoBlog && echo 'Проєкт успішно видалено!'
    echo 'Виконайте цей скрипт знову'
    exit
  fi
  read -p 'Запустити Django Web сервер? y/N: ' run_server
  if [ "$run_server" == 'y' ]; then
    cd MyDjangoBlog
    source ./blogenv/bin/activate
    run_django_web_server
    echo
    exit
  fi
fi

read -p 'Виконувати скрипт покомандно? [y/N]: ' step_by_step
# Далі виконуватимемо скрипт покомандно із підсвідкою команд
if [ "$step_by_step" == 'y' ]; then
   trap 'echo -ne "\033[1;33m$BASH_COMMAND\n# \033[0m";read' DEBUG
fi


#############################################################
# Крок 1. Початкове налаштування блогу на Django
#############################################################

# 1.1 Створимо нову директорію для проєкту з назвою MyDjangoBlog та 
#     перейдемо у неї
mkdir -p MyDjangoBlog
cd MyDjangoBlog

# 1.2 Активуємо віртуальне оточення
## pipenv install django==3.1 # Це новий інструмент
## pipenv shell
virtualenv blogenv || exit # Це традиційний інструмент
source ./blogenv/bin/activate

# 1.3 Встановимо Django у цьому новому віртуальному оточенні
pip3 install django

# 1.4 Створимо новий проєкт з назвою blog_project
django-admin startproject blog_project .

# 1.5 Створимо у проєкті застосунок/аплікацію з назвою blog
./manage.py startapp blog

# 1.6 Виконаємо міграцію для створення бази даних
./manage.py migrate

# 1.7 Перевіримо роботу (при потребі)
#     Запустимо сервер і перевіримо роботу блогу з браузера
false && ./manage.py runserver ${SERVER_HOSTNAME}:${SERVER_PORT}; echo
# При переході на адресу http://127.0.0.1:8000/ у браузері відкриється 
# початкова сторінка.

# 1.8 Оновимо файл налаштувань проєкту blog_project/settings.py
#     Зареєструємо створений застосунок/аплікацію blog
#
# #   blog_project/settings.py
# INSTALLED_APPS = [
#     . . .
#     'blog.apps.BlogConfig', # Додаємо наш застосунок
# ]
#
cp blog_project/settings.py blog_project/settings.py.copy
cat blog_project/settings.py.copy | awk '
BEGIN { True = 1; False = 0; isInstalledAppsList = False }
/^INSTALLED_APPS =/ { isInstalledAppsList = True }
/^]/ && isInstalledAppsList == True {
  isInstalledAppsList = False
  print "    '\''blog.apps.BlogConfig'\'', # наш застосунок"
}
{ print }
' >blog_project/settings.py
rm blog_project/settings.py.copy

# 1.9 Встановимо українську локалізацію у проєкті
cp blog_project/settings.py blog_project/settings.py.copy
cat blog_project/settings.py.copy | awk '
/^LANGUAGE_CODE =/ { print "LANGUAGE_CODE = '\''uk-ua'\'' # нове"; next; }
/^TIME_ZONE =/ { print "TIME_ZONE = '\''Europe/Helsinki'\'' # нове"; next; }
{ print }
' >blog_project/settings.py
rm blog_project/settings.py.copy

# 1.10 Встановимо дозволені адреси (hostname)
cp blog_project/settings.py blog_project/settings.py.copy
cat blog_project/settings.py.copy | awk '
/^ALLOWED_HOSTS = / { 
  print "ALLOWED_HOSTS = [ '\'${SERVER_HOSTNAME}\'', '\''127.0.0.1'\'', '\''localhost'\'', ] # нове"
  next
}
{ print }
' >blog_project/settings.py
rm blog_project/settings.py.copy

#############################################################
# 2.  Створення моделі Post для роботи із дописами блогу
#############################################################

# 2.1 Створимо файл blog/models.py з моделлю Post для блогу
# Модель містить поля:
# * Заголовок допису;
# * Автор допису;
# * Текст допису.
tee blog/models.py <<'EOF'
# blog/models.py
from django.db import models

class Tag(models.Model):
    name = models.CharField(max_length=50)
    color = models.CharField(max_length=10)

    def __str__(self):
        return self.name

class Post(models.Model):
    title = models.CharField(max_length=200)
    author = models.ForeignKey(
        'auth.User',
        on_delete=models.CASCADE,
    )
    body = models.TextField()

    tags = models.ManyToManyField(Tag)

    def __str__(self):
        return self.title

EOF

# 2.2 Створимо міграцію моделі
./manage.py makemigrations blog
# 2.3 Виконаємо міграцію (перенесемо модель у базу даних)
./manage.py migrate blog


#############################################################
# 3. Створення адміністратора блогу та панелі адміністратора
#############################################################

# 3.1 Створимо адміністратора блогу (проєкту)
./manage.py createsuperuser

# 3.2 Перевіримо роботу панелі адміністратора (при потребі)
#     Запустимо сервер і перевіримо роботу панелі адміністратора з браузера
#
false && run_django_web_server
 ${SERVER_HOSTNAME}:${SERVER_PORT}; echo
#
# При переході на адресу http://127.0.0.1:8000/admin/ у браузері відкриється 
# початкова панель адміністратора без нашої моделі Post для роботи 
# із записами блогу.

# 3.3 Створимо панель адміністратора із моделлю Post для роботи із записами блогу
tee blog/admin.py <<'EOF'
# blog/admin.py
from django.contrib import admin
from .models import Post, Tag

admin.site.register(Post)
admin.site.register(Tag)
EOF

# 3.4 Знову перевіримо роботу панелі адміністратора (при потребі)
#     Запустимо сервер і перевіримо роботу панелі адміністратора з браузера
#
false && run_django_web_server
#
# При переході на адресу http://127.0.0.1:8000/admin/ у браузері відкриється 
# панель адміністратора із нашої моделлю Post для роботи із записами блогу.


#############################################################
# 4. Налаштування URL маршрутів для блогу
#############################################################

# 4.1 Оновимо файл blog/urls.py і налаштуємо у ньому URL маршрути,
#     для відображення записів блогу на головній сторінці.
touch blog/urls.py
tee blog/urls.py <<'EOF'
# blog/urls.py
from django.urls import path
from .views import BlogListView

urlpatterns = [
    path('', BlogListView.as_view(), name='home'),
]
EOF

# 4.2 Оновимо файл blog_project/urls.py, щоб надалі всі запити надсилалися
#     безпосередньо до застосунку/аплікації blog
tee blog_project/urls.py <<'EOF'
# blog_project/urls.py
from django.contrib import admin
from django.urls import path, include # нові зміни

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('blog.urls')), # нові зміни
]
EOF


#############################################################
# 5. Створення Вигляду/View з назвою BlogListView для 
#    відображення дописів блогу
#############################################################

# 5.1 Створимо Вигляд/View — BlogListView для відображення вмісту 
#     з моделі Post при використаннs ListView у Django.
tee -a blog/views.py <<'EOF'
# blog/views.py
from django.views.generic import ListView
from .models import Post

class BlogListView(ListView):
    model = Post
    template_name = 'home.html'
EOF


#############################################################
# 6. Створення шаблону для блогу
#############################################################

# 6.1 Створимо директорію для шаблонів та порожні HTML файли шаблонів
mkdir templates
touch templates/base.html
touch templates/home.html

# 6.2 Додамо шлях до файлів шаблонів у файл конфігурації проєкту
#
# blog_project/settings.py
# TEMPLATES = [
#     {
#         ...
#         'DIRS': [os.path.join(BASE_DIR, 'templates')], # нове
#         ...
#     },
# ]
#
cp blog_project/settings.py blog_project/settings.py.copy
cat blog_project/settings.py.copy | awk '
BEGIN { True = 1; False = 0; isTemplates = False
  print "import os # нове"
}
/^TEMPLATES =/ { isTemplates = True }
/'\''DIRS'\'':/ && isTemplates == True {
  print "        '\''DIRS'\'': [os.path.join(BASE_DIR, '\''templates'\'')], # нове"
  next
}
/^]/ && isTemplates == True {
  isTemplates = False
}
{ print }
' >blog_project/settings.py
rm blog_project/settings.py.copy

# 6.3 Створимо шаблон templates/base.html
#     Цей шаблон будуть успадковувати як основну структуру інші шаблони
#     Місце між {% block content %} та {% endblock content %}
#     буде заповнено вмістом інших файлів, наприклад home.html.
tee templates/base.html <<'EOF'
<!-- templates/base.html -->
<html>
  <head>
    <title>Django blog</title>
  </head>
  <body>
    <header>
      <h1><a href="{% url 'home' %}">Django blog</a></h1>
    </header>
    <div>
      {% block content %}
      {% endblock content %}
    </div>
  </body>
</html>
EOF

# 6.4 Створимо шаблон templates/home.html
#     Цей шаблон розширює базовий шаблон base.html і далі заповнює
#     блок content даними.
#     Команда спеціальної мови шаблонів for використовується для 
#     відображення усіх дописів.
#     Змінна object_list походить від класу ListView та містить
#     усі об'єкти нашого Вигляду
tee templates/home.html <<'EOF'
<!-- templates/home.html -->
{% extends 'base.html' %}
 
{% block content %}
  {% for post in object_list %}
    <div class="post-entry">
      <h2><a href="">{{ post.title }}</a></h2>
      <p>{{ post.body }}</p>
    </div>
  {% endfor %}
{% endblock content %}
EOF


#############################################################
# 7.  Налаштування роботи зі статичними файлами у Django
#############################################################

# 7.1 Створимо директорію для статичних файів
mkdir static

# 7.2 Оновимо файл налаштувань проєкту та додамо у нього 
#     рядок зі шляхом до статичних файлів
# blog_project/settings.py
tee -a blog_project/settings.py <<'EOF'

STATICFILES_DIRS = [os.path.join(BASE_DIR, 'static')] # нове
EOF

# 7.3 Створимо директорію для статичних файлів стилів
mkdir static/css
touch static/css/base.css

# 7.4 Створимо файл зі стилями
false && tee static/css/base.css <<'EOF'
/* static/css/base.css */
header h1 a {
  color: red;
}
EOF

# 7.5 Оновимо файл templates/base.html (команда не виконується)
#     Включимо статичні файли до наших шаблонів, додавши 
#     рядок {% load static %} на початок файла templates/base.html
#     Інші шаблони успадковують каркас від base.html і статичні файли 
#     з директорії static автоматично з'являтимуться у всіх шаблонах.
false && tee templates/base.html <<'EOF'
<!-- templates/base.html -->
{% load static %}
<html>
  <head>
    <title>Django blog</title>
    <link href="{% static 'css/base.css' %}" rel="stylesheet">
  </head>
  ...
EOF


# 7.6 Ще трохи доповнимо файл templates/base.html (команда не виконується)
#     додамо відкриті шрифти "Source Sans Pro" із сайту
#     https://fonts.googleapis.com/css
false && tee templates/base.html <<'EOF'
<!-- templates/base.html -->
{% load static %}
<html>
<head>
  <title>Django blog</title>
  <link href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:400" rel="stylesheet">
  <link href="{% static 'css/base.css' %}" rel="stylesheet">
</head>
  ...
EOF

# 7.7 Запишемо остаточий варіант файла шаблонів templates/base.html
tee templates/base.html <<'EOF'
<!-- templates/base.html -->
{% load static %}
<html>
  <head>
    <title>Django blog</title>
    <link href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:400" rel="stylesheet">
    <link href="{% static 'css/base.css' %}" rel="stylesheet">
  </head>
  <body>
    <header>
      <h1><a href="{% url 'home' %}">Django blog</a></h1>
    </header>
    <div>
      {% block content %}
      {% endblock content %}
    </div>
  </body>
</html>
EOF

# Запишемо остаточий варіант статичного файла стилів static/css/base.css
tee -a static/css/base.css <<'EOF'
/* static/css/base.css */
body {
  font-family: 'Source Sans Pro', sans-serif;
  font-size: 18px;
}

header {
  border-bottom: 1px solid #999;
  margin-bottom: 2rem;
  display: flex;
}

header h1 a {
  color: red;
  text-decoration: none;
}

.nav-left {
  margin-right: auto;
}

.nav-right {
  display: flex;
  padding-top: 2rem;
}

.post-entry {
  margin-bottom: 2rem;
}

.post-entry h2 {
  margin: 0.5rem 0;
}

.post-entry h2 a,
.post-entry h2 a:visited {
  color: blue;
  text-decoration: none;
}

.post-entry p {
  margin: 0;
  font-weight: 400;
}

.post-entry h2 a:hover {
  color: red;
}

.tag {
    display: inline-block;
    padding: 5;
    margin: 5;
}
EOF

#############################################################
# 8.  Створення окремої сторінкі DetailView для допису блогу
#############################################################

# Створюємо окрему сторінку DetailView для допису, 
# в якій додамо функціонал на персональних сторінках блогу.
# Для цього створимо новий Вигляд (View), налаштування URL маршруту 
# та HTML шаблон.


# 8.1 Створимо новий Вигляд
tee blog/views.py <<'EOF'
# blog/views.py
from django.views.generic import ListView, DetailView # нове
from django.db.models import Q
from django.shortcuts import render

from .models import Post, Tag


class BlogListView(ListView) :
    model = Post
    template_name = 'home.html'

    def get(self, request):
        search = request.GET.get("search", False)
        tag = request.GET.get("tag", False)

        posts = Post.objects.all()
        response = []

        if search :
            query = Q(title__icontains=search)
            posts = posts.filter(query).select_related()

        if tag :
            query = Q(tags__name__icontains=tag)
            posts = posts.filter(query).select_related()
        
        for post in posts:
            tags = post.tags.all()
            response.append({'post': post, 'tags': tags})

        context = {'data' : response, 'search': search, 'tag': tag}
        return render(request, self.template_name, context)


class BlogDetailView(DetailView): # нове
    model = Post
    template_name = 'post_detail.html'

    def get(self, request, pk) :
        selected = Post.objects.get(id=pk)
        tags = Tag.objects.filter(post=selected)

        context = { 'post': selected, 'tags': tags }
        return render(request, self.template_name, context)
EOF

# 8.2 Створимо новий HTML шаблон templates/post_detail.html
#     для перегляду дописів на окремій сторінці
touch templates/post_detail.html

tee templates/post_detail.html <<'EOF'
<!-- templates/post_detail.html -->
{% extends 'base.html' %}

{% block content %}
  <div class="post-entry">
    <h2>{{ post.title }}</h2>
    <p>{{ post.body }}</p>
    {% for tag in tags %}
        <p class="tag" style="background: {{ tag.color }}">{{ tag.name }}</p>
    {% endfor %}
  </div>
{% endblock content %}
EOF

# 8.3 Додамо новий URL маршрут для роботи з окремими дописами у блозі
#     залежно від їхнього ID
#     Django автоматично додає первинний автоінкрементний ключ до
#     моделі бази даних
#     У моделі Post були означені поля title, author та body
#     Django автоматично додав ще одне поле - первинний ключ з назвою id
#     Отримати доступ до цього ключа можна через id або pk
#     Тепер перший допис буде доступний за адресою http://127.0.0.1:8000/post/1/
tee blog/urls.py <<'EOF'
# blog/urls.py
from django.urls import path

from .views import BlogListView, BlogDetailView # нові зміни

urlpatterns = [
    path('post/<int:pk>/', BlogDetailView.as_view(), name='post_detail'), # нові зміни
    path('', BlogListView.as_view(), name='home'),
]
EOF

# 8.4 Оновимо посилання на домашній сторінці, щоб мати з неї доступ до 
#     всіх дописів.
#     У створеному нами файлі templates/home.html посилання <a href=""> 
#     на файл порожнє.
#     Оновимо це посилання як <a href="{% url 'post_detail' post.pk %}">
#     Тепер посилання на домашній сторінці вказуватимуть на сторінки дописів
tee templates/home.html <<'EOF'
<!-- templates/home.html -->
{% extends 'base.html' %}

{% block content %}
    <form>
        <input
            type="search"
            placeholder="Search..."
            name="search"
            {% if search %} value="{{ search }}" {% endif %}>
        <input
            type="search"
            placeholder="Tag..."
            name="tag"
            {% if tag %} value="{{ tag }}" {% endif %}>
        <button type="submit">Search</button>
    </form>

    {% for item in data %}
    <div class="post-entry">
        <h2><a href="{% url 'post_detail' item.post.pk %}">{{ item.post.title }}</a></h2>
        <p>{{ item.post.body }}</p>
        {% for tag in item.tags %}
            <p class="tag" style="background: {{ tag.color }}">{{ tag.name }}</p>
        {% endfor %}
    </div>
    {% endfor %}
{% endblock content %}
EOF


#############################################################
# 9.  Створення TestCase для блогу на Django та тестування
#############################################################

# 9.1 Створимо TestCase для блогу на Django
#     У тесті перевіримо нашу модель та Вигляди/Views
#     Протестуємо загальні класи Виглядів ListView та DetailView
tee blog/tests.py <<'EOF'
# blog/tests.py
from django.contrib.auth import get_user_model
from django.test import TestCase
from django.urls import reverse

from .models import Post


class BlogTests(TestCase):

    def setUp(self):
        self.user = get_user_model().objects.create_user(
            username='testuser',
            email='test@email.com',
            password='secret'
        )

        self.post = Post.objects.create(
            title='A good title',
            body='Nice body content',
            author=self.user,
        )

    def test_string_representation(self):
        post = Post(title='A sample title')
        self.assertEqual(str(post), post.title)

    def test_post_content(self):
        self.assertEqual(f'{self.post.title}', 'A good title')
        self.assertEqual(f'{self.post.author}', 'testuser')
        self.assertEqual(f'{self.post.body}', 'Nice body content')

    def test_post_list_view(self):
        response = self.client.get(reverse('home'))
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, 'Nice body content')
        self.assertTemplateUsed(response, 'home.html')

    def test_post_detail_view(self):
        response = self.client.get('/post/1/')
        no_response = self.client.get('/post/100000/')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(no_response.status_code, 404)
        self.assertContains(response, 'A good title')
        self.assertTemplateUsed(response, 'post_detail.html')
EOF

false && cat <<'EOF'
На початку файла імпортуємо get_user_model для відсилання активних 
User та TestCase, які ми переглянули раніше.
У метод setUp додається зразок допису блогу для тестування та подальшого
підтвердження, що рядки та вміст працюють правильно.
Потім використовується test_post_list_view, який підтверджує, 
що домашня сторінка повертає HTTP код стану 200, містить правильний текст 
у тегу body та використовує правильний шаблон home.html. 
Наприкінці, test_post_detail_view перевіряє, що перегляд сторінкок 
допису працює правильно, а для відсутньої сторінки повертається помилка 404. 
У тестах потрібно проводити перевірку як на наявність певних даних, 
так і на відсутність різноманітних помилок.
EOF

# 9.2 Виконаємо тестування
./manage.py test

# Запустимо сервер
run_django_web_server

exit # Завершимо роботу


#############################################################
# 10. Завантаження файлів блогу на Github
#############################################################

# Завантажуємо файли блогу на Github (при потребі)
git status
git add -A
git commit -m 'initial commit'

# EOF