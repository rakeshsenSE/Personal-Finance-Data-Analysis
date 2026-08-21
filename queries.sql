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

