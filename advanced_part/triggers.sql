-- Функция резервирования товара
CREATE OR REPLACE FUNCTION trg_reserve_product()
RETURNS TRIGGER AS $$
DECLARE
    current_stock INT;
BEGIN
    SELECT quantity_on_hand INTO current_stock
    FROM PRODUCT
    WHERE product_id = NEW.product_id;

    IF current_stock < NEW.quantity THEN
        RAISE EXCEPTION 'Not enough stock';
    END IF;

    UPDATE PRODUCT
    SET quantity_on_hand = quantity_on_hand - NEW.quantity
    WHERE product_id = NEW.product_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER reserve_product_trigger
BEFORE INSERT ON "ORDER"
FOR EACH ROW
EXECUTE FUNCTION trg_reserve_product();


-- Функция возврата товара
CREATE OR REPLACE FUNCTION trg_restore_product()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'cancelled' AND OLD.status != 'cancelled' THEN
        UPDATE PRODUCT
        SET quantity_on_hand = quantity_on_hand + OLD.quantity
        WHERE product_id = OLD.product_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER restore_product_trigger
AFTER UPDATE ON "ORDER"
FOR EACH ROW
EXECUTE FUNCTION trg_restore_product();