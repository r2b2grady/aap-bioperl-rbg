CREATE TABLE org_types
(
    ot_id INT NOT NULL,
    type_name TEXT NOT NULL,
    PRIMARY KEY (ot_id)
);

CREATE TABLE organisms
(
    o_id INT NOT NULL,
    org_type INT,
    comm_name TEXT,
    sci_name TEXT NOT NULL,
    PRIMARY KEY (o_id),
    FOREIGN KEY (org_type) REFERENCES org_types(ot_id)
);

CREATE TABLE tissues
(
    t_id INT NOT NULL,
    name TEXT NOT NULL,
    PRIMARY KEY (t_id)
);

CREATE TABLE genes
(
    g_id INT NOT NULL,
    name TEXT NOT NULL,
    organism INT,
    seq TEXT,
    tissue INT,
    exp_level DOUBLE,
    orf_start INT,
    orf_stop INT,
    PRIMARY KEY (g_id),
    FOREIGN KEY (organism) REFERENCES organisms(o_id),
    FOREIGN KEY (tissue) REFERENCES tissues(t_id)
);
