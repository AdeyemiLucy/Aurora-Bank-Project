 /*AURORA BANK PROJECT 
LINKING THE 4 DIFFERENT TABLES */

-- Link Users Table To Cards Table
ALTER TABLE Cards
ADD CONSTRAINT FK_cards_users
FOREIGN KEY (client_id)
REFERENCES Users(id);

-- Link Users Table To Transactions Table
ALTER TABLE Transactions
ADD CONSTRAINT FK_transactions_users
FOREIGN KEY (client_id) REFERENCES Users(id);

-- Link Transaction Table To Cards Table
ALTER TABLE transactions
ADD CONSTRAINT FK_transactions_cards
FOREIGN KEY (card_id) REFERENCES Cards(id);

-- Link To Mcc_Codes Table To Transactions Table
ALTER TABLE Transactions
ADD CONSTRAINT FK_transactions_mcc
FOREIGN KEY (mcc) REFERENCES MCCcodes(mcc_id);


/* UNDERSTANDING CUSTOMER DEMOGRAPHICS

1. AGE DISTRIBUTION */

SELECT 
    CASE
        WHEN current_age BETWEEN 18 AND 24 THEN '18-24'
        WHEN current_age BETWEEN 25 AND 35 THEN '25-35'
        WHEN current_age BETWEEN 26 AND 45 THEN '26-45'
        WHEN current_age BETWEEN 46 AND 55 THEN '46-55'
        WHEN current_age BETWEEN 56 AND 65 THEN '56-65'
        WHEN current_age BETWEEN 66 AND 75 THEN '66-75'
        ELSE '75+'
    END AS Age_group,
COUNT(*) AS age_count
FROM Users
GROUP BY 
      CASE
        WHEN current_age BETWEEN 18 AND 24 THEN '18-24'
        WHEN current_age BETWEEN 25 AND 35 THEN '25-35'
        WHEN current_age BETWEEN 26 AND 45 THEN '26-45'
        WHEN current_age BETWEEN 46 AND 55 THEN '46-55'
        WHEN current_age BETWEEN 56 AND 65 THEN '56-65'
        WHEN current_age BETWEEN 66 AND 75 THEN '66-75'
        ELSE '75+'
    END 
    ORDER BY age_count DESC;


--2 GENDER DISTRIBUTION

SELECT gender, 
        COUNT(*) AS count,
        ROUND(CAST(100.0 * COUNT(*) AS FLOAT)/ SUM(COUNT(*)) OVER (), 2) AS percentage
FROM Users
GROUP BY gender
ORDER BY [count] DESC;

--3 RETIREMENT STATUS
SELECT 
    CASE 
        WHEN current_age >= retirement_age THEN 'Retired'
        ELSE 'Not retired'
        END AS Retirement_status,
        COUNT(*) AS user_count
FROM Users
GROUP BY
    CASE 
        WHEN current_age >= retirement_age THEN 'Retired'
        ELSE 'Not retired'
        END;


/* INCOME DISTRIBUTION

1. INCOME-BASED CLASSIFICATION */

WITH Income_bracket AS (
    SELECT
      id, 
      yearly_income,
      CASE 
        WHEN yearly_income < 20000 THEN 'Low income earners (<20K)'
        WHEN yearly_income BETWEEN 20000 AND 50000 THEN 'Middle income earners(20k-50k)'
        WHEN yearly_income BETWEEN 50000 AND 100000 THEN 'Upper middle income earners'
        ELSE 'High income earners(>100k)'
    END AS Income_category
FROM Users
)

SELECT
      Income_category, 
      COUNT(id) AS Count,
      ROUND(AVG(yearly_income),2) AS Average_income
FROM Income_bracket
GROUP BY Income_category
ORDER BY Count DESC;


--2 GENDER- BASED INCOME COMPARISON

SELECT 
  u.gender,
  ROUND(AVG(yearly_income), 2) AS avg_income,
    COUNT(*) AS transaction_count
FROM transactions t
JOIN Users u ON u.id = t.client_id
GROUP BY u.gender
ORDER BY avg_income DESC;



--3 AGE VS AVERAGE INCOME

WITH age_bracket AS(
    SELECT  
      CASE
          WHEN current_age BETWEEN 18 AND 24 THEN '18-24'
          WHEN current_age BETWEEN 25 AND 35 THEN '25-35'
          WHEN current_age BETWEEN 26 AND 45 THEN '26-45'
          WHEN current_age BETWEEN 46 AND 55 THEN '46-55'
          WHEN current_age BETWEEN 56 AND 65 THEN '56-65'
          WHEN current_age BETWEEN 66 AND 75 THEN '66-75'
          ELSE '75+'
      END AS Age_group,
      yearly_income
     FROM Users
)
SELECT
   Age_group,
   COUNT(*) AS count,
   AVG(yearly_income) AS avg_income
FROM age_bracket
GROUP BY Age_group
ORDER BY avg_income DESC;




/* SPENDING PATTERN AND INCOME DISTRIBUTION 

-- 1. TRANSACTION VOLUME AND SPEND BY MERCHANT LOCATION (City/State)- Top Spending locations */

SELECT TOP 50
    merchant_city,
    merchant_state,
    COUNT(*) AS transaction_count,
    ROUND(SUM(amount), 2) AS total_spent
FROM transactions
WHERE merchant_state IS NOT NULL
GROUP BY merchant_city, merchant_state
ORDER BY total_spent DESC;



--2 TRANSACTION VOLUME AND SPEND BY MCC (Merchant Category Code)

WITH categorized AS (
  SELECT 
    mc.mcc_id,
    mc.[Description],
    LEN(mc.[Description]) - LEN(REPLACE(mc.[Description], ',', '')) AS comma_count
  FROM MCCcodes mc
),
split_or_not AS (
  SELECT 
    t.amount,
    CASE 
      WHEN c.comma_count > 0 AND c.[Description] NOT LIKE '%Utilities%' 
           AND c.[Description] NOT LIKE '%water%' 
        THEN TRIM(value)
      ELSE c.[Description]
    END AS mcc_description
  FROM transactions t
  JOIN categorized c ON t.mcc = c.mcc_id
  OUTER APPLY (
    SELECT value
    FROM STRING_SPLIT(c.[Description], ',')
    WHERE c.comma_count > 0 AND c.[Description] NOT LIKE '%Utilities%' 
  ) AS s
)
SELECT TOP 10
  mcc_description,
  COUNT(*) AS transaction_count,
  ROUND(SUM(amount), 2) AS total_spent
FROM split_or_not
GROUP BY mcc_description
ORDER BY total_spent DESC;





--3 . SPENDING BASED ON INCOME 

SELECT 
     CASE 
          WHEN yearly_income < 20000 THEN 'Low income earners (<20K)'
          WHEN yearly_income BETWEEN 20000 AND 50000 THEN 'Middle income earners(20k-50k)'
         WHEN yearly_income BETWEEN 50000 AND 100000 THEN 'Upper middle income earners(50-100k)'
        ELSE 'High income earners(>100k)'
    END AS Income_category,
  ROUND(SUM(t.amount), 2) AS total_spent
FROM transactions t
JOIN Users u ON t.client_id = u.id
GROUP BY
     CASE 
         WHEN yearly_income < 20000 THEN 'Low income earners (<20K)'
         WHEN yearly_income BETWEEN 20000 AND 50000 THEN 'Middle income earners(20k-50k)'
         WHEN yearly_income BETWEEN 50000 AND 100000 THEN 'Upper middle income earners(50-100k)'
        ELSE 'High income earners(>100k)'
    END
ORDER BY total_spent DESC;




--4. SPENDING BY GENDER AND AGE

WITH income_vs_spend AS(
    SELECT
        U.gender,
        U.yearly_income,
        T.amount,   
    CASE
        WHEN current_age BETWEEN 18 AND 24 THEN '18-24'
        WHEN current_age BETWEEN 25 AND 35 THEN '25-35'
        WHEN current_age BETWEEN 26 AND 45 THEN '26-45'
        WHEN current_age BETWEEN 46 AND 55 THEN '46-55'
        WHEN current_age BETWEEN 56 AND 65 THEN '56-65'
        WHEN current_age BETWEEN 66 AND 75 THEN '66-75'
        ELSE '75+'
    END AS Age_group
FROM Users U
JOIN Transactions T
ON U.id = T.client_id
)
SELECT 
    gender,
    age_group,
    SUM(amount) AS total_spent
FROM income_vs_spend 
GROUP BY gender, age_group 
ORDER BY total_spent DESC;    




/*CREDIT AND DEBIT LEVEL ANALYSIS 

1 CREDIT SCORE ANALYSIS*/


SELECT
    CASE
        WHEN credit_score < 580 THEN 'Poor'
        WHEN credit_score BETWEEN 580 AND 669 THEN 'Fair'
        WHEN credit_score BETWEEN 670 AND 739 THEN 'Good'
        WHEN credit_score BETWEEN 740 AND 799 THEN 'Very good'
        ELSE 'Excellent'
    END AS credit_category,
    COUNT(*) AS Count,
    ROUND(CAST(COUNT(*) AS FLOAT) * 100 / SUM(COUNT(*)) OVER (), 2) AS Percentage
FROM Users
GROUP BY 
        CASE
        WHEN credit_score < 580 THEN 'Poor'
        WHEN credit_score BETWEEN 580 AND 669 THEN 'Fair'
        WHEN credit_score BETWEEN 670 AND 739 THEN 'Good'
        WHEN credit_score BETWEEN 740 AND 799 THEN 'Very good'
        ELSE 'Excellent'
    END
ORDER BY Count DESC;

SELECT
    CASE
        WHEN current_age BETWEEN 18 AND 24 THEN '18-24'
        WHEN current_age BETWEEN 25 AND 35 THEN '25-35'
        WHEN current_age BETWEEN 26 AND 45 THEN '26-45'
        WHEN current_age BETWEEN 46 AND 55 THEN '46-55'
        WHEN current_age BETWEEN 56 AND 65 THEN '56-65'
        WHEN current_age BETWEEN 66 AND 75 THEN '66-75'
        ELSE '75+'
    END AS Age_group,
  AVG(credit_score) AS avg_credit_score
FROM users
GROUP BY
    CASE
        WHEN current_age BETWEEN 18 AND 24 THEN '18-24'
        WHEN current_age BETWEEN 25 AND 35 THEN '25-35'
        WHEN current_age BETWEEN 26 AND 45 THEN '26-45'
        WHEN current_age BETWEEN 46 AND 55 THEN '46-55'
        WHEN current_age BETWEEN 56 AND 65 THEN '56-65'
        WHEN current_age BETWEEN 66 AND 75 THEN '66-75'
        ELSE '75+'
  END;




--2. DEBT TO INCOME RATIO(DTI)

WITH dti_calculation AS (
    SELECT
        id AS client_id,
        gender,
        total_debt,
        yearly_income,
        ROUND(CAST(total_debt AS FLOAT) / NULLIF(yearly_income, 0), 2) AS dti_ratio
    FROM Users
)

SELECT 
    CASE
        WHEN dti_ratio < 0.2 THEN 'Low Risk'
        WHEN dti_ratio BETWEEN 0.2 AND 0.35 THEN 'Moderate Risk'
        WHEN dti_ratio BETWEEN 0.36 AND 0.5 THEN 'High Risk'
        ELSE 'Very High Risk'
    END AS dti_risk_tier,
    COUNT(*) AS user_count
FROM dti_calculation
GROUP BY 
     CASE
        WHEN dti_ratio < 0.2 THEN 'Low Risk'
        WHEN dti_ratio BETWEEN 0.2 AND 0.35 THEN 'Moderate Risk'
        WHEN dti_ratio BETWEEN 0.36 AND 0.5 THEN 'High Risk'
        ELSE 'Very High Risk'
    END
ORDER BY user_count DESC;




--3. USERS WITH THE HIGHES DTI

SELECT TOP 100
  id AS client_id,
  total_debt,
  yearly_income,
  ROUND(CAST(total_debt AS FLOAT) / NULLIF(yearly_income, 0), 2) AS dti_ratio
FROM Users
WHERE yearly_income > 0
ORDER BY dti_ratio DESC;





--4  CREDIT RISK CLASSIFICATION

WITH risk_profile AS (
    SELECT
        id AS client_id,
        ROUND(CAST(total_debt AS FLOAT) / NULLIF(yearly_income, 0), 2) AS dti_ratio,
        credit_score,
       CASE
        WHEN credit_score < 580 THEN 'Poor'
        WHEN credit_score BETWEEN 580 AND 669 THEN 'Fair'
        WHEN credit_score BETWEEN 670 AND 739 THEN 'Good'
        WHEN credit_score BETWEEN 740 AND 799 THEN 'Very good'
        ELSE 'Excellent'
    END AS credit_category
    FROM Users
)
SELECT *,
    CASE 
        WHEN dti_ratio >= 0.5 AND credit_category IN ('Poor', 'Fair') THEN 'High Risk'
        WHEN dti_ratio BETWEEN 0.36 AND 0.49 AND credit_category IN ('Fair', 'Good') THEN 'Moderate Risk'
        ELSE 'Low Risk'
    END AS risk_class
FROM risk_profile
ORDER BY risk_class;


