
-- ============================================================
-- Project: VirtualMart
-- File: 03_indexes.sql
-- Purpose: Improve common query and join performance
-- ============================================================

BEGIN;

-- Customer order history
CREATE INDEX IF NOT EXISTS idx_sales_orders_customer_date
    ON virtualmart.sales_orders (customer_id, order_date DESC);

-- Filter orders by status and date
CREATE INDEX IF NOT EXISTS idx_sales_orders_status_date
    ON virtualmart.sales_orders (order_status, order_date DESC);

-- Find orders containing a product
CREATE INDEX IF NOT EXISTS idx_order_items_product
    ON virtualmart.order_items (product_id);

-- Find payments for an order
CREATE INDEX IF NOT EXISTS idx_payments_order_status
    ON virtualmart.payments (order_id, payment_status);

-- Find shipments for an order
CREATE INDEX IF NOT EXISTS idx_shipments_order
    ON virtualmart.shipments (order_id);

-- Find returns for an order
CREATE INDEX IF NOT EXISTS idx_returns_order_status
    ON virtualmart.returns (order_id, return_status);

-- Product lookup by category
CREATE INDEX IF NOT EXISTS idx_products_category_status
    ON virtualmart.products (category_id, product_status);

-- Inventory lookup by product
CREATE INDEX IF NOT EXISTS idx_inventory_product
    ON virtualmart.inventory (product_id);

-- Address lookup by customer
CREATE INDEX IF NOT EXISTS idx_customer_addresses_customer
    ON virtualmart.customer_addresses (customer_id);

-- Audit history lookup
CREATE INDEX IF NOT EXISTS idx_audit_log_table_record_date
    ON virtualmart.audit_log (table_name, record_identifier, changed_at DESC);

-- Inventory movement history
CREATE INDEX IF NOT EXISTS idx_inventory_movements_product_date
    ON virtualmart.inventory_movements (product_id, created_at DESC);

COMMIT;

-- Verify indexes in the VirtualMart schema
SELECT
    tablename,
    indexname
FROM pg_indexes
WHERE schemaname = 'virtualmart'
ORDER BY tablename, indexname;
