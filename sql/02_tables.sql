
-- ============================================================
-- Project: VirtualMart
-- File: 02_tables.sql
-- Purpose: Create core relational database tables
-- PostgreSQL 18
-- All business data is fictional.
-- ============================================================

BEGIN;

-- 1. Customers
CREATE TABLE virtualmart.customers (
    customer_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(30),
    customer_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
        CHECK (customer_status IN ('ACTIVE', 'INACTIVE', 'BLOCKED')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 2. Customer addresses
CREATE TABLE virtualmart.customer_addresses (
    address_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id BIGINT NOT NULL
        REFERENCES virtualmart.customers(customer_id),
    address_type VARCHAR(20) NOT NULL
        CHECK (address_type IN ('BILLING', 'SHIPPING', 'BOTH')),
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state_region VARCHAR(100),
    postal_code VARCHAR(20),
    country_code CHAR(2) NOT NULL,
    is_default BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 3. Product categories
CREATE TABLE virtualmart.categories (
    category_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    parent_category_id BIGINT
        REFERENCES virtualmart.categories(category_id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 4. Suppliers
CREATE TABLE virtualmart.suppliers (
    supplier_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    supplier_name VARCHAR(200) NOT NULL,
    contact_email VARCHAR(255),
    contact_phone VARCHAR(30),
    supplier_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
        CHECK (supplier_status IN ('ACTIVE', 'INACTIVE')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 5. Products
CREATE TABLE virtualmart.products (
    product_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_id BIGINT NOT NULL
        REFERENCES virtualmart.categories(category_id),
    product_name VARCHAR(200) NOT NULL,
    sku VARCHAR(64) NOT NULL UNIQUE,
    description TEXT,
    unit_price NUMERIC(12, 2) NOT NULL CHECK (unit_price >= 0),
    product_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
        CHECK (product_status IN ('ACTIVE', 'INACTIVE', 'DISCONTINUED')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 6. Supplier-product relationship
CREATE TABLE virtualmart.supplier_products (
    supplier_id BIGINT NOT NULL
        REFERENCES virtualmart.suppliers(supplier_id),
    product_id BIGINT NOT NULL
        REFERENCES virtualmart.products(product_id),
    supplier_sku VARCHAR(64),
    supply_cost NUMERIC(12, 2) CHECK (supply_cost >= 0),
    PRIMARY KEY (supplier_id, product_id)
);

-- 7. Warehouses
CREATE TABLE virtualmart.warehouses (
    warehouse_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    warehouse_name VARCHAR(150) NOT NULL UNIQUE,
    city VARCHAR(100) NOT NULL,
    country_code CHAR(2) NOT NULL,
    warehouse_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
        CHECK (warehouse_status IN ('ACTIVE', 'INACTIVE')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 8. Inventory by product and warehouse
CREATE TABLE virtualmart.inventory (
    warehouse_id BIGINT NOT NULL
        REFERENCES virtualmart.warehouses(warehouse_id),
    product_id BIGINT NOT NULL
        REFERENCES virtualmart.products(product_id),
    quantity_on_hand INTEGER NOT NULL DEFAULT 0
        CHECK (quantity_on_hand >= 0),
    quantity_reserved INTEGER NOT NULL DEFAULT 0
        CHECK (quantity_reserved >= 0),
    reorder_level INTEGER NOT NULL DEFAULT 10
        CHECK (reorder_level >= 0),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (warehouse_id, product_id),
    CHECK (quantity_reserved <= quantity_on_hand)
);

-- 9. Customer orders
CREATE TABLE virtualmart.sales_orders (
    order_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id BIGINT NOT NULL
        REFERENCES virtualmart.customers(customer_id),
    shipping_address_id BIGINT
        REFERENCES virtualmart.customer_addresses(address_id)
        ON DELETE SET NULL,
    order_number VARCHAR(40) NOT NULL UNIQUE,
    order_status VARCHAR(20) NOT NULL DEFAULT 'PENDING'
        CHECK (order_status IN (
            'PENDING', 'CONFIRMED', 'PROCESSING',
            'SHIPPED', 'DELIVERED', 'CANCELLED', 'RETURNED'
        )),
    order_date TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    currency_code CHAR(3) NOT NULL DEFAULT 'INR',
    subtotal NUMERIC(14, 2) NOT NULL DEFAULT 0 CHECK (subtotal >= 0),
    tax_amount NUMERIC(14, 2) NOT NULL DEFAULT 0 CHECK (tax_amount >= 0),
    shipping_amount NUMERIC(14, 2) NOT NULL DEFAULT 0
        CHECK (shipping_amount >= 0),
    discount_amount NUMERIC(14, 2) NOT NULL DEFAULT 0
        CHECK (discount_amount >= 0),
    total_amount NUMERIC(14, 2) NOT NULL DEFAULT 0
        CHECK (total_amount >= 0),
    CHECK (discount_amount <= subtotal + tax_amount + shipping_amount)
);

-- 10. Order line items
CREATE TABLE virtualmart.order_items (
    order_item_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id BIGINT NOT NULL
        REFERENCES virtualmart.sales_orders(order_id),
    product_id BIGINT NOT NULL
        REFERENCES virtualmart.products(product_id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(12, 2) NOT NULL CHECK (unit_price >= 0),
    discount_amount NUMERIC(12, 2) NOT NULL DEFAULT 0
        CHECK (discount_amount >= 0),
    line_total NUMERIC(14, 2) NOT NULL CHECK (line_total >= 0),
    UNIQUE (order_id, product_id),
    CHECK (discount_amount <= quantity * unit_price)
);

-- 11. Payments
CREATE TABLE virtualmart.payments (
    payment_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id BIGINT NOT NULL
        REFERENCES virtualmart.sales_orders(order_id),
    payment_reference VARCHAR(100) UNIQUE,
    payment_method VARCHAR(30) NOT NULL
        CHECK (payment_method IN (
            'CARD', 'UPI', 'NET_BANKING', 'COD', 'WALLET'
        )),
    payment_status VARCHAR(20) NOT NULL DEFAULT 'PENDING'
        CHECK (payment_status IN (
            'PENDING', 'AUTHORIZED', 'COMPLETED', 'FAILED', 'REFUNDED'
        )),
    amount NUMERIC(14, 2) NOT NULL CHECK (amount > 0),
    currency_code CHAR(3) NOT NULL DEFAULT 'INR',
    paid_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 12. Shipments
CREATE TABLE virtualmart.shipments (
    shipment_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id BIGINT NOT NULL
        REFERENCES virtualmart.sales_orders(order_id),
    warehouse_id BIGINT
        REFERENCES virtualmart.warehouses(warehouse_id)
        ON DELETE SET NULL,
    tracking_number VARCHAR(100) UNIQUE,
    carrier_name VARCHAR(100),
    shipment_status VARCHAR(20) NOT NULL DEFAULT 'PREPARING'
        CHECK (shipment_status IN (
            'PREPARING', 'SHIPPED', 'IN_TRANSIT',
            'DELIVERED', 'LOST', 'CANCELLED'
        )),
    shipped_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 13. Returns
CREATE TABLE virtualmart.returns (
    return_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id BIGINT NOT NULL
        REFERENCES virtualmart.sales_orders(order_id),
    return_reference VARCHAR(40) NOT NULL UNIQUE,
    return_reason TEXT NOT NULL,
    return_status VARCHAR(20) NOT NULL DEFAULT 'REQUESTED'
        CHECK (return_status IN (
            'REQUESTED', 'APPROVED', 'REJECTED',
            'RECEIVED', 'REFUNDED', 'CLOSED'
        )),
    requested_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMPTZ
);

-- 14. Items included in each return
CREATE TABLE virtualmart.return_items (
    return_item_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    return_id BIGINT NOT NULL
        REFERENCES virtualmart.returns(return_id),
    order_item_id BIGINT NOT NULL
        REFERENCES virtualmart.order_items(order_item_id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    item_condition VARCHAR(30)
        CHECK (item_condition IN (
            'UNOPENED', 'GOOD', 'DAMAGED', 'DEFECTIVE'
        )),
    refund_amount NUMERIC(14, 2) NOT NULL DEFAULT 0
        CHECK (refund_amount >= 0),
    UNIQUE (return_id, order_item_id)
);

-- 15. Inventory movement history
CREATE TABLE virtualmart.inventory_movements (
    movement_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    warehouse_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    movement_type VARCHAR(20) NOT NULL
        CHECK (movement_type IN (
            'RECEIPT', 'SALE', 'RETURN', 'ADJUSTMENT', 'TRANSFER'
        )),
    quantity_change INTEGER NOT NULL CHECK (quantity_change <> 0),
    reference_note VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (warehouse_id, product_id)
        REFERENCES virtualmart.inventory(warehouse_id, product_id)
);

-- 16. Audit log for tracking application-recorded changes
CREATE TABLE virtualmart.audit_log (
    audit_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    record_identifier VARCHAR(100) NOT NULL,
    action_type VARCHAR(20) NOT NULL
        CHECK (action_type IN ('INSERT', 'UPDATE', 'DELETE')),
    changed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(100) NOT NULL DEFAULT CURRENT_USER,
    change_details JSONB
);

COMMIT;

-- Verify that all 16 tables were created.
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'virtualmart'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;
