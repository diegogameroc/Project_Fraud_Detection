USE Credit_Card

SELECT*
FROM dbo.Datos_Usuarios

SELECT*
FROM dbo.Tarjetas_Usuarios

SELECT TOP 1000 *
FROM dbo.Transacciones_Tarjetas


WITH CTE_KPI AS(
SELECT 
SUM(CASE 
		WHEN Is_Fraud='Yes' THEN 1
		ELSE 0
	END
	) Cant_Fraud,
COUNT(1) AS Total_Transactions
FROM dbo.Transacciones_Tarjetas
)
SELECT
Cant_Fraud,
Total_Transactions,
ROUND(Cant_Fraud*100.00/Total_Transactions,2) AS Fraud_Rate
FROM CTE_KPI



--1.¿Cuál es la tasa de fraude para cada marca de tarjeta (Visa, Mastercard, American Express, etc.)?

WITH CTE_T1 AS (
SELECT 
tu.Card_Brand AS Marca,
COUNT(1) AS Total_Transactions,
SUM(CASE 
		WHEN tt.Is_Fraud='Yes' THEN 1
		ELSE 0 
	END
) AS Cant_Fraud
FROM dbo.Tarjetas_Usuarios as tu
INNER JOIN dbo.Transacciones_Tarjetas as tt
ON tu.Card_Index=tt.Card AND tu.User_ID=tt.User_ID
GROUP BY tu.Card_Brand
)
SELECT
Marca,
Cant_Fraud,
Total_Transactions,
ROUND(Cant_Fraud*100.00/Total_Transactions,4)AS Fraud_Rate
FROM CTE_T1
ORDER BY Fraud_Rate DESC

--2. ¿Cuál es la tasa de fraude según el tipo de transacción (Swipe, Chip, Online)?

WITH CTE_KPI AS(
SELECT 
Use_Chip,
SUM(CASE 
		WHEN Is_Fraud='Yes' THEN 1
		ELSE 0
	END
	) Cant_Fraud,
COUNT(1) AS Total_Transactions
FROM dbo.Transacciones_Tarjetas
GROUP BY Use_Chip
)
SELECT
Use_Chip,
Cant_Fraud,
Total_Transactions,
ROUND(Cant_Fraud*100.00/Total_Transactions,2) AS Fraud_Rate
FROM CTE_KPI
ORDER BY Fraud_Rate DESC



WITH CTE_KPI AS (
    SELECT 
        Use_Chip,
        SUM(CASE 
                WHEN Is_Fraud = 'Yes' THEN 1
                ELSE 0
            END) AS Cant_Fraud,
        COUNT(*) AS Total_Transactions
    FROM dbo.Transacciones_Tarjetas
    GROUP BY Use_Chip
),
CTE_FRAUD AS (
    SELECT
        Use_Chip,
        Cant_Fraud,
        Total_Transactions,
        ROUND(Cant_Fraud * 100.0 / Total_Transactions, 4) AS Fraud_Rate
    FROM CTE_KPI
)

SELECT
    Use_Chip,
    Cant_Fraud,
    Total_Transactions,
    Fraud_Rate,
    ROUND(
        Fraud_Rate /
        (
            SELECT Fraud_Rate
            FROM CTE_FRAUD
            WHERE Use_Chip = 'Chip Transaction'
        ),
        2
    ) AS Risk_Ratio
FROM CTE_FRAUD 
ORDER BY Risk_Ratio DESC;
 
--3. ¿Cómo varía la tasa de fraude según el monto de la transacción?

WITH CTE_KPI AS (
    SELECT 
        CASE
            WHEN ROUND(CAST(REPLACE(Amount,'$','') AS FLOAT),2) < 10 THEN 'Micro-gasto'
            WHEN ROUND(CAST(REPLACE(Amount,'$','') AS FLOAT),2) <= 600 THEN 'Gasto Diario'
            ELSE 'Gasto Fuerte'
        END AS Categoria_Gasto,
        CASE 
            WHEN Is_Fraud = 'Yes' THEN 1
            ELSE 0
        END AS Fraud_Flag
    FROM dbo.Transacciones_Tarjetas
)
SELECT
    Categoria_Gasto,
    COUNT(*) AS Total_Transactions,
    SUM(Fraud_Flag) AS Cant_Fraud,
    ROUND(SUM(Fraud_Flag) * 100.0 / COUNT(*), 4) AS Fraud_Rate
FROM CTE_KPI
GROUP BY Categoria_Gasto
ORDER BY Fraud_Rate DESC;


--4. ¿Qué estados concentran la mayor tasa de fraude?

WITH CTE_BASE AS (
    SELECT 
        d.State,
        CASE 
            WHEN t.Is_Fraud = 'Yes' THEN 1
            ELSE 0
        END AS Fraud_Flag
    FROM dbo.Transacciones_Tarjetas t
    INNER JOIN dbo.Tarjetas_Usuarios tu
        ON t.User_ID = tu.User_ID
       AND t.Card = tu.Card_Index
    INNER JOIN dbo.Datos_Usuarios d
        ON tu.User_ID = d.User_ID
)

SELECT
    State,
    COUNT(*) AS Total_Transactions,
    SUM(Fraud_Flag) AS Cant_Fraud,
    ROUND(SUM(Fraud_Flag) * 100.0 / COUNT(*), 4) AS Fraud_Rate
FROM CTE_BASE
GROUP BY State
ORDER BY Fraud_Rate DESC;

-- 5. Fraude por merchant (MCC o tipo de comercio)
WITH CTE_BASE AS (
    SELECT 
         MCC,
        CASE 
            WHEN Is_Fraud = 'Yes' THEN 1
            ELSE 0
        END AS Fraud_Flag
    FROM dbo.Transacciones_Tarjetas 
)

SELECT
    MCC,
    COUNT(1) AS Total_Transactions,
    SUM(Fraud_Flag) AS Cant_Fraud,
    ROUND(SUM(Fraud_Flag) * 100.0 / COUNT(1), 4) AS Fraud_Rate
FROM CTE_BASE
GROUP BY MCC
HAVING COUNT(1) >= 5000
ORDER BY Fraud_Rate DESC;


--6. ¿Cómo varía la tasa de fraude según el nivel de FICO Score de los usuarios?

WITH CTE_BASE AS (
    SELECT
    	us.User_ID,
        us.FICO_Score,
        CASE 
            WHEN t.Is_Fraud = 'Yes' THEN 1
            ELSE 0
        END AS Fraud_Flag,
        CASE 
        	WHEN us.FICO_SCORE <650 THEN 'Riesgo Alto'
        	WHEN us.FICO_SCORE <=750 THEN 'Riesgo Medio'
        	ELSE 'Riesgo Bajo' 
        END AS Segmento_Fico
    FROM dbo.Transacciones_Tarjetas t
    INNER JOIN dbo.Datos_Usuarios us
    ON  us.User_ID = t.User_ID
)
SELECT
	Segmento_Fico,
	COUNT(1) AS Total_Transactions,
    SUM(Fraud_Flag) AS Cant_Fraud,
    ROUND(SUM(Fraud_Flag) * 100.0 / COUNT(1), 4) AS Fraud_Rate
FROM CTE_BASE
GROUP BY Segmento_Fico
ORDER BY Fraud_Rate DESC
 
--7. Cómo varía la tasa de fraude según el Límite de Crédito de los usuarios

WITH CTE_BASE AS (
    SELECT
    	CAST(REPLACE(tu.Credit_Limit,'$','') AS FLOAT) Credit_Limit,
        CASE 
            WHEN t.Is_Fraud = 'Yes' THEN 1
            ELSE 0
        END AS Fraud_Flag,
        CASE 
        	WHEN CAST(REPLACE(tu.Credit_Limit,'$','') AS FLOAT) <7043 THEN 'Bajo'
        	WHEN CAST(REPLACE(tu.Credit_Limit,'$','') AS FLOAT) <=12593 THEN 'Medio'
        	WHEN CAST(REPLACE(tu.Credit_Limit,'$','') AS FLOAT) <=19157 THEN 'Alto'
        	ELSE 'Premium' 
        END AS Segmento_Credito
    FROM dbo.Transacciones_Tarjetas t
    INNER JOIN dbo.Tarjetas_Usuarios as tu
    ON  t.User_ID = tu.User_ID  
)
SELECT
Segmento_Credito,
COUNT(1) Total_Transactions,
SUM(Fraud_Flag) Cant_Fraud,
ROUND(SUM(Fraud_Flag)*100.00/COUNT(1),4) Fraud_Rate
FROM CTE_BASE
GROUP BY Segmento_Credito
ORDER BY Fraud_Rate DESC
 

