# Домашнее задание

Запускаем кластер postgresql в контейнере под именем master на стандартном порту :

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Replica_ps/images/master_ps_run.png)

Запускаем кластер postgresql в контейнере под именем replica на другом порту :

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Replica_ps/images/replica_run.png)

Смотрим диапазон ip адресов выделяемых докером контейнерам:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Replica_ps/images/ip_bridge.png)

Смотрим  ip адрес шлюза, с него мы сделаем backup для реплики:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Replica_ps/images/ip_address_gateway.png)

Смотрим  ip адрес контейнера master:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Replica_ps/images/ip_address_master.png)

Смотрим  ip адрес контейнера replica:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Replica_ps/images/ip_address_container_replica.png)

Настраиваем master для физической репликации через слот:
 
![Image of PS](https://github.com/nesteg/otus_db/blob/master/Replica_ps/images/ip_address_master.png)

Далее в файле $HOME/docker/volume/postgres/postgresql.conf устанавливаем listen_addresses (используем отображение volume докера):

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Replica_ps/images/listen_address.png)

Затем конфигурируем $HOME/docker/volume/postgres/pg_hba.conf (разрешаем доступ к БД и слоту репликации узлам gateway,replica):

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Replica_ps/images/pg_hba_on_master.png) 

Делаем restart кластера postgresql:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Replica_ps/images/reload_container.png) 

Проверяем, что это мастер:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Replica_ps/images/master_recovery.png) 

Смотрим на состояние слота,запросов на реплику нет.Все Ок:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Replica_ps/images/check_replications_slot.png) 

Останавливаем контайнер replica и удаляем все из каталога $HOME/docker/volume/replica командой:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Replica_ps/images/rm_replica_data.png)

Запускаем backup:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Replica_ps/images/basebackup.png)

Смотрим на состояние слота,есть запрос на реплику-это от backup:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Replica_ps/images/check_replications_slot_after_backup.png) 

Устанавливаем в файле конфигурации replica задержку репликации минимум 5 минут $HOME/docker/volume/replica/postgresql.conf:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Replica_ps/images/min_recovery_5min.png) 

Устанавливаем в файле конфигурации replica  $HOME/docker/volume/replica/postgresql.auto.conf:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Replica_ps/images/replica_auto_conf.png) 

Запускаем кластер postgresql replica и смотрим что он настроен как реплика:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Replica_ps/images/replica_recovery.png) 

Запускаем терминального клиента psql на мастере, создаем базу данных eshop, таблицу и добавляем запись в эту таблицу:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Replica_ps/images/create_table_master.png) 

Запускаем терминального клиента psql на replica, и ждем 5 минут появление базы данных и таблицы:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Replica_ps/images/replica_show_db.png) 

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Replica_ps/images/replica_select.png)

Из последней картинки видно, что таблица country реплицировалась, а данные еще нет.
После пары запросов появились и записи.

Посмотрим состояние слота реплики на master.Поле active стало t(true),
изменилось зачение у поля restart_lsn: 

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Replica_ps/images/change_replica_slot.png)

Вывод - физическая реплика работает.

Теперь настройка логической реплики.

В файле $HOME/docker/volume/postgres/postgresql.conf устанавливаем wal_level = logical:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Replica_ps/images/logical_master_wal.png)

Делаем restart кластера master postgresql.

Далее стартуем еще один кластер postgresql replicalogic:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Replica_ps/images/replicalogic_start.png)

Таким же образом  настраиваем его конфигурационный файл  $HOME/docker/volume/replicalogic/postgresql.conf
и делаем restart replicalogic.
Запускаем  клиента psql с подсоединением к replicalogic, создаем таблицу, такую же которую хотим реплицировать
с master и подписку :

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Replica_ps/images/logic_subscription_create.png)

Запускаем  клиента psql с подсоединением к master, создаем публикацию :

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Replica_ps/images/logic_publication_create.png)

Идем в клиент psql к replicalogic и выполняем refresh publication :

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Replica_ps/images/logic_sub_after_publish.png)

Из картинки видим , что записи реплицировались.

Затем в клиенте psql master добавляем запись в таблицу:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Replica_ps/images/logic_pub_insert_row.png)

Смотрим, что произошло в replicalogic:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Replica_ps/images/logic_sub_after_add_row.png)

Из картинки видим , что запись появилась на replicalogic.

Также привожу результаты запроса "select * from pg_replication_slots \gx" для  логического слота:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Replica_ps/images/replication_slots.png)

и результаты запроса "select * from pg_stat_replication \gx" :

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Replica_ps/images/logic_stat.png)


Вывод - логическая репликация настроена и работает.





















