# Домашнее задание


Сначала настроим журнал медленных запросов в MySQL.В файле конфигурации отредактируем следующие строки:

```
slow-query-log=1
slow_query_log_file="LAPTOP-97I588DP-slow.log"
long_query_time=1
``` 
То есть в файл "LAPTOP-97I588DP-slow.log" будут записываться запросы, время выполнения которых превышают 1 секунду.


Выполним следующий запрос:

```
select  sum(Cnt) as 'К-во предложений',max(Mx) as 'Макс,₽' ,min(Mn) as 'Мин,₽' ,
if(grouping(cat_name),'Все категории',cat_name) as 'Категория' from (
select Cnt,Mx,Mn, get_path_by_id(cat_id) as cat_name 
from ( select prod.category_id as cat_id,
	   count(prod.product_id) as Cnt,
	   max(amount_base)Mx,min(amount_base)Mn
       from products as  prod
       join prices as pr
       on prod.last_price_id=pr.price_id 
       join categorys as cat
       on cat.category_id=prod.category_id
       group by prod.category_id
       )T
 )T1
group by cat_name,Cnt
with rollup
having max(Mx) <> min(Mn)
order by Cnt desc;
```
Если отрыть журнал, то мы увидим что он присутствует в нем с временем выполнения 2.813 секунд.
Значит надо попробовать оптимитизировать этот запрос.
Запустим клиента mysql с подключением к БД customers и выполним следующий запрос(опускаю тело запроса за троеточием):
```
explain ... \G;

```

Результат выполнения:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/PerfomQuery_mysql/images/explain_table_part1_1.png)

Видим, что планировщик использует два запроса - primary(основной) и derived(производный).
В основном запросе  используются (using temporary) временные таблицы и filesort - поле Extra, причем без использования индексов.
Во втором запросе тоже используется временная таблица.
Последние два подзапроса оптимальны, птому что используют индексы, которые автоматически создаются для первичных ключей.

![Image of PS](https://github.com/nesteg/otus_db/blob/master/PerfomQuery_mysql/images/explain_table_part2_2.png)
 
Теперь посмотрим вывод команды explain в формате json:
```
explain format=json ... \G
```
Вывод, для удобства восприятия, разобъем на несколько частей.


![Image of PS](https://github.com/nesteg/otus_db/blob/master/PerfomQuery_mysql/images/explain_json_part1_1.png)


![Image of PS](https://github.com/nesteg/otus_db/blob/master/PerfomQuery_mysql/images/explain_json_part2_1.png)

Здесь мы видим, что для материализации подзапроса создается временная таблица(отметим это для себя)

Последующие части относятся к операции inner join таблиц products:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/PerfomQuery_mysql/images/explain_json_part3_1.png) 

,prices:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/PerfomQuery_mysql/images/explain_json_part5_1.png) 

,categorys:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/PerfomQuery_mysql/images/explain_json_part4_1.png) 

Можно еще прсмотреть план в виде дерева. Для этого используется запрос:
```
explain format=tree ... \G
```

Но мы запустим другой запрос. Он тоже представляет план запроса в виде дерева, 
но также выполняет этот запрос и ставит у каждого узла дерева,кроме стоимости, время выполнения, что очень удобно для анализа:

```
explain analyze ... \G
``` 

и результаты вывода:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/PerfomQuery_mysql/images/explain_tree_1.png) 

Обращаем внимание на узел "Materialize  (actual time=1070.067..1070.257 rows=137 loops=1)".  Надо попытаться уменьшить время выполнения.
Это достигается, если переделать запрос выкинув внутренний select:
```
select  sum(Cnt) as 'К-во предложений',max(Mx) as 'Макс,₽' ,min(Mn) as 'Мин,₽' ,
if(grouping(cat_id),'Все категории',get_path_by_id(cat_id)) as 'Категория' from (
 select cat.category_id as cat_id,
	   count(prod.product_id) as Cnt,
	   max(pr.amount_base)Mx,min(pr.amount_base)Mn
       from products as  prod
       join prices as pr
       on prod.last_price_id=pr.price_id 
       join categorys as cat
       on cat.category_id=prod.category_id
       group by prod.category_id
       )T
group by cat_id,Cnt
with rollup
having max(Mx) <> min(Mn)
order by Cnt desc;
```

Повторяем запрос с посроением дерева плана и выполнением. Видно что время запроса уменьшилось:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/PerfomQuery_mysql/images/explain_tree_2_1.png) 

Но основной запрос все равно больше 1 секунды:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/PerfomQuery_mysql/images/explain_tree_2.png) 

Если пойти вверх по дереву, то можно увидеть следующий узел, в котором время резко увеличивается, а дальше меняется незначительно:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/PerfomQuery_mysql/images/explain_tree_2_2.png) 

Если посмотреть на текст запроса, то во внешнем select можно увидеть использование функции get_path_by_id.
Значит надо проанализировать ее план. Тело функции следующее (это рекурсивный cte):

```
 with recursive a(Parent,Name,CategoryId,level,pathstr) as 
( 
   select t1.parent,t1.name,t1.category_id,0 as level,cast(t1.name as char(255)) as pathstr from categorys as t1
   where t1.parent is null
   union all
   select t2.parent,t2.name,t2.category_id,ct.level+1,concat(ct.pathstr,'\\', t2.name) as pathstr from a ct
   join categorys as t2
   on (t2.parent=ct.CategoryId)
 
)

select pathstr 
from a
where CategoryId=35
limit 1; 
```

Здесь входящий параметр id заменен на конкретное значение 35.
Смотрим на план построенный

```
 explain ... \G
```


Видим, что для доступа к ряду в  таблице t1 используется Using where c значением фильтра 10.0(filtered):

![Image of PS](https://github.com/nesteg/otus_db/blob/master/PerfomQuery_mysql/images/explain_table_func_part1_1.png)

,а в таблице t2 используется Using where c значением фильтра 4.55 (filtered):

![Image of PS](https://github.com/nesteg/otus_db/blob/master/PerfomQuery_mysql/images/explain_table_func_part2_1.png)

Поскльку t1 и t2 псевдонимы таблицы categorys,и для более быстрого поиска лучше использовать индекс,
построим индекс на поле parent:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/PerfomQuery_mysql/images/add_index.png) 

Смотрим обновленный план:

![Image of PS](https://github.com/nesteg/otus_db/blob/master/PerfomQuery_mysql/images/explain_table_func_part1_2.png.png) 

и

![Image of PS](https://github.com/nesteg/otus_db/blob/master/PerfomQuery_mysql/images/explain_table_func_part2_2.png)


Индекс включился.Смотрим время исполнения:

[Image of PS](https://github.com/nesteg/otus_db/blob/master/PerfomQuery_mysql/images/explain_tree_func_2.png) 

Ок.Запускаем основной запрос:

[Image of PS](https://github.com/nesteg/otus_db/blob/master/PerfomQuery_mysql/images/explain_tree_func_3.png) 

Запрос стал меньше 1 секунды.

Вывод:
Удалось оптимитизировать запрос изменением тела запроса(удаление внутреннего select)
и добавлением индекса на поле parent в таблице categorys .   

