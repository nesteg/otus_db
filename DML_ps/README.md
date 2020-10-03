# Домашнее задание



```

```

Запрос с оператором where и join , который возвращает список всех проданных товаров в 2019 году:

```
select  p.name ,b.unit,b.amount,c.short_name as currency from selling.products as p
join selling.buys as b
on p.product_id=b.product_id
join selling.currency as c
on b.currency_id=c.currency_id
where '2019-01-01 0:0:0' = (select date_trunc('year',b.date_buy))
```

  Запрос с оператором where и join, который возвращает список всех проданных телевизоров в  2019 году жителям,
например города London:

```
select * from selling.buys as b
join customers.customs as cust
on b.custom_id=cust.custom_id
join customers.customs_addresses as ca 
on cust.custom_id=ca.custom_id
join customers.addresses as a 
on a.address_id=ca.address_id
join customers.substreets as s
on a.substreet_id=s.substreet_id
join customers.streets as str
on s.street_id=str.street_id
join customers.subtowns as stwn
on s.subtown_id=stwn.subtown_id
join customers.towns as twn
on stwn.town_id=twn.town_id
join selling.currency as c
on b.currency_id=c.currency_id
where twn.town like 'London'
and '2019-01-01 0:0:0' = (select date_trunc('year',b.date_buy))
```

Добавление строки в таблицу c возратом id вставленной строки:

```
insert into customers.countrys(symbols,full_name) values('RU','Russia')
returning country_id
```

  Пример запроса с left join, который возвращает список  всех товаров, и проданных хотя бы один раз, и не проданных.
Ели товар не продан,то поле byu будет равно 0.
Поскольку слева оператора left join стоит таблица products, то из нее будут выбраны все записи,
а отсутствующие в таблице продаж buys будут выбраны как null: 

```
select  distinct p.name as prod_name,c.name as cat_name,(not b.unit is null)::int as buy  from selling.products as p
left join selling.buys as b
on p.product_id=b.product_id
join selling.categorys as c
on p.category_id=c.category_id
```

Удаляем все продукты принадлежащие категории и саму категорию:

```
delete from selling.products using selling.categorys cat
where cat.category_id = 3
```







