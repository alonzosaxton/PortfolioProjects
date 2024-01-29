--Cleaning Data in SQL Queries

select *
From PortfolioProject..NashvilleHousing

-- Standardize date format

Select SaleDate
From PortfolioProject..NashvilleHousing

select SaleDateConverted, convert(date,saledate)
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SaleDate = Convert(date,saledate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = Convert(date,saledate)


--Populate Property Address data

select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City

From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255)

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From PortfolioProject..NashvilleHousing




Select OwnerAddress
From PortfolioProject..NashvilleHousing
where OwnerAddress is not null

Select
ParseName(Replace(OwnerAddress,',','.'), 3),
ParseName(Replace(OwnerAddress,',','.'), 2),
ParseName(Replace(OwnerAddress,',','.'), 1)

From PortfolioProject..NashvilleHousing
where OwnerAddress is not null


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

update NashvilleHousing
set OwnerSplitAddress = ParseName(Replace(OwnerAddress,',','.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

update NashvilleHousing
set OwnerSplitCity = ParseName(Replace(OwnerAddress,',','.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255)

update NashvilleHousing
set OwnerSplitState = ParseName(Replace(OwnerAddress,',','.'), 1)


Select *
From PortfolioProject..NashvilleHousing


--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
		END
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
		END


--Remove Duplicates

Select *,
	ROW_NUMBER () OVER (
		PARTITION BY ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY
						UniqueID
						) row_num
			
From PortfolioProject..NashvilleHousing
ORDER BY ParcelID


Select *
From PortfolioProject..NashvilleHousing

WITH RowNumCTE as (
Select *,
	ROW_NUMBER () OVER (
		PARTITION BY ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY
						UniqueID
						) row_num
			
From PortfolioProject..NashvilleHousing )
--ORDER BY ParcelID
Select *
FROM RowNumCTE
where Row_num > 1
--Order by PropertyAddress

----------------------------------------------------------------

--Delete Unused Columns

Select *
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, TaxDistrict, OwnerAddress

