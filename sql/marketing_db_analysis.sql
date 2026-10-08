SELECT * FROM responses;
SELECT * FROM customers;
SELECT * FROM campaigns;


-- Q1: What is the response rate by campaign?
SELECT c.campaign_id,
       c.campaign_name,
       SUM(r.accepted) AS responders,
       COUNT(*) AS contacted,
       ROUND(SUM(r.accepted) / COUNT(*) * 100, 2) AS response_rate_pct
FROM responses r
JOIN campaigns c ON r.campaign_id = c.campaign_id
GROUP BY c.campaign_id, c.campaign_name
ORDER BY response_rate_pct DESC;

-- Q2. Which campaign generated the most total revenue and highest revenue per responding customer?

SELECT c.campaign_name,
       SUM(r.accepted) * c.revenue_per_response AS total_revenue
FROM responses r
JOIN campaigns c ON r.campaign_id = c.campaign_id
GROUP BY c.campaign_id;

-- Q2b. Which campaign attracted the highest-spending customers?
SELECT r.campaign_id,
       COUNT(*) AS responders,
       ROUND(AVG(c.total_spend), 2) AS avg_spend
FROM responses r
JOIN customers c ON r.customer_id = c.customer_id
WHERE r.accepted = 1
GROUP BY r.campaign_id
ORDER BY avg_spend DESC;

-- Q3. What percentage of campaign responders were recently active?
-- considered 30-day activity rate

SELECT r.campaign_id,
       COUNT(*) AS responders,
       SUM(c.recency <= 30) AS active_30d,
       ROUND(SUM(c.recency <= 30) / COUNT(*) * 100, 2) AS activity_rate_pct
FROM responses r
JOIN customers c ON r.customer_id = c.customer_id
WHERE r.accepted = 1
GROUP BY r.campaign_id
ORDER BY activity_rate_pct DESC;


-- Q4. Which customer demographics (age group) responded best to each campaign?

SELECT MIN(age_enrolled), MAX(age_enrolled) FROM customers;
SELECT CASE
           WHEN c.age_enrolled < 30 THEN 'Under 30'
           WHEN c.age_enrolled BETWEEN 30 AND 44 THEN '30-44'
           WHEN c.age_enrolled BETWEEN 45 AND 59 THEN '45-59'
           ELSE '60+'
       END AS age_group,
       r.campaign_id,
       COUNT(*) AS customers,
       SUM(r.accepted) AS responders,
       ROUND(SUM(r.accepted) / COUNT(*) * 100, 2) AS response_rate_pct
FROM responses r
JOIN customers c ON r.customer_id = c.customer_id
GROUP BY age_group, r.campaign_id
ORDER BY r.campaign_id, response_rate_pct DESC;

-- Q5. Campaign performance scorecard combining response rate, responder spend and 30-day activity rate
-- ranked with window functions (lower avg_rank = better)

WITH campaign_metrics AS (
    SELECT r.campaign_id,
           ROUND(SUM(r.accepted) / COUNT(*) * 100, 2) AS response_rate_pct,
           ROUND(AVG(CASE WHEN r.accepted = 1 THEN c.total_spend END), 2) AS avg_spend_responders,
           ROUND(SUM(CASE WHEN r.accepted = 1 AND c.recency <= 30 THEN 1 ELSE 0 END)
                 / SUM(r.accepted) * 100, 2) AS activity_rate_pct
    FROM responses r
    JOIN customers c ON r.customer_id = c.customer_id
    GROUP BY r.campaign_id
),
ranked AS (
    SELECT campaign_id, response_rate_pct, avg_spend_responders, activity_rate_pct,
           RANK() OVER (ORDER BY response_rate_pct DESC)   AS rank_response,
           RANK() OVER (ORDER BY avg_spend_responders DESC) AS rank_spend,
           RANK() OVER (ORDER BY activity_rate_pct DESC)    AS rank_activity
    FROM campaign_metrics
)
SELECT *,
       ROUND((rank_response + rank_spend + rank_activity) / 3, 2) AS avg_rank
FROM ranked
ORDER BY avg_rank;