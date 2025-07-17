Set search_path to project;
CREATE TABLE State_ (
state_no CHAR(2) PRIMARY KEY,
state_name TEXT NOT NULL UNIQUE
);
CREATE TABLE District (
district_no CHAR(2) NOT NULL,
state_no CHAR(2) NOT NULL,
district_name TEXT NOT NULL,
PRIMARY KEY (district_no, state_no),
FOREIGN KEY (state_no)
REFERENCES State_(state_no)
ON UPDATE CASCADE ON DELETE CASCADE
);
CREATE TABLE Village (
village_no CHAR(2) NOT NULL,
district_no CHAR(2) NOT NULL,
state_no CHAR(2) NOT NULL,
village_name TEXT NOT NULL,
PRIMARY KEY (village_no, district_no, state_no),
FOREIGN KEY (district_no, state_no)
REFERENCES District(district_no, state_no)
ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Crop (
crop_name TEXT PRIMARY KEY
);
CREATE TABLE SOIL (
soil_name TEXT PRIMARY KEY,
nature TEXT NOT NULL
);
CREATE TABLE TARGET (
quantity INT NOT NULL,
crop_id TEXT NOT NULL REFERENCES Crop(crop_name)
ON UPDATE CASCADE ON DELETE CASCADE,
village_no CHAR(2) NOT NULL,
district_no CHAR(2) NOT NULL,
state_no CHAR(2) NOT NULL,
FOREIGN KEY (village_no, district_no, state_no)
REFERENCES Village(village_no, district_no, state_no)
ON UPDATE CASCADE ON DELETE CASCADE,
PRIMARY KEY (crop_id, village_no, district_no, state_no)
);
CREATE TABLE Grows_on (
soil_id TEXT NOT NULL REFERENCES Soil(soil_name)
ON UPDATE CASCADE ON DELETE CASCADE,
crop_id TEXT NOT NULL REFERENCES Crop(crop_name)
ON UPDATE CASCADE ON DELETE CASCADE,
PRIMARY KEY (soil_id, crop_id)
);

CREATE TABLE Landlord (
landlord_name TEXT NOT NULL,
village_no CHAR(2) NOT NULL,
district_no CHAR(2) NOT NULL,
state_no CHAR(2) NOT NULL,
landlord_contact_no DECIMAL(10,0) PRIMARY KEY,
sell_status INTEGER,
occupation TEXT NOT NULL,
FOREIGN KEY (village_no, district_no, state_no)
REFERENCES Village(village_no, district_no, state_no)
ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Tenant (
tenant_name TEXT NOT NULL,
tenant_contact_no DECIMAL(10,0) PRIMARY KEY,
village_no CHAR(2) NOT NULL,
district_no CHAR(2) NOT NULL,
state_no CHAR(2) NOT NULL,
FOREIGN KEY (village_no, district_no, state_no)
REFERENCES Village(village_no, district_no, state_no)
ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Land (
land_no CHAR(2) NOT NULL,
village_no CHAR(2) NOT NULL,
district_no CHAR(2) NOT NULL,
state_no CHAR(2) NOT NULL,
landlord DECIMAL(10,0) NOT NULL REFERENCES Landlord(landlord_contact_no)
ON UPDATE CASCADE ON DELETE CASCADE,
temporary_landlord DECIMAL(10,0) REFERENCES Tenant(tenant_contact_no)
ON UPDATE CASCADE ON DELETE SET NULL,
need_staff INTEGER NOT NULL,
soil_type TEXT NOT NULL,
area DECIMAL(6,2) NOT NULL,
date_of_lease DATE,
time_of_lease INTEGER,
PRIMARY KEY (land_no, village_no, district_no, state_no),
FOREIGN KEY (village_no, district_no, state_no)
REFERENCES Village(village_no, district_no, state_no)
ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Buyer (
buyer_name TEXT NOT NULL,
required_soil_type TEXT NOT NULL REFERENCES Soil(soil_name)
ON UPDATE CASCADE ON DELETE CASCADE,
required_land_area INT NOT NULL,
village_no CHAR(2) NOT NULL,
district_no CHAR(2) NOT NULL,
state_no CHAR(2) NOT NULL,
occupation TEXT NOT NULL,
buyer_contact_no DECIMAL(10,0) PRIMARY KEY,
buy_status INTEGER NOT NULL CHECK(buy_status=1 or buy_status=0),
FOREIGN KEY (land_no, village_no, district_no, state_no)
REFERENCES Land(land_no, village_no, district_no, state_no)
ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Buyer_crops (
buyer_contact_no DECIMAL(10,0) NOT NULL REFERENCES Buyer(buyer_contact_no)
ON UPDATE CASCADE ON DELETE CASCADE,
crops_offered TEXT NOT NULL REFERENCES Crop(crop_name)
ON UPDATE CASCADE ON DELETE CASCADE,
PRIMARY KEY (buyer_contact_no, crops_offered)
);


CREATE TABLE LABOUR (
labour_name TEXT NOT NULL,
work_in_village CHAR(2) NOT NULL,
work_in_district CHAR(2) NOT NULL,
work_in_state CHAR(2) NOT NULL,
working_hours text NOT NULL,
contact_no DECIMAL(10,0) PRIMARY KEY,
FOREIGN KEY (work_in_village, work_in_district, work_in_state)
REFERENCES Village(village_no, district_no, state_no)
ON UPDATE CASCADE ON DELETE CASCADE
);
Create table Labour_Specification(
Labour_id decimal(10,0) references Labour(contact_no),
Specification TEXT,
Primary KEY (Labour_id,specification)
);

CREATE TABLE Crop_season (
Season TEXT,
crop_name TEXT references Crop(crop_name),
Primary Key(crop_name, season)
);
CREATE TABLE Pesticide (
pesticide_name TEXT PRIMARY KEY,
information TEXT NOT NULL
);
CREATE TABLE Fertilizer (
fertilizer_name TEXT PRIMARY KEY,
information TEXT NOT NULL
);
CREATE TABLE Produces (
crop_id TEXT NOT NULL REFERENCES Crop(crop_name)
ON UPDATE CASCADE ON DELETE CASCADE,
land_no CHAR(2) NOT NULL,
village_no CHAR(2) NOT NULL,
district_no CHAR(2) NOT NULL,
state_no CHAR(2) NOT NULL,
quantity INTEGER NOT NULL,
PRIMARY KEY (crop_id, land_no, village_no, district_no, state_no),
FOREIGN KEY (land_no, village_no, district_no, state_no)
REFERENCES Land(land_no, village_no, district_no, state_no)
ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Requires (
crop_id TEXT NOT NULL,
fertilizer_id TEXT NOT NULL REFERENCES Fertilizer(fertilizer_name)
ON UPDATE CASCADE ON DELETE CASCADE,
soil_id TEXT NOT NULL REFERENCES Soil(soil_name)
ON UPDATE CASCADE ON DELETE CASCADE,
PRIMARY KEY (crop_id, fertilizer_id, soil_id)
);

CREATE TABLE Landlord_hires_labour (
head_farmer DECIMAL(10,0) NOT NULL REFERENCES Landlord(landlord_contact_no)
ON UPDATE CASCADE ON DELETE CASCADE,
labour DECIMAL(10,0) NOT NULL REFERENCES Labour(contact_no)
ON UPDATE CASCADE ON DELETE CASCADE,
work_hour_per_week DECIMAL(2,0) NOT NULL,
PRIMARY KEY (head_farmer, labour)
);

CREATE TABLE Tenant_hires_labour (
head_farmer DECIMAL(10,0) NOT NULL REFERENCES Tenant(tenant_contact_no)
ON UPDATE CASCADE ON DELETE CASCADE,
labour DECIMAL(10,0) NOT NULL REFERENCES Labour(contact_no)
ON UPDATE CASCADE ON DELETE CASCADE,
work_hour_per_week DECIMAL(2,0) NOT NULL,
PRIMARY KEY (head_farmer, labour)
);

CREATE TABLE Treats (
crop_id TEXT NOT NULL REFERENCES Crop(crop_name)
ON UPDATE CASCADE ON DELETE CASCADE,
pesticide_id TEXT NOT NULL REFERENCES Pesticide(pesticide_name)
ON UPDATE CASCADE ON DELETE CASCADE,
symptoms TEXT NOT NULL,
PRIMARY KEY (crop_id, pesticide_id)
);
CREATE TABLE Can_grow (
crop_id TEXT NOT NULL REFERENCES Crop(crop_name)
ON UPDATE CASCADE ON DELETE CASCADE,
labour_id DECIMAL(10,0) NOT NULL REFERENCES Labour(contact_no)
ON UPDATE CASCADE ON DELETE CASCADE,
PRIMARY KEY (crop_id, labour_id)
);

CREATE TABLE WANTS (
land_no char(2) NOT NULL,
village_no char(2) NOT NULL,
district_no char(2) NOT NULL,
state_no char(2) NOT NULL,
buyer_contact_no DECIMAL(10,0) NOT NULL REFERENCES buyer(buyer_contact_no) on delete cascade on update cascade,
PRIMARY KEY (land_no,village_no, district_no, state_no, buyer_contact_no),
FOREIGN KEY (land_no, village_no, district_no, state_no)
REFERENCES Land(land_no, village_no, district_no, state_no)
ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE village_production (
    crop_id TEXT NOT NULL REFERENCES Crop(crop_name) ON UPDATE CASCADE ON DELETE CASCADE,
    village_no CHAR(2) NOT NULL,
    district_no CHAR(2) NOT NULL,
    state_no CHAR(2) NOT NULL,
    quantity INTEGER NOT NULL,
    PRIMARY KEY (crop_id, village_no, district_no, state_no),
    FOREIGN KEY (village_no, district_no, state_no) REFERENCES Village(village_no, district_no, state_no)
    ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE district_production (
    crop_id TEXT NOT NULL REFERENCES Crop(crop_name) ON UPDATE CASCADE ON DELETE CASCADE,
    district_no CHAR(2) NOT NULL,
    state_no CHAR(2) NOT NULL,
    quantity INTEGER NOT NULL,
    PRIMARY KEY (crop_id, district_no, state_no),
    FOREIGN KEY (district_no, state_no) REFERENCES District(district_no, state_no)
    ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE state_production (
    crop_id TEXT NOT NULL REFERENCES Crop(crop_name) ON UPDATE CASCADE ON DELETE CASCADE,
    state_no CHAR(2) NOT NULL,
    quantity INTEGER NOT NULL,
    PRIMARY KEY (crop_id, state_no),
    FOREIGN KEY (state_no) REFERENCES State_(state_no)
    ON UPDATE CASCADE ON DELETE CASCADE
);



create table Buyer_village_requirement(
	buyer_contact_no DECIMAL(10,0) REFERENCES Buyer(buyer_contact_no)
	ON UPDATE CASCADE ON DELETE CASCADE,
	required_village_no char(2),
	required_district_no char(2),
	required_state_no char(2),
	Foreign key (required_village_no, required_district_no, required_state_no) 
	references Village(village_no, district_no, state_no),
	primary key(required_village_no, required_district_no, required_state_no,buyer_contact_no)
);

 
CREATE OR REPLACE FUNCTION update_village_production()
RETURNS TRIGGER AS $$
DECLARE
    village_total INT;
BEGIN
    -- Calculate the total production for the specific crop in the village
    SELECT SUM(p.quantity) INTO village_total
    FROM Produces p
    WHERE p.village_no = NEW.village_no
      AND p.district_no = NEW.district_no
      AND p.state_no = NEW.state_no
	  AND p.crop_id= NEW.crop_id;

    -- Insert or update the village production for each crop based on the total
    INSERT INTO village_production (crop_id, village_no, district_no, state_no, quantity)
    VALUES (NEW.crop_id, NEW.village_no, NEW.district_no, NEW.state_no, village_total)
    ON CONFLICT (crop_id, village_no, district_no, state_no) -- Assuming these columns form the unique constraint
    DO UPDATE SET quantity = village_total;  -- Update quantity if the record already exists

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_update_village_production
AFTER INSERT OR UPDATE ON produces  -- Replace 'Land' with your table
FOR EACH ROW
EXECUTE FUNCTION update_village_production();



CREATE OR REPLACE FUNCTION update_district_production_function()
            RETURNS TRIGGER AS $$
DECLARE
    district_total INT;
BEGIN
    -- Calculate the total production for the specific crop in the district
    SELECT SUM(quantity) INTO district_total
    FROM village_production
    WHERE district_no = NEW.district_no
      AND state_no = NEW.state_no
      AND crop_id = NEW.crop_id;

    -- Insert or update the district production for the crop and year
    INSERT INTO district_production (crop_id, district_no, state_no, quantity, year_)
    VALUES (NEW.crop_id, NEW.district_no, NEW.state_no, district_total)
    ON CONFLICT (crop_id, district_no, state_no)  -- Adjust based on your unique constraints
    DO UPDATE SET quantity = district_total;  -- Update quantity if the record already exists

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION update_state_production_function()
RETURNS TRIGGER AS $$
DECLARE
    state_total INT;
BEGIN
    -- Calculate new total production for the crop in the state
    SELECT SUM(quantity) INTO state_total
    FROM district_production
    WHERE state_no = NEW.state_no
      AND crop_id = NEW.crop_id; -- Use the year from the updated row

    -- Update or insert state production for that crop
    INSERT INTO state_production (crop_id, state_no, quantity)
    VALUES (NEW.crop_id, NEW.state_no, state_total)
    ON CONFLICT (crop_id, state_no)  -- Assuming these columns form the unique constraint
    DO UPDATE SET quantity = state_total;  -- Update quantity if the record already exists

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER update_state_production
AFTER INSERT OR UPDATE ON district_production
FOR EACH ROW
EXECUTE FUNCTION update_state_production_function();

CREATE TRIGGER update_district_production
AFTER INSERT OR UPDATE ON village_production
FOR EACH ROW
EXECUTE FUNCTION update_district_production_function();

--check before delete on village production
CREATE FUNCTION prevent_delete_from_village_production()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if there is any row in Produces with the same crop_id, village_no, district_no, and state_no
    IF EXISTS (
        SELECT 1 
        FROM Produces 
        WHERE crop_id = OLD.crop_id
          AND village_no = OLD.village_no
          AND district_no = OLD.district_no
          AND state_no = OLD.state_no
    ) THEN
        RAISE EXCEPTION 'Cannot delete row from village_production as it is referenced in Produces';
    END IF;
    
    RETURN OLD; -- Proceed with deletion if no match is found
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_produces_before_delete_on_village
BEFORE DELETE ON village_production
FOR EACH ROW
EXECUTE FUNCTION prevent_delete_from_village_production();

--check before delete on district production
CREATE FUNCTION prevent_delete_from_district_production()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if there is any row in Produces with the same crop_id, district_no, and state_no
    IF EXISTS (
        SELECT 1 
        FROM Produces 
        WHERE crop_id = OLD.crop_id
          AND district_no = OLD.district_no
          AND state_no = OLD.state_no
    ) THEN
        RAISE EXCEPTION 'Cannot delete row from district_production as it is referenced in Produces';
    END IF;
    
    RETURN OLD; -- Proceed with deletion if no match is found
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_produces_before_delete_on_district
BEFORE DELETE ON district_production
FOR EACH ROW
EXECUTE FUNCTION prevent_delete_from_district_production();

--check before delete for state production
CREATE FUNCTION prevent_delete_from_state_production()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if there is any row in Produces with the same crop_id and state_no
    IF EXISTS (
        SELECT 1 
        FROM Produces 
        WHERE crop_id = OLD.crop_id
          AND state_no = OLD.state_no
    ) THEN
        RAISE EXCEPTION 'Cannot delete row from state_production as it is referenced in Produces';
    END IF;
    
    RETURN OLD; -- Proceed with deletion if no match is found
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_produces_before_delete_on_state
BEFORE DELETE ON state_production
FOR EACH ROW
EXECUTE FUNCTION prevent_delete_from_state_production();


--update after delete in produces
CREATE FUNCTION update_on_delete_village_production_quantity()
RETURNS TRIGGER AS $$
BEGIN
    -- Update the quantity in village_production by summing the remaining quantities in Produces
    UPDATE village_production
    SET quantity = COALESCE(
        (SELECT SUM(quantity) 
         FROM Produces 
         WHERE village_no = OLD.village_no
           AND district_no = OLD.district_no
           AND state_no = OLD.state_no), 
        0) -- Set quantity to 0 if no matching rows remain in Produces
    WHERE village_no = OLD.village_no
      AND district_no = OLD.district_no
      AND state_no = OLD.state_no;

    -- Delete the row from village_production if the updated quantity is zero
    DELETE FROM village_production
    WHERE village_no = OLD.village_no
      AND district_no = OLD.district_no
      AND state_no = OLD.state_no
      AND quantity = 0;

    RETURN NULL; -- No need to return a row for AFTER DELETE trigger
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_quantity_after_delete
AFTER DELETE ON Produces
FOR EACH ROW
EXECUTE FUNCTION update_on_delete_village_production_quantity();

--to delete any row that has quantity equal to zero
CREATE FUNCTION delete_district_production_if_zero()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if the quantity is zero
    IF NEW.quantity = 0 THEN
        -- Delete the row from district_production if quantity is zero
        DELETE FROM district_production
        WHERE crop_id = NEW.crop_id
          AND district_no = NEW.district_no
          AND state_no = NEW.state_no;

        -- Prevent the INSERT or UPDATE by returning NULL
        RETURN NULL;
    END IF;

    -- Allow the operation to proceed if quantity is not zero
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER delete_if_quantity_zero_on_district
BEFORE INSERT OR UPDATE ON district_production
FOR EACH ROW
EXECUTE FUNCTION delete_district_production_if_zero();


--to delete any row that has quantity equal to zero
CREATE FUNCTION delete_state_production_if_zero()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if the quantity is zero
    IF NEW.quantity = 0 THEN
        -- Delete the row from state_production if quantity is zero
        DELETE FROM state_production
        WHERE crop_id = NEW.crop_id
          AND state_no = NEW.state_no;

        -- Prevent the INSERT or UPDATE by returning NULL
        RETURN NULL;
    END IF;

    -- Allow the operation to proceed if quantity is not zero
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER delete_if_quantity_zero_on_state
BEFORE INSERT OR UPDATE ON state_production
FOR EACH ROW
EXECUTE FUNCTION delete_state_production_if_zero();


--to automatically insert buyer with land that satisfy his requirement in wants table
CREATE OR REPLACE FUNCTION insert_into_wants_for_new_buyer()
RETURNS TRIGGER AS $$
BEGIN
    -- Insert the buyer-specific data into WANTS
    INSERT INTO WANTS (land_no, village_no, district_no, state_no, buyer_contact_no)
    SELECT DISTINCT L.land_no, L.village_no, L.district_no, L.state_no, NEW.buyer_contact_no
    FROM Land L
    JOIN Buyer_village_requirement BVR 
        ON L.village_no = BVR.required_village_no 
        AND L.district_no = BVR.required_district_no
        AND L.state_no = BVR.required_state_no
    WHERE BVR.buyer_contact_no = NEW.buyer_contact_no

    UNION

    SELECT DISTINCT L.land_no, L.village_no, L.district_no, L.state_no, NEW.buyer_contact_no
    FROM Land L
    JOIN Buyer B 
        ON L.soil_type = B.required_soil_type
    WHERE B.buyer_contact_no = NEW.buyer_contact_no

    UNION

    SELECT DISTINCT L.land_no, L.village_no, L.district_no, L.state_no, NEW.buyer_contact_no
    FROM Land L
    JOIN Buyer B 
        ON L.area BETWEEN B.required_land_area - 10 AND B.required_land_area + 10
    WHERE B.buyer_contact_no = NEW.buyer_contact_no

    UNION

    SELECT DISTINCT L.land_no, L.village_no, L.district_no, L.state_no, BC.buyer_contact_no
    FROM Land L
    JOIN Grows_on GO 
        ON L.soil_type = GO.soil_id
    JOIN Buyer_crops BC 
        ON GO.crop_id = BC.crops_offered
    WHERE BC.buyer_contact_no = NEW.buyer_contact_no;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER buyer_insert_trigger
AFTER INSERT ON Buyer
FOR EACH ROW
EXECUTE FUNCTION insert_into_wants_for_new_buyer();




