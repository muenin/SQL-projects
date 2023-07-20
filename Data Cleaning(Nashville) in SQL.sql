--CLEANING DATA IN SQL QUERIES

SELECT*
FROM ProjectB..Nashville

--STANDARDIZE DATE FORMAT

SELECT SaleDate,CONVERT(Date,SaleDate)
FROM ProjectB..Nashville

UPDATE ProjectB..Nashville
SET SaleDate=CONVERT(Date,SaleDate)

--IF IT DOESN'T UPDATE PROPERLY

ALTER TABLE ProjectB..Nashville
Add SaleDateConverted Date;

UPDATE ProjectB..Nashville
SET SaleDateConverted=CONVERT(Date,SaleDate)



--POPULATE PROPERTY ADDRESS DATA

SELECT *
FROM ProjectB..Nashville
ORDER BY ParcelID

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM ProjectB..Nashville a
JOIN ProjectB..Nashville b
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is NULL

UPDATE a 
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM ProjectB..Nashville a
JOIN ProjectB..Nashville b
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is NULL



--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS(ADDRESS,CITY.,STATE)

SELECT PropertyAddress
FROM ProjectB..Nashville

SELECT 
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress )-1)as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress )+1 ,LEN(PropertyAddress)) as Address

FROM ProjectB..Nashville

ALTER TABLE ProjectB..Nashville
ADD PropertySplitAddress nvarchar(255);

UPDATE ProjectB..Nashville
SET PropertySplitAddress=SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress )-1)

ALTER TABLE ProjectB..Nashville
ADD PropertySplitCity nvarchar(255);

UPDATE ProjectB..Nashville
SET PropertySplitCity=SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress )+1 ,LEN(PropertyAddress))



SELECT*
FROM ProjectB..Nashville



SELECT OwnerAddress
FROM ProjectB..Nashville



SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3) 
,PARSENAME(REPLACE(OwnerAddress,',','.'),2) 
,PARSENAME(REPLACE(OwnerAddress,',','.'),1) 
FROM ProjectB..Nashville

ALTER TABLE ProjectB..Nashville
ADD OwnerSplitAddress nvarchar(255);

UPDATE ProjectB..Nashville
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE ProjectB..Nashville
ADD OwnerSplitCity nvarchar(255);

UPDATE ProjectB..Nashville
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE ProjectB..Nashville
ADD OwnerSplitState nvarchar(255);

UPDATE ProjectB..Nashville
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)


SELECT*
FROM ProjectB..Nashville


--Change Y and N in "Sold as Vacant" field


SELECT Distinct(SoldAsVacant),Count(SoldAsVacant)
FROM ProjectB..Nashville
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant='Y' THEN 'Yes'
WHEN SoldAsVacant='N' THEN 'No'
ELSE SoldAsVacant
END
FROM ProjectB..Nashville

UPDATE ProjectB..Nashville
SET SoldAsVacant= CASE WHEN SoldAsVacant='Y' THEN 'Yes'
WHEN SoldAsVacant='N' THEN 'No'
ELSE SoldAsVacant
END


--REMOVE DUPLICATES

WITH RowNumCTE as(
SELECT*,
 ROW_NUMBER()OVER(
 PARTITION BY ParcelID,
              PropertyAddress,
			  SalePrice,
			  SaleDate,
			  LegalReference
			  ORDER BY 
			    UniqueID
				) row_num

FROM ProjectB..Nashville
)
DELETE
FROM RowNumCTE
WHERE row_num >1
--ORDER BY PropertyAddress



--DELETE UNUSED COLUMNS

SELECT*
FROM ProjectB..Nashville

ALTER TABLE ProjectB..Nashville
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress,SaleDate

