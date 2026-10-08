-- DATA INSERT INTO 5 TABLES------------------------------------------------

-- CAMPAIGNS TABLE

INSERT INTO campaigns VALUES
(1, 'Campaign 1', 3.00, 11.00),
(2, 'Campaign 2', 3.00, 11.00),
(3, 'Campaign 3', 3.00, 11.00),
(4, 'Campaign 4', 3.00, 11.00),
(5, 'Campaign 5', 3.00, 11.00),
(6, 'Campaign 6', 3.00, 11.00);

-- CHANNELS TABLE
INSERT INTO channels VALUES
(1, 'Web'),
(2, 'Catalog'),
(3, 'Store');

SELECT * FROM campaigns;

-- -------------------------------------------------------------------------------------------------
-- Imported marketing_db_cleaned.csv data using Table data import wizard 
-- as marketing_staging table into marketing_db
-- -------------------------------------------------------------------------------------------------
SELECT COUNT(*) FROM marketing_staging;

-- CUSTOMERS TABLE
INSERT INTO customers
    (customer_id, year_birth, age_enrolled, education, marital_status,
     income, kidhome, teenhome, dt_customer, recency, complain)
SELECT
     ID, Year_Birth, Age_Enrolled, Education, Marital_Status,
     Income, Kidhome, Teenhome, Dt_Customer, Recency, Complain
FROM marketing_staging;

-- check
SELECT COUNT(*) FROM customers;
SELECT * FROM customers LIMIT 5;


-- RESPONSE TABLE
INSERT INTO responses (customer_id, campaign_id, accepted)
SELECT ID, 1, AcceptedCmp1 FROM marketing_staging
UNION ALL
SELECT ID, 2, AcceptedCmp2 FROM marketing_staging
UNION ALL
SELECT ID, 3, AcceptedCmp3 FROM marketing_staging
UNION ALL
SELECT ID, 4, AcceptedCmp4 FROM marketing_staging
UNION ALL
SELECT ID, 5, AcceptedCmp5 FROM marketing_staging
UNION ALL
SELECT ID, 6, Response FROM marketing_staging;

-- check
SELECT COUNT(*) FROM responses;
SELECT campaign_id, SUM(accepted) AS accepted, COUNT(*) AS contacted
FROM responses
GROUP BY campaign_id;

-- PURCHASE TABLE
INSERT INTO purchases (customer_id, channel_id, num_purchases)
SELECT ID, 1, NumWebPurchases FROM marketing_staging
UNION ALL
SELECT ID, 2, NumCatalogPurchases FROM marketing_staging
UNION ALL
SELECT ID, 3, NumStorePurchases FROM marketing_staging;

-- check
SELECT COUNT(*) FROM purchases;

-- TOTAL SPEND PER CUSTOMER (used by the analysis queries) ------------------
-- Sum of the six product spend columns from the staging table.

ALTER TABLE customers ADD COLUMN total_spend DECIMAL(10,2);

UPDATE customers c
JOIN marketing_staging s ON c.customer_id = s.ID
SET c.total_spend = s.MntWines + s.MntFruits + s.MntMeatProducts
                  + s.MntFishProducts + s.MntSweetProducts + s.MntGoldProds;
