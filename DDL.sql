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


