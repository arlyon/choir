-- Table for choir works/booklets
CREATE TABLE works (
    work_id TEXT PRIMARY KEY NOT NULL, -- ID used in QR codes
    title TEXT NOT NULL,
    composer TEXT
);

-- Table for choir members
CREATE TABLE users (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE -- Optional: for contact/notifications
);

-- Table to track checkouts
CREATE TABLE checkouts (
    checkout_id INTEGER PRIMARY KEY AUTOINCREMENT,
    work_id TEXT NOT NULL,
    user_id INTEGER NOT NULL,
    checkout_timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    return_timestamp DATETIME, -- NULL indicates currently checked out
    FOREIGN KEY (work_id) REFERENCES works(work_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Index for faster lookups of currently checked out items
CREATE INDEX idx_current_checkouts ON checkouts(work_id) WHERE return_timestamp IS NULL;
CREATE INDEX idx_user_checkouts ON checkouts(user_id, return_timestamp);


-- View to easily see currently checked out works and who has them
CREATE VIEW checked_out_works AS
SELECT
    c.checkout_id,
    c.checkout_timestamp,
    w.work_id,
    w.title AS work_title,
    w.composer,
    u.user_id,
    u.name AS user_name,
    u.email AS user_email
FROM
    checkouts c
JOIN
    works w ON c.work_id = w.work_id
JOIN
    users u ON c.user_id = u.user_id
WHERE
    c.return_timestamp IS NULL; -- Only show items not yet returned

CREATE VIEW completed_checkouts AS
SELECT
    c.checkout_id,
    c.checkout_timestamp,
    c.return_timestamp,
    w.work_id,
    w.title as work_title,
    w.composer,
    u.user_id,
    u.name as user_name,
    u.email as user_email
FROM
    checkouts c
JOIN
    works w ON c.work_id = w.work_id
JOIN
    users u ON c.user_id = u.user_id
WHERE
    c.return_timestamp IS NOT NULL;