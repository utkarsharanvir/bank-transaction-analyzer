-- Query 1: Monthly spending by category
SELECT 
  strftime('%Y-%m', txn_date) AS month,
  category,
  SUM(amount) AS total_spent,
  COUNT(*) AS num_transactions
FROM transactions
WHERE txn_type = 'debit'
GROUP BY month, category
ORDER BY month, total_spent DESC;

-- Query 2: Top 5 customers by total balance
SELECT 
  c.name,
  c.city,
  SUM(a.balance) AS total_balance
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
GROUP BY c.name, c.city
ORDER BY total_balance DESC
LIMIT 5;

-- Query 3: Anomaly detection - high value transactions
SELECT 
  txn_id,
  account_id,
  amount,
  txn_date,
  category
FROM transactions
WHERE amount > (
  SELECT AVG(amount) * 1.5
  FROM transactions
)
ORDER BY amount DESC;

-- Query 4: Running balance per account (window function)
SELECT 
  t.account_id,
  t.txn_date,
  t.amount,
  t.txn_type,
  t.category,
  SUM(CASE WHEN t.txn_type='credit' THEN t.amount ELSE -t.amount END)
    OVER (PARTITION BY t.account_id ORDER BY t.txn_date) AS running_balance
FROM transactions t
ORDER BY t.account_id, t.txn_date;

-- Query 5: Category wise spending per customer
SELECT 
  c.name,
  t.category,
  COUNT(*) AS num_transactions,
  ROUND(SUM(t.amount), 2) AS total_amount
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id
WHERE t.txn_type = 'debit'
GROUP BY c.name, t.category
ORDER BY c.name, total_amount DESC;

-- Query 6: Most active accounts
SELECT 
  a.account_id,
  a.account_type,
  c.name,
  c.city,
  COUNT(t.txn_id) AS total_transactions,
  ROUND(SUM(t.amount), 2) AS total_volume
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id
GROUP BY a.account_id, a.account_type, c.name, c.city
ORDER BY total_transactions DESC
LIMIT 10;

-- Query 7: Credit vs Debit summary by city
SELECT 
  c.city,
  t.txn_type,
  COUNT(*) AS num_transactions,
  ROUND(SUM(t.amount), 2) AS total_amount,
  ROUND(AVG(t.amount), 2) AS avg_transaction
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id
GROUP BY c.city, t.txn_type
ORDER BY c.city, t.txn_type;

-- Query 8: Monthly transaction volume trend
SELECT 
  strftime('%Y-%m', txn_date) AS month,
  COUNT(*) AS num_transactions,
  ROUND(SUM(CASE WHEN txn_type='credit' THEN amount ELSE 0 END), 2) AS total_credits,
  ROUND(SUM(CASE WHEN txn_type='debit' THEN amount ELSE 0 END), 2) AS total_debits,
  ROUND(SUM(CASE WHEN txn_type='credit' THEN amount ELSE -amount END), 2) AS net_flow
FROM transactions
GROUP BY month
ORDER BY month;
