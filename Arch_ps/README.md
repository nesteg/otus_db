# Домашнее задание

##### Условие:
1. Развернуть контейнер с PostgreSQL или установить СУБД на виртуальную машину.
2. Запустить сервер.
3. Создать клиента с подключением к базе данных postgres через командную строку.
4. Подключиться к серверу используя pgAdmin или другое аналогичное приложение.
##### Результаты:

Скачиваем image контейнера с postgresql версии 12

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Arch_ps/images/docker_ps_pull.png)

Убеждаемся , что он есть

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Arch_ps/images/docker_ps_images.png)

Запускаем кластер postgresql в контейнере

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Arch_ps/images/docker_ps_run.png)

Убеждаемся , что он стартовал

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Arch_ps/images/docker_ps_cont.png)

Запускаем терминального клиента psql

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Arch_ps/images/psql_run.png)

Запускаем оконный менеджер phAdmin 4. На картинке видим , что подключено два клиента

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Arch_ps/images/pgAdmin_4.png)

