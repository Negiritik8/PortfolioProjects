-- Cleaning Data In SQL Queries

select * from dbo.NashvilleHousing

-----------------------------------------------

-- Standardize Date Format

select SaleDate, convert(date,SaleDate) 
from dbo.NashvilleHousing

update NashvilleHousing 
set SaleDate = convert(date,SaleDate)

alter  table NashvilleHousing
add SaleDateConverted Date

update NashvilleHousing 
set SaleDateConverted = convert(date,SaleDate)

-------------------------------------------------

-- Populate Property Address Data

select * 
from dbo.NashvilleHousing 
-- where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, 
b.ParcelID, b.PropertyAddress, 
isnull(a.PropertyAddress,b.PropertyAddress) 
from dbo.NashvilleHousing a
join dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress =
isnull(a.PropertyAddress,b.PropertyAddress) 
from dbo.NashvilleHousing a
join dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



-------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from dbo.NashvilleHousing 
-- where PropertyAddress is null
-- order by ParcelID

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
 , SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
from dbo.NashvilleHousing 


alter  table NashvilleHousing
add PropertySplitAddress Varchar(255)

update NashvilleHousing 
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

alter  table NashvilleHousing
add PropertySplitCities varchar(255)

Update NashvilleHousing
SET PropertySplitCities = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))



select * 
from dbo.NashvilleHousing


select OwnerAddress 
from dbo.NashvilleHousing


select
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from dbo.NashvilleHousing




alter  table NashvilleHousing
add OwnerSplitAddress NVarchar(255)

update NashvilleHousing 
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

alter  table NashvilleHousing
add OwnerSplitCities Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitCities = PARSENAME(replace(OwnerAddress,',','.'),2)

alter  table NashvilleHousing
add OwnerSplitState NVarchar(255)

update NashvilleHousing 
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)


select * from dbo.NashvilleHousing

----------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from dbo.NashvilleHousing
group by SoldAsVacant order by 2


select SoldAsVacant,
case when SoldAsVacant = 'Y' Then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from dbo.NashvilleHousing


update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' Then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end


------------------------------------------------------------------

-- Remove Duplicates

with RowNumCTE as (
select * ,
	ROW_NUMBER() OVER(
	PARTITION by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				order by 
				UniqueID
				) row_num


from dbo.NashvilleHousing
-- order by ParcelID
)

select * from RowNumCTE
where row_num > 1 
-- order by PropertyAddress




select *
from dbo.NashvilleHousing



----------------------------------------------------------------


-- Delete Unused Columns 

select * from dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate