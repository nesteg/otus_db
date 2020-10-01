# Домашнее задание

Запускаем терминального клиента psql c с логином postgres и соединением к базе данных postgres.
Создаем роль администратора новой БД:

```
CREATE ROLE dba
CREATEDB
CREATEROLE
REPLICATION
LOGIN
PASSWORD 'docker';
```

Создаем tablespace:

```
CREATE TABLESPACE fastspace 
OWNER dba 
LOCATION '/mnt/sdd/postgresql/data';
```

Переключаемся с логином dba:

```
\c - dba
```

Создаем БД eshop:

```
CREATE DATABASE eshop OWNER dba;
```

Подключаемся к ней:

```
\c eshop
```

Создаем следующие схемы:

```
CREATE SCHEMA IF NOT EXISTS customers;
CREATE SCHEMA IF NOT EXISTS selling;
```

Создаем 2 роли со следующими опциями:

```
CREATE ROLE writer
LOGIN
PASSWORD 'dock0wrt'
CONNECTION LIMIT 100;

CREATE ROLE reader
LOGIN
PASSWORD 'dock5rdr'
CONNECTION LIMIT 1000;
```

Устанавливаем для них следующие разрешения:

```
GRANT SELECT ON ON ALL TABLES IN SCHEMA customers,selling TO reader;

GRANT SELECT, UPDATE, INSERT, DELETE ON ALL TABLES IN SCHEMA customers,selling TO writer;
```


Выходим из psql и выполняем скрипт создания структуры БД:

```
 psql -h localhost -U dba -d eshop  < init_db.sql
```





