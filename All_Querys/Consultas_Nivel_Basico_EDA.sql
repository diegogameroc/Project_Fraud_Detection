USE Credit_Card;

-- Volumen total de registros en cada tabla
SELECT 'Transacciones' AS Tabla, COUNT(1) AS Total_Registros FROM dbo.Transacciones_Tarjetas
UNION ALL
SELECT 'Usuarios', COUNT(1) FROM dbo.Datos_Usuarios
UNION ALL
SELECT 'Tarjetas', COUNT(1) FROM dbo.Tarjetas_Usuarios;

-- Rango de fechas que cubre el dataset
SELECT
    MIN(Transaction_Year) AS Anio_Inicio,
    MAX(Transaction_Year) AS Anio_Fin,
    COUNT(DISTINCT Transaction_Year) AS Cantidad_Anios
FROM dbo.Transacciones_Tarjetas;

-- Distribución de usuarios únicos y tarjetas únicas en las transacciones
SELECT
    COUNT(DISTINCT User_ID) AS Usuarios_Unicos,
    COUNT(DISTINCT CONCAT(User_ID,'-',Card)) AS Tarjetas_Unicas
FROM dbo.Transacciones_Tarjetas;

-- Transacciones por año 
SELECT
    Transaction_Year,
    COUNT(1) AS Total_Transactions
FROM dbo.Transacciones_Tarjetas
GROUP BY Transaction_Year
ORDER BY Transaction_Year;

-- Distribución por tipo de transacción (Swipe, Chip, Online)
SELECT
    Use_Chip,
    COUNT(1) AS Total_Transactions,
    ROUND(COUNT(1) * 100.0 / SUM(COUNT(1)) OVER(), 2) AS Porcentaje
FROM dbo.Transacciones_Tarjetas
GROUP BY Use_Chip
ORDER BY Total_Transactions DESC;

-- Top 10 estados con más transacciones 
SELECT TOP 10
    Merchant_State,
    COUNT(1) AS Total_Transactions
FROM dbo.Transacciones_Tarjetas
WHERE Merchant_State IS NOT NULL
GROUP BY Merchant_State
ORDER BY Total_Transactions DESC;

-- Top 10 tipos de comercio (MCC) con más transacciones
SELECT TOP 10
    MCC,
    COUNT(1) AS Total_Transactions
FROM dbo.Transacciones_Tarjetas
GROUP BY MCC
ORDER BY Total_Transactions DESC;


-- Distribución de tarjetas por marca (Visa, Mastercard, Amex, Discover)
	SELECT
	    Card_Brand,
	    COUNT(1) AS Total_Tarjetas,
	    ROUND(COUNT(1) * 100.0 / SUM(COUNT(1)) OVER(), 2) AS Porcentaje
	FROM dbo.Tarjetas_Usuarios
	GROUP BY Card_Brand
	ORDER BY Total_Tarjetas DESC;

-- Distribución de tarjetas por tipo (Crédito, Débito, Prepago)
SELECT
    Card_Type,
    COUNT(1) AS Total_Tarjetas
FROM dbo.Tarjetas_Usuarios
GROUP BY Card_Type
ORDER BY Total_Tarjetas DESC;

