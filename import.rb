# Use this file to import the sales information into the
# the database.

require "pg"
require "csv"

def db_connection
  begin
    connection = PG.connect(dbname: "korning")
    yield(connection)
  ensure
    connection.close
  end
end

@sales = CSV.read('sales.csv')
@sales.shift

def populate_employees_table
  @employees = {}
  @sales.each do |sale|
    emp = sale[0].gsub(/[)]/, "").split("(")
    @employees[emp[0].strip] = emp[1]
  end

  db_connection do |conn|
    @employees.each do |key, value|
      conn.exec_params("INSERT INTO employees (name, email) VALUES ($1, $2)", [key, value])
    end
  end
end

def populate_customers_table
  @customers = {}
  @sales.each do |sale|
    cust = sale[1].gsub(/[)]/, "").split("(")
    @customers[cust[0].strip] = cust[1]
  end

  db_connection do |conn|
    @customers.each do |key, value|
      conn.exec_params("INSERT INTO customers (name, account_no) VALUES ($1, $2)", [key, value])
    end
  end
end

def populate_products_table
  @products = []
  @sales.each do |sale|
    @products << sale[2]
  end
  @products.uniq!
  db_connection do |conn|
    @products.each do |product|
      conn.exec_params("INSERT INTO products (product_name) VALUES ($1)", [product])
    end
  end
end

def populate_sales_table
  insert = "INSERT INTO sales (
              invoice_num,
              sale_date,
              sale_amount,
              units_sold,
              cust_id,
              emp_id,
              product_id,
              invoice_freq
            )
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8)"

  db_connection do |conn|
    @sales.each do |sale|
      cust_name = sale[1].split("(").first.strip
      emp_name = sale[0].split("(").first.strip
      cust_id = conn.exec_params("select cust_id from customers where name = $1", [cust_name])
      emp_id = conn.exec_params("select emp_id from employees where name = $1", [emp_name])
      product_id = conn.exec_params("select product_id from products where product_name = $1", [sale[2]])
      conn.exec_params(insert, [sale[6].to_i, sale[3], sale[4], sale[5].to_i, cust_id[0]["cust_id"],
        emp_id[0]["emp_id"], product_id[0]["product_id"], sale[7]])
    end
  end
end

populate_employees_table
populate_customers_table
populate_products_table
populate_sales_table