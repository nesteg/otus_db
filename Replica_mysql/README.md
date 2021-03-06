# Домашнее задание


### Предполагаемый размер БД
Размер БД грубо оценим  по предполагаемым количеством покупателей, продуктов и числа покупок в среднем за сутки.
При добавлении 1154 пользователей суммарный  размер таблиц (данные и индексы)  для хранения данных пользователей и их 
адресов (исходя из преположения , что большинство будут иметь 1 адрес)  равен Мб: 

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Replica_mysql/images/size_custom.png)

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Replica_mysql/images/count_customs.png)

Средний объем записи равен 855,7 байт. При миллионе записей пользователей общий объем памяти 
занимаемой соответствующими таблицами составит 857Мб. 

При количестве записей в таблице products 25696 и связанных с ней таблиц все вместе занимают 20,97 Мб: 

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Replica_mysql/images/size_product.png)

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Replica_mysql/images/count_product.png)

Средний объем записи равен 855,7 байт. Тогда при номенклатуре продуктов в 500000 позиций общий размер
будет равен 408,04 Мб
 
При количестве записей 612936  таблица buys занимает 63,36 Мб:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Replica_mysql/images/size_buys.png)

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Replica_mysql/images/count_buys.png)

Средний размер записи составляет 108,4 байт.Тогда за сутки мы получим увелечение размера таблицы buys на 1,03 Мб. 
Итого за год у нас увеличится размер таблицы до 376 Мб.
В сумме при заданных допущениях (1000000 зарегистрированных покупателей, 500000 позиций товара и среднесуточный объем продаж 10000 покупок )  за год эксплуатации БД мы получим размер БД (это грубо) примерно  857 + 408 + 376 = 1,64 Gb. 

### Репликация БД
Обычно репликацию в большей мере используют для резервирования. Для этого  хорошо подходит тип репликации Master-Slave.Рекомендуется использовать, как минимум 2 Slave, что позволит распределять запросы на чтение между 2 Slave-амим.А запросы на изменение данных отправлять на мастер. Для этого предлагается  использовать ProxySQL. Рекомендуется использовать асинхронный режим репликации между Master и Slave. В отличии от сихронного режима это позволит легче поддерживать производительность SQL сервера на достаточном уровне. Также необходимо учитывать, что при асинхронном режиме изменения на Master не появляются сразу же на Slave - есть задержка. Это надо учитывать в приложении при последовательных операциях записи и чтения. Можно начать с конфигурации, в которой используетя один Slave, увеличивая их количество по мере необходимости.

### Резервное копирование БД
Поскольку условия эксплуатации базы данных предполагают довольно частое изменение сохраняемой информации (добавление новых клиентов, товаров и их характеристик,обновление цен,покупки) ,то предлагается смешанное дифференциальное резервное копирование.Раз в неделю производиться полный бэкап,каждые сутки дифференцированный. Лучше всего использовать для этого специализированное ПО, которое позволяет автоматизировать рутинные операции, например создание бэкапа по расписанию,выбор типа бэкапа и т.д.Также надо учитывать, что с увеличением нагрузки и увеличением объема данных возможно придется менять стратегию резервного архивировния. Непосредсвенно для создания бэкапов выбрана Percona XtraBackup.

### Безопасность БД
Для выполения условий безопасности БД необходимо выполнение следующих действий и мероприятий:
1. К файлам БД имеет доступ только DBA.
2. Создание ролей для определенных действий над таблицами БД.
3. Периодическая смена паролей у DBA и ролей.
4. Периодический аудит действий ролей, который может выявить не стандартное (не обычное) поведение для 
    выбранной роли. 

















