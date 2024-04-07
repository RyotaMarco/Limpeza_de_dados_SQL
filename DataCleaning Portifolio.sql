
--Fazendo a limpeza dos dados com SQL 


SELECT *
FROM ProjetoDePortifolio.dbo.NashvilleHousing

-------------------------------------------------------------

--A formatação inicial da coluna data(Date):

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM ProjetoDePortifolio.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

-------------------------------------------------------------

-- Organizando a coluna Endereços(Address):

SELECT PropertyAddress
FROM ProjetoDePortifolio.dbo.NashvilleHousing
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM ProjetoDePortifolio.dbo.NashvilleHousing a
JOIN ProjetoDePortifolio.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null 

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM ProjetoDePortifolio.dbo.NashvilleHousing a
JOIN ProjetoDePortifolio.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null 

-------------------------------------------------------------

--Fragmentando a coluna Endereços (Address) em colunas individuais mais específicas (Endereço, Cidade e estado)

SELECT PropertyAddress
FROM ProjetoDePortifolio.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) AS Address

FROM ProjetoDePortifolio.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
ADD PropertySplitCity  Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))


SELECT OwnerAddress
FROM ProjetoDePortifolio.dbo.NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3), 
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2), 
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
FROM ProjetoDePortifolio.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity  Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState  Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

-------------------------------------------------------------

-- Alternando os Y e N Para Yes e No na coluna 'Sold as Vacant'(Vendido e vago) 

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM ProjetoDePortifolio.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM ProjetoDePortifolio.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM ProjetoDePortifolio.dbo.NashvilleHousing

-------------------------------------------------------------

--Removendo os dados duplicados


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM ProjetoDePortifolio.dbo.NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1

-------------------------------------------------------------

--Removendo Colunas irrelevantes ou que não serão utilizadas


SELECT *
FROM ProjetoDePortifolio.dbo.NashvilleHousing

ALTER TABLE ProjetoDePortifolio.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE ProjetoDePortifolio.dbo.NashvilleHousing
DROP COLUMN SaleDate
