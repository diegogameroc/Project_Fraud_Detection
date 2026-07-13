SELECT*
FROM dbo.Datos_Usuarios

SELECT*
FROM dbo.Tarjetas_Usuarios

SELECT TOP 1000 *
FROM dbo.Transacciones_Tarjetas

SELECT 
ERRORS,
count(1) as cant
FROM Transacciones_Tarjetas
WHERE Errors is not null
group by errors
ORDER BY cant DESC

--Data cleaning

--Verificar si existe algún usuario duplicado

	SELECT
	Person,
	COUNT(1)
	FROM dbo.Datos_Usuarios
	group by Person
	HAVING COUNT(1) > 1;
	

	SELECT
	User_ID,
	Person,
	Current_Age,
	Address,
	City
	FROM Datos_Usuarios
	WHERE PERSON IN (
		SELECT Person
		    FROM Datos_Usuarios
		    GROUP BY Person
		    HAVING COUNT(1) > 1
	)
	
	--Conclusión: se tratan de personas con nombres homónimos , más no de duplicados

		
-- Verificar si hay tarjeta duplicadas
SELECT 
    Card_Number,
    COUNT(1) AS Cantidad_Repeticiones
FROM Tarjetas_Usuarios
GROUP BY Card_Number
HAVING COUNT(*) > 1;
	
--Conclusión: No encontramos duplicados de numeros de tarjetas


SELECT
Card_Brand,
ROUND(AVG(CAST(REPLACE(Credit_Limit, '$', '') AS FLOAT)),2) AS PROMEDIO_LIMITE_CREDITO
FROM dbo.Tarjetas_Usuarios
GROUP BY Card_Brand
ORDER BY  PROMEDIO_LIMITE_CREDITO DESC


--2. Proporción de Tarjetas de Crédito vs. Débito


SELECT
Card_Type,
COUNT(1) AS CANTIDAD,
--SUM(COUNT(1)) OVER() AS SUMA_TOTAL,
ROUND((COUNT(1))*100.00/ (SUM(COUNT(1)) OVER()),2) AS '% PORCENTAJE'
FROM dbo.Tarjetas_Usuarios
GROUP BY Card_Type
ORDER BY CANTIDAD DESC


--3. Impacto del FICO Score en la Deuda (Usando CTE)


WITH CTE_CLASIFICACION AS (
SELECT
PERSON,
FICO_Score,
CAST(REPLACE(Total_Debt,'$','') AS FLOAT) AS Deuda_Total,
CASE
	WHEN FICO_Score<650 THEN 'Riesgo Alto'
	WHEN FICO_Score<=750  THEN 'Riesgo Medio'
	ELSE 'Riesgo Bajo'
	END AS SEGMENTO_RIESGO
FROM dbo.Datos_Usuarios
)
SELECT 
SEGMENTO_RIESGO, 
ROUND(AVG(Deuda_Total),2) PROMEDIO_DEUDA_SEGMENTO_RIESGO
FROM CTE_CLASIFICACION
GROUP BY SEGMENTO_RIESGO
ORDER BY PROMEDIO_DEUDA_SEGMENTO_RIESGO DESC;

--4. Análisis de Fraude y Uso de Chip

SELECT*
FROM dbo.Tarjetas_Usuarios

SELECT TOP 3 *
FROM dbo.Transacciones_Tarjetas

	SELECT 
	Use_Chip,
	ROUND((COUNT(1))*100.00/ (SUM(COUNT(1)) OVER()),2) '% porcentaje'
	FROM dbo.Transacciones_Tarjetas
	WHERE Is_Fraud= 'Yes'
	GROUP BY Use_Chip
	ORDER BY ROUND((COUNT(1))*100.00/ (SUM(COUNT(1)) OVER()),2) DESC


--5. Ranking de Estados por Fraude y Marca (Usando Funciones de Ventana)
	
SELECT*
FROM dbo.Datos_Usuarios

SELECT*
FROM dbo.Tarjetas_Usuarios

SELECT TOP 1000 *
FROM dbo.Transacciones_Tarjetas
	
WITH CTE_RNK AS (
SELECT 
usuario.State,
tarjeta.card_brand, 
ROUND(SUM(CAST(REPLACE(trx.Amount,'$','') AS FLOAT)),2) AS Monto_Total_Fraude,
RANK() OVER(PARTITION BY card_brand ORDER BY SUM(CAST(REPLACE(trx.Amount,'$','') AS FLOAT)) DESC) RANKING
FROM dbo.Datos_Usuarios AS usuario
INNER JOIN dbo.Tarjetas_Usuarios AS tarjeta
ON usuario.User_ID=tarjeta.User_ID
INNER JOIN dbo.Transacciones_Tarjetas AS trx
on tarjeta.User_ID = trx.User_ID AND tarjeta.Card_Index=trx.Card
WHERE trx.Is_Fraud ='Yes'
GROUP BY usuario.State,tarjeta.card_brand
)
SELECT *
FROM CTE_RNK
WHERE RANKING<=3
ORDER BY card_brand,RANKING

--6. Relación entre Edad y Número de Tarjetas

SELECT*
FROM dbo.Datos_Usuarios

WITH CTE_Edad as (
SELECT
usuario.User_ID,
usuario.Current_Age,
COUNT(tarjeta.Card_Index) AS CANTIDAD
FROM dbo.Datos_Usuarios as usuario
INNER JOIN  dbo.Tarjetas_Usuarios as tarjeta
ON usuario.User_ID=tarjeta.User_ID
GROUP BY usuario.Current_Age,usuario.User_ID
)

SELECT
Current_Age,
ROUND(AVG(CAST(CANTIDAD AS FLOAT)),2) as promedio_tarjeta
FROM CTE_Edad
GROUP BY Current_Age
ORDER BY Current_Age ASC


--7. Top 3 Transacciones Legítimas por Usuario 



WITH RNK_TRX AS(
SELECT  
User_ID,
ROUND(CAST(REPLACE(Amount,'$','') AS FLOAT),2) AS Monto,
ROW_NUMBER() OVER(PARTITION BY User_ID ORDER BY ROUND(CAST(REPLACE(Amount,'$','') AS FLOAT),2) DESC ) AS RNK
FROM dbo.Transacciones_Tarjetas
WHERE Is_Fraud='No'
)

SELECT*
FROM RNK_TRX
WHERE RNK <=3 AND Monto>0
ORDER BY User_ID, RNK 

--8. Categorización de Montos y Frecuencia de Errores (Usando CTE)


WITH CTE_CLASIFICACION AS(
SELECT
Errors,
ROUND(CAST(REPLACE(Amount,'$','') AS FLOAT),2) AS Monto,
CASE
	WHEN ROUND(CAST(REPLACE(Amount,'$','') AS FLOAT),2) <10 THEN 'Micro-gasto'
	WHEN ROUND(CAST(REPLACE(Amount,'$','') AS FLOAT),2) <=100 THEN 'Gasto Diario'
	ELSE 'Gasto Fuerte'
END AS Categoria_Gasto
FROM dbo.Transacciones_Tarjetas
)

SELECT 
    Categoria_Gasto,
    COUNT(Errors) AS Transacciones_Con_Error,
    COUNT(1) AS Total_Transacciones_Del_Grupo,
    ROUND(COUNT(Errors) * 100.0 / COUNT(1), 2) AS Porcentaje_Error
FROM CTE_CLASIFICACION
GROUP BY Categoria_Gasto
ORDER BY Porcentaje_Error DESC;


--9. Antigüedad de la Cuenta vs Límite de Crédito

SELECT*
FROM dbo.Tarjetas_Usuarios

SELECT
RIGHT(Acct_Open_Date, 4) AS Year_Apertura,
ROUND(AVG(CAST(REPLACE(Credit_Limit,'$','') AS FLOAT)),2) Promedio_Limite
FROM dbo.Tarjetas_Usuarios
GROUP BY RIGHT(Acct_Open_Date, 4)
ORDER BY Year_Apertura ASC;





