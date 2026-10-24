
-- ============================================================
-- Project: VirtualMart
-- File: 04_sample_data.sql
-- Purpose: Insert fictional demonstration data
-- All names, contact details, and records are synthetic.
-- ============================================================

BEGIN;

-- Categories
INSERT INTO virtualmart.categories
    (category_name, description)
VALUES
    ('Electronics', 'Consumer electronic devices'),
    ('Home and Kitchen', 'Household and kitchen products'),
    ('Books', 'Printed books and learning materials');

-- Suppliers
INSERT INTO virtualmart.suppliers
    (supplier_name, contact_email, contact_phone)
VALUES
    ('DemoTech Supplies', 'sales@demotech.example', '+910000000001'),
    ('Fictional Home Goods', 'orders@homegoods.example', '+910000000002'),
    ('Sample Book Distributors', 'contact@samplebooks.example', '+910000000003');

-- Products
INSERT INTO virtualmart.products
    (category_id, product_name, sku, description, unit_price)
SELECT category_id, 'Wireless Mouse', 'VM-ELEC-001',
       'Fictional wireless computer mouse', 799.00
FROM virtualmart.categories WHERE category_name = 'Electronics';

INSERT INTO virtualmart.products
    (category_id, product_name, sku, description, unit_price)
SELECT category_id, 'USB Keyboard', 'VM-ELEC-002',
       'Fictional USB keyboard', 1199.00
FROM virtualmart.categories WHERE category_name = 'Electronics';

INSERT INTO virtualmart.products
    (category_id, product_name, sku, description, unit_price)
SELECT category_id, 'Steel Water Bottle', 'VM-HOME-001',
       'Fictional reusable steel bottle', 499.00
FROM virtualmart.categories WHERE category_name = 'Home and Kitchen';

INSERT INTO virtualmart.products
    (category_id, product_name, sku, description, unit_price)
SELECT category_id, 'SQL Learning Guide', 'VM-BOOK-001',
       'Fictional introductory SQL guide', 599.00
FROM virtualmart.categories WHERE category_name = 'Books';

-- Supplier-product relationships
INSERT INTO virtualmart.supplier_products
    (supplier_id, product_id, supplier_sku, supply_cost)
SELECT s.supplier_id, p.product_id, 'SUP-MOUSE-01', 500.00
FROM virtualmart.suppliers s
CROSS JOIN virtualmart.products p
WHERE s.supplier_name = 'DemoTech Supplies'
  AND p.sku = 'VM-ELEC-001';

INSERT INTO virtualmart.supplier_products
    (supplier_id, product_id, supplier_sku, supply_cost)
SELECT s.supplier_id, p.product_id, 'SUP-KEY-01', 800.00
FROM virtualmart.suppliers s
CROSS JOIN virtualmart.products p
WHERE s.supplier_name = 'DemoTech Supplies'
  AND p.sku = 'VM-ELEC-002';

INSERT INTO virtualmart.supplier_products
    (supplier_id, product_id, supplier_sku, supply_cost)
SELECT s.supplier_id, p.product_id, 'SUP-BOTTLE-01', 300.00
FROM virtualmart.suppliers s
CROSS JOIN virtualmart.products p
WHERE s.supplier_name = 'Fictional Home Goods'
  AND p.sku = 'VM-HOME-001';

INSERT INTO virtualmart.supplier_products
    (supplier_id, product_id, supplier_sku, supply_cost)
SELECT s.supplier_id, p.product_id, 'SUP-BOOK-01', 350.00
FROM virtualmart.suppliers s
CROSS JOIN virtualmart.products p
WHERE s.supplier_name = 'Sample Book Distributors'
  AND p.sku = 'VM-BOOK-001';

-- Fictional customers: reserved .example email domain
INSERT INTO virtualmart.customers
    (first_name, last_name, email, phone)
VALUES
    ('Aarav', 'Demo', 'aarav.demo@example.com', '+910000001001'),
    ('Mira', 'Sample', 'mira.sample@example.com', '+910000001002'),
    ('Kiran', 'Fiction', 'kiran.fiction@example.com', '+910000001003'),
    ('Nila', 'Test', 'nila.test@example.com', '+910000001004'),
    ('Dev', 'Example', 'dev.example@example.com', '+910000001005');

-- Fictional customer addresses
INSERT INTO virtualmart.customer_addresses
    (customer_id, address_type, address_line1, city,
     state_region, postal_code, country_code, is_default)
SELECT customer_id, 'BOTH', '100 Demo Street', 'Hyderabad',
       'Telangana', '500001', 'IN', TRUE
FROM virtualmart.customers
WHERE email = 'aarav.demo@example.com';

INSERT INTO virtualmart.customer_addresses
    (customer_id, address_type, address_line1, city,
     state_region, postal_code, country_code, is_default)
SELECT customer_id, 'BOTH', '200 Sample Avenue', 'Bengaluru',
       'Karnataka', '560001', 'IN', TRUE
FROM virtualmart.customers
WHERE email = 'mira.sample@example.com';

INSERT INTO virtualmart.customer_addresses
    (customer_id, address_type, address_line1, city,
     state_region, postal_code, country_code, is_default)
SELECT customer_id, 'BOTH', '300 Fiction Road', 'Chennai',
       'Tamil Nadu', '600001', 'IN', TRUE
FROM virtualmart.customers
WHERE email = 'kiran.fiction@example.com';

INSERT INTO virtualmart.customer_addresses
    (customer_id, address_type, address_line1, city,
     state_region, postal_code, country_code, is_default)
SELECT customer_id, 'BOTH', '400 Example Lane', 'Pune',
       'Maharashtra', '411001', 'IN', TRUE
FROM virtualmart.customers
WHERE email = 'nila.test@example.com';

INSERT INTO virtualmart.customer_addresses
    (customer_id, address_type, address_line1, city,
     state_region, postal_code, country_code, is_default)
SELECT customer_id, 'BOTH', '500 Practice Road', 'Delhi',
       'Delhi', '110001', 'IN', TRUE
FROM virtualmart.customers
WHERE email = 'dev.example@example.com';

-- Warehouses
INSERT INTO virtualmart.warehouses
    (warehouse_name, city, country_code)
VALUES
    ('Demo Hyderabad Warehouse', 'Hyderabad', 'IN'),
    ('Demo Bengaluru Warehouse', 'Bengaluru', 'IN');

-- Initial stock for every product at both warehouses
INSERT INTO virtualmart.inventory
    (warehouse_id, product_id, quantity_on_hand, quantity_reserved,
     reorder_level)
SELECT w.warehouse_id, p.product_id, 100, 0, 10
FROM virtualmart.warehouses w
CROSS JOIN virtualmart.products p;

-- Three demonstration orders with consistent totals
INSERT INTO virtualmart.sales_orders
    (customer_id, shipping_address_id, order_number, order_status,
     currency_code, subtotal, tax_amount, shipping_amount,
     discount_amount, total_amount)
SELECT c.customer_id, a.address_id, 'VM-ORD-1001', 'DELIVERED',
       'INR', 1598.00, 79.90, 50.00, 0.00, 1727.90
FROM virtualmart.customers c
JOIN virtualmart.customer_addresses a
  ON a.customer_id = c.customer_id AND a.is_default
WHERE c.email = 'aarav.demo@example.com';

INSERT INTO virtualmart.sales_orders
    (customer_id, shipping_address_id, order_number, order_status,
     currency_code, subtotal, tax_amount, shipping_amount,
     discount_amount, total_amount)
SELECT c.customer_id, a.address_id, 'VM-ORD-1002', 'SHIPPED',
        'INR', 1199.00, 59.95, 40.00, 100.00, 1198.95
FROM virtualmart.customers c
JOIN virtualmart.customer_addresses a
  ON a.customer_id = c.customer_id AND a.is_default
WHERE c.email = 'mira.sample@example.com';

INSERT INTO virtualmart.sales_orders
    (customer_id, shipping_address_id, order_number, order_status,
     currency_code, subtotal, tax_amount, shipping_amount,
     discount_amount, total_amount)
SELECT c.customer_id, a.address_id, 'VM-ORD-1003', 'PROCESSING',
       'INR', 599.00, 29.95, 40.00, 0.00, 668.95
FROM virtualmart.customers c
JOIN virtualmart.customer_addresses a
  ON a.customer_id = c.customer_id AND a.is_default
WHERE c.email = 'kiran.fiction@example.com';

-- Order line items
INSERT INTO virtualmart.order_items
    (order_id, product_id, quantity, unit_price, discount_amount, line_total)
SELECT o.order_id, p.product_id, 2, 799.00, 0.00, 1598.00
FROM virtualmart.sales_orders o
CROSS JOIN virtualmart.products p
WHERE o.order_number = 'VM-ORD-1001' AND p.sku = 'VM-ELEC-001';

INSERT INTO virtualmart.order_items
    (order_id, product_id, quantity, unit_price, discount_amount, line_total)
SELECT o.order_id, p.product_id, 1, 1199.00, 0.00, 1199.00
FROM virtualmart.sales_orders o
CROSS JOIN virtualmart.products p
WHERE o.order_number = 'VM-ORD-1002' AND p.sku = 'VM-ELEC-002';

INSERT INTO virtualmart.order_items
    (order_id, product_id, quantity, unit_price, discount_amount, line_total)
SELECT o.order_id, p.product_id, 1, 599.00, 0.00, 599.00
FROM virtualmart.sales_orders o
CROSS JOIN virtualmart.products p
WHERE o.order_number = 'VM-ORD-1003' AND p.sku = 'VM-BOOK-001';

-- Payments
INSERT INTO virtualmart.payments
    (order_id, payment_reference, payment_method, payment_status,
     amount, currency_code, paid_at)
SELECT order_id, 'VM-PAY-1001', 'UPI', 'COMPLETED',
       1727.90, 'INR', CURRENT_TIMESTAMP - INTERVAL '5 days'
FROM virtualmart.sales_orders WHERE order_number = 'VM-ORD-1001';

INSERT INTO virtualmart.payments
    (order_id, payment_reference, payment_method, payment_status,
     amount, currency_code, paid_at)
SELECT order_id, 'VM-PAY-1002', 'CARD', 'COMPLETED',
       1198.95, 'INR', CURRENT_TIMESTAMP - INTERVAL '2 days'
FROM virtualmart.sales_orders WHERE order_number = 'VM-ORD-1002';

INSERT INTO virtualmart.payments
    (order_id, payment_reference, payment_method, payment_status,
     amount, currency_code)
SELECT order_id, 'VM-PAY-1003', 'UPI', 'PENDING',
       668.95, 'INR'
FROM virtualmart.sales_orders WHERE order_number = 'VM-ORD-1003';

-- Shipments
INSERT INTO virtualmart.shipments
    (order_id, warehouse_id, tracking_number, carrier_name,
     shipment_status, shipped_at, delivered_at)
SELECT o.order_id, w.warehouse_id, 'VM-TRACK-1001',
       'Demo Delivery Co', 'DELIVERED',
       CURRENT_TIMESTAMP - INTERVAL '4 days',
       CURRENT_TIMESTAMP - INTERVAL '2 days'
FROM virtualmart.sales_orders o
CROSS JOIN virtualmart.warehouses w
WHERE o.order_number = 'VM-ORD-1001'
  AND w.warehouse_name = 'Demo Hyderabad Warehouse';

INSERT INTO virtualmart.shipments
    (order_id, warehouse_id, tracking_number, carrier_name,
     shipment_status, shipped_at)
SELECT o.order_id, w.warehouse_id, 'VM-TRACK-1002',
       'Sample Logistics', 'SHIPPED',
       CURRENT_TIMESTAMP - INTERVAL '1 day'
FROM virtualmart.sales_orders o
CROSS JOIN virtualmart.warehouses w
WHERE o.order_number = 'VM-ORD-1002'
  AND w.warehouse_name = 'Demo Bengaluru Warehouse';

-- Inventory movement examples
INSERT INTO virtualmart.inventory_movements
    (warehouse_id, product_id, movement_type, quantity_change, reference_note)
SELECT i.warehouse_id, i.product_id, 'RECEIPT', 100,
       'Initial fictional stock setup'
FROM virtualmart.inventory i;

COMMIT;

-- Verify inserted records by table
SELECT 'customers' AS table_name, COUNT(*) AS row_count
FROM virtualmart.customers
UNION ALL
SELECT 'products', COUNT(*) FROM virtualmart.products
UNION ALL
SELECT 'sales_orders', COUNT(*) FROM virtualmart.sales_orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM virtualmart.order_items
UNION ALL
SELECT 'payments', COUNT(*) FROM virtualmart.payments
UNION ALL
SELECT 'shipments', COUNT(*) FROM virtualmart.shipments
ORDER BY table_name;
