/* Data Cleaning in SQL */

Select *
From PortfolioProject.dbo.NashvilleHousing

--Changing the Date Format
Select SalesDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

Alter Table NashvilleHousing
Add SalesDateConverted Date;

UPDATE NashvilleHousing
SET SalesDateConverted = CONVERT(Date, SaleDate)

-- Populate Property Address Data
Select *
From PortfolioProject.dbo.NashvilleHousing
Order by ParcelID

Select Table1.ParcelID,Table1.PropertyAddress, Table2.ParcelID, Table2.PropertyAddress, ISNULL(Table1.PropertyAddress, Table2.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing as Table1
Join PortfolioProject.dbo.NashvilleHousing as Table2
     on Table1.ParcelID = Table2.ParcelID
	 AND Table1.[UniqueID ] <> Table2.[UniqueID ]
Where Table1.PropertyAddress is NULL

Update Table1
SET PropertyAddress = ISNULL(Table1.PropertyAddress, Table2.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing as Table1
Join PortfolioProject.dbo.NashvilleHousing as Table2
     on Table1.ParcelID = Table2.ParcelID
	 AND Table1.[UniqueID ] <> Table2.[UniqueID ]
Where Table1.PropertyAddress is NULL

--Breaking out address into Individual Columns (Address, City, State)
Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
From PortfolioProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From PortfolioProject..NashvilleHousing

--Now with the OnwerAddress Column

Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From PortfolioProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress  = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)


Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity  = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)


Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState  = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

Select *
From PortfolioProject..NashvilleHousing

--Changing Y and N to Yes and No in "Sold as Vacant" Field

Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE 
                        WHEN SoldAsVacant = 'Y' THEN 'Yes'
                        WHEN SoldAsVacant = 'N' THEN 'No'
	                    ELSE SoldAsVacant
	                    END

-- Removing Duplicates

With RowNumCTE AS (
Select *,
ROW_NUMBER() OVER(PARTITION BY ParcelID, 
		               PropertyAddress,
					   SalePrice,
					   SaleDate,
					   LegalReference
			           Order by UniqueID
			           ) row_num
From PortfolioProject.dbo.NashvilleHousing
)

DELETE
FROM RowNumCTE
Where row_num > 1

-- Deleting Unused Columns

Select *
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate