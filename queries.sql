-- USE finance_db;
-- SELECT * FROM categories;
-- SELECT * FROM accounts;
-- SELECT * FROM transactions;

-- Q1. What is the total income across all accounts?
-- ANSWER:
SELECT ROUND(SUM(ABS(t.amount))) AS total_income 
FROM transactions t
JOIN categories c
ON t.category_id = c.category_id
WHERE transaction_type = 'Income';


-- Q2. What is the total amount of expenses across all accounts?
-- Answer:
SELECT ROUND(SUM(ABS(t.amount))) AS total_income 
FROM transactions t
JOIN categories c
ON t.category_id = c.category_id
WHERE transaction_type = 'Expense';


-- Q3. What is the net savings (total income minus total expenses)?
-- Answer:
SELECT
	ROUND(SUM(CASE WHEN c.transaction_type = 'Income' THEN ABS(t.amount) ELSE 0 END) , 2) AS total_income,
    ROUND(SUM(CASE WHEN c.transaction_type = 'Expense' THEN ABS(t.amount) ELSE 0 END) , 2) AS total_expense,
    ROUND(ABS((SUM(CASE WHEN c.transaction_type = 'Income' THEN ABS(t.amount) ELSE 0 END)- 
	SUM(CASE WHEN c.transaction_type = 'Expense' THEN ABS(t.amount) ELSE 0 END)))) AS net_saving
FROM transactions t 
JOIN categories c
ON t.category_id = c.category_id;


-- Q4. What percentage of income is being saved (savings rate)?
-- ANSWER:
SELECT 
	ROUND(
    (SUM(CASE WHEN c.transaction_type = 'Income' THEN ABS(t.amount) ELSE 0 END)
    - 
    SUM(CASE WHEN c.transaction_type = 'Expense' THEN ABS(t.amount) ELSE 0 END)) * 100
    / 
    NULLIF(SUM(CASE WHEN c.transaction_type = 'Income' THEN ABS(t.amount) ELSE 0 END),0),2)
AS saving_rate_per
FROM transactions t
JOIN categories c 
ON t.category_id = c.category_id;


-- Q5. What is the monthly cash flow (income vs expenses per month)?
-- ANSWER:
	SELECT 
		date_format(t.transaction_date,'%Y - %m') AS month_wise,
		ROUND(SUM(CASE WHEN c.transaction_type = 'Income' THEN ABS(t.amount) ELSE 0 END) , 2) AS income,
        ROUND(SUM(CASE WHEN c.transaction_type = 'Expense' THEN ABS(t.amount) ELSE 0 END) , 2) AS expense,
        ROUND(SUM(CASE WHEN c.transaction_type = 'Income' THEN ABS(t.amount) ELSE - ABS(t.amount) END) , 2 ) AS net_case_flow
        FROM transactions t
        join categories c 
        ON t.category_id = c.category_id
        GROUP BY month_wise
        ORDER BY month_wise;


-- Q6. How much income is coming from each income source/category?
-- ANSWER:
	SELECT  
		c.category_name AS income_source,
        SUM(ABS(t.amount)) AS total_income
	FROM transactions t
	join categories c 
	ON c.category_id = t.category_id
	WHERE c.transaction_type = 'Income'
	GROUP BY income_source
	ORDER BY total_income DESC
	LIMIT 10;
	
-- Q7. How much is being spent in each expense category?
-- ANSWER:
	SELECT 
		c.category_name AS category,
        SUM(ABS(t.amount)) AS total_expenses
	FROM transactions t
	join categories c 
	ON c.category_id = t.category_id
	WHERE c.transaction_type = 'Expense'
	GROUP BY category
	ORDER BY total_expenses DESC
	LIMIT 10;
    
-- Q8. Which expense category has the highest total spending?
-- ANSWER:
	SELECT 
		c.category_name AS category , sum(ABS(t.amount)) AS total_expense
        FROM t.transactions t
        JOIN categories c 
        ON c.category_id = t.category_id
        WHERE c.transaction_type = 'Expense'
        GROUP BY category
        ORDER BY total_expense DESC
        LIMIT 10;
		
        
-- Q9. How does actual spending compare to the budgeted amount for each category?
-- ANSWER:
	WITH monthly AS (
		SELECT c.category_name , date_format(t.transaction_date , '%Y - %m') AS month,
			SUM(ABS(t.amount)) AS spend
		FROM transactions t
        JOIN categories c 
        ON c.category_id = t.category_id
		WHERE c.transaction_type = 'Expense'
        GROUP BY c.category_name , month),
        budget AS (
			SELECT category_name , ROUND(AVG(spend) , 2) AS budget_amount
            FROM monthly 
            GROUP BY category_name),
		lestest_month AS (
			SELECT MAX(month) AS m FROM monthly),
		actual AS(
			SELECT category_name , ROUND(spend, 2) AS actual_amount FROM monthly , lestest_month
		WHERE monthly.month = lestest_month.m)
            
		SELECT b.category_name AS category , b.budget_amount,
		COALESCE(a.actual_amount,0) AS actual_amount,
		(COALESCE(a.actual_amount,0) - b.budget_amount) AS variance 
		FROM budget b
		LEFT JOIN actual a ON b.category_name = a.a.category_name
		ORDER BY variance DESC
		LIMIT 10;
        
-- Q10. What is the average amount spent per day?
-- ANSWER:
	SELECT ROUND(SUM(ABS(t.amount)) * 1.0 / COUNT(DISTINCT t.transaction_date) , 2) 
		AS daily_spending
	FROM transactions t
    JOIN categories c 
    ON t.category_id = c.category_id 
    WHERE transaction_type = 'Expense';
    
-- Q11.What is the trend of total spending month by month?
-- ANSWER:
	SELECT date_format(t.transaction_date , '%y-%m') AS month,
			SUM(ABS(t.amount)) AS total_spent
	FROM transactions t
    JOIN categories c 
    ON t.category_id = c.category_id 
    WHERE transaction_type = 'Expense'
    GROUP BY month 
    ORDER BY month
    LIMIT 12;
    
-- Q12. What is the running account balance after each transaction?
-- ANSWER:
	WITH top_account AS ( 
		SELECT account_id FROM transactions
		GROUP BY account_id ORDER BY COUNT(*) DESC LIMIT 1 )
   SELECT t.transaction_id , t.transaction_date , t.amount , 
    (a.opening_balance + SUM(t.amount) OVER( 
     ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) AS running_balance
     FROM transactions t 
     JOIN accounts a 
     ON t.account_id  = a.account_id
     WHERE t.account_id = (SELECT account_id FROM top_account)
     ORDER BY t.transaction_id , transaction_date LIMIT 10;
     
-- Q13. Which expenses are recurring every month (subscriptions, bills, etc.)?
-- ANSWER:
	SELECT 
		c.category_name AS category,
		COUNT(distinct(date_format(t.transaction_date,'%Y-%m') )) AS month,
        SUM(ABS(t.amount)) AS total_amount ,
        AVG(ABS(t.amount)) as avg_amount
	FROM transactions t 
	JOIN categories c
	ON c.category_id  = c.category_id
	WHERE c.transaction_type = 'Expense'
    GROUP BY c.category_name
    HAVING month >= 6
	ORDER BY month DESC , total_amount DESC LIMIT 10;
     
-- Q14. Is spending higher on weekends or on weekdays?
-- ANSWER:
	SELECT 
		CASE WHEN dayofweek(t.transaction_date) IN (1,7) THEN 'weekend'
        ELSE 'weekday' END AS date_type,
        COUNT(*) AS num_transaction,
        SUM(ABS(t.amount)) AS total_spent,
        ROUND(AVG(ABS(t.amount)) , 2) AS avg_spent
	FROM transactions t
    JOIN categories c 
    ON c.category_id = t.category_id
    WHERE c.transaction_type = 'Expense'
    GROUP BY date_type
    ORDER BY total_spent DESC 
    LIMIT 10;
-- 15. Which are the top 10 largest transactions overall?
-- ANSWER:
	SELECT 
		t.transaction_id , t.transaction_date , a.account_name , c.category_name, ABS(t.amount) AS amount
	FROM transactions t
    JOIN accounts a 
    ON t.account_id = a.account_id
    JOIN categories c 
    ON c.category_id = t.category_id
    ORDER BY amount DESC
    LIMIT 10;
