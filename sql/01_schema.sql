
-- ============================================================
-- Project: VirtualMart
-- Task: Week 1 - Data Modeling and Architecture Design
-- Database: PostgreSQL
-- File: 01_schema.sql
-- ============================================================

CREATE SCHEMA IF NOT EXISTS virtualmart;

COMMENT ON SCHEMA virtualmart IS
'Core schema for the fictional VirtualMart online retail platform.';

SELECT schema_name
FROM information_schema.schemata
WHERE schema_name = 'virtualmart';
      