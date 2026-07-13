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
HAVING COUNT(1) >= 50000
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
    AND t.Card = tu.Card_Index
)
SELECT
Segmento_Credito,
COUNT(1) Total_Transactions,
SUM(Fraud_Flag) Cant_Fraud,
ROUND(SUM(Fraud_Flag)*100.00/COUNT(1),4) Fraud_Rate
FROM CTE_BASE
GROUP BY Segmento_Credito
ORDER BY Fraud_Rate DESC

--8. ¿Las transacciones que presentan errores tienen una mayor tasa de fraude que las que no presentan errores?

USE Credit_Card

SELECT TOP 5 *
FROM dbo.Transacciones_Tarjetas


WITH CTE_BASE AS (
    SELECT
    	Errors,
        CASE 
            WHEN Is_Fraud = 'Yes' THEN 1
            ELSE 0
        END AS Fraud_Flag
    FROM dbo.Transacciones_Tarjetas
)

SELECT 
Errors,
COUNT(1) AS Total_Transactions,
SUM(Fraud_Flag) AS Cant_Fraud,
ROUND(SUM(Fraud_Flag)*100.00/COUNT(1),4) AS Fraud_Rate
FROM CTE_BASE
WHERE Errors is not NULL 
GROUP BY Errors
HAVING COUNT(1)>1000
ORDER BY Fraud_Rate DESC


--9. ¿Cómo varía la tasa de fraude según el número de tarjetas que posee un usuario?

WITH CTE_BASE AS (
    SELECT
        CASE
            WHEN us.Num_Credit_Cards >= 6 THEN '6+ Tarjetas'
            WHEN us.Num_Credit_Cards = 5 THEN '5 Tarjetas'
            WHEN us.Num_Credit_Cards = 4 THEN '4 Tarjetas'
            WHEN us.Num_Credit_Cards = 3 THEN '3 Tarjetas'
            WHEN us.Num_Credit_Cards = 2 THEN '2 Tarjetas'
            ELSE '1 Tarjeta'
        END AS Segmento_Tarjetas,
        
        CASE
            WHEN t.Is_Fraud = 'Yes' THEN 1
            ELSE 0
        END AS Fraud_Flag
        
    FROM dbo.Transacciones_Tarjetas AS t
    INNER JOIN dbo.Datos_Usuarios AS us
        ON t.User_ID = us.User_ID
)

SELECT
    Segmento_Tarjetas,
    COUNT(*) AS Total_Transactions,
    SUM(Fraud_Flag) AS Cant_Fraud,
    ROUND(SUM(Fraud_Flag) * 100.0 / COUNT(*), 4) AS Fraud_Rate
FROM CTE_BASE
GROUP BY Segmento_Tarjetas
ORDER BY Fraud_Rate DESC


-----------Detector de fraude con Flags
WITH CTE_Flags AS (
    SELECT
        t.User_ID,
        t.Card,
        t.Amount,
        t.Use_Chip,
        t.Errors,
        t.MCC,
        t.Is_Fraud,
        tu.Credit_Limit,
        us.Num_Credit_Cards,

        CASE WHEN t.Use_Chip = 'Online Transaction' THEN 1 ELSE 0 END AS Flag_Online,
        CASE WHEN ROUND(CAST(REPLACE(t.Amount,'$','') AS FLOAT),2) > 600 THEN 1 ELSE 0 END AS Flag_Monto_Alto,
        CASE WHEN t.Errors IN ('Bad CVV','Bad Expiration','Bad Card Number','Bad PIN') THEN 1 ELSE 0 END AS Flag_Error_Critico,
        CASE WHEN CAST(REPLACE(tu.Credit_Limit,'$','') AS FLOAT) < 7043 THEN 1 ELSE 0 END AS Flag_Limite_Bajo,
        CASE WHEN t.MCC IN (5045,5732,5094,5816,5712) THEN 1 ELSE 0 END AS Flag_MCC_Riesgo,
        CASE WHEN us.Num_Credit_Cards >= 5 THEN 1 ELSE 0 END AS Flag_Muchas_Tarjetas

    FROM dbo.Transacciones_Tarjetas t
    INNER JOIN dbo.Tarjetas_Usuarios tu
        ON t.User_ID = tu.User_ID
       AND t.Card = tu.Card_Index
    INNER JOIN dbo.Datos_Usuarios us
        ON t.User_ID = us.User_ID
),

CTE_Score AS (
    SELECT
        *,
        (Flag_Online + Flag_Monto_Alto + Flag_Error_Critico + Flag_Limite_Bajo + Flag_MCC_Riesgo + Flag_Muchas_Tarjetas) AS Risk_Score
    FROM CTE_Flags
)

SELECT
    Risk_Score,
    COUNT(1) AS Total_Transactions,
    SUM(CASE WHEN Is_Fraud = 'Yes' THEN 1 ELSE 0 END) AS Cant_Fraud,
    ROUND(SUM(CASE WHEN Is_Fraud = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(1), 4) AS Fraud_Rate
FROM CTE_Score
GROUP BY Risk_Score
ORDER BY Risk_Score DESC;