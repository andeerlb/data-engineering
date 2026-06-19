# JSONB Operators

### Operator Overview

| Operator | Right operand | Returns | Description |
|----------|--------------|---------|-------------|
| `->` | text / integer | jsonb | Get object field or array element |
| `->>` | text / integer | text | Get object field or array element as text |
| `#>` | text[] | jsonb | Get value at path |
| `#>>` | text[] | text | Get value at path as text |
| `@>` | jsonb | boolean | Does left contain right? |
| `<@` | jsonb | boolean | Is left contained in right? |
| `?` | text | boolean | Does key/element exist? |
| `?\|` | text[] | boolean | Do **any** of the keys exist? |
| `?&` | text[] | boolean | Do **all** of the keys exist? |
| `\|\|` | jsonb | jsonb | Concatenate / merge two JSONB values |
| `-` | text / integer | jsonb | Delete a key or array element |
| `#-` | text[] | jsonb | Delete the field at a path |


### `->` — Get field (returns JSONB)

Returns the value of a key as a JSONB value. Useful when you need to further operate on the result (compare, nest, index, etc.).

```sql
-- Get the brand field as JSONB
SELECT attrs->'brand' FROM products LIMIT 3;
```

```sql
-- Access a nested object
SELECT attrs->'ratings' FROM products LIMIT 3;
```

```sql
-- Chain operators to go deeper
SELECT attrs->'ratings'->'average' FROM products LIMIT 3;
-- result: 4.7
```

```sql
-- Access an array element by index (0-based)
SELECT attrs->'tags'->0 FROM products LIMIT 3;
```


### `->>` — Get field as text (returns TEXT)

Same as `->` but casts the result to plain text. Use this when you need to filter, sort, or cast to a SQL type.

```sql
-- Get brand as text (no surrounding quotes)
SELECT attrs->>'brand' FROM products LIMIT 3;
-- result: Keychron  (plain text)
```

```sql
-- Cast to numeric for math
SELECT
    name,
    (attrs->>'price')::NUMERIC AS price
FROM products
ORDER BY price DESC
LIMIT 5;
```

```sql
-- Filter by text value
SELECT name FROM products
WHERE attrs->>'brand' = 'Sony';
```

```sql
-- Get array element as text
SELECT attrs->'tags'->>0 FROM products LIMIT 3;
-- result: keyboard  (plain text, no quotes)
```

### `->` vs `->>` at a glance

| Expression | Type returned | Value example |
|------------|--------------|---------------|
| `attrs->'brand'` | jsonb | `"Keychron"` |
| `attrs->>'brand'` | text | `Keychron` |
| `attrs->'price'` | jsonb | `119.99` |
| `attrs->>'price'` | text | `119.99` (castable to NUMERIC) |

> Use `->>` whenever you need to compare with a SQL string, cast to a number, or use in `WHERE`/`ORDER BY`. Use `->` when you need to keep working with the result as JSONB.


### `#>` — Get value at path (returns JSONB)

Navigates a nested path in one step using a text array instead of chaining `->`.

```sql
-- Equivalent to attrs->'specs'->'switch_type'
SELECT attrs #> '{specs, switch_type}' FROM products LIMIT 1;
-- result: "Cherry MX Red"
```

```sql
-- Access a nested array element by index
SELECT attrs #> '{tags, 0}' FROM products LIMIT 1;
-- result: "keyboard"
```

```sql
-- Navigate multiple levels deep
SELECT attrs #> '{specs, connectivity, 0}' FROM products LIMIT 1;
-- result: "USB-C"
```

### `#>>` — Get value at path as text (returns TEXT)

Same as `#>` but returns plain text. The path variant of `->>`

```sql
SELECT attrs #>> '{specs, switch_type}' FROM products LIMIT 1;
-- result: Cherry MX Red  (plain text)
```

```sql
-- Cast and filter using a deep path
SELECT name, (attrs #>> '{ratings, average}')::NUMERIC AS avg_rating
FROM products
WHERE (attrs #>> '{ratings, count}')::INTEGER > 10000
ORDER BY avg_rating DESC;
```

### Path operators at a glance

| Expression | Equivalent | Returns |
|------------|-----------|---------|
| `attrs #> '{specs, weight_kg}'` | `attrs->'specs'->'weight_kg'` | jsonb |
| `attrs #>> '{specs, weight_kg}'` | `attrs->'specs'->>'weight_kg'` | text |

### `@>` — Containment (left contains right)

Returns `true` if the left JSONB value contains all keys/values present in the right operand. The right side is a subset check.

```sql
-- Does the product have brand "Sony"?
SELECT name FROM products
WHERE attrs @> '{"brand": "Sony"}';
```

```sql
-- Does the product have in_stock true AND price 119.99?
SELECT name FROM products
WHERE attrs @> '{"in_stock": true, "price": 119.99}';
```

```sql
-- Does the tags array contain "wireless"?
SELECT name FROM products
WHERE attrs @> '{"tags": ["wireless"]}';
-- Note: the right side must also be an array, but order doesn't matter
```

```sql
-- Does the nested specs object contain a specific key-value?
SELECT name FROM products
WHERE attrs @> '{"specs": {"panel": "IPS"}}';
```

> `@>` is the operator that benefits most from a **GIN index**. For large tables, always index before using it in `WHERE`.

### `<@` — Containment (left is contained in right)

The reverse of `@>`. Returns `true` if the left value is a subset of the right.

```sql
-- Is this literal a subset of the product's attrs?
SELECT name FROM products
WHERE '{"brand": "LG"}'::JSONB <@ attrs;
-- Same result as: WHERE attrs @> '{"brand": "LG"}'
```

> In practice, `<@` is less common. It's mainly useful when you have a known superset on the right and want to check containment from the opposite direction.

### `?` — Key / element existence

Returns `true` if the given text key exists as a top-level key in the object, or as an element in a JSONB array.

```sql
-- Does the top-level key "brand" exist?
SELECT name FROM products
WHERE attrs ? 'brand';
```

```sql
-- Does the "specs" key exist?
SELECT name FROM products
WHERE attrs ? 'specs';
```

```sql
-- Check existence on a nested array
SELECT name FROM products
WHERE attrs->'tags' ? 'wireless';
-- Returns products whose tags array contains the string "wireless"
```

> `?` checks for key presence, not value. Use `@>` when you need to match both key and value.


### `?|` — Any key exists

Returns `true` if **at least one** of the provided keys exists.

```sql
-- Products that have either a "battery_hours" OR "switch_type" spec
SELECT name FROM products
WHERE attrs->'specs' ?| ARRAY['battery_hours', 'switch_type'];
```

```sql
-- Products tagged with "wireless" OR "bluetooth" OR "nvme"
SELECT name FROM products
WHERE attrs->'tags' ?| ARRAY['wireless', 'bluetooth', 'nvme'];
```

### `?&` — All keys exist

Returns `true` only if **every** key in the array exists.

```sql
-- Products whose attrs have both "brand" AND "in_stock" AND "price"
SELECT name FROM products
WHERE attrs ?& ARRAY['brand', 'in_stock', 'price'];
```

```sql
-- Products whose specs contain both "material" and "colors"
SELECT name FROM products
WHERE attrs->'specs' ?& ARRAY['material', 'colors'];
```

### Existence operators at a glance

| Operator | Meaning | Example |
|----------|---------|---------|
| `? 'key'` | key exists | `attrs ? 'brand'` |
| `?\| ARRAY[...]` | any key exists | `attrs ?\| ARRAY['a','b']` |
| `?& ARRAY[...]` | all keys exist | `attrs ?& ARRAY['a','b']` |


### `||` — Concatenation / Merge

Merges two JSONB objects. On key conflict, the **right side wins**. Already introduced in basics; shown here in context with operators.

```sql
-- Merge two objects
SELECT
    '{"name": "Alice", "city": "NYC"}'::JSONB
    ||
    '{"city": "London", "country": "UK"}'::JSONB;
-- result: {"city": "London", "country": "UK", "name": "Alice"}
```

```sql
-- Add a computed field to query output (does not modify the table)
SELECT
    name,
    attrs || jsonb_build_object('on_sale', true, 'sale_price', (attrs->>'price')::NUMERIC * 0.9) AS enriched
FROM products
WHERE category = 'electronics';
```

### `-` — Delete key or array element

Removes a key from an object or an element from an array by index. Returns the modified JSONB (does **not** update the table unless used in an `UPDATE`).

```sql
-- Remove the "brand" key from attrs
SELECT attrs - 'brand' FROM products LIMIT 3;
```

```sql
-- Remove multiple keys at once (pass a text array)
SELECT attrs - ARRAY['brand', 'in_stock'] FROM products LIMIT 3;
```

```sql
-- Remove the first element (index 0) from an array
SELECT '["a", "b", "c"]'::JSONB - 0;
-- result: ["b", "c"]
```

```sql
-- Persist the removal (UPDATE)
UPDATE products
SET attrs = attrs - 'legacy_field'
WHERE attrs ? 'legacy_field';
```

### `#-` — Delete field at path

Removes a nested field identified by a path array.

```sql
-- Remove specs.weight_kg from all products
SELECT attrs #- '{specs, weight_kg}' FROM products LIMIT 3;
```

```sql
-- Remove the second tag (index 1) from the tags array
SELECT attrs #- '{tags, 1}' FROM products LIMIT 3;
```

```sql
-- Persist the removal
UPDATE products
SET attrs = attrs #- '{specs, weight_kg}';
```

### Deletion operators at a glance

| Operator | Use case | Example |
|----------|---------|---------|
| `- 'key'` | Remove top-level key | `attrs - 'brand'` |
| `- ARRAY[...]` | Remove multiple top-level keys | `attrs - ARRAY['a','b']` |
| `- integer` | Remove array element by index | `arr - 0` |
| `#- '{path}'` | Remove key at nested path | `attrs #- '{specs, weight_kg}'` |

## Combining Operators

Operators compose naturally — chain and combine them in `SELECT`, `WHERE`, and `UPDATE`.

```sql
-- Filter by nested value, return a nested field as text
SELECT
    name,
    attrs->>'brand'                          AS brand,
    (attrs #>> '{ratings, average}')::NUMERIC AS avg_rating
FROM products
WHERE attrs @> '{"in_stock": true}'
  AND (attrs #>> '{ratings, count}')::INTEGER > 5000
ORDER BY avg_rating DESC;
```

```sql
-- Update a nested value using || and #-
UPDATE products
SET attrs = (attrs #- '{specs, legacy}') || '{"specs": {"updated": true}}'
WHERE name = 'Mechanical Keyboard TKL';
```

```sql
-- Check containment AND key existence together
SELECT name FROM products
WHERE attrs @> '{"in_stock": true}'
  AND attrs->'specs' ? 'battery_hours';
```
