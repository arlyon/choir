-- SQL data generation for Choir Library Schema
-- Generated on: 2025-04-12

-- Clear existing data (optional, uncomment if needed)
-- DELETE FROM checkouts;
-- DELETE FROM users;
-- DELETE FROM works;

-- Insert sample works
INSERT INTO works (work_id, title, composer) VALUES
('BWV244', 'St. Matthew Passion', 'J.S. Bach'),
('HWV56', 'Messiah', 'G.F. Handel'),
('K626', 'Requiem', 'W.A. Mozart'),
('FAU048', 'Requiem, Op. 48', 'Gabriel Fauré'),
('BRA045', 'Ein deutsches Requiem, Op. 45', 'Johannes Brahms'),
('RUT001', 'Gloria', 'John Rutter'),
('VIV589', 'Gloria in D Major, RV 589', 'Antonio Vivaldi'),
('ORF001', 'Carmina Burana', 'Carl Orff'),
('BWV232', 'Mass in B Minor', 'J.S. Bach'),
('HAY021', 'The Creation', 'Joseph Haydn'),
('WHI001', 'Lux Aurumque', 'Eric Whitacre'),
('MEN070', 'Elijah, Op. 70', 'Felix Mendelssohn'),
('PURZ339','Dido and Aeneas', 'Henry Purcell'),
('TAV001', 'Song for Athene', 'John Tavener'),
('VER001', 'Requiem', 'Giuseppe Verdi');

-- Insert sample users
INSERT INTO users (user_id, name, email) VALUES
('USR001', 'Alice Smith', 'alice.s@choirmail.org'),
('USR002', 'Bob Johnson', 'b.johnson@choirmail.org'),
('USR003', 'Charlie Brown', 'charlie.brown@example.com'),
('USR004', 'Diana Evans', 'diana.e@choirmail.org'),
('USR005', 'Evan Williams', 'e.williams@example.com'),
('USR006', 'Fiona Davis', 'fiona.davis@choirmail.org'),
('USR007', 'George Miller', 'george.m@example.com'),
('USR008', 'Hannah Wilson', 'hannah.w@choirmail.org'),
('USR009', 'Ian Moore', 'ian.moore@example.com'),
('USR010', 'Jessica Taylor', 'jess.t@choirmail.org'),
('USR011', 'Kevin Anderson', 'k.anderson@example.com'),
('USR012', 'Laura Thomas', 'laura.t@choirmail.org'),
('USR013', 'Michael Jackson', 'm.jackson@example.com'),
('USR014', 'Nancy White', 'nancy.w@choirmail.org'),
('USR015', 'Oliver Harris', 'oliver.h@example.com'),
('USR016', 'Patricia Martin', 'pat.m@choirmail.org'),
('USR017', 'Quentin Thompson', 'q.thompson@example.com'),
('USR018', 'Rachel Garcia', 'rachel.g@choirmail.org'),
('USR019', 'Steven Martinez', 'steve.m@example.com'),
('USR020', 'Tracy Robinson', 'tracy.r@choirmail.org'),
('USR021', 'Ursula Clark', 'ursula.c@example.com'),
('USR022', 'Victor Rodriguez', 'victor.r@choirmail.org'),
('USR023', 'Wendy Lewis', 'wendy.l@example.com'),
('USR024', 'Xavier Lee', 'xavier.l@choirmail.org'),
('USR025', 'Yvonne Walker', 'yvonne.w@example.com');

-- Insert sample checkouts (mix of current and returned)
-- Note: instance numbers must be unique
-- Returned items
INSERT INTO checkouts (work_id, user_id, instance, checkout_timestamp, return_timestamp) VALUES
('HWV56', 'USR001', 1, '2025-01-10 10:00:00', '2025-02-15 17:30:00'), -- Alice returned Messiah
('FAU048', 'USR003', 2, '2025-02-20 11:00:00', '2025-03-30 09:15:00'), -- Charlie returned Faure Requiem
('BWV244', 'USR006', 3, '2025-01-05 14:00:00', '2025-04-01 18:00:00'), -- Fiona returned St Matthew Passion
('VIV589', 'USR008', 4, '2025-03-10 16:00:00', '2025-04-10 12:00:00'), -- Hannah returned Vivaldi Gloria
('HWV56', 'USR010', 5, '2025-01-15 09:30:00', '2025-03-01 11:00:00'), -- Jessica returned Messiah
('MEN070', 'USR015', 6, '2025-03-15 13:00:00', '2025-04-11 10:45:00'), -- Oliver returned Elijah
('BWV232', 'USR016', 7, '2025-03-02 10:15:00', '2025-04-08 14:00:00'), -- Patricia returned B Minor Mass
('RUT001', 'USR017', 8, '2025-03-06 17:00:00', '2025-04-09 09:00:00'), -- Quentin returned Rutter Gloria
('BRA045', 'USR020', 9, '2025-02-18 18:00:00', '2025-04-05 16:30:00'), -- Tracy returned Brahms Requiem
('ORF001', 'USR022', 10, '2025-03-22 12:00:00', '2025-04-12 09:00:00'),-- Victor returned Carmina Burana (Today)
('BWV244', 'USR023', 11, '2025-01-10 19:00:00', '2025-03-15 10:00:00'),-- Wendy returned St Matthew Passion
('VIV589', 'USR001', 12, '2025-03-11 11:00:00', '2025-04-11 17:00:00'),-- Alice returned Vivaldi Gloria
('BRA045', 'USR002', 13, '2025-02-16 15:00:00', '2025-04-06 10:30:00'),-- Bob returned Brahms Requiem
('HWV56', 'USR006', 14, '2025-01-25 10:00:00', '2025-03-10 19:00:00'),-- Fiona returned Messiah
('BWV244', 'USR009', 15, '2025-01-15 16:30:00', '2025-04-02 11:15:00'),-- Ian returned St Matthew Passion
('FAU048', 'USR011', 16, '2025-03-01 09:00:00', '2025-04-07 17:45:00'),-- Kevin returned Faure Requiem
('VIV589', 'USR013', 17, '2025-03-15 14:30:00', '2025-04-10 10:00:00'); -- Michael returned Vivaldi Gloria

-- Currently checked out items (return_timestamp is NULL)
INSERT INTO checkouts (work_id, user_id, instance, checkout_timestamp, return_timestamp) VALUES
('BWV232', 'USR001', 18, '2025-03-01 10:30:00', NULL), -- Alice has B Minor Mass
('HWV56', 'USR002', 19, '2025-01-11 12:00:00', NULL), -- Bob has Messiah
('RUT001', 'USR004', 20, '2025-03-05 09:00:00', NULL), -- Diana has Rutter Gloria
('K626', 'USR006', 21, '2025-04-02 18:30:00', NULL), -- Fiona has Mozart Requiem
('BRA045', 'USR007', 22, '2025-02-15 10:00:00', NULL), -- George has Brahms Requiem
('ORF001', 'USR009', 23, '2025-03-20 17:00:00', NULL), -- Ian has Carmina Burana
('BWV244', 'USR011', 24, '2025-01-06 11:00:00', NULL), -- Kevin has St Matthew Passion
('FAU048', 'USR012', 25, '2025-02-21 14:00:00', NULL), -- Laura has Faure Requiem
('HAY021', 'USR013', 26, '2025-04-01 10:00:00', NULL), -- Michael has The Creation
('WHI001', 'USR014', 27, '2025-04-05 11:30:00', NULL), -- Nancy has Lux Aurumque
('HWV56', 'USR018', 28, '2025-01-20 15:00:00', NULL), -- Rachel has Messiah
('K626', 'USR019', 29, '2025-04-03 13:00:00', NULL), -- Steven has Mozart Requiem
('VIV589', 'USR021', 30, '2025-03-12 09:45:00', NULL), -- Ursula has Vivaldi Gloria
('FAU048', 'USR024', 31, '2025-02-25 16:00:00', NULL), -- Xavier has Faure Requiem
('HAY021', 'USR025', 32, '2025-04-02 10:30:00', NULL), -- Yvonne has The Creation
('WHI001', 'USR003', 33, '2025-04-06 11:00:00', NULL), -- Charlie has Lux Aurumque
('MEN070', 'USR004', 34, '2025-03-16 12:30:00', NULL), -- Diana has Elijah
('BWV232', 'USR007', 35, '2025-03-05 15:00:00', NULL), -- George has B Minor Mass
('ORF001', 'USR008', 36, '2025-03-25 10:00:00', NULL), -- Hannah has Carmina Burana
('K626', 'USR010', 37, '2025-04-04 14:00:00', NULL), -- Jessica has Mozart Requiem
('RUT001', 'USR012', 38, '2025-03-10 10:00:00', NULL), -- Laura has Rutter Gloria
('BRA045', 'USR014', 39, '2025-02-20 13:30:00', NULL), -- Nancy has Brahms Requiem
('HWV56', 'USR015', 40, '2025-01-30 17:00:00', NULL), -- Oliver has Messiah
('VER001', 'USR019', 41, '2025-04-10 09:30:00', NULL), -- Steven has Verdi Requiem
('PURZ339','USR023', 42, '2025-04-08 15:00:00', NULL); -- Wendy has Dido and Aeneas

-- End of generated data