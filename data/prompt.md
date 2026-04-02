# Промт для генерации синтетических данных

## Метаданные LLM
LLM: GPT-5.3 (ChatGPT)
Дата генерации: 2026-04-02
SQL версия: PostgreSQL 15+

## Полный текст промта
Ты — эксперт по SQL (PostgreSQL) и генерации синтетических данных. Помоги создать скрипт для базы данных «Автоматизированная система логистики склада» по следующей физической модели.

## 1. Таблицы и атрибуты (точное описание из модели) 
### WAREHOUSE — склады 
- warehouse_id SERIAL PRIMARY KEY
- name VARCHAR(100) NOT NULL
- location VARCHAR(250) NOT NULL

### CLIENT — клиенты 
- client_id SERIAL PRIMARY KEY
- first_name VARCHAR(100) NOT NULL
- last_name VARCHAR(100) NOT NULL
- phone VARCHAR(15) NOT NULL
- email VARCHAR(100) NOT NULL UNIQUE

### EMPLOYEE — сотрудники 
- employee_id SERIAL PRIMARY KEY
- name VARCHAR(50) NOT NULL
- position VARCHAR(50) NOT NULL CHECK (position <> ' ')

### SUPPLIER — поставщики 
- supplier_id SERIAL PRIMARY KEY
- name VARCHAR(100) NOT NULL
- contact_info TEXT NOT NULL
### PRODUCT — товары 
- product_id SERIAL PRIMARY KEY
- name VARCHAR(100) NOT NULL
- sku VARCHAR(50) NOT NULL UNIQUE
- price DECIMAL(10,2) NOT NULL CHECK (price >= 0)
- supplier_id INT NOT NULL REFERENCES SUPPLIER(supplier_id)
- quantity_on_hand INT NOT NULL DEFAULT 0 CHECK (quantity_on_hand >= 0)

### ORDER — заказы (каждая строка — один товар в заказе) 
- order_id SERIAL PRIMARY KEY
- order_date DATE NOT NULL DEFAULT CURRENT_DATE
- status VARCHAR(20) NOT NULL CHECK (status IN ('new','processing','shipped','delivered','cancelled'))
- client_id INT NOT NULL REFERENCES CLIENT(client_id)
- warehouse_id INT NOT NULL REFERENCES WAREHOUSE(warehouse_id)
- employee_id INT NOT NULL REFERENCES EMPLOYEE(employee_id)
- product_id INT NOT NULL REFERENCES PRODUCT(product_id)
- quantity INT NOT NULL CHECK (quantity > 0)


## 2. Требования к SQL-скрипту создания таблиц 
- Учитывать порядок создания: сначала таблицы без внешних ключей (WAREHOUSE, CLIENT, EMPLOYEE, SUPPLIER), затем PRODUCT (ссылается на SUPPLIER), затем ORDER (ссылается на CLIENT, WAREHOUSE, EMPLOYEE, PRODUCT).
- Все ограничения (PRIMARY KEY, FOREIGN KEY, NOT NULL, CHECK, DEFAULT, UNIQUE) должны быть прописаны.
- Скрипт должен быть готов к выполнению в PostgreSQL (использовать SERIAL, REFERENCES, ON DELETE RESTRICT — по умолчанию).

## 3. Требования к данным (синтетическим) 
Каждая таблица должна содержать **не менее 20 строк**.
Все связи должны быть проиллюстрированы:
 - Один поставщик (SUPPLIER) имеет несколько товаров (PRODUCT).
 - Один клиент (CLIENT) имеет несколько заказов (ORDER).
 - Один склад (WAREHOUSE) фигурирует в нескольких заказах.
 - Один сотрудник (EMPLOYEE) оформляет несколько заказов.
 - Один товар (PRODUCT) может быть заказан много раз (в разных ORDER).
 Значения должны быть реалистичными для логистики склада:
 - Названия складов: «Северный склад», «Южный логистический центр», «Склад готовой продукции» и т.п.
 - Адреса: реальные или вымышленные (г. Москва, ул. Логистическая, д.1).
 - Клиенты: имена и фамилии (например, Иван Петров, Анна Сидорова), телефоны в формате +7 900 123-45-67, email уникальные.
 - Сотрудники: должности: 'менеджер склада', 'комплектовщик', 'грузчик', 'логист', 'оператор'.
 - Поставщики: реальные названия (ООО «ТехноТрейд», ЗАО «СкладСервис»), контактные данные — текст с телефоном и адресом.
 - Товары: названия («Ноутбук Lenovo ThinkPad», «Мышь Logitech MX», «Паллета деревянная 1200x800»), SKU уникальные (например, 'NB-LEN-T14-001'), цены от 100 до 50000 руб., остатки на складе от 0 до 1000.
 - Заказы: даты за последние 3 месяца, статусы распределены (больше всего 'delivered' и 'shipped'), количество товара от 1 до 50.
 Для наглядности связей:
 - Создайте хотя бы одного поставщика с 3+ товарами.
 - Создайте хотя бы одного клиента с 3+ заказами.
 - Создайте хотя бы одного сотрудника с 4+ заказами.
 - Создайте хотя бы один склад, на который приходится 5+ заказов.
 - Один и тот же товар должен встречаться в разных заказах.

## 4. Выходные форматы 

Предоставь в ответе: 

1. **Файл create_tables.sql** — полный SQL-скрипт создания таблиц.
2. **Данные** в одном из двух вариантов (лучше оба):
  - CSV-файлы для каждой таблицы (с заголовками) — можно выдать в виде блоков кода, имитирующих содержимое файлов.
  - Либо INSERT-скрипт (insert_data.sql) с командами INSERT ... VALUES (не более 50 строк на один INSERT для читаемости).
3. **Краткое описание логики генерации** (какие списки имён, диапазоны цен, как распределяли статусы и т.д.).

## 5. Метаданные для отчёта 

В конце ответа укажи: 
- Используемая модель LLM (например, GPT-4o, Claude 3.5 Sonnet, DeepSeek-V3).
- Дата генерации. - Версия SQL (PostgreSQL 15+).

## 6. Дополнительные замечания 

- Убедись, что для всех внешних ключей существуют родительские записи.
- Для таблицы ORDER: order_date пусть будет случайной датой в диапазоне от '2025-01-01' до '2026-03-31'.
- Поле quantity_on_hand в PRODUCT должно быть неотрицательным. При генерации заказов не нужно уменьшать остатки. Можно оставить любые положительные числа.
- Для демонстрации связей можно добавить один заказ с cancelled статусом, один с processing и т.д.


Сгенерируй, пожалуйста, результат.
