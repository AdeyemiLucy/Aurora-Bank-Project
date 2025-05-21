# AURORA BANK PROJECT

This project is a comprehensive SQL-based data analysis initiative designed to extract insights from the operations and customers of a fictional digital bank. This project explores transaction behaviors, error patterns, customer risk profiles, and potential fraud signals using multiple datasets.

### OBJECTIVES:

* Analyze customer demographics including age, gender, and income. 
* Evaluate spending patterns across merchant categories (MCC) and locations.
* Flag unusually high-value or abnormal transaction behavior for fraud detection.
* Assess customer credit risk using debt-to-income ratio and credit score segmentation.
* Analyze the distribution of debt to identify high-risk customer segments.


### ANALYSIS

### A. Customer Demographics: 
This section explores the demographic composition of Aurora Bank’s customers based on their age, gender, and income levels. Understanding these attributes helps in segmenting users, tailoring financial products, and identifying underserved customer groups.


#### 1. Age Distribution:
Majority of Aurora Bank users fall within the 25–35 age group, with the 46–55 group close behind. Overall, most users are between 18 and 55 years old.
```
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
    ORDER BY Age_group DESC;

```
 <img width="195" alt="image" src="https://github.com/user-attachments/assets/754b209f-5170-4355-82a5-e6e8dc455605" />

 

#### 2. Gender Distribution : The platform has a slightly higher proportion of female users compared to male users.
```
SELECT gender, 
        COUNT(*) AS count,
        ROUND(CAST(100.0 * COUNT(*) AS FLOAT)/ SUM(COUNT(*)) OVER (), 2) AS percentage
FROM Users
GROUP BY gender
ORDER BY [count] DESC;
```
<img width="242" alt="image" src="https://github.com/user-attachments/assets/8131629b-df87-4832-817a-16069f025ac6" />



#### 3. Retirement Status :  The majority of users are not yet retired, indicating an active, working-age customer population.
  
```
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
<img width="242" alt="image" src="https://github.com/user-attachments/assets/4de1c1d0-fe97-483b-9395-a4849bc332d9" />

### B Income Distribution 

- The majority of users (1,399) fall into the middle-income bracket, making up the core of Aurora Bank’s customer base.
- This is followed by upper-middle income earners (543), while only 52 users fall into the high-income bracket, indicating a relatively small affluent segment.
- Low-income earners represent the smallest group, suggesting the bank's services may be underutilized by lower-income demographics.

```
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

```
<img width="364" alt="Income Distribution" src="https://github.com/user-attachments/assets/2a3403f2-c871-42d1-bb81-f175353ec82f" />

#### 2. Gender-Based Income Comparison:
- On average, female users earn slightly more than male users, though the difference is marginal.  The female users also transact more with the bank.
```
SELECT 
  u.gender,
  ROUND(AVG(yearly_income), 2) AS avg_income,
    COUNT(*) AS transaction_count
FROM transactions t
JOIN Users u ON u.id = t.client_id
GROUP BY u.gender
ORDER BY avg_income DESC;
```
<img width="290" alt="image" src="https://github.com/user-attachments/assets/8e3acd0b-97d2-48bb-a795-b7fd042080f9" />



#### 3 Age vs. Average Income:
- The 18–24 age group has the highest average income (48,359), slightly ahead of older working-age groups — possibly reflecting a smaller, high-earning segment.
- Income remains relatively stable across the 25–55 range, with average incomes between 45,700 and 47,200, indicating this as the core earning phase for most users.
- From age 56 onward, a gradual decline is observed, with average income decreasing to 41,724 for users aged 66–75 and further to 35,601 for those 75 and older — likely due to retirement and reduced active income.
  
  ```
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
  ```

<img width="257" alt="image" src="https://github.com/user-attachments/assets/4ec19390-8867-472a-b853-821e44787619" />


  

### B. Spending Patterns
This section analyzes how customers are spending their money both by merchant category (MCC) and by location (city/state). The goal is to identify the most active transaction categories and geographic areas to understand customer behavior, product preferences, and potential revenue-driving segments.



#### 1. Transaction Volume and Spend by Merchant Location (City/State)- Top Spending locations
- Users are geographically distributed across a wide range of cities, with high transaction volumes recorded in major hubs such as Houston, Orlando, Atlanta, San Diego, Seattle, Dallas, and New York.
- Several mid-sized and suburban cities like Yorba Linda, Crown Point, and Williston Park also appear in the top 50, suggesting widespread adoption of the bank’s services beyond just large metropolitan areas.



```
SELECT TOP 50
    merchant_city,
    merchant_state,
    COUNT(*) AS transaction_count,
    ROUND(SUM(amount), 2) AS total_spent
FROM transactions
WHERE merchant_state IS NOT NULL
GROUP BY merchant_city, merchant_state
ORDER BY total_spent DESC;
```
<img width="436" alt="Mcc by location 2" src="https://github.com/user-attachments/assets/b7ef1064-f3fd-4c61-9b02-7cd45550b206" />
<img width="440" alt="Mcc by location 1" src="https://github.com/user-attachments/assets/a50c7e2f-c5a6-4058-adeb-fd1c4d67a9d7" />





#### 2.Transaction Volume and Spend by MCC (Merchant Category Code)
During the spending pattern analysis, it was observed that the mcc_description column contained a mix of multiple categories separated by commas and single-category descriptions that also included commas. Applying STRING_SPLIT() universally caused misclassification by incorrectly splitting descriptive values. To address this, a conditional logic was implemented to apply STRING_SPLIT() only when multiple distinct categories were likely present, while preserving known descriptive phrases. This approach ensured accurate categorization and improved the reliability of the merchant category analysis.


- Insight : The top spending categories among Aurora Bank users include essential and everyday items such as Money Transfers, Grocery Stores, Supermarkets, and Utilities (Electric, Water, Gas, Sanitary services). This indicates that Aurora bank is widely used for both routine expenses and essential payments.
- Drug Stores, Pharmacies, Wholesale Clubs, and Service Stations also feature in the top 10, showing customer preference for spending on health, household supplies, and transportation.




```
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
```
<img width="466" alt="image" src="https://github.com/user-attachments/assets/4d9f0002-e1c9-4fc3-992a-6be46380b70c" />




#### 3 Spending By Income Bracket

- Middle-income earners (20k–50k) contribute the highest total spending, accounting for over 4.1 million, which suggests they form the most economically active customer segment for Aurora Bank.

- Upper-middle income earners (50k–100k) follow closely, spending approximately ₦2.39 million, indicating a strong engagement with higher financial capacity users.

- High-income earners (>100k) contribute significantly less (228k), which may imply lower platform usage or a preference for alternative banking channels.

- Low-income earners (<20k) have the lowest total spend (122k), likely due to limited disposable income or fewer transactions

```
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
```
<img width="318" alt="image" src="https://github.com/user-attachments/assets/5dcefc57-0905-423b-bae7-dd040513d547" />




#### 4. Spendings By Gender and Age-group
Females aged 46–55 recorded the highest total spend, followed by females aged 26–45, indicating that women in these age groups are among the most financially active users on the platform.

Males aged 26–45 and 46–55 also contributed significantly to overall spending, though slightly less than their female counterparts in the same age ranges.

Spending generally decreases with age beyond 55, but users aged 75+ still show considerable activity, with females outspending males in that group.

The youngest age group (18–24) contributes the least to total spend, particularly among males, which may reflect lower income levels, financial dependency, or limited engagement with banking services.

```
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
```










