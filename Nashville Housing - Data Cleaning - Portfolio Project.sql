-- Cleaning Data in SQL Queries --



SELECT *
FROM NashvilleHousing



-- Standardise Date Fromat
Select SaleDateConverted, CONVERT(Date, SaleDate)
FROM NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)



-- Populate Property Address Data
Select *
FROM NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing AS A
INNER JOIN NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing AS A
INNER JOIN NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null




-- Seperateing Address Into Individual Fields (Address, City, State)
Select PropertyAddress
FROM NashvilleHousing
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address

FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT *
FROM NashvilleHousing


--Using PARSENAME for Seperateing Address Into Individual Fields

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)




---- CHANGE 1 AND 0 to Yes and No for 'Sold as Vacant' field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From NashvilleHousing
Group BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 1 THEN 'Yes'
	WHEN SoldAsVacant = 0 THEN 'No'
	ELSE CAST(SoldAsVacant AS VARCHAR)
	END
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ALTER COLUMN SoldAsVacant VARCHAR(3);

UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 1 THEN 'Yes'
	WHEN SoldAsVacant = 0 THEN 'No'
	ELSE CAST(SoldAsVacant AS VARCHAR)
	END
FROM NashvilleHousing



---- Remove Duplicates
WITH RowNumCTE AS (
SELECT *
	,ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID
				) row_num
FROM NashvilleHousing
--ORDER BY ParcelID
)

----DELETE *
----FROM RoWNumCTE
----WHERE row_num > 1
----ORDER BY PropertyAddress

SELECT *
FROM RoWNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



---- Delete Unused Columns (if needed)
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate