-- Performing Data Cleaning on Laptop Dataset

-- Create schema for laptop data
CREATE SCHEMA laptopdata

-- Creating backup of the data
CREATE TABLE laptop_backup LIKE laptop
INSERT INTO laptop_backup
SELECT * FROM laptop

-- Check number of rows
SELECT count(*) FROM laptop

-- Check memory consumption for reference 
SELECT DATA_LENGTH/1024 FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'laptopdata' and TABLE_NAME= 'laptop'

-- Drop non important columns
-- Drop unnamed column - no useful
ALTER TABLE laptop DROP COLUMN `unnamed: 0`;

-- Drop null values
DELETE FROM laptop
WHERE Company IS NULL AND TypeName IS NULL AND Inches IS NULL
AND ScreenResolution IS NULL AND Cpu IS NULL AND Ram IS NULL
AND Memory IS NULL AND Gpu IS NULL AND OpSys IS NULL 
AND WEIGHT IS NULL AND Price IS NULL;

-- Inches is in Text datatype converting it into
ALTER TABLE LAPTOP MODIFY COLUMN Inches DECIMAL(10,1)

-- Replace the GB in RAM column and converting it to integer datatype
UPDATE laptop
SET Ram = REPLACE(Ram,'GB', '')

ALTER TABLE LAPTOP MODIFY COLUMN Ram INTEGER

-- Replace the KG in Weight column 
UPDATE laptop
SET weight = REPLACE(weight,'kg', '')

-- Rounding off the Price amount and converting it to integer datatype
UPDATE laptop
SET Price = ROUND(Price)

ALTER TABLE LAPTOP MODIFY COLUMN Price INTEGER

-- Create Categories and updating OpSys column
-- mac
-- windows
-- linux
-- no os
-- Android chrome(others)

SELECT OpSys,
CASE 
	WHEN OpSys LIKE '%mac%' THEN 'macos'
    WHEN OpSys LIKE 'windows%' THEN 'windows'
    WHEN OpSys LIKE '%linux%' THEN 'linux'
    WHEN OpSys = 'No OS' THEN 'N/A'
    ELSE 'other'
END AS 'os_brand'
FROM laptop;

UPDATE laptop
SET OpSys = 
CASE 
	WHEN OpSys LIKE '%mac%' THEN 'macos'
    WHEN OpSys LIKE 'windows%' THEN 'windows'
    WHEN OpSys LIKE '%linux%' THEN 'linux'
    WHEN OpSys = 'No OS' THEN 'N/A'
    ELSE 'other'
END;

-- Creating two new Columns for GPU brand and GPU name from GPU column and then drop the GPU column 
ALTER TABLE laptop ADD COLUMN Gpu_brand VARCHAR(255) AFTER GPU,
ADD COLUMN Gpu_name VARCHAR(255) AFTER Gpu_brand;

UPDATE laptop
SET Gpu_brand = substring_index(Gpu,' ',1)

UPDATE laptop
SET Gpu_name = REPLACE(Gpu, gpu_brand, '');

Alter TABLE laptop DROP COLUMN Gpu;

-- Create 3 new columns names Cpu_brand,Cpu_name,Cpu_speed from CPU column and then drop the GPU column
ALTER TABLE laptop
ADD COLUMN cpu_brand VARCHAR(255) AFTER Cpu,
ADD COLUMN cpu_name VARCHAR(255) AFTER cpu_brand,
ADD COLUMN cpu_speed DECIMAL(10,1) AFTER cpu_name;

UPDATE laptop
SET Cpu_brand = SUBSTRING_INDEX(Cpu, ' ', 1);

UPDATE laptop
SET cpu_speed = CAST(REPLACE(SUBSTRING_INDEX(Cpu, ' ', -1), 'GHz', '') AS DECIMAL(10,2));

UPDATE laptop
SET cpu_name = REPLACE(REPLACE(Cpu, cpu_brand, ''), SUBSTRING_INDEX(REPLACE(Cpu, cpu_brand, ''), ' ', -1), '');

UPDATE laptop
SET cpu_name = SUBSTRING_INDEX(TRIM(cpu_name),' ',2);

Alter TABLE laptop DROP COLUMN Cpu;

-- Creating 3 new column from ScreenResolution column names as touchscreen, resolution_width and resolution_height and then drop the column  ScreenResolution
ALTER TABLE laptop
ADD COLUMN resolution_width INTEGER AFTER ScreenResolution,
ADD COLUMN resolution_height INTEGER AFTER resolution_width,
ADD COLUMN touchscreen INTEGER AFTER resolution_height;

UPDATE laptop
SET resolution_width = SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',1),
resolution_height = SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',-1),
touchscreen = ScreenResolution LIKE '%Touch%';

ALTER TABLE laptop
DROP COLUMN ScreenResolution;

-- Creating 3 new column from Memory column names as memory_type, primary_storage and secondary_storage and then drop the column Memory 
ALTER TABLE laptop
ADD COLUMN memory_type VARCHAR(255) AFTER Memory,
ADD COLUMN primary_storage INTEGER AFTER memory_type,
ADD COLUMN secondary_storage INTEGER AFTER primary_storage;

UPDATE laptop
SET memory_type = CASE
	WHEN Memory LIKE '%SSD%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
    WHEN Memory LIKE '%SSD%' THEN 'SSD'
    WHEN Memory LIKE '%HDD%' THEN 'HDD'
    WHEN Memory LIKE '%Flash Storage%' THEN 'Flash Storage'
    WHEN Memory LIKE '%Hybrid%' THEN 'Hybrid'
    WHEN Memory LIKE '%Flash Storage%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
    ELSE NULL
END;

UPDATE laptop
SET primary_storage = REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',1),'[0-9]+'),
secondary_storage = CASE WHEN Memory LIKE '%+%' THEN REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',-1),'[0-9]+') ELSE 0 END;

UPDATE laptop
SET primary_storage = CASE WHEN primary_storage <= 2 THEN primary_storage*1024 ELSE primary_storage END,
secondary_storage = CASE WHEN secondary_storage <= 2 THEN secondary_storage*1024 ELSE secondary_storage END;

ALTER TABLE laptop DROP COLUMN Memory;

-- Drop column gpu_name as it not that much useful
ALTER TABLE laptop DROP COLUMN gpu_name;

-- Creating an index column
ALTER TABLE laptop
ADD COLUMN `index` INT AUTO_INCREMENT PRIMARY KEY;
