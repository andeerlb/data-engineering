-- 1. JSON vs JSONB — what's the difference?
-- JSON  → stores the raw text as-is (preserves key order and whitespace)
-- JSONB → decomposes into a binary format on insert:
--           • duplicate keys are removed (last value wins)
--           • key order is NOT guaranteed
--           • significantly faster to query and supports indexes

-- JSON preserves duplicates and order:
SELECT '{"a": 1, "b": 2, "a": 99}'::JSON;
-- result: {"a": 1, "b": 2, "a": 99}   ← duplicate key kept

-- JSONB removes duplicates (last value wins) and may reorder keys:
SELECT '{"a": 1, "b": 2, "a": 99}'::JSONB;
-- result: {"a": 99, "b": 2}            ← duplicate removed, order may differ


-- Casting text to JSONB
SELECT '{"name": "Alice", "age": 30}'::JSONB;

-- You can also use the CAST() function — equivalent
SELECT CAST('{"name": "Alice", "age": 30}' AS JSONB);


-- Selecting JSONB columns
SELECT id, name, attrs
FROM products
LIMIT 3;

-- Pretty-print with jsonb_pretty()
SELECT id, name, jsonb_pretty(attrs)
FROM products
LIMIT 3;


-- jsonb_typeof() — inspect the data type of a JSONB value
-- Returns: 'object', 'array', 'string', 'number', 'boolean', 'null'

SELECT jsonb_typeof('{"key": "value"}'::JSONB);   -- object
SELECT jsonb_typeof('[1, 2, 3]'::JSONB);           -- array
SELECT jsonb_typeof('"hello"'::JSONB);             -- string
SELECT jsonb_typeof('42'::JSONB);                  -- number
SELECT jsonb_typeof('true'::JSONB);                -- boolean
SELECT jsonb_typeof('null'::JSONB);                -- null

-- Check the type of each column and a nested value
SELECT
    id,
    name,
    jsonb_typeof(attrs)              AS attrs_type,
    jsonb_typeof(attrs->'tags')      AS tags_type,
    jsonb_typeof(attrs->'in_stock')  AS in_stock_type,
    jsonb_typeof(attrs->'price')     AS price_type
FROM products
LIMIT 5;


-- Storing JSONB — valid vs invalid JSON
-- JSONB will reject malformed JSON at insert time:

-- Valid
SELECT '{"valid": true}'::JSONB;

-- Invalid — uncomment to see the error:
SELECT '{bad json}'::JSONB;
-- ERROR: invalid input syntax for type json


-- ============================================================
-- 6. NULL handling in JSONB
-- ============================================================
-- SQL NULL (column is absent) vs JSON null (explicit null value)

-- The brand column is SQL NULL for books:
SELECT id, name, attrs->>'brand' AS brand_text
FROM products
WHERE category = 'books'
LIMIT 3;

-- But the value IS present in the JSON as null — not missing:
SELECT id, name, attrs->'brand' AS brand_jsonb
FROM products
WHERE category = 'books'
LIMIT 3;
-- brand_jsonb returns: null  (JSON null, rendered as text "null")

-- Filtering on JSON null vs SQL NULL:
SELECT id, name
FROM products
WHERE attrs->'brand' = 'null'::JSONB;  -- books with explicit JSON null

SELECT id, name
FROM products
WHERE attrs->>'brand' IS NULL;  -- returns rows where brand is JSON null OR key is missing


-- ============================================================
-- 7. Comparing JSONB values
-- ============================================================
-- JSONB supports =, <>, <, >, <=, >= operators

SELECT '{"a": 1}'::JSONB = '{"a": 1}'::JSONB;   -- true
SELECT '{"a": 1}'::JSONB = '{"a": 2}'::JSONB;   -- false

-- Key order doesn't matter for equality in JSONB
SELECT '{"b": 2, "a": 1}'::JSONB = '{"a": 1, "b": 2}'::JSONB;  -- true


-- ============================================================
-- 8. Concatenation and merging with ||
-- ============================================================
-- The || operator merges two JSONB objects (right side wins on conflict)

SELECT
    '{"name": "Alice", "city": "NYC"}'::JSONB
    ||
    '{"city": "London", "country": "UK"}'::JSONB;
-- result: {"city": "London", "country": "UK", "name": "Alice"}

-- Add a new field to attrs on the fly (read-only, not persisted):
SELECT
    id,
    name,
    attrs || '{"discount": 0.10}'::JSONB AS attrs_with_discount
FROM products
WHERE category = 'electronics'
LIMIT 3;
