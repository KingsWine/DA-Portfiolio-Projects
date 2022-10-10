/*

Cleaning data with SQL Queries

*/


select *
from NewPortfolioProject.dbo.HousingData$

--------------------------------------------------------------------------------------------------------------------------------------------

--Standardize Date formart
select SaleDate
from NewPortfolioProject.dbo.HousingData$

alter table HousingData$
add SaleDateConverted Date;

update HousingData$
set SaleDateConverted = convert(Date, SaleDate)

select SaleDateConverted
from NewPortfolioProject..HousingData$


------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

select *
from NewPortfolioProject.dbo.HousingData$
--where PropertyAddress is null
order by ParcelID


select *
from NewPortfolioProject..HousingData$ a
join NewPortfolioProject..HousingData$ b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]

/* We noticed that a particular ParcelID corresponds to a particular PropertyAddress. So we can populate the PropertyAddress based on corresponding ParcelID.
*/

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NewPortfolioProject..HousingData$ a
join NewPortfolioProject..HousingData$ b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NewPortfolioProject..HousingData$ a
join NewPortfolioProject..HousingData$ b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



---------------------------------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City State)


-- For Property Address
select PropertyAddress
from NewPortfolioProject..HousingData$



select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress)) as City

from NewPortfolioProject..HousingData$



alter table HousingData$
add PropertySplitAddress nvarchar(255);

update HousingData$
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


alter table HousingData$
add PropertySplitCity nvarchar(255);

update HousingData$
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress))




-- For Owners Address

select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from NewPortfolioProject..HousingData$


alter table HousingData$
add OwnerSplitAddress nvarchar(255);

update HousingData$
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

alter table HousingData$
add OwnerSplitCity nvarchar(255);

update HousingData$
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

alter table HousingData$
add OwnerSplitState nvarchar(255);

update HousingData$
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


select *
from NewPortfolioProject..HousingData$



--------------------------------------------------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in 'Sold as Vacant' field

select distinct(SoldAsVacant), count(SoldAsVacant)
from NewPortfolioProject..HousingData$
group by SoldAsVacant
order by 2




select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from NewPortfolioProject..HousingData$


update HousingData$
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end



-------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

with RowNumCTE as(
select *,
	ROW_NUMBER() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
					UniqueID 
					)row_num

from NewPortfolioProject..HousingData$
)
delete
from RowNumCTE
where row_num > 1


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


select *
from NewPortfolioProject..HousingData$



alter table NewPortfolioProject..HousingData$
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
