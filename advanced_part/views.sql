CREATE OR REPLACE VIEW order_full_info AS
SELECT 
    o.order_id,
    o.order_date,
    o.status,

    c.first_name || ' ' || c.last_name AS client_name,

    p.sku,
    p.price,

    o.quantity,
    (p.price * o.quantity) AS total_price,

    w.name AS warehouse_name,
    e.employee_id

FROM "ORDER" o
JOIN CLIENT c ON o.client_id = c.client_id
JOIN PRODUCT p ON o.product_id = p.product_id
JOIN WAREHOUSE w ON o.warehouse_id = w.warehouse_id
JOIN EMPLOYEE e ON o.employee_id = e.employee_id;

CREATE MATERIALIZED VIEW employee_workload_mv AS
SELECT 
    e.employee_id,
    COUNT(o.order_id) AS total_orders,
    COUNT(*) FILTER (WHERE o.status = 'processing') AS processing_orders
FROM EMPLOYEE e
LEFT JOIN "ORDER" o ON e.employee_id = o.employee_id
GROUP BY e.employee_id;