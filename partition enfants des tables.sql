------------ CREATION DES PARTITIONS-------------------

--------------table ordre-------------------------
CREATE TABLE ordre_2026_01
PARTITION OF ordre
FOR VALUES FROM ('2025-12-30') TO ('2026-01-30');

CREATE TABLE ordre_2026_02
PARTITION OF ordre
FOR VALUES FROM ('2026-01-30') TO ('2026-02-28');

CREATE TABLE ordre_2025_12
PARTITION OF ordre
FOR VALUES FROM ('2025-12-01') TO ('2025-12-30');


--------------table trade-------------------------
CREATE TABLE trade_2026_01
PARTITION OF trade
FOR VALUES FROM ('2025-12-30') TO ('2026-01-30');

CREATE TABLE trade_2026_02
PARTITION OF trade
FOR VALUES FROM ('2026-01-30') TO ('2026-02-28');

CREATE TABLE trade_2025_12
PARTITION OF trade
FOR VALUES FROM ('2025-12-01') TO ('2025-12-30');

--------------table audit_trail-------------------------
CREATE TABLE audit_trail_2026_01
PARTITION OF audit_trail
FOR VALUES FROM ('2025-12-30') TO ('2026-01-30');

CREATE TABLE audit_trail_2026_02
PARTITION OF audit_trail
FOR VALUES FROM ('2026-01-30') TO ('2026-02-28');

CREATE TABLE audit_trail_2025_12
PARTITION OF audit_trail
FOR VALUES FROM ('2025-12-01') TO ('2025-12-30');