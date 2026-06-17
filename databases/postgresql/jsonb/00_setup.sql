CREATE TABLE products (
    id        INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name      TEXT    NOT NULL,
    category  TEXT    NOT NULL,
    attrs     JSONB   NOT NULL
);
-- Electronics
INSERT INTO products (name, category, attrs) VALUES
(
    'Mechanical Keyboard TKL',
    'electronics',
    '{
        "brand": "Keychron",
        "price": 119.99,
        "in_stock": true,
        "tags": ["keyboard", "mechanical", "rgb", "tenkeyless"],
        "specs": {
            "switch_type": "Cherry MX Red",
            "connectivity": ["USB-C", "Bluetooth"],
            "backlight": "RGB",
            "weight_kg": 0.84
        },
        "ratings": {"average": 4.7, "count": 3812}
    }'
),
(
    'Wireless Noise-Cancelling Headphones',
    'electronics',
    '{
        "brand": "Sony",
        "price": 349.00,
        "in_stock": true,
        "tags": ["headphones", "wireless", "noise-cancelling", "premium"],
        "specs": {
            "battery_hours": 30,
            "connectivity": ["Bluetooth 5.2", "3.5mm jack"],
            "foldable": true,
            "weight_kg": 0.25
        },
        "ratings": {"average": 4.8, "count": 21045}
    }'
),
(
    '27" 4K Monitor',
    'electronics',
    '{
        "brand": "LG",
        "price": 599.99,
        "in_stock": false,
        "tags": ["monitor", "4k", "ips", "usb-c"],
        "specs": {
            "resolution": "3840x2160",
            "refresh_rate_hz": 60,
            "panel": "IPS",
            "connectivity": ["HDMI 2.0", "DisplayPort 1.4", "USB-C"],
            "weight_kg": 5.9
        },
        "ratings": {"average": 4.5, "count": 8721}
    }'
),
(
    'USB-C Hub 7-in-1',
    'electronics',
    '{
        "brand": "Anker",
        "price": 45.99,
        "in_stock": true,
        "tags": ["hub", "usb-c", "adapter", "portable"],
        "specs": {
            "ports": ["USB-A x3", "HDMI", "SD", "microSD", "USB-C PD"],
            "max_power_delivery_w": 100,
            "weight_kg": 0.09
        },
        "ratings": {"average": 4.4, "count": 5530}
    }'
),
(
    'Mechanical SSD 2TB',
    'electronics',
    '{
        "brand": "Samsung",
        "price": 189.99,
        "in_stock": true,
        "tags": ["storage", "ssd", "nvme"],
        "specs": {
            "capacity_gb": 2000,
            "interface": "NVMe PCIe 4.0",
            "read_speed_mb_s": 7000,
            "write_speed_mb_s": 6500,
            "form_factor": "M.2 2280"
        },
        "ratings": {"average": 4.9, "count": 14200}
    }'
),
-- Clothing
(
    'Merino Wool T-Shirt',
    'clothing',
    '{
        "brand": "Unbound Merino",
        "price": 65.00,
        "in_stock": true,
        "tags": ["t-shirt", "merino", "travel", "odor-resistant"],
        "specs": {
            "material": "100% Merino Wool",
            "sizes": ["XS", "S", "M", "L", "XL", "XXL"],
            "colors": ["white", "black", "navy", "grey"],
            "care": "Machine wash cold"
        },
        "ratings": {"average": 4.6, "count": 2100}
    }'
),
(
    'Slim Fit Chinos',
    'clothing',
    '{
        "brand": "Bonobos",
        "price": 98.00,
        "in_stock": true,
        "tags": ["pants", "chinos", "slim", "casual"],
        "specs": {
            "material": "97% Cotton, 3% Elastane",
            "sizes": ["28x30", "30x30", "30x32", "32x30", "32x32", "34x32"],
            "colors": ["khaki", "olive", "navy", "stone"],
            "care": "Machine wash cold, tumble dry low"
        },
        "ratings": {"average": 4.3, "count": 870}
    }'
),
(
    'Running Shoes',
    'clothing',
    '{
        "brand": "Brooks",
        "price": 140.00,
        "in_stock": true,
        "tags": ["shoes", "running", "cushioned", "neutral"],
        "specs": {
            "material": "Engineered mesh upper",
            "sizes": [7, 7.5, 8, 8.5, 9, 9.5, 10, 10.5, 11, 12, 13],
            "drop_mm": 12,
            "weight_oz": 10.2,
            "colors": ["black/white", "blue/orange", "grey/green"]
        },
        "ratings": {"average": 4.7, "count": 5643}
    }'
),
(
    'Insulated Winter Jacket',
    'clothing',
    '{
        "brand": "Patagonia",
        "price": 299.00,
        "in_stock": false,
        "tags": ["jacket", "insulated", "winter", "outdoor", "recycled"],
        "specs": {
            "material": "100% recycled polyester",
            "insulation": "700-fill-power recycled down",
            "sizes": ["XS", "S", "M", "L", "XL"],
            "colors": ["black", "blue", "red"],
            "waterproof": false,
            "water_resistant": true
        },
        "ratings": {"average": 4.8, "count": 3321}
    }'
),

-- Food and Kitchen
(
    'Single Origin Ethiopian Coffee Beans',
    'food',
    '{
        "brand": "Blue Bottle",
        "price": 22.00,
        "in_stock": true,
        "tags": ["coffee", "single-origin", "light-roast", "ethiopia"],
        "specs": {
            "origin": "Yirgacheffe, Ethiopia",
            "roast": "Light",
            "process": "Washed",
            "tasting_notes": ["floral", "blueberry", "citrus"],
            "weight_g": 250
        },
        "ratings": {"average": 4.6, "count": 1890}
    }'
),
(
    'Cast Iron Skillet 12"',
    'food',
    '{
        "brand": "Lodge",
        "price": 49.90,
        "in_stock": true,
        "tags": ["cookware", "cast-iron", "skillet", "oven-safe"],
        "specs": {
            "material": "Cast Iron",
            "diameter_in": 12,
            "pre_seasoned": true,
            "oven_safe_f": 500,
            "compatible_surfaces": ["gas", "electric", "induction", "oven", "campfire"],
            "weight_kg": 3.6
        },
        "ratings": {"average": 4.8, "count": 42800}
    }'
),
(
    'Stainless Steel Water Bottle 32oz',
    'food',
    '{
        "brand": "Hydro Flask",
        "price": 44.95,
        "in_stock": true,
        "tags": ["water-bottle", "insulated", "stainless", "bpa-free"],
        "specs": {
            "capacity_oz": 32,
            "insulation_hours": {"cold": 24, "hot": 12},
            "material": "18/8 stainless steel",
            "bpa_free": true,
            "colors": ["black", "white", "fog", "pacific", "olive"],
            "weight_g": 349
        },
        "ratings": {"average": 4.7, "count": 18500}
    }'
),
-- Books
(
    'Designing Data-Intensive Applications',
    'books',
    '{
        "brand": null,
        "price": 55.99,
        "in_stock": true,
        "tags": ["books", "databases", "distributed-systems", "engineering"],
        "specs": {
            "author": "Martin Kleppmann",
            "publisher": "O'\''Reilly",
            "year": 2017,
            "pages": 616,
            "isbn": "978-1449373320",
            "format": ["hardcover", "ebook", "pdf"]
        },
        "ratings": {"average": 4.9, "count": 6700}
    }'
),
(
    'The Pragmatic Programmer',
    'books',
    '{
        "brand": null,
        "price": 49.99,
        "in_stock": true,
        "tags": ["books", "software-engineering", "career", "classic"],
        "specs": {
            "author": "David Thomas & Andrew Hunt",
            "publisher": "Addison-Wesley",
            "year": 2019,
            "pages": 352,
            "isbn": "978-0135957059",
            "format": ["hardcover", "ebook"]
        },
        "ratings": {"average": 4.7, "count": 4210}
    }'
),
(
    'Clean Code',
    'books',
    '{
        "brand": null,
        "price": 39.99,
        "in_stock": true,
        "tags": ["books", "software-engineering", "best-practices"],
        "specs": {
            "author": "Robert C. Martin",
            "publisher": "Prentice Hall",
            "year": 2008,
            "pages": 431,
            "isbn": "978-0132350884",
            "format": ["hardcover", "ebook", "audiobook"]
        },
        "ratings": {"average": 4.4, "count": 9800}
    }'
),
-- Health and Fitness
(
    'Adjustable Dumbbells 5-52.5 lbs',
    'fitness',
    '{
        "brand": "Bowflex",
        "price": 429.00,
        "in_stock": true,
        "tags": ["dumbbells", "adjustable", "home-gym", "strength"],
        "specs": {
            "weight_range_lbs": [5, 52.5],
            "increments_lbs": 2.5,
            "material": "Steel",
            "replaces_sets": 15,
            "weight_each_lbs": 52.5
        },
        "ratings": {"average": 4.6, "count": 7200}
    }'
),
(
    'Yoga Mat Non-Slip',
    'fitness',
    '{
        "brand": "Manduka",
        "price": 88.00,
        "in_stock": true,
        "tags": ["yoga", "mat", "non-slip", "eco"],
        "specs": {
            "thickness_mm": 5,
            "material": "Natural tree rubber",
            "dimensions_cm": [180, 61],
            "weight_kg": 2.0,
            "colors": ["black", "teal", "purple", "sage"]
        },
        "ratings": {"average": 4.8, "count": 3100}
    }'
),
(
    'Resistance Bands Set',
    'fitness',
    '{
        "brand": "Fit Simplify",
        "price": 14.95,
        "in_stock": true,
        "tags": ["resistance-bands", "home-gym", "rehab", "portable"],
        "specs": {
            "resistance_levels": ["X-Light", "Light", "Medium", "Heavy", "X-Heavy"],
            "resistance_lbs": [2, 4, 6, 8, 10],
            "material": "Natural latex",
            "set_count": 5
        },
        "ratings": {"average": 4.5, "count": 28000}
    }'
),
(
    'Protein Powder Whey Vanilla 5lb',
    'fitness',
    '{
        "brand": "Optimum Nutrition",
        "price": 59.99,
        "in_stock": true,
        "tags": ["protein", "whey", "supplement", "post-workout"],
        "specs": {
            "weight_lbs": 5,
            "servings": 74,
            "protein_per_serving_g": 24,
            "calories_per_serving": 120,
            "flavor": "Vanilla Ice Cream",
            "allergens": ["milk", "soy"],
            "certifications": ["NSF Certified", "Informed Choice"]
        },
        "ratings": {"average": 4.6, "count": 51000}
    }'
);

-- Verify the data
SELECT
    category,
    COUNT(*) AS product_count,
    ROUND(AVG((attrs->>'price')::NUMERIC), 2) AS avg_price
FROM products
GROUP BY category
ORDER BY category;
