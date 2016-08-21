CREATE TABLE cities
(
    c_id INTEGER PRIMARY KEY AUTOINCREMENT,
    c_name TEXT NOT NULL
);

CREATE TABLE friends
(
    f_id INTEGER PRIMARY KEY AUTOINCREMENT,
    f_name TEXT NOT NULL,
    home_city INTEGER REFERENCES cities(c_id)
);

CREATE TABLE gifts
(
    g_id INTEGER PRIMARY KEY AUTOINCREMENT,
    g_name TEXT NOT NULL
);

CREATE TABLE retailers
(
    r_id INTEGER PRIMARY KEY AUTOINCREMENT,
    r_name TEXT NOT NULL,
    is_online INTEGER(1) NOT NULL DEFAULT 0,
    has_stores INTEGER(1) NOT NULL DEFAULT 1
);


CREATE TABLE retailer_locations
(
    retailer INTEGER REFERENCES retailers(r_id),
    city INTEGER REFERENCES cities(c_id),
    ships_items INTEGER(1) NOT NULL DEFAULT 0,
    PRIMARY KEY(r_id, c_id)
);

CREATE TABLE prices
(
    retailer INTEGER REFERENCES retailers(r_id),
    gift INTEGER REFERENCES gifts(g_id),
    price FLOAT NOT NULL,
    PRIMARY KEY(r_id, g_id)
);

CREATE TABLE city_distances
(
    city_a INTEGER REFERENCES cities(c_id),
    city_b INTEGER REFERENCES cities(c_id)
    miles FLOAT NOT NULL,
    PRIMARY KEY(city_a, city_b)
);

CREATE TABLE shipping
(
    retailer INTEGER,
    gift INTEGER,
    to_city INTEGER REFERENCES cities(c_id),
    avg_days INTEGER NOT NULL,
    shipping_cost FLOAT NOT NULL,
    FOREIGN KEY(retailer, gift) REFERENCES prices(retailer, gift),
    PRIMARY KEY(retailer, gift, to_city)
);