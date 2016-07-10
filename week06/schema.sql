CREATE TABLE IF NOT EXISTS organisms
(
    o_id INTEGER PRIMARY KEY AUTOINCREMENT,
    sci_name VARCHAR(255) NOT NULL,
    comm_name VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS tissues
(
    t_id INTEGER PRIMARY KEY AUTOINCREMENT,
    t_name VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS genes
(
    g_id INTEGER PRIMARY KEY AUTOINCREMENT,
    g_name VARCHAR(255) NOT NULL,
    organism INTEGER REFERENCES organisms(o_id),
    seq TEXT NOT NULL,
    tissue INTEGER REFERENCES tissues(t_id),
    exp_level DOUBLE,
    orf_start INTEGER,
    orf_stop INTEGER
);
