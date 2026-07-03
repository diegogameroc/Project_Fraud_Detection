CREATE DATABASE Credit_Card
use Credit_Card

IF OBJECT_ID('Transacciones_Tarjetas', 'U') IS NOT NULL
    DROP TABLE Transacciones_Tarjetas;

CREATE TABLE Transacciones_Tarjetas (
    User_ID INT,
    Card INT,
    Transaction_Year SMALLINT,
    Transaction_Month TINYINT,
    Transaction_Day TINYINT,
    Transaction_Time TIME(0),
    Amount VARCHAR(50), 
    Use_Chip VARCHAR(50),
    Merchant_Name VARCHAR(255),
    Merchant_City VARCHAR(100),
    Merchant_State VARCHAR(50),
    Zip VARCHAR(20),
    MCC INT,
    Errors VARCHAR(255),
    Is_Fraud VARCHAR(100)
);


BULK INSERT Transacciones_Tarjetas
FROM 'C:\DataSQL\credit_card_transactions-ibm_v2.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',  
    CODEPAGE = '65001',
    TABLOCK
);


BULK INSERT dbo.Transacciones_Tarjetas
FROM 'C:\DataSQL\credit_card_transactions-ibm_v2.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);





IF OBJECT_ID('Tarjetas_Usuarios', 'U') IS NOT NULL
    DROP TABLE Tarjetas_Usuarios;

CREATE TABLE Tarjetas_Usuarios (
    User_ID INT,
    Card_Index INT,
    Card_Brand VARCHAR(50),
    Card_Type VARCHAR(50),
    Card_Number VARCHAR(20),  
    Expires VARCHAR(10),
    CVV VARCHAR(5),           
    Has_Chip VARCHAR(10),
    Cards_Issued TINYINT,
    Credit_Limit VARCHAR(50), 
    Acct_Open_Date VARCHAR(10),
    Year_PIN_Last_Changed SMALLINT,
    Card_On_Dark_Web VARCHAR(10)
);


BULK INSERT Tarjetas_Usuarios
FROM 'C:\DataSQL\sd254_cards.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',  
    CODEPAGE = '65001',
    TABLOCK
);

IF OBJECT_ID('Datos_Usuarios', 'U') IS NOT NULL
    DROP TABLE Datos_Usuarios;

-- 1. Creamos la tabla para los usuarios
CREATE TABLE Datos_Usuarios (
    Person VARCHAR(255),
    Current_Age TINYINT,
    Retirement_Age TINYINT,
    Birth_Year SMALLINT,
    Birth_Month TINYINT,
    Gender VARCHAR(50),
    Address VARCHAR(255),
    Apartment VARCHAR(50),        -- VARCHAR porque los apartamentos pueden tener letras (ej. "4B") o venir vacíos
    City VARCHAR(100),
    State VARCHAR(50),
    Zipcode VARCHAR(20),          -- VARCHAR para no perder ceros a la izquierda en los códigos postales
    Latitude VARCHAR(50),         -- Texto temporal para absorber el punto decimal sin error de formato
    Longitude VARCHAR(50),        -- Texto temporal para absorber el punto decimal sin error de formato
    Per_Capita_Income_Zipcode VARCHAR(50), -- VARCHAR porque trae el símbolo $
    Yearly_Income_Person VARCHAR(50),      -- VARCHAR porque trae el símbolo $
    Total_Debt VARCHAR(50),                -- VARCHAR porque trae el símbolo $
    FICO_Score SMALLINT,
    Num_Credit_Cards TINYINT
);

-- Añadimos la columna User_ID empezando en 0 e incrementando de 1 en 1
ALTER TABLE Datos_Usuarios
ADD User_ID INT IDENTITY(0,1);

-- 2. Cargamos los datos desde tu carpeta segura
BULK INSERT Datos_Usuarios
FROM 'C:\DataSQL\sd254_users.csv' 
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',   -- El código infalible para saltos de línea \n puros
    CODEPAGE = '65001',
    TABLOCK
);

SELECT @@SERVERNAME;
SELECT DB_NAME();


