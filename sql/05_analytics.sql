
-- ============================================================
-- Project: VirtualMart
-- File: 05_analytics.sql
-- Purpose: Business reporting and analytical SQL queries
-- All data is fictional.
-- ============================================================

-- 1. Order summary and revenue by status
SELECT
    order_status,
    COUNT(*) AS order_count,
    SUM(total_amount) AS total_order_value
FROM virtualmart.sales_orders
GROUP BY order_status
ORDER BY total_order_value DESC;

-- 2. Top-selling products by quantity
SELECT
    p.sku,
    p.product_name,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.line_total - oi.discount_amount) AS net_item_revenue
FROM virtualmart.order_items oi
JOIN virtualmart.products p
    ON p.product_id = oi.product_id
JOIN virtualmart.sales_orders so
    ON so.order_id = oi.order_id
WHERE so.order_status <> 'CANCELLED'
GROUP BY p.sku, p.product_name
ORDER BY units_sold DESC, net_item_revenue DESC;

-- 3. Customer order history
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    COUNT(so.order_id) AS order_count,
    COALESCE(SUM(so.total_amount), 0) AS total_order_value
FROM virtualmart.customers c
LEFT JOIN virtualmart.sales_orders so
    ON so.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_order_value DESC;

-- 4. Inventory below reorder level
SELECT
    w.warehouse_name,
    p.sku,
    p.product_name,
    i.quantity_on_hand,
    i.quantity_reserved,
    i.reorder_level
FROM virtualmart.inventory i
JOIN virtualmart.warehouses w
    ON w.warehouse_id = i.warehouse_id
JOIN virtualmart.products p
    ON p.product_id = i.product_id
WHERE i.quantity_on_hand - i.quantity_reserved <= i.reorder_level
ORDER BY w.warehouse_name, p.product_name;

-- 5. Payment status monitoring
SELECT
    payment_status,
    payment_method,
    COUNT(*) AS payment_count,
    SUM(amount) AS payment_amount
FROM virtualmart.payments
GROUP BY payment_status, payment_method
ORDER BY payment_status, payment_method;

-- 6. Orders with their shipment status
SELECT
    so.order_number,
    so.order_status,
    sh.tracking_number,
    sh.carrier_name,
    sh.shipment_status
FROM virtualmart.sales_orders so
LEFT JOIN virtualmart.shipments sh
    ON sh.order_id = so.order_id
ORDER BY so.order_date DESC;

-- 7. Supplier coverage by product
SELECT
    s.supplier_name,
    COUNT(sp.product_id) AS products_supplied
FROM virtualmart.suppliers s
LEFT JOIN virtualmart.supplier_products sp
    ON sp.supplier_id = s.supplier_id
GROUP BY s.supplier_id, s.supplier_name
ORDER BY products_supplied DESC, s.supplier_name;

-- 8. Daily order volume and value
SELECT
    (order_date AT TIME ZONE 'UTC')::date AS order_day_utc,
    COUNT(*) AS order_count,
    SUM(total_amount) AS total_order_value
FROM virtualmart.sales_orders
GROUP BY (order_date AT TIME ZONE 'UTC')::date
ORDER BY order_day_utc;
