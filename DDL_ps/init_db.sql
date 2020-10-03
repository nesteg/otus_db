
CREATE TABLE IF NOT EXISTS customers.countrys(
	country_id smallserial PRIMARY KEY,
  	symbols    varchar(2) NOT NULL,
  	full_name  varchar(45) DEFAULT NULL,
        UNIQUE(symbols),
        UNIQUE(full_name)
);

CREATE TABLE IF NOT EXISTS customers.regions(
	region_id smallserial PRIMARY KEY,
        region varchar(80)  DEFAULT NULL ,
        country_id integer  REFERENCES customers.countrys
);

CREATE TABLE IF NOT EXISTS customers.postalcodes(
	postalcode_id serial PRIMARY KEY,
	postalcode varchar(24) NOT NULL CHECK(postalcode > ''),
	region_id integer  REFERENCES customers.regions
);

CREATE TABLE IF NOT EXISTS customers.towns(
	town_id serial PRIMARY KEY,
        town varchar(100) DEFAULT NULL,
        UNIQUE(town)
);

CREATE TABLE IF NOT EXISTS customers.subtowns(
	subtown_id serial PRIMARY KEY,
  	town_id     integer REFERENCES customers.towns,
  	postalcode_id integer REFERENCES customers.postalcodes
);

CREATE TABLE IF NOT EXISTS customers.streets(
	street_id serial PRIMARY KEY,
        street varchar(120) DEFAULT NULL,
        UNIQUE(street)
);

CREATE TABLE IF NOT EXISTS customers.substreets(
	substreet_id serial PRIMARY KEY,
  	street_id   integer  REFERENCES customers.streets,
  	subtown_id  integer  REFERENCES customers.subtowns
);

CREATE TABLE IF NOT EXISTS customers.addresses(
	address_id serial PRIMARY KEY,
	house varchar(12) DEFAULT NULL ,
	substreet_id integer REFERENCES customers.substreets
);

CREATE TABLE IF NOT EXISTS customers.languages(
	language_id serial PRIMARY KEY,
        language varchar(100) DEFAULT NULL,
        UNIQUE(language)
);

CREATE TABLE IF NOT EXISTS customers.gender(
	gender_id serial PRIMARY KEY,
        gender varchar(100) DEFAULT NULL,
        UNIQUE(gender)
);


CREATE TABLE IF NOT EXISTS customers.titles(
	title_id serial PRIMARY KEY,
        title varchar(100) DEFAULT NULL,
        UNIQUE(title)
);


CREATE TABLE IF NOT EXISTS customers.customs(
	custom_id serial PRIMARY KEY,
	gender_id integer REFERENCES customers.gender,
	title_id  integer REFERENCES customers.titles,
	birthday date DEFAULT NULL ,
	marital_status bit(1) DEFAULT NULL,
	language_id integer REFERENCES customers.languages,
	first_name  varchar(100) DEFAULT NULL,
	last_name   varchar(100) DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS customers.customs_addresses (
	custom_id integer REFERENCES customers.customs,
	address_id  integer REFERENCES customers.addresses
);



CREATE TABLE IF NOT EXISTS  selling.currency (
	currency_id serial PRIMARY KEY,
	symbol varchar(1) NOT NULL,
	short_name varchar(3) DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS  selling.changes(
	currency_id integer REFERENCES selling.currency,
	date  TIMESTAMP WITH TIME ZONE NOT NULL,
	ratio decimal(10,0) DEFAULT NULL,
	PRIMARY KEY (currency_id,date)
)TABLESPACE fastspace;


CREATE TABLE IF NOT EXISTS selling.categorys (
	category_id serial PRIMARY KEY,
	name varchar(60) NOT NULL,
	parent integer  DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS selling.manufacturers (
	manufacturer_id serial PRIMARY KEY,
	manufacturer varchar(100)  NOT NULL CHECK(manufacturer <> ''),
	address varchar(120) NOT NULL CHECK(manufacturer <> ''),
	email varchar(18) DEFAULT NULL,
	country char(2)  DEFAULT NULL
);


CREATE TABLE IF NOT EXISTS selling.shippers(
	shipper_id serial PRIMARY KEY,
	shipper varchar(80)  NOT NULL, 
	address varchar(100)  NOT NULL, 
	email varchar(18)  DEFAULT NULL 
);

COMMENT ON COLUMN selling.shippers.shipper_id IS 'Ключ поставщика';
COMMENT ON COLUMN selling.shippers.shipper IS 'Название поставщика';
COMMENT ON COLUMN selling.shippers.address IS 'адрес поставщика';
COMMENT ON COLUMN selling.shippers.email  IS 'email.может не быть';

CREATE TABLE IF NOT EXISTS selling.products(
	product_id serial PRIMARY KEY,
	name varchar(80) NOT NULL,
	manufacturer_id integer REFERENCES selling.manufacturers,
	category_id integer REFERENCES selling.categorys,
	propertys jsonb DEFAULT NULL ,
	last_price_id integer DEFAULT NULL
)TABLESPACE fastspace;

COMMENT ON COLUMN selling.products.product_id IS 'Ключ продукта';
COMMENT ON COLUMN selling.products.name IS 'Название продукта';
COMMENT ON COLUMN selling.products.manufacturer_id IS 'Производитель продукта';
COMMENT ON COLUMN selling.products.category_id IS 'Кюч категории к которой относится товар';
COMMENT ON COLUMN selling.products.propertys IS 'Cвойства товарa, такие как (габариты,масса,цвет,упаковка и т.д)';
COMMENT ON COLUMN selling.products.last_price_id IS 'Последний id цены в таблице prices для продукта';

CREATE TABLE IF NOT EXISTS selling.shippers_products(
	shipper_id integer REFERENCES selling.shippers,
	product_id integer REFERENCES selling.products
);

COMMENT ON COLUMN selling.shippers_products.shipper_id IS 'Ключ поставщика';
COMMENT ON COLUMN selling.shippers_products.product_id IS 'Ключ производителя';

CREATE TABLE IF NOT EXISTS selling.prices (
	price_id bigserial PRIMARY KEY,
	product_id integer REFERENCES selling.products,
	currency_id integer REFERENCES selling.currency,
	date_from TIMESTAMP WITH TIME ZONE NOT NULL ,
	date_to TIMESTAMP WITH TIME ZONE NOT NULL ,
	amount_base decimal(10,2) NOT NULL
)TABLESPACE fastspace;

COMMENT ON COLUMN selling.prices.price_id IS 'Кюч цены для некоторого продукта';
COMMENT ON COLUMN selling.prices.product_id IS 'Внешний ключ продукта';
COMMENT ON COLUMN selling.prices.currency_id IS 'Ключ базовой валюты';
COMMENT ON COLUMN selling.prices.date_from IS 'Дата выставления цены';
COMMENT ON COLUMN selling.prices.date_to IS 'Дата окончания действия текущей цены';

CREATE TABLE IF NOT EXISTS selling.attributes(
	attribute_id serial PRIMARY KEY,
	name varchar(80)  NOT NULL,
	type varchar(9)  NOT NULL ,
	default_value varchar(12)  NOT NULL ,
	measurement_unit varchar(12) DEFAULT NULL
);

COMMENT ON COLUMN selling.attributes.attribute_id IS 'Ключ аттрибут';
COMMENT ON COLUMN selling.attributes.name IS 'Имя аттрибута';
COMMENT ON COLUMN selling.attributes.type  IS 'Тип значения аттрибута';
COMMENT ON COLUMN selling.attributes.default_value IS  'Значение по умолчанию';

CREATE TABLE IF NOT EXISTS selling.products_attributes(
	attribute_id integer REFERENCES selling.attributes,
	product_id integer REFERENCES selling.products,
	value_int integer DEFAULT NULL,
	value_flt real DEFAULT NULL ,
	value_varchar varchar(1000) DEFAULT NULL ,
	value_datetime TIMESTAMP WITH TIME ZONE DEFAULT NULL ,
	value_year date DEFAULT NULL 
);

COMMENT ON COLUMN selling.products_attributes.attribute_id IS 'Внешний ключ на перв. ключ аттрибута';
COMMENT ON COLUMN selling.products_attributes.product_id IS 'Внешний ключ на перв. ключ продукта';
COMMENT ON COLUMN selling.products_attributes.value_int IS 'Содержит целочисленные значения';
COMMENT ON COLUMN selling.products_attributes.value_flt IS 'Содержит вещественные.Обычно тип float достаточен';
COMMENT ON COLUMN selling.products_attributes.value_varchar IS 'Текст - используем varchar';
COMMENT ON COLUMN selling.products_attributes.value_datetime IS 'Дата и время';
COMMENT ON COLUMN selling.products_attributes.value_year IS 'Просто год.Например год выпуска продукта';




CREATE TABLE IF NOT EXISTS selling.buys (
	custom_id integer REFERENCES customers.customs,
	product_id integer REFERENCES selling.products,
	date_buy TIMESTAMP WITH TIME ZONE DEFAULT NULL,
	amount decimal(10,2) NOT NULL,
	unit smallint NOT NULL,
	currency_id integer REFERENCES selling.currency 
) TABLESPACE fastspace; 

COMMENT ON COLUMN selling.buys.custom_id IS 'Ключ клиента,который купил';
COMMENT ON COLUMN selling.buys.product_id IS 'Ключ продукта,который купили';
COMMENT ON COLUMN selling.buys.date_buy IS 'Время и дата покупк';
COMMENT ON COLUMN selling.buys.amount IS 'Цена в национальной валюте';
COMMENT ON COLUMN selling.buys.unit IS 'Количество штук';
COMMENT ON COLUMN selling.buys.currency_id IS 'Валюта покупки';


