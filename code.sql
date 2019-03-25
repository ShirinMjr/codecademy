-- Quiz Funnel: Shirin Mohajer Winter 2019
-- 1. Select all columns from the first 10 rows. What columns does the table have?
SELECT *
FROM survey
LIMIT 10;
-- 2. Create a quiz funnel using the GROUP BY command.
-- What is the number of responses for each question?
SELECT question,
		COUNT(DISTINCT(user_id))
FROM survey
GROUP BY question;
-- 3. Which question(s) of the quiz have a lower completion rates?
-- What do you think is the reason?
SELECT COUNT(DISTINCT(user_id))
FROM survey;
-- ==== 4 =====
-- Finding out whether or not users who get more pairs to try on at home will be more likely to make a purchase.
-- q4 -- 4.1. Examine the first five rows of each table What are the column names?
SELECT *
FROM quiz
LIMIT 5;

SELECT *
FROM home_try_on
LIMIT 5;

SELECT *
FROM purchase
LIMIT 5;
--q5 -- 4.2 Combine Three Tables to create a new layout
SELECT DISTINCT q.user_id,
	CASE 
    WHEN h.user_id IS NOT NULL THEN 'True'
    ELSE 'False'
  END AS 'is_home_try_on',
   h.number_of_pairs,
  CASE
  	WHEN p.user_id IS NOT NULL THEN 'True'
    ELSE 'False'
  END AS 'is_purchase'
FROM quiz q
LEFT JOIN home_try_on h
   ON q.user_id = h.user_id
LEFT JOIN purchase p
   ON p.user_id = q.user_id
LIMIT 10;
--q6 -- 4.3 Analysis: Calculate overall conversion rates based on aggregating across all rows.
-- aggregating across all rows
with funnel as (    
SELECT DISTINCT q.user_id,
	CASE 
    WHEN h.user_id IS NOT NULL THEN 'True'
    ELSE 'False'
  END AS 'is_home_try_on',
   h.number_of_pairs,
  CASE
  	WHEN p.user_id IS NOT NULL THEN 'True'
    ELSE 'False'
  END AS 'is_purchase'
FROM quiz q
LEFT JOIN home_try_on h
   ON q.user_id = h.user_id
LEFT JOIN purchase p
   ON p.user_id = q.user_id)
-- 4.3.1 Calculating Conversion Rate: How many people who tried on at home, ended up purchaseing
SELECT 
   1.0* sum(
   CASE 
   WHEN funnel.is_home_try_on == 'True' 
         and funnel.is_purchase = 'True' 
         THEN 1 
   ELSE 0 
   END
   ) 
   /sum(
   CASE
      WHEN funnel.is_home_try_on == 'True' then 1 
      ELSE 0
   END ) as conversion_rate
from funnel;
-- 4.3.2 Compare conversion from quiz→home_try_on and home_try_on→purchase
-- aggregating across all rows
with funnel as (   
SELECT DISTINCT q.user_id,
	 h.user_id IS NOT NULL AS 'is_home_try_on',
    p.user_id IS NOT NULL AS 'is_purchased'
FROM quiz q
LEFT JOIN home_try_on h
   ON q.user_id = h.user_id
LEFT JOIN purchase p
   ON p.user_id = q.user_id)
SELECT 
   count (user_id) AS 'brows',
   SUM(is_home_try_on) AS 'home_try',
   SUM(is_purchased) AS 'purchased',
   1.0 * SUM(is_home_try_on)/ count (user_id) 
      AS brows_to_checkout,
   1.0 * SUM(is_purchased) / SUM(is_home_try_on)
      AS checkedout_to_purchase
FROM funnel;
-- 4.3.3 calculate the difference in purchase rates between customers who had 3 number_of_pairs with ones who had 5.
with funnel as (   
SELECT DISTINCT q.user_id, h.number_of_pairs,
	h.user_id IS NOT NULL AS 'is_home_try_on',
   p.user_id IS NOT NULL AS 'is_purchased'
FROM quiz q
LEFT JOIN home_try_on h
   ON q.user_id = h.user_id
LEFT JOIN purchase p
   ON p.user_id = q.user_id)
SELECT 
   count (user_id) AS 'brows',
   SUM(is_home_try_on) AS 'home_try',
   SUM(is_purchased) AS 'purchased',
   1.0 * SUM(is_home_try_on)/ count (user_id) 
      AS brows_to_checkout,
   1.0 * SUM(is_purchased) / SUM(is_home_try_on)
      AS checkedout_to_purchase,
   1.0* SUM(number_of_pairs like '%3%')/SUM (is_purchased)
  	   AS 'three_pairs',
   1.0* SUM(funnel.number_of_pairs like '%5%')/SUM (is_purchased)
  	   AS 'five_pairs'
FROM funnel;
-- 5.1 Most common results of the style quiz. Popular (style)s
/*
Women's Styles
Men's Styles
I'm not sure. Let's skip it.
*/
SELECT style, COUNT(style) AS 'count_num',
  	100. * COUNT(style)
    /(SELECT COUNT(style) FROM quiz) AS 'percentage' 
FROM quiz
GROUP BY style;
-- 5.1 (style)s conversion rate based on the answers to style quiz
SELECT q.style, COUNT(q.style) AS 'count_num',
  	100. * COUNT(q.style)
    /(SELECT COUNT(style) FROM quiz)  AS 'percentage',
    number_of_pairs,
	h.user_id IS NOT NULL AS 'is_home_try_on',
   p.user_id IS NOT NULL AS 'is_purchased'
FROM quiz q
LEFT JOIN home_try_on h
   ON q.user_id = h.user_id
LEFT JOIN purchase p
   ON p.user_id = q.user_id
GROUP BY q.style, h.number_of_pairs;
-- 5.2.1 (style)s conversion rate based on the answers to style quiz
SELECT q.style, 
	COUNT(q.style) AS 'count_num',
	COUNT(h.user_id) AS 'is_home_try_on',
	COUNT(p.user_id) AS 'is_purchased'
FROM quiz q
LEFT JOIN purchase p
ON
	q.user_id = p.user_id
LEFT JOIN home_try_on h
ON
	q.user_id = h.user_id
GROUP BY q.style;
-- 5.2.2 (style)s conversion rate based on the answers to style quiz
SELECT COUNT(*) AS 'number_answered_quiz'
FROM quiz;

SELECT q.style,
	COUNT(q.style) AS 'count_num',
    	100. * COUNT(q.style)
    /(SELECT COUNT(style) FROM quiz) AS 'style_percentage',
	COUNT(h.user_id) AS 'is_home_try_on',
    	100. * COUNT(h.user_id)
    /(SELECT COUNT(style) FROM quiz) AS 'home_try_percentage',
	COUNT(p.user_id) AS 'is_purchased',
    	100. * COUNT(p.user_id)
    /(SELECT COUNT(style) FROM quiz) AS 'purchased_percentage'
FROM quiz q
LEFT JOIN purchase p
ON
	q.user_id = p.user_id
LEFT JOIN home_try_on h
ON
	q.user_id = h.user_id
GROUP BY q.style;
---- 5.2.3 (color)s conversion rate based on the answers to style quiz
SELECT q.color,
	COUNT(q.color) AS 'count_num',
    	100. * COUNT(q.color)
    /(SELECT COUNT(color) FROM quiz) AS 'color_percentage',
	COUNT(h.user_id) AS 'is_home_try_on',
    	100. * COUNT(h.user_id)
    /(SELECT COUNT(color) FROM quiz) AS 'home_try_percentage',
	COUNT(p.user_id) AS 'is_purchased',
    	100. * COUNT(p.user_id)
    /(SELECT COUNT(color) FROM quiz) AS 'purchased_percentage'
FROM quiz q
LEFT JOIN purchase p
ON
	q.user_id = p.user_id
LEFT JOIN home_try_on h
ON
	q.user_id = h.user_id
GROUP BY q.color;