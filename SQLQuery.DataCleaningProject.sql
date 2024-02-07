--Cleaning data

SELECT *
FROM ashvilleHousing

--Standardize date format (This tep ensures that the date format is consistent throughtout the dataset)

SELECT SaleConvertedDate, CONVERT(DATE, SaleDate)
FROM PortflioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing 
SET SaleDate = CONVERT(DATE, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleConvertedDate DATE;

UPDATE NashvilleHousing 
SET SaleConvertedDate = CONVERT(DATE, SaleDate)

--POPULATE THE PROPERTY ADDRESS COLUMN BY ParcelID (to do that we used 'isnull' which populates the nulll)

SELECT PropertyAddress
FROM PortflioProject.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT a.PropertyAddress , a.ParcelID,  b.PropertyAddress, b.ParcelID ,ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortflioProject.dbo.NashvilleHousing a
JOIN PortflioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL  (--once updated, this query should return an output with only headers)

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM PortflioProject.dbo.NashvilleHousing a
JOIN PortflioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ] 
WHERE a.PropertyAddress IS NULL 

--Breaking the address column into separate columns 

SELECT PropertyAddress
FROM PortflioProject.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address  --(the '-1' is to remove the comma at the end of the address) 
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))  AS Address
FROM PortflioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SeparatedAddress NVARCHAR(255);

UPDATE NashvilleHousing 
SET  SeparatedAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

ALTER TABLE NashvilleHousing
ADD SeparatedCity NVARCHAR(255);

UPDATE NashvilleHousing 
SET  SeparatedCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) 

SELECT *
FROM PortflioProject.dbo.NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),  --PARSENAME WORKS BACKWARD COMPARED TO THE SUBSTRING
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortflioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SeparatedOwnerAddress NVARCHAR(255);

UPDATE NashvilleHousing 
SET SeparatedOwnerAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD SeparatedOwnerCity NVARCHAR(255);

UPDATE NashvilleHousing 
SET  SeparatedOwnerCity= PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD SeparatedOwnerState NVARCHAR(255);

UPDATE NashvilleHousing 
SET  SeparatedOwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) --Please run these separately


--Change the Y and N to Yes and No in the 'Sold as Vacant' field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortflioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		WHEN  SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END
FROM PortflioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		WHEN  SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END


--Remove duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) ROW_NUM
FROM PortflioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)

DELETE
FROM RowNumCTE
WHERE ROW_NUM > 1  --RUN THESE 2 QUERIES TOGETHER

--Delete unused data (Always have an oroginal copy of your data)

SELECT *
FROM PortflioProject.dbo.NashvilleHousing

ALTER TABLE PortflioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

