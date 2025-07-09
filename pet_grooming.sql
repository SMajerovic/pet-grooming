-- Pet Grooming Business Scenario
-- T-SQL script implementing the scenario described in README.md

DROP TABLE IF EXISTS dbo.PetGrooming;

-- Create table to store pet grooming customers and their pets
CREATE TABLE dbo.PetGrooming (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    CustomerName NVARCHAR(100) NOT NULL CONSTRAINT ck_PetGrooming_CustomerName_not_blank CHECK(CustomerName <> ''),
    Address NVARCHAR(255) NOT NULL CONSTRAINT ck_PetGrooming_Address_not_blank CHECK(Address <> ''),
    AnimalType NVARCHAR(20) NOT NULL CONSTRAINT ck_PetGrooming_Animal CHECK(AnimalType IN ('dog','cat','rabbit','guinea pig')),
    PetName NVARCHAR(50) NOT NULL CONSTRAINT ck_PetGrooming_PetName_not_blank CHECK(PetName <> ''),
    PricePerGrooming DECIMAL(6,2) NOT NULL CONSTRAINT ck_PetGrooming_Price_positive CHECK(PricePerGrooming > 0),
    ServiceFrequency NVARCHAR(10) NOT NULL CONSTRAINT ck_PetGrooming_Frequency CHECK(ServiceFrequency IN ('weekly','biweekly')),
    PickupDate DATE NOT NULL CONSTRAINT ck_PetGrooming_PickupDate CHECK(PickupDate >= '2019-01-01'),
    EndDate DATE NULL,
    CONSTRAINT ck_PetGrooming_EndDate CHECK(EndDate IS NULL OR EndDate >= PickupDate)
);

-- Insert sample data from the README
INSERT INTO dbo.PetGrooming (CustomerName, Address, AnimalType, PetName, PricePerGrooming, ServiceFrequency, PickupDate)
VALUES
    ('Bry-Ann Yates', '326 34th St. S', 'rabbit', 'Longears', 30, 'weekly', '2019-08-21'),
    ('Meg Ross', '1719 Beach Dr SE', 'dog', 'Trooper', 55, 'biweekly', '2020-01-19'),
    ('Brayanna Mille', '2255 22 Ave N', 'rabbit', 'Hunny Bunny', 40, 'biweekly', '2019-11-05'),
    ('Brayanna Mille', '2255 22 Ave N', 'rabbit', 'Hazel', 40, 'biweekly', '2019-11-05'),
    ('Marianne Griffin', '312 Sand Pine Ln', 'dog', 'Mr. Stich', 60, 'biweekly', '2021-06-20'),
    ('Mike Smith', '145 Menhaden St', 'guinea pig', 'Pippin', 30, 'biweekly', '2022-04-30'),
    ('Bethany Singer', '1818 Bay St', 'cat', 'Dingus', 40, 'biweekly', '2022-06-07'),
    ('Bobbi Welker', '324 Wilcox St', 'dog', 'Moose', 45, 'weekly', '2021-03-14'),
    ('Bobbi Welker', '324 Wilcox St', 'dog', 'Piper', 60, 'weekly', '2021-03-14'),
    ('Bobbi Welker', '324 Wilcox St', 'dog', 'Kipper', 65, 'weekly', '2021-03-14'),
    ('Mark Doppler', '5329 53rd St', 'guinea pig', 'Ginger', 35, 'biweekly', '2019-10-29'),
    ('Tara Hamid', '210 Sunrise Dr.', 'rabbit', 'Holly', 50, 'biweekly', '2021-12-12'),
    ('Leni Baker', '3210 Gandy Blvd.', 'cat', 'Pussy Willow', 55, 'weekly', '2019-09-24'),
    ('Leni Baker', '3210 Gandy Blvd.', 'cat', 'Kitty Cat', 60, 'weekly', '2019-09-24'),
    ('Heather Rieder', '937 MLK St.', 'rabbit', 'Hopper', 45, 'weekly', '2022-02-02'),
    ('Lee Kleshinski', '4903 49th Ave', 'dog', 'Phillip', 60, 'weekly', '2021-07-08'),
    ('Tracy Price', '9027 Juniper St', 'rabbit', 'Dopey', 55, 'biweekly', '2019-09-30'),
    ('Tracy Price', '9027 Juniper St', 'guinea pig', 'Spicy', 40, 'biweekly', '2019-09-30');

-- ---------------------------------------------------------------------------
-- Reports
-- ---------------------------------------------------------------------------

-- 1) Number of each pet currently active
SELECT
    AnimalType,
    COUNT(*) AS PetCount
FROM dbo.PetGrooming
WHERE EndDate IS NULL
GROUP BY AnimalType;

-- 2) Customers with multiple pets (show how many they have)
SELECT
    CustomerName,
    Address,
    COUNT(*) AS PetCount
FROM dbo.PetGrooming
WHERE EndDate IS NULL
GROUP BY CustomerName, Address
HAVING COUNT(*) > 1;

-- 3) Top customer by estimated monthly spend
--    Weekly customers are assumed to have 4 appointments per month
--    Biweekly customers are assumed to have 2 appointments per month
WITH RevenueByPet AS (
    SELECT
        CustomerName,
        Address,
        CASE ServiceFrequency
            WHEN 'weekly' THEN PricePerGrooming * 4
            ELSE PricePerGrooming * 2
        END AS MonthlyRevenue
    FROM dbo.PetGrooming
    WHERE EndDate IS NULL
)
SELECT TOP 1
    CustomerName,
    Address,
    SUM(MonthlyRevenue) AS TotalMonthlyRevenue
FROM RevenueByPet
GROUP BY CustomerName, Address
ORDER BY TotalMonthlyRevenue DESC;

-- 4) Average price per grooming by animal type
SELECT
    AnimalType,
    AVG(PricePerGrooming) AS AvgPrice
FROM dbo.PetGrooming
WHERE EndDate IS NULL
GROUP BY AnimalType;
GO
