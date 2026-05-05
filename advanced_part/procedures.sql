-- Функция стоимости заказа
CREATE OR REPLACE FUNCTION get_order_total(p_order_id INT)
RETURNS DECIMAL AS $$
DECLARE
    total DECIMAL;
BEGIN
    SELECT p.price * o.quantity INTO total
    FROM "ORDER" o
    JOIN PRODUCT p ON o.product_id = p.product_id
    WHERE o.order_id = p_order_id;

    IF total IS NULL THEN
        RAISE EXCEPTION 'Order not found';
    END IF;

    RETURN total;
END;
$$ LANGUAGE plpgsql;


-- Функция загрузки сотрудника
CREATE OR REPLACE FUNCTION get_employee_workload(p_employee_id INT)
RETURNS INT AS $$
DECLARE
    cnt INT;
BEGIN
    SELECT COUNT(*) INTO cnt
    FROM "ORDER"
    WHERE employee_id = p_employee_id
      AND status IN ('new', 'processing');

    RETURN cnt;
END;
$$ LANGUAGE plpgsql;


-- Процедура изменения статуса
CREATE OR REPLACE PROCEDURE update_order_status(
    p_order_id INT,
    p_new_status VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    current_status VARCHAR;
BEGIN
    SELECT status INTO current_status
    FROM "ORDER"
    WHERE order_id = p_order_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Order not found';
    END IF;

    IF current_status = 'delivered' THEN
        RAISE EXCEPTION 'Cannot change delivered order';
    END IF;

    UPDATE "ORDER"
    SET status = p_new_status
    WHERE order_id = p_order_id;
END;
$$;