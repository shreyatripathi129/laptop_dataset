-- Performing Exploratory Data Analysis (EDA) on Laptop Dataset

-- head, tail and sample
SELECT * FROM laptop
ORDER BY `index` LIMIT 5;

SELECT * FROM laptop
ORDER BY `index` DESC LIMIT 5;

SELECT * FROM laptop
ORDER BY rand() LIMIT 5;

-- Taking One Numerical Column - Price
-- 1.Finding 8 number summary
SELECT 
    COUNT(Price) OVER() AS 'total_count',
    MIN(Price) OVER() AS 'min_price',
    MAX(Price) OVER() AS 'max_price',
    AVG(Price) OVER() AS 'avg_price',
    STDDEV(Price) OVER() AS 'std_dev',
    PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY Price) OVER() AS 'Q1',
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Price) OVER() AS 'Median',
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Price) OVER() AS 'Q3'
FROM laptop
ORDER BY `index` 
LIMIT 1;

-- 2.missing value
SELECT COUNT(Price)
FROM laptop
WHERE Price IS NULL;

-- 3.outliers
SELECT * FROM (SELECT *,
PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY Price) OVER() AS 'Q1',
PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY Price) OVER() AS 'Q3'
FROM laptops) t
WHERE t.Price < t.Q1 - (1.5*(t.Q3 - t.Q1)) OR
t.Price > t.Q3 + (1.5*(t.Q3 - t.Q1));

-- Vertical/Horizontal Histogram
SELECT t.buckets,REPEAT('*',COUNT(*)/5) FROM (SELECT price, 
CASE 
	WHEN price BETWEEN 0 AND 25000 THEN '0-25K'
    WHEN price BETWEEN 25001 AND 50000 THEN '25K-50K'
    WHEN price BETWEEN 50001 AND 75000 THEN '50K-75K'
    WHEN price BETWEEN 75001 AND 100000 THEN '75K-100K'
	ELSE '>100K'
END AS 'buckets'
FROM laptop) t
GROUP BY t.buckets;

-- Taking one Categorical Column - Company
-- 1.Value count 
SELECT Company,COUNT(Company) FROM laptop
GROUP BY Company;

-- 2. Missing values
SELECT * FROM laptop
where Company is null;

-- Taking Two numerical columns - 
-- side by side 8 number analysis
-- Scatterplot
-- Correlation

-- Taking 2 categorical columns - Company, Touchscreen and cpu_brand,company
-- contigency tablecross tab)- stacked bar chart
SELECT Company,
SUM(CASE WHEN Touchscreen = 1 THEN 1 ELSE 0 END) AS 'Touchscreen_yes',
SUM(CASE WHEN Touchscreen = 0 THEN 1 ELSE 0 END) AS 'Touchscreen_no'
FROM laptop
GROUP BY Company;

SELECT Company,
SUM(CASE WHEN cpu_brand = 'Intel' THEN 1 ELSE 0 END) AS 'intel',
SUM(CASE WHEN cpu_brand = 'AMD' THEN 1 ELSE 0 END) AS 'amd',
SUM(CASE WHEN cpu_brand = 'Samsung' THEN 1 ELSE 0 END) AS 'samsung'
FROM laptop
GROUP BY Company;

-- Taking one numerical and one categorical column - Bivariate analysis
-- compare distribution across treatment
SELECT Company,
MIN(price),
MAX(price),
AVG(price),
STD(price)
FROM laptop
GROUP BY Company;

-- Feature Engineering
-- 1.Create a new Column name PPI
ALTER TABLE laptops ADD COLUMN ppi INTEGER;

UPDATE laptops
SET ppi = ROUND(SQRT(resolution_width*resolution_width + resolution_height*resolution_height)/Inches);

SELECT * FROM laptops
ORDER BY ppi DESC;

-- 2.Create a new column name screen_size
ALTER TABLE laptops ADD COLUMN screen_size VARCHAR(255) AFTER Inches;

UPDATE laptops
SET screen_size = 
CASE 
	WHEN Inches < 14.0 THEN 'small'
    WHEN Inches >= 14.0 AND Inches < 17.0 THEN 'medium'
	ELSE 'large'
END;

SELECT screen_size,AVG(price) FROM laptops
GROUP BY screen_size;

-- One Hot Encoding
SELECT gpu_brand,
CASE WHEN gpu_brand = 'Intel' THEN 1 ELSE 0 END AS 'intel',
CASE WHEN gpu_brand = 'AMD' THEN 1 ELSE 0 END AS 'amd',
CASE WHEN gpu_brand = 'nvidia' THEN 1 ELSE 0 END AS 'nvidia',
CASE WHEN gpu_brand = 'arm' THEN 1 ELSE 0 END AS 'arm'
FROM laptop