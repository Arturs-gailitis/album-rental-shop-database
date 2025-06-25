CREATE TABLE album ( 
id integer PRIMARY KEY, 
album_name varchar (25), 
price decimal, 
description text, 
available boolean); 

INSERT INTO album (id, album_name, price, description, available) 
VALUES 
(1, 'Some Girls', 19.91, 'Author: Rolling Stones', true), 
(2, 'Continuum', 24.09, 'Author: John Mayer', false), 
(3, 'Ask Rufus', 25.53, 'Author: Rufus', true); 

ALTER TABLE album 
ADD COLUMN label_id integer, 
ADD CONSTRAINT fk_label 
FOREIGN KEY (label_id) 
REFERENCES label(id); 

ALTER TABLE album 
ADD COLUMN music_group_id integer, 
ADD CONSTRAINT fk_music_group_id 
FOREIGN KEY (music_group_id) 
REFERENCES music_group (id); 

CREATE INDEX index_album_name ON album(album_name); 
CREATE INDEX index_label_id ON album(label_id); 

ALTER TABLE album 
ADD CONSTRAINT check_price_non_negative CHECK (price >= 0); 

ALTER TABLE album 
ADD CONSTRAINT unique_album_name UNIQUE (album_name);  

ALTER TABLE album 
ALTER COLUMN album_name SET NOT NULL; 

ALTER TABLE album 
ALTER COLUMN available SET DEFAULT true; 

ALTER TABLE album 
ADD CONSTRAINT max_length_album_name CHECK (LENGTH(album_name) <= 50); 

CREATE OR REPLACE FUNCTION update_album_availability() 
RETURNS TRIGGER AS $$ 
BEGIN 
   UPDATE album 
   SET available = false 
   WHERE id = NEW.album_id; 
   RETURN NEW; 
END; 

$$ LANGUAGE plpgsql; 

CREATE TRIGGER update_album_availability_trigger 
AFTER INSERT ON listened_album_by_user 
FOR EACH ROW 
EXECUTE FUNCTION update_album_availability(); 

CREATE TABLE label ( 
id integer PRIMARY KEY, 
name varchar (50) ); 

INSERT INTO label (id, name) 
VALUES 
(11, 'Rolling Stones Records'), 
(22, 'Awere Records'), 
(33, 'ABC Records'); 

ALTER TABLE label 
ADD COLUMN album_id integer, 
ADD CONSTRAINT fk_album 
FOREIGN KEY (album_id) 
REFERENCES album (id); 

CREATE INDEX index_label_name ON label(name); 

ALTER TABLE label 
ADD CONSTRAINT unique_label_name UNIQUE (name); 

ALTER TABLE label 
ALTER COLUMN name SET NOT NULL; 

CREATE TABLE album_release ( 
id integer PRIMARY KEY, 
release_date date); 

INSERT INTO album_release (id, release_date) 
VALUES 
(111, '1978-06-09'), 
(222, '2006-09-12'), 
(333, '1977-01-19'); 

ALTER TABLE album_release 
ADD COLUMN album_id integer, 
ADD CONSTRAINT fk_album 
FOREIGN KEY (album_id) 
REFERENCES album (id); 

CREATE INDEX index_release_date ON album_release (release_date); 

CREATE INDEX index_album_id ON album_release (album_id); 

CREATE TABLE music_genre ( 
id integer PRIMARY KEY, 
genre_name varchar (35), 
description text); 

INSERT INTO music_genre (id, genre_name, description) 
VALUES 
(1111, 'Rock', 'broad genre of popular music that originated as "rock and roll"'), 
(2222, 'Pop rock', 'a fusion genre'), 
(3333, 'Funk', 'a music genre that originated in African American communities'); 

CREATE INDEX index_genre_name ON music_genre (genre_name); 

ALTER TABLE music_genre 
ADD CONSTRAINT unique_genre_name UNIQUE (genre_name); 

ALTER TABLE music_genre 
ALTER COLUMN genre_name SET NOT NULL; 

CREATE TABLE music_group ( 
id integer PRIMARY KEY, 
group_name varchar (50), 
album_id integer, 
FOREIGN KEY (album_id) REFERENCES album(id)); 

INSERT INTO music_group (id, group_name, album_id) 
VALUES 
(11111, 'the Rolling Stones', 1), 
(22222, 'John Mayer', 2), 
(33333, 'Rufus', 3); 

ALTER TABLE music_group 
ADD COLUMN music_genre_id integer, 
ADD CONSTRAINT fk_music_genre_id 
FOREIGN KEY (music_genre_id) REFERENCES music_genre(id); 

ALTER TABLE music_group 
ADD COLUMN group_members_id integer, 
ADD CONSTRAINT fk_group_members_id 
FOREIGN KEY (group_members_id) REFERENCES group_members(id); 

CREATE INDEX index_group_name ON music_group(group_name);

CREATE INDEX index_music_genre_id ON music_group(music_genre_id);

CREATE INDEX index_group_members_id ON music_group(group_members_id); 

ALTER TABLE music_group 
ADD CONSTRAINT unique_group_name UNIQUE (group_name); 

ALTER TABLE music_group 
ADD CONSTRAINT unique_album_id UNIQUE (album_id); 

ALTER TABLE music_group 
ALTER COLUMN group_name SET NOT NULL; 

CREATE OR REPLACE FUNCTION update_group_members_count() 
RETURNS TRIGGER AS $$ 
BEGIN 
     UPDATE music_group 
 SET group_members_count = (SELECT COUNT (*) FROM group_members WHERE group_id = NEW.group_id) 
 WHERE id = NEW.group_id; 
 RETURN NEW; 
END; 

$$ LANGUAGE plpgsql; 

CREATE TRIGGER update_group_members_count_trigger 
AFTER INSERT ON group_members 
FOR EACH ROW 
EXECUTE FUNCTION update_group_members_count(); 

CREATE TABLE group_members ( 
id integer PRIMARY KEY, 
name varchar (40), 
lastname varchar (45)); 

INSERT INTO group_members (id, name, lastname) 
VALUES 
(1111112, 'Mick', 'Jagger'), 
(1111113, 'Keith', 'Richards'), 
(1111114, 'Ronnie', 'Wood'), 
(22221, 'John', 'Mayer'), 
(3333331, 'Chaca', 'Khan'), 
(3333332, 'Tony', 'Maiden'); 

ALTER TABLE group_members 
ADD COLUMN music_instrument_id integer, 
ADD CONSTRAINT fk_music_instrument_id 
FOREIGN KEY (music_instrument_id) REFERENCES music_instrument(id); 

CREATE INDEX index_name ON group_members (name); 

CREATE INDEX index_lastname ON group_members (lastname); 

ALTER TABLE group_members 
ADD CONSTRAINT unique_group_member_name_lastname UNIQUE (name, lastname); 

ALTER TABLE group_members 
ALTER COLUMN name SET NOT NULL; 

ALTER TABLE group_members 
ALTER COLUMN lastname SET NOT NULL; 

CREATE TABLE listened_album_by_user ( 
rented_times integer, 
album_id integer, 
music_genre_id integer, 
listener_id integer); 

INSERT INTO listened_album_by_user (rented_times, album_id, music_genre_id, listener_id) 
VALUES 
(4, 1, 1111, 4), 
(6, 2, 2222, 5), 
(4, 3, 3333, 6); 

ALTER TABLE listened_album_by_user 
ADD CONSTRAINT fk_album 
FOREIGN KEY (album_id) 
REFERENCES album (id) 

ALTER TABLE listened_album_by_user 
ADD CONSTRAINT fk_music_genre_id 
FOREIGN KEY (music_genre_id) REFERENCES music_genre(id); 

ALTER TABLE listened_album_by_user 
ADD CONSTRAINT fk_listener_id 
FOREIGN KEY (listener_id) REFERENCES listener(id); 

CREATE INDEX index_listener ON listened_album_by_user (listener_id); 
CREATE INDEX index_rented_times ON listened_album_by_user (rented_times); 

ALTER TABLE listened_album_by_user 
ADD CONSTRAINT unique_listener_id UNIQUE (listener_id); 

SELECT * FROM listened_album_by_user 

CREATE TABLE music_instrument ( 
id integer PRIMARY KEY, 
name varchar(25), 
description text, 
uses_music_instrument_id integer, 
FOREIGN KEY (uses_music_instrument_id) REFERENCES group_members (id)); 

INSERT INTO music_instrument (id, name, description) 
VALUES 
(1111111, 'Drums', 'percussion group of musical instrument'), 
(2222222, 'guitar', 'fretted musical instrument'); 

CREATE INDEX index_instrument_name ON music_instrument (name); 

ALTER TABLE music_instrument 
ADD CONSTRAINT unique_name UNIQUE (name); 

ALTER TABLE music_instrument 
ALTER COLUMN name SET NOT NULL; 

CREATE OR REPLACE FUNCTION prevent_delete_used_music_instrument() 
RETURNS TRIGGER AS $$ 
BEGIN 
     IF EXISTS ( 
    SELECT 1 
    FROM group_members 
    WHERE music_instrument_id = OLD.id 
 ) THEN  
   RAISE EXCEPTION 'Cannot delete a music instrument that is already used by a group member.'; 
  END IF; 
  RETURN OLD; 
END; 

$$ LANGUAGE plpgsql; 

CREATE TRIGGER prevent_delete_used_music_instrument_trigger 
BEFORE DELETE ON music_instrument 
FOR EACH ROW 
EXECUTE FUNCTION prevent_delete_used_music_instrument(); 

CREATE TABLE listener ( 
id integer PRIMARY KEY, 
name varchar (30), 
lastname varchar (45), 
description text); 

INSERT INTO listener (id, name, lastname, description) 
VALUES 
(4, 'John', 'Long', 'Average male'), 
(5, 'Liza', 'Johnson', 'Small size female'), 
(6, 'Rob', 'Fance', 'Customer who likes rock music'); 

CREATE INDEX index_listener_name ON listener (name); 

CREATE INDEX index_listener_lastname ON listener (lastname); 

ALTER TABLE listener 
ADD CONSTRAINT unique_listener_name_lastname UNIQUE (name, lastname); 

ALTER TABLE listener 
ALTER COLUMN name SET NOT NULL; 

ALTER TABLE listener 
ALTER COLUMN lastname SET NOT NULL; 

CREATE ROLE admin; 

CREATE ROLE can_edit_user; 

CREATE ROLE view_only_user; 

CREATE ROLE blocked_user; 

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin; 

GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO admin; 

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE album, label, album_release, music_genre, music_group, group_members, listened_album_by_user, music_instrument, listener TO can_edit_user; 

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO can_edit_user; 

GRANT SELECT ON TABLE album, label, album_release, music_genre, music_group, group_members, listened_album_by_user, music_instrument, listener TO view_only_user; 

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO view_only_user; 

ALTER USER admin SET ROLE admin; 

ALTER USER can_edit_user SET ROLE can_edit_user; 

ALTER USER view_only_user SET ROLE view_only_user; 

ALTER USER blocked_user SET ROLE blocked_user; 