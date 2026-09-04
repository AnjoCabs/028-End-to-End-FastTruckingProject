CREATE DATABASE fleetFlowLogistics;

USE fleetFlowLogistics;

CREATE TABLE dimCustomer (
    customerKey INT AUTO_INCREMENT PRIMARY KEY,
    customerID VARCHAR(20) NOT NULL,
    customerName VARCHAR(150) NOT NULL,
    customerType VARCHAR(50),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    industry VARCHAR(100),
    creditLimit DECIMAL(12,2),
    customerStatus VARCHAR(30)
);

CREATE TABLE dimDriver (
    driverKey INT AUTO_INCREMENT PRIMARY KEY,
    driverID VARCHAR(20) NOT NULL,
    driverName VARCHAR(150) NOT NULL,
    phone VARCHAR(30),
    hireDate DATE,
    licenseNumber VARCHAR(50),
    licenseExpiration DATE,
    certificationExpiration DATE,
    driverStatus VARCHAR(30)
);

CREATE TABLE dimTruck (
    truckKey INT AUTO_INCREMENT PRIMARY KEY,
    truckID VARCHAR(20) NOT NULL,
    VIN VARCHAR(50),
    truckType VARCHAR(50),
    make VARCHAR(50),
    model VARCHAR(50),
    modelYear INT,
    currentMileage DECIMAL(12,2),
    fuelType VARCHAR(30),
    truckStatus VARCHAR(30)
);

CREATE TABLE dimDate (
    dateKey INT PRIMARY KEY,
    fullDate DATE NOT NULL,
    Year INT,
    Quarter INT,
    monthNumber INT,
    monthName VARCHAR(20),
    weekNumber INT,
    dayOfMonth INT,
    dayName VARCHAR(20),
    dayOfWeekNumber INT,
    IsWeekend BOOLEAN
);

CREATE TABLE dimRoute (
    routeKey INT AUTO_INCREMENT PRIMARY KEY,
    routeID VARCHAR(20) NOT NULL,
    originCity VARCHAR(100),
    originState VARCHAR(100),
    destinationCity VARCHAR(100),
    destinationState VARCHAR(100),
    distanceMiles DECIMAL(12,2),
    routeType VARCHAR(50)
);

CREATE TABLE factShipment (
    shipmentKey BIGINT AUTO_INCREMENT PRIMARY KEY,
    shipmentID VARCHAR(30) NOT NULL,
    dateKey INT NOT NULL,
    customerKey INT NOT NULL,
    driverKey INT NOT NULL,
    truckKey INT NOT NULL,
    routeKey INT NOT NULL,
    pickupDate DATE,
    expectedDeliveryDate DATE,
    actualDeliveryDate DATE,
    shipmentStatus VARCHAR(50),
    distanceMiles DECIMAL(12,2),
    revenue DECIMAL(12,2),
    freightCost DECIMAL(12,2),
    FOREIGN KEY (DateKey)
        REFERENCES dimDate(DateKey),
    FOREIGN KEY (CustomerKey)
        REFERENCES dimCustomer(CustomerKey),
    FOREIGN KEY (DriverKey)
        REFERENCES dimDriver(DriverKey),
    FOREIGN KEY (TruckKey)
        REFERENCES dimTruck(TruckKey),
    FOREIGN KEY (RouteKey)
        REFERENCES dimRoute(RouteKey)
);

CREATE TABLE factFuel (
    fuelKey BIGINT AUTO_INCREMENT PRIMARY KEY,
    fuelID VARCHAR(30) NOT NULL,
    dateKey INT NOT NULL,
    truckKey INT NOT NULL,
    driverKey INT NOT NULL,
    fuelDate DATE NOT NULL,
    odometer DECIMAL(12,2),
    gallons DECIMAL(10,2),
    fuelPricePerGallons DECIMAL(10,2),
    totalFuelCost DECIMAL(12,2),
    fuelStation VARCHAR(150),
    FOREIGN KEY (dateKey)
        REFERENCES dimDate(dateKey),
    FOREIGN KEY (truckKey)
        REFERENCES dimTruck(truckKey),
    FOREIGN KEY (driverKey)
        REFERENCES dimDriver(driverKey)
);

CREATE TABLE factMaintenance (
    maintenanceKey BIGINT AUTO_INCREMENT PRIMARY KEY,
    maintenanceID VARCHAR(30) NOT NULL,
    dateKey INT NOT NULL,
    truckKey INT NOT NULL,
    maintenanceDate DATE NOT NULL,
    maintenanceType VARCHAR(100),
    maintenanceDescription VARCHAR(255),
    odometer DECIMAL(12,2),
    maintenanceCost DECIMAL(12,2),
    nextServiceMileage DECIMAL(12,2),
    maintenanceStatus VARCHAR(50),
    FOREIGN KEY (dateKey)
        REFERENCES dimDate(dateKey),
    FOREIGN KEY (truckKey)
        REFERENCES dimTruck(truckKey)
);

CREATE TABLE factExpense (
    expenseKey BIGINT AUTO_INCREMENT PRIMARY KEY,
    expenseID VARCHAR(30) NOT NULL,
    dateKey INT NOT NULL,
    truckKey INT,
    driverKey INT,
    expenseDate DATE NOT NULL,
    expenseCategory VARCHAR(100),
    expenseDescription VARCHAR(255),
    expenseAmount DECIMAL(12,2),
    vendor VARCHAR(150),
    FOREIGN KEY (dateKey)
        REFERENCES dimDate(dateKey),
    FOREIGN KEY (truckKey)
        REFERENCES dimTruck(truckKey),
    FOREIGN KEY (driverKey)
        REFERENCES dimDriver(driverKey)
);

CREATE TABLE factDelivery (
    deliveryKey BIGINT AUTO_INCREMENT PRIMARY KEY,
    deliveryID VARCHAR(30) NOT NULL,
    shipmentKey BIGINT NOT NULL,
    dateKey INT NOT NULL,
    deliveryStatus VARCHAR(50),
    eventDateTime DATETIME,
    actualArrivalDateTime DATETIME,
    proofOfDeliveryReceived BOOLEAN DEFAULT FALSE,
    delayReason VARCHAR(255),
    notes VARCHAR(500),
    FOREIGN KEY (shipmentKey)
        REFERENCES factShipment(shipmentKey),
    FOREIGN KEY (dateKey)
        REFERENCES dimDate(dateKey)
);

CREATE TABLE factInvoice (
    invoiceKey BIGINT AUTO_INCREMENT PRIMARY KEY,
    invoiceID VARCHAR(30) NOT NULL,
    shipmentKey BIGINT NOT NULL,
    customerKey INT NOT NULL,
    invoiceDate DATE,
    dueDate DATE,
    paymentDate DATE,
    invoiceAmount DECIMAL(12,2),
    paymentStatus VARCHAR(50),
    FOREIGN KEY (shipmentKey)
        REFERENCES factShipment(shipmentKey),
    FOREIGN KEY (customerKey)
        REFERENCES dimCustomer(customerKey)
);

SET SESSION cte_max_recursion_depth = 2000;


INSERT INTO dimDate (
    dateKey,
    fullDate,
    Year,
    Quarter,
    monthNumber,
    monthName,
    weekNumber,
    dayOfMonth,
    dayName,
    dayOfWeekNumber,
    isWeekend
)
WITH RECURSIVE dates AS (
    SELECT DATE('2024-01-01') AS fullDate
    UNION ALL
    SELECT DATE_ADD(fullDate, INTERVAL 1 DAY)
    FROM dates
    WHERE fullDate < '2026-12-31'
)
SELECT
    CAST(DATE_FORMAT(fullDate, '%Y%m%d') AS UNSIGNED) AS dateKey,
    fullDate,
    YEAR(fullDate) AS Year,
    QUARTER(fullDate) AS Quarter,
    MONTH(fullDate) AS monthNumber,
    MONTHNAME(fullDate) AS monthName,
    WEEK(fullDate, 1) AS weekNumber,
    DAY(fullDate) AS dayOfMonth,
    DAYNAME(fullDate) AS dayName,
    DAYOFWEEK(fullDate) - 1 AS dayOfWeekNumber,
    CASE
        WHEN DAYOFWEEK(fullDate) IN (1, 7)
        THEN TRUE
        ELSE FALSE
    END AS isWeekend
FROM dates;

INSERT INTO dimCustomer (
    customerID,
    customerName,
    customerType,
    city,
    state,
    country,
    industry,
    creditLimit,
    customerStatus
)
VALUES
('CUS-0001', 'ABC Manufacturing', 'Enterprise', 'Chicago', 'Illinois', 'USA', 'Manufacturing', 150000, 'Active'),
('CUS-0002', 'NorthStar Retail', 'Enterprise', 'Dallas', 'Texas', 'USA', 'Retail', 200000, 'Active'),
('CUS-0003', 'Green Valley Foods', 'Mid-Market', 'Atlanta', 'Georgia', 'USA', 'Food & Beverage', 100000, 'Active'),
('CUS-0004', 'Metro Electronics', 'Enterprise', 'Los Angeles', 'California', 'USA', 'Electronics', 175000, 'Active'),
('CUS-0005', 'Summit Construction', 'Mid-Market', 'Denver', 'Colorado', 'USA', 'Construction', 85000, 'Active'),
('CUS-0006', 'Pacific Medical Supply', 'Enterprise', 'Seattle', 'Washington', 'USA', 'Healthcare', 125000, 'Active'),
('CUS-0007', 'East Coast Furniture', 'Mid-Market', 'Boston', 'Massachusetts', 'USA', 'Furniture', 75000, 'Active'),
('CUS-0008', 'Central Auto Parts', 'Mid-Market', 'Detroit', 'Michigan', 'USA', 'Automotive', 90000, 'Active'),
('CUS-0009', 'FreshMart Distribution', 'Enterprise', 'Phoenix', 'Arizona', 'USA', 'Retail', 140000, 'Active'),
('CUS-0010', 'BlueLine Chemicals', 'Enterprise', 'Houston', 'Texas', 'USA', 'Chemicals', 180000, 'Active');

INSERT INTO dimDriver (
    driverID,
    driverName,
    phone,
    hireDate,
    licenseNumber,
    licenseExpiration,
    certificationExpiration,
    driverStatus
)
VALUES
('DRV-0001', 'James Carter', '555-0101', '2021-03-15', 'CDL-10001', '2027-05-20', '2027-03-15', 'Active'),
('DRV-0002', 'Michael Johnson', '555-0102', '2020-07-10', 'CDL-10002', '2027-08-15', '2027-06-10', 'Active'),
('DRV-0003', 'Robert Williams', '555-0103', '2022-01-20', 'CDL-10003', '2028-01-20', '2027-12-20', 'Active'),
('DRV-0004', 'David Brown', '555-0104', '2019-11-05', 'CDL-10004', '2027-11-05', '2027-09-05', 'Active'),
('DRV-0005', 'William Davis', '555-0105', '2023-02-12', 'CDL-10005', '2027-02-12', '2027-01-12', 'Active'),
('DRV-0006', 'Richard Miller', '555-0106', '2021-09-18', 'CDL-10006', '2028-09-18', '2028-06-18', 'Active'),
('DRV-0007', 'Joseph Wilson', '555-0107', '2020-04-25', 'CDL-10007', '2027-04-25', '2027-02-25', 'Active'),
('DRV-0008', 'Thomas Moore', '555-0108', '2022-06-30', 'CDL-10008', '2028-06-30', '2028-04-30', 'Active'),
('DRV-0009', 'Christopher Taylor', '555-0109', '2023-08-14', 'CDL-10009', '2027-08-14', '2027-06-14', 'Active'),
('DRV-0010', 'Daniel Anderson', '555-0110', '2018-12-01', 'CDL-10010', '2027-12-01', '2027-10-01', 'Active');

INSERT INTO dimTruck (
    truckID,
    VIN,
    truckType,
    make,
    model,
    modelYear,
    currentMileage,
    fuelType,
    truckStatus
)
VALUES
('TRK-0001', '1FTFW1ET1NFA10001', 'Dry Van', 'Freightliner', 'Cascadia', 2022, 185420, 'Diesel', 'Active'),
('TRK-0002', '1FTFW1ET1NFA10002', 'Dry Van', 'Peterbilt', '579', 2021, 245680, 'Diesel', 'Active'),
('TRK-0003', '1FTFW1ET1NFA10003', 'Refrigerated', 'Freightliner', 'Cascadia', 2023, 126540, 'Diesel', 'Active'),
('TRK-0004', '1FTFW1ET1NFA10004', 'Dry Van', 'Kenworth', 'T680', 2020, 318750, 'Diesel', 'Active'),
('TRK-0005', '1FTFW1ET1NFA10005', 'Flatbed', 'Peterbilt', '579', 2022, 198430, 'Diesel', 'Active'),
('TRK-0006', '1FTFW1ET1NFA10006', 'Refrigerated', 'Volvo', 'VNL', 2021, 276820, 'Diesel', 'Active'),
('TRK-0007', '1FTFW1ET1NFA10007', 'Dry Van', 'International', 'LT', 2023, 98450, 'Diesel', 'Active'),
('TRK-0008', '1FTFW1ET1NFA10008', 'Dry Van', 'Freightliner', 'Cascadia', 2019, 392650, 'Diesel', 'Active'),
('TRK-0009', '1FTFW1ET1NFA10009', 'Flatbed', 'Kenworth', 'T680', 2022, 164280, 'Diesel', 'Active'),
('TRK-0010', '1FTFW1ET1NFA10010', 'Refrigerated', 'Peterbilt', '579', 2020, 335740, 'Diesel', 'Active'),
('TRK-0011', '1FTFW1ET1NFA10011', 'Dry Van', 'Volvo', 'VNL', 2023, 112360, 'Diesel', 'Active'),
('TRK-0012', '1FTFW1ET1NFA10012', 'Dry Van', 'International', 'LT', 2021, 228940, 'Diesel', 'Active'),
('TRK-0013', '1FTFW1ET1NFA10013', 'Flatbed', 'Freightliner', 'Cascadia', 2020, 301520, 'Diesel', 'Active'),
('TRK-0014', '1FTFW1ET1NFA10014', 'Refrigerated', 'Kenworth', 'T680', 2022, 142780, 'Diesel', 'Active'),
('TRK-0015', '1FTFW1ET1NFA10015', 'Dry Van', 'Peterbilt', '579', 2021, 267390, 'Diesel', 'Active');

INSERT INTO dimRoute (
    routeID,
    originCity,
    originState,
    destinationCity,
    destinationState,
    distanceMiles,
    routeType
)
VALUES
('RTE-0001', 'Chicago', 'Illinois', 'Dallas', 'Texas', 925, 'Long Haul'),
('RTE-0002', 'Dallas', 'Texas', 'Atlanta', 'Georgia', 780, 'Long Haul'),
('RTE-0003', 'Atlanta', 'Georgia', 'Miami', 'Florida', 660, 'Long Haul'),
('RTE-0004', 'Los Angeles', 'California', 'Phoenix', 'Arizona', 370, 'Regional'),
('RTE-0005', 'Houston', 'Texas', 'Denver', 'Colorado', 1030, 'Long Haul'),
('RTE-0006', 'Denver', 'Colorado', 'Chicago', 'Illinois', 1000, 'Long Haul'),
('RTE-0007', 'New York', 'New York', 'Boston', 'Massachusetts', 215, 'Regional'),
('RTE-0008', 'Boston', 'Massachusetts', 'New York', 'New York', 215, 'Regional'),
('RTE-0009', 'Detroit', 'Michigan', 'Chicago', 'Illinois', 285, 'Regional'),
('RTE-0010', 'Chicago', 'Illinois', 'Detroit', 'Michigan', 285, 'Regional'),
('RTE-0011', 'Phoenix', 'Arizona', 'Los Angeles', 'California', 370, 'Regional'),
('RTE-0012', 'Miami', 'Florida', 'Atlanta', 'Georgia', 660, 'Long Haul'),
('RTE-0013', 'Dallas', 'Texas', 'Houston', 'Texas', 240, 'Regional'),
('RTE-0014', 'Houston', 'Texas', 'Dallas', 'Texas', 240, 'Regional'),
('RTE-0015', 'Seattle', 'Washington', 'Los Angeles', 'California', 1135, 'Long Haul'),
('RTE-0016', 'Los Angeles', 'California', 'Seattle', 'Washington', 1135, 'Long Haul'),
('RTE-0017', 'Kansas City', 'Missouri', 'Chicago', 'Illinois', 510, 'Long Haul'),
('RTE-0018', 'Chicago', 'Illinois', 'Kansas City', 'Missouri', 510, 'Long Haul'),
('RTE-0019', 'Nashville', 'Tennessee', 'Atlanta', 'Georgia', 250, 'Regional'),
('RTE-0020', 'Atlanta', 'Georgia', 'Nashville', 'Tennessee', 250, 'Regional');

INSERT INTO factShipment (
    shipmentID,
    dateKey,
    customerKey,
    driverKey,
    truckKey,
    routeKey,
    pickupDate,
    expectedDeliveryDate,
    actualDeliveryDate,
    shipmentStatus,
    distanceMiles,
    revenue,
    freightCost
)
SELECT

    CONCAT(
        'SHP-',
        LPAD(n.n, 6, '0')
    ) AS shipmentID,

    d.dateKey,

    MOD(n.n - 1, 10) + 1 AS customerKey,

    MOD(n.n - 1, 10) + 1 AS driverKey,

    MOD(n.n - 1, 15) + 1 AS truckKey,

    MOD(n.n - 1, 20) + 1 AS routeKey,

    d.fullDate AS pickupDate,

    DATE_ADD(
        d.fullDate,
        INTERVAL
        CASE
            WHEN r.distanceMiles <= 300 THEN 1
            WHEN r.distanceMiles <= 600 THEN 2
            WHEN r.distanceMiles <= 900 THEN 3
            ELSE 4
        END DAY
    ) AS expectedDeliveryDate,

    CASE

        WHEN MOD(n.n, 100) < 80 THEN

            DATE_ADD(
                d.fullDate,
                INTERVAL
                CASE
                    WHEN r.distanceMiles <= 300 THEN 1
                    WHEN r.distanceMiles <= 600 THEN 2
                    WHEN r.distanceMiles <= 900 THEN 3
                    ELSE 4
                END DAY
            )

        WHEN MOD(n.n, 100) < 95 THEN

            DATE_ADD(
                d.fullDate,
                INTERVAL
                CASE
                    WHEN r.distanceMiles <= 300 THEN 2
                    WHEN r.distanceMiles <= 600 THEN 3
                    WHEN r.distanceMiles <= 900 THEN 4
                    ELSE 5
                END DAY
            )

        ELSE NULL

    END AS actualDeliveryDate,

    CASE

        WHEN MOD(n.n, 100) < 80 THEN 'Delivered'

        WHEN MOD(n.n, 100) < 90 THEN 'In Transit'

        WHEN MOD(n.n, 100) < 97 THEN 'Delayed'

        ELSE 'Cancelled'

    END AS shipmentStatus,

    r.distanceMiles,

    ROUND(
        r.distanceMiles *
        (
            2.75 +
            MOD(n.n * 13, 176) / 100
        ),
        2
    ) AS revenue,

    ROUND(
        r.distanceMiles *
        (
            1.45 +
            MOD(n.n * 17, 86) / 100
        ),
        2
    ) AS freightCost

FROM
(
    SELECT
        a.n
        + (b.n * 10)
        + (c.n * 100)
        + 1 AS n

    FROM
    (
        SELECT 0 AS n UNION ALL
        SELECT 1 UNION ALL
        SELECT 2 UNION ALL
        SELECT 3 UNION ALL
        SELECT 4 UNION ALL
        SELECT 5 UNION ALL
        SELECT 6 UNION ALL
        SELECT 7 UNION ALL
        SELECT 8 UNION ALL
        SELECT 9
    ) a

    CROSS JOIN
    (
        SELECT 0 AS n UNION ALL
        SELECT 1 UNION ALL
        SELECT 2 UNION ALL
        SELECT 3 UNION ALL
        SELECT 4 UNION ALL
        SELECT 5 UNION ALL
        SELECT 6 UNION ALL
        SELECT 7 UNION ALL
        SELECT 8 UNION ALL
        SELECT 9
    ) b

    CROSS JOIN
    (
        SELECT 0 AS n UNION ALL
        SELECT 1 UNION ALL
        SELECT 2 UNION ALL
        SELECT 3 UNION ALL
        SELECT 4 UNION ALL
        SELECT 5 UNION ALL
        SELECT 6 UNION ALL
        SELECT 7 UNION ALL
        SELECT 8 UNION ALL
        SELECT 9
    ) c

) n

INNER JOIN dimDate d
    ON d.fullDate =
       DATE_ADD(
           '2024-01-01',
           INTERVAL MOD(n.n * 17, 1096) DAY
       )

INNER JOIN dimRoute r
    ON r.routeKey =
       MOD(n.n - 1, 20) + 1;
       
SELECT
    COUNT(*) AS totalShipments
FROM factShipment;

SELECT
    SUM(revenue) AS totalRevenue
FROM factShipment;

SELECT
    SUM(freightCost) AS totalFreightCost
FROM factShipment;

SELECT
    SUM(revenue) - SUM(freightCost) AS grossProfit
FROM factShipment;

SELECT
    ROUND(( SUM(revenue) - SUM(freightCost))
        / NULLIF(SUM(revenue), 0) * 100, 2) AS profitMargin
FROM factShipment;

SELECT
    ROUND(SUM(revenue) / NULLIF(SUM(distanceMiles), 0),2) AS revenuePerMile
FROM factShipment;

SELECT
    ROUND(SUM(freightCost) / NULLIF(SUM(distanceMiles), 0), 2
    ) AS freightCostPerMile
FROM factShipment;

SELECT
    ROUND(
        (SUM(revenue) - SUM(freightCost))
        / NULLIF(SUM(distanceMiles), 0),2) AS profitPerMile
FROM factShipment;

SELECT
    COUNT(*) AS totalShipments,
    ROUND(
        SUM(revenue),2
    ) AS TotalRevenue,
    ROUND(
        SUM(freightCost),
        2
    ) AS totalFreightCost,
    ROUND(
        SUM(revenue) - SUM(freightCost),
        2
    ) AS grossProfit,
    ROUND(( SUM(revenue) - SUM(freightCost))
        / NULLIF(SUM(revenue), 0) * 100,
        2
    ) AS profitMargin,
    ROUND(
        SUM(distanceMiles),
        2
    ) AS totalMiles,
    ROUND(
        SUM(revenue)
        / NULLIF(SUM(distanceMiles), 0),
        2
    ) AS revenuePerMile,
    ROUND(
        SUM(freightCost)
        / NULLIF(SUM(distanceMiles), 0),
        2
    ) AS freightCostPerMile,
    ROUND((SUM(revenue) - SUM(freightCost))
        / NULLIF(SUM(distanceMiles), 0),
        2) AS profitPerMile
FROM factShipment;

SELECT
    c.customerName,
    COUNT(s.shipmentKey) AS totalShipments,
    ROUND(
        SUM(s.revenue), 2) AS revenue,
    ROUND(
        SUM(s.freightCost),2
    ) AS freightCost,
    ROUND(
        SUM(s.revenue) - SUM(s.freightCost),2
    ) AS grossProfit,
    ROUND((SUM(s.revenue) - SUM(s.freightCost))
        / NULLIF(SUM(s.revenue), 0) * 100,
        2
    ) AS profitMargin
FROM factShipment s
INNER JOIN dimCustomer c
    ON s.customerKey = c.customerKey
GROUP BY
    c.customerKey,
    c.customerName
ORDER BY
    grossProfit DESC;

 
INSERT INTO factDelivery
(
    deliveryID,
    shipmentKey,
    dateKey,
    deliveryStatus,
    eventDateTime,
    actualArrivalDateTime,
    proofOfDeliveryReceived,
    delayReason,
    notes
)
SELECT
    CONCAT(
        'DLV-',
        LPAD(fs.shipmentKey, 6, '0')
    ) AS deliveryID,
    fs.shipmentKey,
    COALESCE(
        actualDate.dateKey,
        pickupDate.dateKey
    ) AS dateKey,
    fs.shipmentStatus AS deliveryStatus,
    TIMESTAMP(
        fs.pickupDate,
        '08:00:00'
    ) AS eventDateTime,
    CASE
        WHEN fs.actualDeliveryDate IS NOT NULL THEN
            TIMESTAMP(
                fs.actualDeliveryDate,
                CASE
                    WHEN MOD(fs.shipmentKey, 4) = 0 THEN '14:30:00'
                    WHEN MOD(fs.shipmentKey, 4) = 1 THEN '16:15:00'
                    WHEN MOD(fs.shipmentKey, 4) = 2 THEN '11:45:00'
                    ELSE '13:20:00'
                END
            )
        ELSE NULL
    END AS actualArrivalDateTime,

    CASE
        WHEN fs.shipmentStatus = 'Delivered'
             AND MOD(fs.shipmentKey, 20) <> 0
        THEN 1
        ELSE 0
    END AS proofOfDeliveryReceived,
    
    CASE
        WHEN fs.shipmentStatus = 'Delayed'
        THEN
            CASE
                WHEN MOD(fs.shipmentKey, 4) = 0
                    THEN 'Traffic'
                WHEN MOD(fs.shipmentKey, 4) = 1
                    THEN 'Weather'
                WHEN MOD(fs.shipmentKey, 4) = 2
                    THEN 'Mechanical Issue'
                ELSE 'Road Closure'
            END
        WHEN fs.shipmentStatus = 'Cancelled'
        THEN
            CASE
                WHEN MOD(fs.shipmentKey, 3) = 0
                    THEN 'Customer Cancellation'
                WHEN MOD(fs.shipmentKey, 3) = 1
                    THEN 'Equipment Unavailable'
                ELSE 'Operational Issue'
            END
        ELSE NULL
    END AS delayReason,

    CASE
        WHEN fs.shipmentStatus = 'Delivered'
             AND MOD(fs.shipmentKey, 20) = 0
        THEN 'Delivery completed - POD pending'
        WHEN fs.shipmentStatus = 'Delivered'
        THEN 'Delivery completed successfully'
        WHEN fs.shipmentStatus = 'Delayed'
        THEN 'Delivery delayed - operations review required'
        WHEN fs.shipmentStatus = 'In Transit'
        THEN 'Shipment currently in transit'
        WHEN fs.shipmentStatus = 'Cancelled'
        THEN 'Shipment cancelled'
        ELSE 'Delivery record created'
    END AS notes
FROM factShipment fs
LEFT JOIN dimDate pickupDate
    ON pickupDate.fullDate = fs.pickupDate
LEFT JOIN dimDate actualDate
    ON actualDate.fullDate = fs.actualDeliveryDate;
    
INSERT INTO factFuel
(
    fuelID,
    dateKey,
    truckKey,
    driverKey,
    fuelDate,
    odometer,
    gallons,
    fuelPricePerGallon,
    totalFuelCost,
    fuelStation
)
WITH numbers AS
(
    SELECT
        a.n
        + (b.n * 10)
        + (c.n * 100)
        + 1 AS n
    FROM
    (
        SELECT 0 AS n UNION ALL
        SELECT 1 UNION ALL
        SELECT 2 UNION ALL
        SELECT 3 UNION ALL
        SELECT 4 UNION ALL
        SELECT 5 UNION ALL
        SELECT 6 UNION ALL
        SELECT 7 UNION ALL
        SELECT 8 UNION ALL
        SELECT 9
    ) a
    
    CROSS JOIN
    (
        SELECT 0 AS n UNION ALL
        SELECT 1 UNION ALL
        SELECT 2 UNION ALL
        SELECT 3 UNION ALL
        SELECT 4 UNION ALL
        SELECT 5 UNION ALL
        SELECT 6 UNION ALL
        SELECT 7 UNION ALL
        SELECT 8 UNION ALL
        SELECT 9
    ) b

    CROSS JOIN
    (
        SELECT 0 AS n UNION ALL
        SELECT 1 UNION ALL
        SELECT 2 UNION ALL
        SELECT 3 UNION ALL
        SELECT 4 UNION ALL
        SELECT 5 UNION ALL
        SELECT 6 UNION ALL
        SELECT 7 UNION ALL
        SELECT 8 UNION ALL
        SELECT 9
    ) c
),

fuelRecords AS
(
    SELECT
        n,
        MOD(n - 1, 15) + 1 AS truckKey,
        MOD(n - 1, 10) + 1 AS driverKey,
        MOD(n * 37, 1096) + 1 AS dateNumber
    FROM numbers
),
numberedDates AS
(
    SELECT
        dateKey,
        fullDate,
        ROW_NUMBER() OVER (
            ORDER BY fullDate
        ) AS dateNumber
    FROM dimDate
)
SELECT
    CONCAT(
        'FUEL-',
        LPAD(fr.n, 6, '0')
    ),
    d.dateKey,
    fr.truckKey,
    fr.driverKey,
    d.fullDate,
    ROUND(
        50000
        + (fr.truckKey * 8500)
        + (fr.n * 145.75),
        2
    ),
    ROUND(
        80 + MOD(fr.n * 17, 101),
        2
    ),
    ROUND(
        3.20 + (MOD(fr.n * 13, 161) / 100),
        2
    ),
    ROUND(
        (
            80 + MOD(fr.n * 17, 101)
        )
        *
        (
            3.20 + (MOD(fr.n * 13, 161) / 100)
        ),
        2
    ),
    CASE
        WHEN MOD(fr.n, 6) = 0
            THEN 'Pilot Flying J'
        WHEN MOD(fr.n, 6) = 1
            THEN 'Love''s Travel Stop'
        WHEN MOD(fr.n, 6) = 2
            THEN 'TA Travel Center'
        WHEN MOD(fr.n, 6) = 3
            THEN 'Shell'
        WHEN MOD(fr.n, 6) = 4
            THEN 'Exxon'
        ELSE 'Chevron'
    END
FROM fuelRecords fr
INNER JOIN numberedDates d
    ON d.dateNumber = fr.dateNumber;


INSERT INTO factMaintenance
(
    maintenanceID,
    dateKey,
    truckKey,
    maintenanceDate,
    maintenanceType,
    maintenanceDescription,
    odometer,
    maintenanceCost,
    nextServiceMileage,
    maintenanceStatus
)
WITH numbers AS
(
    SELECT
        a.n
        + (b.n * 10)
        + (c.n * 100)
        + 1 AS n
    FROM
    (
        SELECT 0 AS n UNION ALL
        SELECT 1 UNION ALL
        SELECT 2 UNION ALL
        SELECT 3 UNION ALL
        SELECT 4 UNION ALL
        SELECT 5 UNION ALL
        SELECT 6 UNION ALL
        SELECT 7 UNION ALL
        SELECT 8 UNION ALL
        SELECT 9
    ) a
    CROSS JOIN
    (
        SELECT 0 AS n UNION ALL
        SELECT 1 UNION ALL
        SELECT 2 UNION ALL
        SELECT 3 UNION ALL
        SELECT 4 UNION ALL
        SELECT 5 UNION ALL
        SELECT 6 UNION ALL
        SELECT 7 UNION ALL
        SELECT 8 UNION ALL
        SELECT 9
    ) b
    CROSS JOIN
    (
        SELECT 0 AS n UNION ALL
        SELECT 1 UNION ALL
        SELECT 2 UNION ALL
        SELECT 3 UNION ALL
        SELECT 4 UNION ALL
        SELECT 5 UNION ALL
        SELECT 6 UNION ALL
        SELECT 7 UNION ALL
        SELECT 8 UNION ALL
        SELECT 9
    ) c
),

maintenanceRecords AS
(
    SELECT
        n,
        MOD(n - 1, 15) + 1 AS truckKey,
        MOD(n * 29, 1096) + 1 AS dateNumber
    FROM numbers
),

numberedDates AS
(
    SELECT
        dateKey,
        fullDate,
        ROW_NUMBER() OVER (
            ORDER BY fullDate
        ) AS dateNumber
    FROM dimDate
)

SELECT
    CONCAT(
        'MNT-',
        LPAD(m.n, 6, '0')
    ) AS maintenanceID,
    d.dateKey,
    m.truckKey,
    d.fullDate AS maintenanceDate,
    CASE
        WHEN MOD(m.n, 10) = 0
            THEN 'Unscheduled Breakdown'
        WHEN MOD(m.n, 10) IN (1,2)
            THEN 'Preventive Maintenance'
        WHEN MOD(m.n, 10) IN (3,4)
            THEN 'Oil Change'
        WHEN MOD(m.n, 10) = 5
            THEN 'Brake Service'
        WHEN MOD(m.n, 10) = 6
            THEN 'Tire Service'
        WHEN MOD(m.n, 10) = 7
            THEN 'Inspection'
        WHEN MOD(m.n, 10) = 8
            THEN 'Engine Service'
        ELSE 'Electrical Service'
    END AS maintenanceType,
    CASE
        WHEN MOD(m.n, 10) = 0
            THEN 'Emergency repair due to unexpected mechanical breakdown'
        WHEN MOD(m.n, 10) IN (1,2)
            THEN 'Scheduled preventive maintenance inspection'
        WHEN MOD(m.n, 10) IN (3,4)
            THEN 'Engine oil and filter replacement'
        WHEN MOD(m.n, 10) = 5
            THEN 'Brake pads and brake system inspection'
        WHEN MOD(m.n, 10) = 6
            THEN 'Tire inspection and replacement'
        WHEN MOD(m.n, 10) = 7
            THEN 'DOT and vehicle safety inspection'
        WHEN MOD(m.n, 10) = 8
            THEN 'Engine diagnostics and service'
        ELSE 'Electrical system inspection and repair'
    END AS maintenanceDescription,
    ROUND(
        50000
        + (m.truckKey * 8500)
        + (m.n * 275.50),
        2
    ) AS odometer,
    CASE
        WHEN MOD(m.n, 10) = 0
            THEN ROUND(
                1500 + MOD(m.n * 73, 2501),
                2
            )
        WHEN MOD(m.n, 10) IN (1,2)
            THEN ROUND(
                450 + MOD(m.n * 41, 751),
                2
            )
        WHEN MOD(m.n, 10) IN (3,4)
            THEN ROUND(
                180 + MOD(m.n * 17, 221),
                2
            )
        WHEN MOD(m.n, 10) = 5
            THEN ROUND(
                600 + MOD(m.n * 31, 901),
                2
            )
        WHEN MOD(m.n, 10) = 6
            THEN ROUND(
                700 + MOD(m.n * 43, 1001),
                2
            )
        WHEN MOD(m.n, 10) = 7
            THEN ROUND(
                150 + MOD(m.n * 23, 351),
                2
            )

        WHEN MOD(m.n, 10) = 8
            THEN ROUND(
                900 + MOD(m.n * 47, 1501),
                2
            )

        ELSE ROUND(
            300 + MOD(m.n * 19, 701),
            2
        )
    END AS maintenanceCost,
    ROUND(
        (
            50000
            + (m.truckKey * 8500)
            + (m.n * 275.50)
        )
        +
        CASE
            WHEN MOD(m.n, 10) = 0
                THEN 5000
            WHEN MOD(m.n, 10) IN (1,2)
                THEN 10000
            ELSE 7500
        END,
        2
    ) AS nextServiceMileage,
    CASE
        WHEN MOD(m.n, 10) = 0
            THEN 'In Progress'
        WHEN MOD(m.n, 10) IN (1,2,3,4,5,6,7,8)
            THEN 'Completed'
        ELSE 'Scheduled'
    END AS maintenanceStatus
FROM maintenanceRecords m
INNER JOIN numberedDates d
    ON d.dateNumber = m.dateNumber;

INSERT INTO factInvoice
(
    invoiceID,
    shipmentKey,
    customerKey,
    invoiceDate,
    dueDate,
    paymentDate,
    invoiceAmount,
    paymentStatus
)
SELECT
    CONCAT(
        'INV-',
        LPAD(fs.shipmentKey, 6, '0')
    ) AS invoiceID,
    fs.shipmentKey,
    fs.customerKey,
    fs.pickupDate AS invoiceDate,
    DATE_ADD(
        fs.pickupDate,
        INTERVAL 30 DAY
    ) AS dueDate,
    CASE
        WHEN MOD(fs.shipmentKey, 100) < 75 THEN
            DATE_ADD(
                fs.pickupDate,
                INTERVAL
                CASE
                    WHEN MOD(fs.shipmentKey, 3) = 0 THEN 7
                    WHEN MOD(fs.shipmentKey, 3) = 1 THEN 14
                    ELSE 21
                END DAY
            )
        ELSE NULL
    END AS paymentDate,

    ROUND(
        fs.revenue,
        2
    ) AS invoiceAmount,

    CASE
        WHEN MOD(fs.shipmentKey, 100) < 75
            THEN 'Paid'
        WHEN MOD(fs.shipmentKey, 100) < 90
            THEN 'Unpaid'
        ELSE 'Overdue'
    END AS paymentStatus
FROM factShipment fs;

INSERT INTO factExpense
(
    expenseID,
    dateKey,
    truckKey,
    driverKey,
    expenseDate,
    expenseCategory,
    expenseDescription,
    expenseAmount,
    vendor
)

WITH numbers AS
(
    SELECT
        a.n
        + (b.n * 10)
        + (c.n * 100)
        + 1 AS n
    FROM
    (
        SELECT 0 AS n UNION ALL
        SELECT 1 UNION ALL
        SELECT 2 UNION ALL
        SELECT 3 UNION ALL
        SELECT 4 UNION ALL
        SELECT 5 UNION ALL
        SELECT 6 UNION ALL
        SELECT 7 UNION ALL
        SELECT 8 UNION ALL
        SELECT 9
    ) a

    CROSS JOIN
    (
        SELECT 0 AS n UNION ALL
        SELECT 1 UNION ALL
        SELECT 2 UNION ALL
        SELECT 3 UNION ALL
        SELECT 4 UNION ALL
        SELECT 5 UNION ALL
        SELECT 6 UNION ALL
        SELECT 7 UNION ALL
        SELECT 8 UNION ALL
        SELECT 9
    ) b

    CROSS JOIN
    (
        SELECT 0 AS n UNION ALL
        SELECT 1 UNION ALL
        SELECT 2 UNION ALL
        SELECT 3 UNION ALL
        SELECT 4 UNION ALL
        SELECT 5 UNION ALL
        SELECT 6 UNION ALL
        SELECT 7 UNION ALL
        SELECT 8 UNION ALL
        SELECT 9
    ) c
),

expenseRecords AS
(
    SELECT
        n,
        MOD(n - 1, 15) + 1 AS truckKey,
        MOD(n - 1, 10) + 1 AS driverKey,
        MOD(n * 43, 1096) + 1 AS dateNumber
    FROM numbers
),

numberedDates AS
(
    SELECT
        dateKey,
        fullDate,
        ROW_NUMBER() OVER (
            ORDER BY fullDate
        ) AS dateNumber
    FROM dimDate
)

SELECT
    CONCAT(
        'EXP-',
        LPAD(e.n, 6, '0')
    ) AS expenseID,
    d.dateKey,
    e.truckKey,
    e.driverKey,
    d.fullDate AS expenseDate,
    CASE
        WHEN MOD(e.n, 10) = 0
            THEN 'Tolls'
        WHEN MOD(e.n, 10) = 1
            THEN 'Insurance'
        WHEN MOD(e.n, 10) IN (2,3)
            THEN 'Driver Expense'
        WHEN MOD(e.n, 10) = 4
            THEN 'Parts'
        WHEN MOD(e.n, 10) = 5
            THEN 'Parking'
        WHEN MOD(e.n, 10) = 6
            THEN 'Permits'
        WHEN MOD(e.n, 10) = 7
            THEN 'Repair'
        WHEN MOD(e.n, 10) = 8
            THEN 'Administration'
        ELSE 'Other Operating Expense'
    END AS expenseCategory,

    CASE
        WHEN MOD(e.n, 10) = 0
            THEN 'Highway and bridge toll charges'
        WHEN MOD(e.n, 10) = 1
            THEN 'Commercial vehicle insurance expense'
        WHEN MOD(e.n, 10) IN (2,3)
            THEN 'Driver meals and travel allowance'
        WHEN MOD(e.n, 10) = 4
            THEN 'Replacement truck parts'
        WHEN MOD(e.n, 10) = 5
            THEN 'Truck parking and overnight parking'
        WHEN MOD(e.n, 10) = 6
            THEN 'Vehicle permits and registration fees'
        WHEN MOD(e.n, 10) = 7
            THEN 'Truck repair and mechanical service'
        WHEN MOD(e.n, 10) = 8
            THEN 'Administrative and office expense'
        ELSE 'Miscellaneous operating expense'
    END AS expenseDescription,

    CASE
        WHEN MOD(e.n, 10) = 0
            THEN ROUND(
                50 + MOD(e.n * 17, 251),
                2
            )
        WHEN MOD(e.n, 10) = 1
            THEN ROUND(
                800 + MOD(e.n * 29, 1201),
                2
            )
        WHEN MOD(e.n, 10) IN (2,3)
            THEN ROUND(
                75 + MOD(e.n * 13, 426),
                2
            )
        WHEN MOD(e.n, 10) = 4
            THEN ROUND(
                250 + MOD(e.n * 31, 1251),
                2
            )
        WHEN MOD(e.n, 10) = 5
            THEN ROUND(
                25 + MOD(e.n * 11, 176),
                2
            )
        WHEN MOD(e.n, 10) = 6
            THEN ROUND(
                100 + MOD(e.n * 23, 901),
                2
            )
        WHEN MOD(e.n, 10) = 7
            THEN ROUND(
                500 + MOD(e.n * 37, 2501),
                2
            )
        WHEN MOD(e.n, 10) = 8
            THEN ROUND(
                100 + MOD(e.n * 19, 601),
                2
            )
        ELSE ROUND(
            50 + MOD(e.n * 17, 451),
            2
        )
    END AS expenseAmount,

    CASE
        WHEN MOD(e.n, 10) = 0
            THEN 'E-ZPass'
        WHEN MOD(e.n, 10) = 1
            THEN 'National Fleet Insurance'
        WHEN MOD(e.n, 10) IN (2,3)
            THEN 'FleetFlow Driver Services'
        WHEN MOD(e.n, 10) = 4
            THEN 'Fleet Parts Supply'
        WHEN MOD(e.n, 10) = 5
            THEN 'Pilot Flying J'
        WHEN MOD(e.n, 10) = 6
            THEN 'State Transportation Department'
        WHEN MOD(e.n, 10) = 7
            THEN 'Fleet Service Center'
        WHEN MOD(e.n, 10) = 8
            THEN 'Office Depot'
        ELSE 'FleetFlow Operations'
    END AS vendor
FROM expenseRecords e
INNER JOIN numberedDates d
    ON d.dateNumber = e.dateNumber;
  