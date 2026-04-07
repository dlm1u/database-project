-- Запрос 1: Товары с низким остатком
-- Помогает выявить позиции, которые могут скоро закончиться
SELECT 
    p.product_id,
    p.name,
    p.quantity_on_hand
FROM PRODUCT p
WHERE p.quantity_on_hand < (
    SELECT AVG(quantity_on_hand) FROM PRODUCT
)
ORDER BY p.quantity_on_hand ASC;



-- Запрос 2: Топ-5 самых отгружаемых товаров
-- Показывает самые популярные товары по количеству продаж
SELECT 
    p.name,
    SUM(o.quantity) AS total_sold
FROM "ORDER" o
JOIN PRODUCT p ON o.product_id = p.product_id
WHERE o.status IN ('shipped', 'delivered')
GROUP BY p.name
ORDER BY total_sold DESC
LIMIT 5;



-- Запрос 3: Количество заказов по каждому складу
-- Оценивает загрузку складов
SELECT 
    w.name,
    COUNT(o.order_id) AS total_orders
FROM WAREHOUSE w
LEFT JOIN "ORDER" o ON w.warehouse_id = o.warehouse_id
GROUP BY w.name
ORDER BY total_orders DESC;



-- Запрос 4: Самые активные клиенты (3+ заказов)
SELECT 
    c.client_id,
    c.first_name,
    c.last_name,
    COUNT(o.order_id) AS orders_count
FROM CLIENT c
JOIN "ORDER" o ON c.client_id = o.client_id
GROUP BY c.client_id, c.first_name, c.last_name
HAVING COUNT(o.order_id) >= 3
ORDER BY orders_count DESC;


-- Запрос 5: Эффективность сотрудников (обработанные заказы)
SELECT 
    e.name,
    e.position,
    COUNT(o.order_id) AS processed_orders
FROM EMPLOYEE e
LEFT JOIN "ORDER" o ON e.employee_id = o.employee_id
GROUP BY e.name, e.position
ORDER BY processed_orders DESC;



-- Запрос 6: Средний размер заказа по складам
SELECT 
    w.name,
    AVG(o.quantity) AS avg_order_size
FROM "ORDER" o
JOIN WAREHOUSE w ON o.warehouse_id = w.warehouse_id
GROUP BY w.name
ORDER BY avg_order_size DESC;


-- Запрос 7: Доля отменённых заказов по складам
-- Помогает выявить проблемные склады
SELECT 
    w.name,
    COUNT(*) FILTER (WHERE o.status = 'cancelled') * 1.0 / COUNT(*) AS cancel_ratio
FROM "ORDER" o
JOIN WAREHOUSE w ON o.warehouse_id = w.warehouse_id
GROUP BY w.name
ORDER BY cancel_ratio DESC;


-- Запрос 8: Последний заказ каждого клиента
-- Позволяет анализировать активность клиентов
SELECT DISTINCT ON (c.client_id)
    c.client_id,
    c.first_name,
    c.last_name,
    o.order_date,
    o.status
FROM CLIENT c
JOIN "ORDER" o ON c.client_id = o.client_id
ORDER BY c.client_id, o.order_date DESC;


-- Запрос 9: Товары, которые не заказывались ни разу
SELECT 
    p.product_id,
    p.name
FROM PRODUCT p
LEFT JOIN "ORDER" o ON p.product_id = o.product_id
WHERE o.product_id IS NULL;



-- Запрос 10: Рейтинг сотрудников по количеству заказов
-- Позволяет сравнить эффективность сотрудников
SELECT
    e.name,
    COUNT(o.order_id) AS total_orders,
    RANK() OVER (ORDER BY COUNT(o.order_id) DESC) AS rank_position
FROM EMPLOYEE e
LEFT JOIN "ORDER" o ON e.employee_id = o.employee_id
GROUP BY e.name
ORDER BY rank_position;