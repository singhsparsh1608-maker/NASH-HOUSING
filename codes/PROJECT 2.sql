# PROJECT 2

SELECT * 
FROM `PROPERTY DATA`.nashville_housing_cleaned;

select Saledate
from nashville_housing_cleaned;

-- creating a new column with datatype as date

alter table nashville_housing_cleaned
add datesale date;

-- turned off safe mode
SET SQL_SAFE_UPDATES = 0;

-- updated the format to date type
update nashville_housing_cleaned
set datesale = str_to_date(saledate,'%Y-%m-%d');

-- showing
select datesale
from nashville_housing_cleaned;

------------------------------------------------------------------------------------------------------------------------------------------

#PROPERTY ADDRESS POPULATE

-- Seeing null values address
select *
from nashville_housing_cleaned
where PropertyAddress is null;

-- to find rows with same parcel id
select *
from nashville_housing_cleaned a
join nashville_housing_cleaned b
 on a.ParcelID= b.ParcelID
 AND
 a.UniqueID  <> b.UniqueID ;
 
 -- putting address with b when a 's property address which means same list having rows with same parcelids but one null and another filled 

 select a.ParcelID,b.ParcelID, a.PropertyAddress,b.PropertyAddress, ifnull(a.PropertyAddress,b.PropertyAddress)
from nashville_housing_cleaned a
join nashville_housing_cleaned b
 on a.ParcelID= b.ParcelID
 AND
 a.UniqueID  <> b.UniqueID 
 where a.PropertyAddress is null;
 
 -- FILLING THE NULL COLUMNS WHERE IN A IS NULL BY THE ENTRY OF B
 UPDATE nashville_housing_cleaned a
join nashville_housing_cleaned b
 on a.ParcelID= b.ParcelID
 AND
 a.UniqueID  <> b.UniqueID 
 set a.PropertyAddress = b.PropertyAddress
 where a.PropertyAddress is null;
  
-------------------------------------------------------------------------------------------------------------------------------------

-- BREAKING OUT ADDRESS INTO ADDRESS ,CITY AND STATE 
 
 SELECT PropertyAddress 
 from nashville_housing_cleaned;
 
 -- taking out city name
select PropertyAddress,
SUBSTRING_INDEX(PropertyAddress, ' ' , -1) as city 
from nashville_housing_cleaned;

-- eliminating city name

-- FIRSTLY CITY
SELECT
  PropertyAddress,
  TRIM(
    SUBSTRING(
      PropertyAddress,1,
      LENGTH(PropertyAddress) 
      - LENGTH(SUBSTRING_INDEX(PropertyAddress, ' ', -1))
    )
  ) AS StreetAddress 
FROM nashville_housing_cleaned;

SELECT
  PropertyAddress,
  TRIM(
    SUBSTRING(
      PropertyAddress,1,
      LENGTH(PropertyAddress) 
      - LENGTH(SUBSTRING_INDEX(PropertyAddress, ' ', -1))
    )
  ) AS StreetAddress ,
  SUBSTRING_INDEX(PropertyAddress, ' ' , -1) as city 
FROM nashville_housing_cleaned;

-- Insert this into the table

-- adding columns 
alter table nashville_housing_cleaned
add column StreetAddress Varchar(255),
add column city Varchar(50),
add column state Varchar(100);
 
 UPDATE nashville_housing_cleaned
SET State = TRIM(
  SUBSTRING(
    PropertyAddress,
    1,
    LENGTH(PropertyAddress)
    - LENGTH(SUBSTRING_INDEX(PropertyAddress, ' ', -1))
  )
);

UPDATE nashville_housing_cleaned
SET City = SUBSTRING_INDEX(
              SUBSTRING_INDEX(PropertyAddress, ' ', -1),
              ' ',
              1
          )
WHERE PropertyAddress IS NOT NULL;

UPDATE nashville_housing_cleaned
SET StreetAddress =
TRIM(
  SUBSTRING(
    PropertyAddress,
    1,
    LENGTH(PropertyAddress)
    - LENGTH(SUBSTRING_INDEX(PropertyAddress, ' ', -2))
  )
)
WHERE PropertyAddress IS NOT NULL;
 
 select *
 from nashville_housing_cleaned;
 
 #STATE NHI NIKALRAAA
 
 ----------------------------------------------------------------------------------------------------------------------------------------------------
 
 -- TURNING Y AND N TO YES AND NO IN SOLD AS VACANT
 
 
 select distinct(soldasvacant) , count(soldasvacant)
 from nashville_housing_cleaned 
 group by SoldAsVacant
 order by 2;
 
 -- cahnging y to yes and n to no
 select soldasvacant,
 case when soldasvacant = 'N' then 'No'
      when soldasvacant = 'Y' then 'Yes'
      else soldasvacant 
      end
 from nashville_housing_cleaned  ;   
 
#sahi h aise but change safe mode off manually for this to work.

#updating in table
UPDATE nashville_housing_cleaned
SET soldasvacant =  case when soldasvacant = 'N' then 'No'
      when soldasvacant = 'Y' then 'Yes'
      else soldasvacant 
      end;     

--------------------------------------------------------------------------------------------------------------------------------------------------

-- REMOVING DUBLICATES






 
 