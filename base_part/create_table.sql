
-- создание схемы
CREATE SCHEMA logistics;
SET search_path TO logistics;

-- создание таблиц
CREATE TABLE warehouse (
    warehouse_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(250) NOT NULL
);

CREATE TABLE client (
    client_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE employee (
    employee_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    position VARCHAR(50) NOT NULL CHECK (position <> ' ')
);

CREATE TABLE supplier (
    supplier_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact_info TEXT NOT NULL
);

-- зависимые таблицы

CREATE TABLE product (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    sku VARCHAR(50) NOT NULL UNIQUE,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    supplier_id INT NOT NULL,
    quantity_on_hand INT NOT NULL DEFAULT 0 CHECK (quantity_on_hand >= 0),

    CONSTRAINT fk_product_supplier
        FOREIGN KEY (supplier_id)
        REFERENCES supplier(supplier_id)
        ON DELETE RESTRICT
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    order_date DATE NOT NULL DEFAULT CURRENT_DATE,
    status VARCHAR(20) NOT NULL CHECK (
        status IN ('new','processing','shipped','delivered','cancelled')
    ),

    client_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    employee_id INT NOT NULL,
    product_id INT NOT NULL,

    quantity INT NOT NULL CHECK (quantity > 0),

    CONSTRAINT fk_order_client
        FOREIGN KEY (client_id)
        REFERENCES client(client_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_order_warehouse
        FOREIGN KEY (warehouse_id)
        REFERENCES warehouse(warehouse_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_order_employee
        FOREIGN KEY (employee_id)
        REFERENCES employee(employee_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_order_product
        FOREIGN KEY (product_id)
        REFERENCES product(product_id)
        ON DELETE RESTRICT
);