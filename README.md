# Aurora Bank Project

This project is a comprehensive SQL-based data analysis initiative designed to extract insights from the operations and customers of a fictional digital bank. This project explores transaction behaviors, error patterns, customer risk profiles, and potential fraud signals using multiple datasets.

## Objectives

* Analyze customer demographics including age, gender, and income. 
* Evaluate spending patterns across merchant categories (MCC) and locations.
* Flag unusually high-value or abnormal transaction behavior for fraud detection.
* Assess customer credit risk using debt-to-income ratio and credit score segmentation.
* Analyze the distribution of debt to identify high-risk customer segments.<br>

---

## Data Description 

The project was built using four well-structured CSV files representing different aspects of a fictional digital bank:

* `users_data.csv` – Contains user demographics, income, debt, and credit scores
* `transactions.csv` – Includes transaction history, merchant info, and error logs
* `cards_data.csv` – Information about the cards issued to users
* `mcc_codes.csv` – Merchant category codes and their descriptions

These datasets were imported into **Microsoft SQL Server**. During import, primary keys were set () and foreign keys were properly linked to maintain referential integrity:

* `transactions.client_id` → `users_data.id`
* `transactions.card_id` → `cards_data.card_id`
* `transactions.mcc` → `mcc_codes.mcc_id`

#### Query 
```
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

```

### Data Cleaning

The data was clean and well-formatted, so no additional cleaning or preprocessing was required. Column data types were reviewed and assigned appropriately (e.g., `INT` for IDs, `DECIMAL` for monetary values, `VARCHAR` for categorical fields). Some minor adjustments were made to ensure compatibility during foreign key creation, but no missing or duplicate values were detected.


---
## Analysis

### A. Customer Demographics: 
This section explores the demographic composition of Aurora Bank’s customers based on their age, gender, and income levels. Understanding these attributes helps in segmenting users, tailoring financial products, and identifying underserved customer groups.


#### 1. Age Distribution:
Majority of Aurora Bank users fall within the 25–35 age group, with the 46–55 group close behind. Overall, most users are between 18 and 55 years of age.
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

#### 1. Inconme- based Classification
- The majority of users (1,399) fall into the middle-income bracket, making up the core of Aurora Bank’s customer base.
- This is followed by upper-middle income earners (543), while only 52 users fall into the high-income bracket, indicating a relatively small affluent segment.
- Low-income earners also represent another small group, suggesting the bank's services may be underutilized by lower-income demographics.

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
- The 18–24 age group has the highest average income (48,359), slightly ahead of older working-age groups, possibly reflecting a smaller, high-earning segment.
- Income remains relatively stable across the 25–55 range, with average incomes between 45,700 and 47,200 indicating this as the core earning phase for most users.
- From age 56 onward, a gradual decline is observed, with average income decreasing to 41,724 for users aged 66–75 and further to 35,601 for those 75 and older likely due to retirement and reduced active income.
  
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
The insights derived include;

-  The top spending categories among Aurora Bank users include essential and everyday items such as Money Transfers, Grocery Stores, Supermarkets, and Utilities (Electric, Water, Gas, Sanitary services). This indicates that Aurora bank is widely used for both routine expenses and essential payments.
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




#### 3. Spending By Income Bracket

- Middle-income earners (20k–50k) contribute the highest total spending, accounting for over 4.1 million, which suggests they form the most economically active customer segment for Aurora Bank.

- Upper-middle income earners (50k–100k) follow closely, spending approximately 2.39 million, indicating a strong engagement with higher financial capacity users.

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
<img width="263" alt="image" src="https://github.com/user-attachments/assets/3e3578eb-f8e2-4d62-adac-cf54870c031d" />



### C. Credit and Debit level Analysis

#### 1. Credit Score Analysis 

- The majority of users fall into the Good credit score category, accounting for 46.55% of the total user base. This indicates that nearly half of the customers maintain a solid credit profile.

- Very Good and Fair categories follow, with 23.7% and 17.4% respectively, suggesting that a large portion of users are financially stable but may have minor credit limitations.

- Only 8.3% of users have Excellent credit scores, indicating that a small segment maintains top-tier creditworthiness.

- The Poor credit group represents just 4.05% of users, which may include new users, users with repayment issues, or limited credit history.

```
ELECT
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
```
<img width="284" alt="image" src="https://github.com/user-attachments/assets/427b8cc9-97a4-4501-8631-f858d06db130" />


### 2 Debt to Income Ratio (DTI)
The DTI distribution is heavily skewed toward high and very high risk, suggesting that a large portion of users may be over-leveraged. This insight highlights the need for credit risk management, possible loan restructuring, or targeted financial education programs to support long-term sustainability and reduce default exposure.

```
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
```

<img width="212" alt="image" src="https://github.com/user-attachments/assets/ab45677f-ccbc-4c18-bf4d-6e6a9192a6db" />




#### 3.  Users with Highest Debt-to-Income Ratios

```
SELECT TOP 100
  id AS client_id,
  total_debt,
  yearly_income,
  ROUND(CAST(total_debt AS FLOAT) / NULLIF(yearly_income, 0), 2) AS dti_ratio
FROM Users
WHERE yearly_income > 0
ORDER BY dti_ratio DESC;
```
<img width="362" alt="image" src="https://github.com/user-attachments/assets/e16c576b-2e61-424c-9db6-6d76af975448" />
<img width="371" alt="image" src="https://github.com/user-attachments/assets/7cf0d8b8-6266-44cb-97f1-e4ec5fb6870a" />
<img width="365" alt="image" src="https://github.com/user-attachments/assets/3b2273bc-6fa9-4a07-a7a7-ffda33d9e7fe" />
<img width="372" alt="image" src="https://github.com/user-attachments/assets/c34b23f2-e7b7-4dd7-9f19-95a2ab3346d3" />


#### 4 Credit Risk Classification 
A classification system was implemented to assess user credit risk by combining their debt-to-income (DTI) ratios with credit score categories. Users were grouped into risk classes—Low, Moderate, High, or Very High—based on how much of their income is consumed by debt and the quality of their credit history. This dual-metric approach provides a more accurate assessment of financial risk and supports better decision-making for lending, fraud prevention, and customer management.

```
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

```
<img width="476" alt="image" src="https://github.com/user-attachments/assets/8fc0dd9b-ea10-47b0-bcc6-22de30aedd7c" />
<img width="470" alt="image" src="https://github.com/user-attachments/assets/37b832a2-f59d-477e-913e-bf3742a3b7cb" />



### Recommendations
- Implement Credit Risk Monitoring: The large number of users with very high debt-to-income (DTI) ratios suggests the need for more rigorous credit risk management. Regular monitoring and credit education programs could help reduce default risk.

- Develop Targeted Financial Products: Middle and upper-middle income users represent the most financially active segments. Tailored savings, credit, or investment products can be developed to meet their needs and deepen engagement.

- Support Younger Users: Many young users (18–35) have high debt loads relative to income. Initiatives such as budgeting tools, financial literacy campaigns, or early-career credit support programs could help improve their financial stability.

- Expand Services for Female Customers: Female users consistently spend more and appear across all income levels. Customized offerings or engagement campaigns could further boost retention and satisfaction among this segment.

- Review MCC Categorization: Merchant categories with multiple comma-separated labels caused inconsistency in reporting. A standardized MCC taxonomy or data preprocessing pipeline should be implemented for cleaner analysis going forward.

### Conclusion
This project showcased the practical application of SQL in analyzing financial and customer data within a banking context. It demonstrated the ability to extract meaningful insights from structured datasets—ranging from spending behavior to credit and debt analysis while reinforcing core data analysis and relational database skills. The outcome highlights how data can inform strategic decision-making and risk management in the financial industry.








  ---
  
*Hi, I’m Lucy,  a passionate data analyst always looking to uncover insights that drive better decisions.*

*I'm open to opportunities in data analytics and would love to connect or collaborate!*
*Feel free to reach out to me on* [LinkedIn](www.linkedin.com/in/adeyemilucy)    or    [X](https://x.com/mamazfavourite)







