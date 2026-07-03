![Data Analytics](Picture\banner.jpg)
<h1 align="left">
📊 Credit Card Fraud Analysis
</h1>

<p align="left">
Análisis exploratorio de transacciones con tarjetas de crédito utilizando SQL Server para identificar patrones de fraude y generar insights de negocio.
</p>

<p align="left">
  <a href="https://www.linkedin.com/in/diego-andres-gamero-cotrina-787511271/">
    <img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white" alt="LinkedIn">
  </a>
  <a href="https://github.com/diegogameroc">
    <img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white" alt="GitHub">
  </a>
</p>

---

# 📖 Resumen

Este proyecto analiza un conjunto de datos de transacciones con tarjetas de crédito con el objetivo de identificar patrones asociados al fraude. Se realizó un proceso de limpieza, validación y análisis exploratorio mediante SQL Server, utilizando consultas avanzadas, CTEs, funciones de ventana y JOINs para responder preguntas de negocio relacionadas con el riesgo financiero.

---

# 🎯 Objetivos

- Analizar el comportamiento de las transacciones fraudulentas.
- Identificar perfiles de usuarios con mayor riesgo.
- Evaluar el impacto del uso del chip en el fraude.
- Analizar el comportamiento por marca y tipo de tarjeta.
- Obtener insights que apoyen la toma de decisiones.

---

# 🛠 Herramientas utilizadas

<p align="center">

<img src="https://img.shields.io/badge/SQL_Server-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white">

<img src="https://img.shields.io/badge/T--SQL-336791?style=for-the-badge">

<img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github">

<img src="https://img.shields.io/badge/DBeaver-372923?style=for-the-badge&logo=dbeaver&logoColor=white">


</p>

---

## 📂 Estructura del Proyecto

- [📁 Sobre los Datos](#-sobre-los-datos)
- [🏗️ Fase 1: Preparación y Calidad de los Datos](#️-fase-1-preparación-y-calidad-de-los-datos)
- [📊 Fase 2: Análisis Exploratorio de Datos (EDA)](#-fase-2-análisis-exploratorio-de-datos-eda)
- [🚨 Fase 3: Análisis del Riesgo de Fraude](#-fase-3-análisis-del-riesgo-de-fraude)
- [💡 Hallazgos Principales](#-hallazgos-principales)
- [📈 Recomendaciones](#-recomendaciones)
- [🚀 Próximos Pasos](#-próximos-pasos)
- [🛠️ Tecnologías Utilizadas](#️-tecnologías-utilizadas)
- [📌 Conclusión](#-conclusión)

---

## 📖 Resumen

Este proyecto analiza un conjunto de datos de transacciones con tarjetas de crédito con el objetivo de identificar patrones asociados al fraude mediante técnicas de análisis de datos utilizando SQL Server. Se desarrolló un proceso de preparación, limpieza y exploración de datos para responder preguntas de negocio relacionadas con el riesgo financiero y el comportamiento de usuarios, tarjetas y transacciones.

---

## 🎯 Objetivo del Proyecto

Identificar patrones asociados al fraude en transacciones con tarjetas de crédito mediante el análisis exploratorio de datos y consultas avanzadas en SQL, generando información que apoye la toma de decisiones en la gestión del riesgo.

---

## 📁 Sobre los Datos

El proyecto utiliza un conjunto de datos de transacciones con tarjetas de crédito obtenido de Kaggle. El dataset original puede consultarse [aquí](https://www.kaggle.com/datasets/ealtman2019/credit-card-transactions).

**Tablas utilizadas:**

- **Datos_Usuarios:** información demográfica y financiera de los usuarios.
- **Tarjetas_Usuarios:** información de las tarjetas de crédito asociadas a cada usuario.
- **Transacciones_Tarjetas:** historial de transacciones, comercios y eventos de fraude.

En conjunto, estas tablas permiten analizar el comportamiento financiero de los usuarios, las características de sus tarjetas y los factores asociados a las transacciones fraudulentas.

### 👤 Datos_Usuarios

Contiene la información demográfica y financiera de cada usuario.

| Columna | Descripción |
|----------|-------------|
| User_ID | Identificador único del usuario. |
| Person | Nombre del usuario. |
| Current Age | Edad actual. |
| Retirement Age | Edad estimada de jubilación. |
| Birth Year / Birth Month | Año y mes de nacimiento. |
| Gender | Género. |
| Address, Apartment | Dirección del usuario. |
| City, State, Zipcode | Ubicación geográfica. |
| Latitude / Longitude | Coordenadas geográficas. |
| Per Capita Income - Zipcode | Ingreso per cápita del código postal. |
| Yearly Income - Person | Ingreso anual del usuario. |
| Total Debt | Deuda total del usuario. |
| FICO Score | Puntaje crediticio del usuario. |
| Num Credit Cards | Número de tarjetas de crédito registradas. |

---

### 💳 Tarjetas_Usuarios

Contiene la información de las tarjetas de crédito asociadas a cada usuario.

| Columna | Descripción |
|----------|-------------|
| User_ID | Identificador del usuario propietario de la tarjeta. |
| Card Index | Identificador de la tarjeta del usuario. |
| Card Brand | Marca de la tarjeta (Visa, Mastercard, etc.). |
| Card Type | Tipo de tarjeta (Crédito, Débito, etc.). |
| Card Number | Número de la tarjeta. |
| Expires | Fecha de vencimiento. |
| CVV | Código de seguridad. |
| Has Chip | Indica si la tarjeta posee chip. |
| Cards Issued | Número de tarjetas emitidas. |
| Credit Limit | Límite de crédito. |
| Acct Open Date | Fecha de apertura de la cuenta. |
| Year PIN Last Changed | Último año de cambio del PIN. |
| Card on Dark Web | Indica si la tarjeta ha sido encontrada en la Dark Web. |

---

### 💰 Transacciones_Tarjetas

Registra el historial de transacciones realizadas con las tarjetas.

| Columna | Descripción |
|----------|-------------|
| User_ID | Usuario que realizó la transacción. |
| Card | Tarjeta utilizada. |
| Year, Month, Day | Fecha de la transacción. |
| Time | Hora de la transacción. |
| Amount | Monto de la compra. |
| Use Chip | Método de pago utilizado (chip, banda, etc.). |
| Merchant Name | Identificador del comercio. |
| Merchant City | Ciudad del comercio. |
| Merchant State | Estado del comercio. |
| Zip | Código postal del comercio. |
| MCC | Merchant Category Code. |
| Errors | Error ocurrido durante la transacción, si existe. |
| Is Fraud | Indica si la transacción fue fraudulenta. |

---

### 🔗 Relación entre las tablas

![DiagramaER](Picture\DiagramaER.png)

# 🏗️ Fase 1: Preparación y Calidad de los Datos

Antes de realizar el análisis exploratorio, se preparó la base de datos para garantizar la integridad y consistencia de la información. Esta etapa incluyó la creación de las tablas, la importación de los datos y la validación de posibles problemas de calidad.

## Actividades realizadas

- Creación de la base de datos `Credit_Card`.
- Diseño de las tablas `Datos_Usuarios`, `Tarjetas_Usuarios` y `Transacciones_Tarjetas`.
- Importación de los archivos CSV mediante `BULK INSERT`.
- Limpieza de caracteres especiales en la columna `Errors`.
- Conversión de campos monetarios (`Amount`, `Credit_Limit`, `Total_Debt`, `Yearly_Income_Person`) para facilitar su análisis.
- Validación de registros duplicados en usuarios y tarjetas.
- Definición de las relaciones entre las tablas mediante el identificador `User_ID`.

## Validaciones realizadas

✔️ Verificación de usuarios duplicados.

✔️ Verificación de tarjetas duplicadas.

✔️ Revisión de valores nulos e inconsistentes.

✔️ Comprobación de la correcta carga de los registros.

## Resultado

Como resultado de esta fase, se obtuvo una base de datos consistente y preparada para el análisis exploratorio, garantizando que las consultas posteriores se realizaran sobre información limpia y estructurada.

# 📊 Fase 2: Análisis Exploratorio de Datos (EDA)

### 📌 Fórmula utilizada

La principal métrica del proyecto es la **Tasa de Fraude (Fraud Rate)**.

```text
Fraud Rate (%) =
(Transacciones Fraudulentas / Total de Transacciones) × 100
```

En SQL, esta métrica se calcula utilizando agregaciones y expresiones `CASE WHEN`, permitiendo obtener la tasa de fraude para diferentes segmentos de usuarios, tarjetas y transacciones.
# 📈 KPIs del Proyecto

Para evaluar los factores asociados al fraude en transacciones con tarjetas de crédito, se definieron los siguientes indicadores clave de desempeño (KPIs):

| KPI | Descripción | Objetivo |
|------|-------------|----------|
| **Fraud Rate** | Porcentaje de transacciones fraudulentas sobre el total de transacciones. | Medir la incidencia general del fraude. |
| **Fraud Rate por FICO Score** | Tasa de fraude según el segmento de puntaje crediticio del usuario. | Analizar si el riesgo crediticio está asociado al fraude. |
| **Fraud Rate por Límite de Crédito** | Tasa de fraude por rango de límite de crédito. | Identificar si usuarios con mayor capacidad crediticia presentan mayor exposición al fraude. |
| **Fraud Rate por Uso de Chip** | Comparación de la tasa de fraude entre transacciones realizadas con y sin chip. | Evaluar el impacto del uso del chip como mecanismo de seguridad. |
| **Fraud Rate por Estado** | Tasa de fraude por estado de residencia del usuario. | Detectar zonas geográficas con mayor incidencia de fraude. |
| **Fraud Rate por Número de Tarjetas** | Tasa de fraude según la cantidad de tarjetas asociadas al usuario. | Analizar si el número de tarjetas influye en el riesgo de fraude. |
| **Fraud Rate por Errores de Transacción** | Tasa de fraude en transacciones con y sin errores registrados. | Evaluar si los errores técnicos están relacionados con actividades fraudulentas. |
| **Top Comercios con Mayor Monto Fraudulento** | Ranking de comercios con mayor monto acumulado en transacciones fraudulentas. | Identificar establecimientos con mayor exposición al fraude. |


```sql
SELECT*
FROM
