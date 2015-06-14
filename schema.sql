-- DEFINE YOUR DATABASE SCHEMA HERE
CREATE TABLE employees (
  emp_id SERIAL,
  name varchar(255) NOT NULL,
  email varchar(255) UNIQUE,
  PRIMARY KEY (emp_id)
);

CREATE TABLE customers (
  cust_id SERIAL,
  name varchar(255) NOT NULL,
  account_no varchar(20) NOT NULL,
  PRIMARY KEY (cust_id)
);

CREATE TABLE products (
  product_id SERIAL,
  product_name varchar(255) NOT NULL,
  PRIMARY KEY (product_id)
);

CREATE TABLE sales (
  order_id SERIAL,
  invoice_num integer NOT NULL,
  sale_date varchar(255) NOT NULL,
  sale_amount varchar(255) NOT NULL,
  units_sold integer NOT NULL,
  cust_id integer NOT NULL references customers(cust_id),
  emp_id integer NOT NULL references employees(emp_id),
  product_id integer NOT NULL references products(product_id),
  invoice_freq varchar(20),
  PRIMARY KEY (order_id)
);