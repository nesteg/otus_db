# Домашнее задание

Расшифровываем зашифрованный сжатый stream backup-а  :

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Backup/images/openssl.png)

Распаковываем сжатый stream backup-а :

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Backup/images/gzip.png)

Распаковываем stream:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Backup/images/xbstream.png)

Получаем  образ контейнера  mysql и запускаем его в docker:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Backup/images/docker_run_mysql.png)

Запускаем shell в контейре. Создаем базу данных otus:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Backup/images/create_db_otus.png)

Создаем таблицу articles.Выполняем команду discard для созданной таблицы:
 
![Image of PS](https://github.com/nesteg/otus_db/blob/master/Backup/images/create_db_table.png)

Останавливаем контейнер:
 
![Image of PS](https://github.com/nesteg/otus_db/blob/master/Backup/images/docker_stop_mysql.png)

Копируем файл таблицы в директорию данных mysql в контейнере, используя отображение директорий(ключ -v):

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Backup/images/copy_table.png)

Снова запускаем контейнер.
Заходим в shell контейнера и запускаем клиента mysql.
Выполняем  команду: 

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Backup/images/table_import.png) 

Смтрим восстановленные данные из таблицы articles.

























