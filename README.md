# Aurora-Bank-Project

This project is a comprehensive SQL-based data analysis initiative designed to extract insights from the operations and customers of a fictional digital bank. This project explores transaction behaviors, error patterns, customer risk profiles, and potential fraud signals using multiple datasets.

### Objectives:

* Analyze customer demographics including age, gender, and income. 
* Evaluate spending patterns across merchant categories (MCC) and locations.
* Identify high-spending regions and locations prone to transaction failures.
* Monitor transaction error types (e.g., bad PIN, CVV issues) to detect user experience issues.
* Flag unusually high-value or abnormal transaction behavior for fraud detection.
* Assess customer credit risk using debt-to-income ratio and credit score segmentation.
* Analyze the distribution of debt to identify high-risk customer segments.

### Analysis

#### Customer Demographics: 
This section explores the demographic composition of Aurora Bank’s customers based on their age, gender, and income levels. Understanding these attributes helps in segmenting users, tailoring financial products, and identifying underserved customer groups.

```
-- AGE DISTRIBUTION

SELECT 
    CASE
        WHEN current_age BETWEEN 18 AND 24 THEN '18-24'
        WHEN current_age BETWEEN 25 AND 35 THEN '25-35'
        WHEN current_age BETWEEN 26 AND 45 THEN '26-45'
        WHEN current_age BETWEEN 46 AND 55 THEN '46-55'
        WHEN current_age BETWEEN 56 AND 65 THEN '56-55'
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
        WHEN current_age BETWEEN 56 AND 65 THEN '56-55'
        WHEN current_age BETWEEN 66 AND 75 THEN '66-75'
        ELSE '75+'
    END 
    ORDER BY Age_group;


-- GENDER DISTRIBUTION

SELECT
      gender,
      COUNT(*) AS count
FROM Users
GROUP BY gender
ORDER BY [count] DESC;


-- INCOME DISTRIBUTION

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


-- RETIREMENT STATUS

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
```

### Insights

- The majority of Aurora Bank users fall within the 25–35 age group, with the 46–55 group close behind. Overall, most users are between 18 and 55 years old.
- The platform has a noticeably higher proportion of female users compared to male users.
- A substantial number of users are in the middle-income bracket, while the high-income group represents a smaller segment of the customer base.
- The majority of users are not yet retired, indicating an active, working-age customer population.
  

#### Income Distribution

```
WITH Customer_Spending AS (

    SELECT U.id,
            U.yearly_income,
            SUM(T.amount) AS total_amount
    FROM Users AS U
    JOIN Transactions AS T 
    ON U.id = T.client_id
    GROUP BY U.id, U.yearly_income
),
    Income_bracket AS(
        SELECT
            id, 
            yearly_income,
            CASE 
                 WHEN yearly_income < 20000 THEN 'Low income earners (<20K)'
                 WHEN yearly_income BETWEEN 20000 AND 50000 THEN 'Middle income earners(20k-50k)'
                WHEN yearly_income BETWEEN 50000 AND 100000 THEN 'Upper middle income earners'
        ELSE 'High income earners(>100k)'
    END AS Income_category
    FROM Customer_Spending
    )

SELECT 
    Income_category,
    ROUND(AVG(total_amount), 2) AS Avg_spent
FROM Customer_Spending AS CS
JOIN Income_bracket AS IB 
ON CS.id = IB.id
GROUP BY Income_category
ORDER BY Avg_spent DESC;

```
### Spending Patterns
This section analyzes how customers are spending their money both by merchant category (MCC) and by location (city/state). The goal is to identify the most active transaction categories and geographic areas to understand customer behavior, product preferences, and potential revenue-driving segments.


```
--1. Transaction Volume and Spend by Merchant Location (City/State)- Top Spending locations

SELECT TOP 50
    merchant_city,
    merchant_state,
    COUNT(*) AS transaction_count,
    ROUND(SUM(amount), 2) AS total_spent
FROM transactions
WHERE merchant_state IS NOT NULL
GROUP BY merchant_city, merchant_state
ORDER BY total_spent DESC;

-- 2.Transaction Volume and Spend by MCC (Merchant Category Code)
SELECT 
    TRIM(VALUE) AS mcc_description,
    COUNT(*) AS transaction_count,
    ROUND(SUM(t.amount), 2) AS total_spent
FROM transactions AS T
JOIN MCCcodes AS MC
 ON T.mcc = MC.mcc_id
CROSS APPLY STRING_SPLIT(MC.[Description], ',')
GROUP BY TRIM(VALUE)
ORDER BY total_spent DESC;

```

### Insights
- The top spending categories among Aurora Bank users include essential and everyday items such as Money Transfers, Grocery Stores, Supermarkets, and Utilities (Electric, Water, Gas, Sanitary services). This indicates that the platform is widely used for both routine expenses and essential payments.

- Drug Stores, Pharmacies, Wholesale Clubs, and Service Stations also feature in the top 10, showing customer preference for spending on health, household supplies, and transportation.

- Users are geographically distributed across a wide range of cities, with high transaction volumes recorded in major hubs such as Houston, Orlando, Atlanta, San Diego, Seattle, Dallas, and New York.

- Several mid-sized and suburban cities like Yorba Linda, Crown Point, and Williston Park also appear in the top 50, suggesting widespread adoption of the bank’s services beyond just large metropolitan areas.






