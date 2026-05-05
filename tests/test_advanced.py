import psycopg2
import pytest

conn = psycopg2.connect(
    dbname="warehouse_logistics",
    user="postgres",
    password="abc1234",
    host="localhost",
    port="5432"
)

conn.autocommit = True
@pytest.fixture
def cur():
    cursor = conn.cursor()
    yield cursor
    cursor.close()


def test_get_order_total_positive(cur):
    cur.execute("SELECT order_id FROM \"ORDER\" LIMIT 1")
    order_id = cur.fetchone()[0]

    cur.execute("SELECT get_order_total(%s)", (order_id,))
    result = cur.fetchone()[0]

    assert result is not None
    assert result > 0


def test_get_order_total_negative(cur):
    with pytest.raises(psycopg2.Error):
        cur.execute("SELECT get_order_total(-1)")


def test_employee_workload_positive(cur):
    cur.execute("SELECT employee_id FROM EMPLOYEE LIMIT 1")
    emp_id = cur.fetchone()[0]

    cur.execute("SELECT get_employee_workload(%s)", (emp_id,))
    result = cur.fetchone()[0]

    assert result >= 0


def test_employee_workload_zero(cur):
    cur.execute("""
        INSERT INTO EMPLOYEE(name, position) 
        VALUES('test_name', 'test') 
        RETURNING employee_id
    """)
    emp_id = cur.fetchone()[0]

    cur.execute("SELECT get_employee_workload(%s)", (emp_id,))
    result = cur.fetchone()[0]

    assert result == 0

    cur.execute("DELETE FROM EMPLOYEE WHERE employee_id = %s", (emp_id,))


def test_update_order_status_positive(cur):
    cur.execute("""
        INSERT INTO "ORDER"(order_date, status, client_id, warehouse_id, employee_id, product_id, quantity)
        VALUES (CURRENT_DATE, 'new', 1, 1, 1, 1, 1)
        RETURNING order_id
    """)
    order_id = cur.fetchone()[0]

    cur.execute("CALL update_order_status(%s, %s)", (order_id, 'processing'))

    cur.execute("SELECT status FROM \"ORDER\" WHERE order_id = %s", (order_id,))
    status = cur.fetchone()[0]

    assert status == 'processing'

    cur.execute("DELETE FROM \"ORDER\" WHERE order_id = %s", (order_id,))


def test_update_order_status_negative(cur):
    cur.execute("""
        INSERT INTO "ORDER"(order_date, status, client_id, warehouse_id, employee_id, product_id, quantity)
        VALUES (CURRENT_DATE, 'delivered', 1, 1, 1, 1, 1)
        RETURNING order_id
    """)
    order_id = cur.fetchone()[0]

    with pytest.raises(psycopg2.Error):
        cur.execute("CALL update_order_status(%s, %s)", (order_id, 'new'))

    cur.execute("DELETE FROM \"ORDER\" WHERE order_id = %s", (order_id,))