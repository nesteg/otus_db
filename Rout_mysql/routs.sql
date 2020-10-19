DELIMITER $$
USE `customers`$$
CREATE PROCEDURE `get_products` (IN category varchar(60),
                                                     IN orderfield smallint,
                                                     IN min_price decimal(10,2),
                                                     IN max_price decimal(10,2),
                                                     IN manufacturer varchar(60),
                                                     IN color varchar(40),
                                                     IN pagenumber integer,
                                                     IN pagesize integer)
SQL SECURITY INVOKER
BEGIN
DECLARE msg VARCHAR(255);
if category is null then 
    signal sqlstate '45000' set message_text = 'category не определен';
end if;
if orderfield < 1 or orderfield > 3 then
    signal sqlstate '45000' set message_text = 'orderfield должен быть 1(name) или 2(amount) или 3(color)';
end if;
if min_price < 0 then 
    set min_price = 0;
end if;    
select category_id into @cat_id from 
(select c.category_id,c.name,c.parent,cat.category_id as leaf  from categorys as c
left join categorys as cat 
on c.category_id = cat.parent
)T
where T.leaf is null
and name = category;
if @cat_id is null then
   set msg = concat('категория ',category,' не найденa');
   signal sqlstate '45000' set message_text = msg;
end if;
select prod.name,pr.amount_base as amount,prod.color from products as prod
join prices as pr
on pr.price_id = prod.last_price_id
join manufacturers as m
on prod.manufacturer_id = m.manufacturer_id
where category_id = @cat_id
and pr.amount_base between min_price and max_price
and m.manufacturer = manufacturer
and prod.color regexp color
order by case 
        when orderfield = 1 then name
        when orderfield = 2 then amount
        when orderfield = 3 then color
        end asc
limit pagenumber,pagesize;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure get_orders
-- -----------------------------------------------------

DELIMITER $$
USE `customers`$$
CREATE PROCEDURE `get_orders` (IN  start datetime,
                               IN  ival tinyint,
                               IN  grp tinyint
                               )
SQL SECURITY INVOKER
BEGIN
DECLARE finish datetime;
DECLARE check_start datetime;
set check_start = coalesce(start,'01.01.2020');
if ival < 1 or orderfield > 3 then
    signal sqlstate '45000' set message_text = 'ival должен быть 1(1 час) или 2(1 день) или 3(7 дней)';
end if;
if grp < 1 or grp > 3 then
    signal sqlstate '45000' set message_text = 'grp должен быть 1(группировка по продукту) или 2(группировка по категории) или 3(группировка по производителю)';
end if;
set finish = case ival 
                  when 1 then DATE_ADD(start,INTERVAL 1 HOUR) 
                  when 2 then DATE_ADD(start,INTERVAL 1 DAY)
                  when 3 then DATE_ADD(start,INTERVAL 7 DAY)
             end;
select case grp 
             when 1 then any_value(p.name)
             when 2 then any_value(c.name)
             when 3 then any_value(m.manufacturer)
       end,      
sum(b.amount*b.unit) as amount,
cur.symbol as currency from buys as b
join products as p
on p.product_id=b.product_id
join categorys as c
on p.category_id=c.category_id
join manufacturers as m
on p.manufacturer_id=m.manufacturer_id
join currency as cur
on b.currency_id = cur.currency_id
where date_buy between start and finish
group by case grp
               when 1 then p.product_id
               when 2 then p.category_id
               when 3 then p.manufacturer_id
          end,
          cur.currency_id;
END$$

DELIMITER ;
