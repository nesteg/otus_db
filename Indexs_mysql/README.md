# Домашнее задание

Проведем тест насколько влияет на скорость запроса наличие индекса на то или иное поле в таблице.
В качестве таблицы возьмем products, в качестве индексируемого поля color.
В таблице продуктов содержится:  

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Indexs_mysql/images/count_query_products.png)

Для начала отключим индекс:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Indexs_mysql/images/alter_color_invisible.png)

Установим флаг разрешающий профилирование запросов:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Indexs_mysql/images/set_profiling.png)

Выполним 3 запроса подряд(сразу же после холодного старта):

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Indexs_mysql/images/query.png)

Смотрим результаты профилирования:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Indexs_mysql/images/query_without_ index.png)

Смотрим результаты работы планировщика запроса:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Indexs_mysql/images/expline_withot_index.png)

Видим, что для того, чтобы найти строки удовлетворяющие условию в запросе происходит полное сканирование
таблицы, при этом возвращается 10% просканированных строк. Это очень не эффективно и при росте числа строк
и исчерпании кэша данный запрос начнет сильно "тормозить".

Теперь включим индекс и перезапустим MySql.Выполним предыдущих 3 запроса подряд.
Смотрим результаты профилирования:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Indexs_mysql/images/query_with_index.png)

Видим, что и при "холодном" старте и в "прогретом" состоянии время запроса уменьшилось.

Смотрим результаты работы планировщика запроса:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Indexs_mysql/images/expline_with_index.png)

Видно, что у нас при поиске строк задействуется именно необходимый индекс fk_products_color, при чем 
без обращения к таблице(поле Extra:null)."Качество" индекса отличное(поле Filter:100%).

Вывод:грамотное применение индексов для запросов позволяет увеличить производительность работы БД.



Также пример запроса, при которм  используются fulltext индексы:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/Indexs_mysql/images/full_text_query.png)


















