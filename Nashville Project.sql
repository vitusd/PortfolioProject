-- Data Cleaning

SELECT *
FROM [Portfolio Project].dbo.nashville_housing



------------------------------------------------------------------------------------------------------------------------

-- Date Formatting

-- Sale Date


SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM [Portfolio Project].dbo.nashville_housing

UPDATE nashville_housing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE nashville_housing
ADD SaleDateConverted DATE;

UPDATE nashville_housing
SET SaleDateConverted = CONVERT(Date, SaleDate)

-------------------------------------------------------------------------------------------------------------------------------------------
-- Correcting NULLs
-- Property Address

SELECT *
FROM [Portfolio Project].dbo.nashville_housing
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project].dbo.nashville_housing AS a
JOIN [Portfolio Project].dbo.nashville_housing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project].dbo.nashville_housing AS a
JOIN [Portfolio Project].dbo.nashville_housing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

------------------------------------------------------------------------------------------------------------------------------

-- Separating Address into Columns by Address, City, State

SELECT PropertyAddress
FROM [Portfolio Project].dbo.nashville_housing


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address
FROM [Portfolio Project].dbo.nashville_housing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM [Portfolio Project].dbo.nashville_housing

ALTER TABLE [Portfolio Project].dbo.nashville_housing
ADD PropertySplitAddress Nvarchar(255);

UPDATE [Portfolio Project].dbo.nashville_housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE [Portfolio Project].dbo.nashville_housing
ADD PropertySplitCity Nvarchar(255);

UPDATE [Portfolio Project].dbo.nashville_housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM [Portfolio Project].dbo.nashville_housing 




SELECT OwnerAddress
FROM [Portfolio Project].dbo.nashville_housing 

SELECT
PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,3)
, PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,2)
, PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,1)
FROM [Portfolio Project].dbo.nashville_housing 


ALTER TABLE [Portfolio Project].dbo.nashville_housing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE [Portfolio Project].dbo.nashville_housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,3)

ALTER TABLE [Portfolio Project].dbo.nashville_housing
ADD OwnerSplitCity Nvarchar(255);

UPDATE [Portfolio Project].dbo.nashville_housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,2)

ALTER TABLE [Portfolio Project].dbo.nashville_housing
ADD OwnerSplitState Nvarchar(255);

UPDATE [Portfolio Project].dbo.nashville_housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,1)

----------------------------------------------------------------------------------------------

-- Changing 'Y' and 'N' to 'yes' and 'no' in "SoldAsVacant" column

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Portfolio Project].dbo.nashville_housing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM [Portfolio Project].dbo.nashville_housing

UPDATE [Portfolio Project].dbo.nashville_housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

--------------------------------------------------------------------------------------------------------------

-- Removing Duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID) AS row_num
FROM [Portfolio Project].dbo.nashville_housing
--ORDER BY ParcelID)
--WHERE row_num >1
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
-- ORDER BY PropertyAddress

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID) AS row_num
FROM [Portfolio Project].dbo.nashville_housing
--ORDER BY ParcelID)
--WHERE row_num >1
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

------------------------------------------------------------------------------------------------------------------------

-- Deleting Unused Columns

SELECT *
FROM [Portfolio Project].dbo.nashville_housing

ALTER TABLE [Portfolio Project].dbo.nashville_housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [Portfolio Project].dbo.nashville_housing
DROP COLUMN SaleDate