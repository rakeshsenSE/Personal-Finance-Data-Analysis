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
        FROM t.transations t
        JOIN categories c 
        ON c.category_id = t.category_id
        WHERE c.transaction_type = 'Expense'
        GROUP BY category
        ORDER BY total_expense DESC
        LIMIT 10;
		
        
-- Q9. How does actual spending compare to the budgeted amount for each category?
-- ANSWER:
	SELECT
		