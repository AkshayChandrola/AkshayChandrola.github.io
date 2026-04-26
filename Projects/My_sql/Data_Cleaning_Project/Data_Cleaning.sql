-- Data Cleaning 

SELECT *
FROM layoffs;

-- steps to be taken to clean this dataset
-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null values or blank values
-- 4. Remove any unneccessary Columns

# Crate new table with similar columns as original table to record cleaned data, 
# this helps to keep original raw data incase of any mistakes happens

CREATE TABLE layoffs_staging
LIKE layoffs;

-- Step 1. Remove Duplicates

SELECT *
FROM layoffs_staging;

# insert all the data into new table form original table

INSERT layoffs_staging
SELECT *
FROM layoffs;

# insert row number to identify duplicates, if row number is 2 or more then we have duplicates for those row

SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage,country, funds_raised_millions) AS row_num
	FROM layoffs_staging;
    
# to seprate out duplicates

WITH duplicate_cte AS
(
	SELECT *,
		ROW_NUMBER() OVER(
			PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage,country, funds_raised_millions) AS row_num
		FROM layoffs_staging
)
SELECT *
	FROM duplicate_cte
    WHERE row_num > 1;
    
# let's check if those are really duplicates for rendom company

SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

# Delete duplicate row, one solution is to creatre new table with row_num where it should give how many numbers of row has same data then getting those row numbers and delete duplicate row

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT	
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
	
SELECT *
FROM layoffs_staging2;

# insert data into staging2 table

INSERT INTO layoffs_staging2
SELECT *,
		ROW_NUMBER() OVER(
			PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage,country, funds_raised_millions) AS row_num
		FROM layoffs_staging;

# check for duplicate row

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

# delete duplicate row 

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

# check agin if duplicates are removed
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- Step 2. Standardizing data

# remove extra whitespace

SELECT company, TRIM(company)
FROM layoffs_staging2;

# update company column

UPDATE layoffs_staging2
SET company = TRIM(company);

# now check for the different types of industries

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

# now update name of the similar industry such as crypto, cryptocurrency to Crypto

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

# Check for other coloumns and correct the mistakes if any found

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT *
FROM layoffs_staging2;

# let's formate date

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

# change data type of date column

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

# check the table after changes until now
SELECT *
FROM layoffs_staging2;

-- Step.3 :check and update table for null value
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_staging2;

-- Step 4. Deleting unneccessary data, rows and column

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2;