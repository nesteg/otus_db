# Домашнее задание

Запускаем кластер postgresql в контейнере под именем master на стандартном порту :

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Replica_ps/images/master_ps_run.png)

Запускаем кластер postgresql в контейнере под именем replica на другом порту :

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Replica_ps/images/replica_run.png)

Смотрим диапазон ip адресов выделяемых докером контейнерам:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Arch_ps/images/ip_bridge.png)

Смотрим  ip адрес шлюза, с него мы сделаем backup для реплики:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Arch_ps/images/ip_address_gateway.png)

Смотрим  ip адрес контейнера master:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Arch_ps/images/ip_address_master.png)

Смотрим  ip адрес контейнера replica:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Arch_ps/images/ip_address_container_replica.png)

Настраиваем master для физической репликации через слот:
 
![Image of PS](https://github.com/nesteg/otus_db/blob/master/Arch_ps/images/ip_address_master.png)

Далее в файле $HOME/docker/volume/postgres/postgresql.conf устанавливаем (используем отображение volume докера):

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Arch_ps/images/listen_address.png)

Затем конфигурируем $HOME/docker/volume/postgres/pg_hba.conf (разрешаем доступ к БД и слоту репликации узлам gateway,replica):

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Arch_ps/images/pg_hba_on_master.png) 

Делаем restart кластера postgresql:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Arch_ps/images/reload_container.png) 

Проверяем, что это мастер:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Arch_ps/images/master_recovery.png) 

Смотрим на состояние слота,запросов на реплику нет.Все Ок:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Arch_ps/images/check_replication_slot.png) 

Останавливаем контайнер replica и удаляем все из каталога $HOME/docker/volume/replica командой:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Arch_ps/images/rm_replica_data.png)

Запускаем basckup:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Arch_ps/images/basebackup.png)

Смотрим на состояние слота,есть запрос на реплику-это от backup:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Arch_ps/images/check_replication_slot_after_backup.png) 

Устанавливаем в файле конфигурации replica задержку репликации минимум 5 минут $HOME/docker/volume/replica/postgresql.conf:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Arch_ps/images/min_recovery_5min.png) 

Устанавливаем в файле конфигурации replica  $HOME/docker/volume/replica/postgresql.auto.conf:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Arch_ps/images/replica_auto_conf.png) 

Запускаем кластер postgresql replica и смотрим что он настроен как реплика:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Arch_ps/images/replica_recovery.png) 

Запускаем терминального клиента psql на мастере, создаем базу данных,таблицу и добавляем запись в эту таблицу:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Arch_ps/images/create_table_master.png) 

Запускаем терминального клиента psql на replica, и ждем 5 минут появление базы данных и таблицы:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Arch_ps/images/replica_show_db.png) 

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Arch_ps/images/replica_select.png)

Из последней картинки видно, что таблица country реплицировалась, а данные еще нет.
После пару запросов появились и записи.

Посмотрим состояние слота реплики на master: 

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Arch_ps/images/change_replica_slot.png)










