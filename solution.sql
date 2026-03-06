-- 1. Top 10 categories by installs 
SELECT category, SUM(maximum_installs) as total_installs FROM google_play_store 
GROUP BY category
ORDER BY total_installs DESC
LIMIT 10;

-- 2. Top 10 categories by rating 
DROP VIEW IF EXISTS best_app_per_category;

CREATE VIEW best_app_per_category AS
 SELECT app_id, app_name, category, rating, RANK() OVER (PARTITION BY category ORDER BY rating DESC, rating_count DESC) AS rnk FROM google_play_store;
 
SELECT * FROM best_app_per_category WHERE rnk=1;

SELECT cat_totals.category, cat_totals.total_installs, b.app_name, b.rating
FROM (
  SELECT category, SUM(maximum_installs) as total_installs
  FROM google_play_store
  GROUP BY category
  ORDER BY total_installs DESC
  LIMIT 10
) AS cat_totals
JOIN best_app_per_category AS b ON b.category = cat_totals.category AND b.rnk = 1
ORDER BY cat_totals.total_installs DESC;

-- 3. Proportion of Paid to Free apps
SELECT category,  SUM(CASE WHEN free <> 'True' THEN 1 ELSE 0 END) as paid_amount, COUNT(*) as total_amount
FROM google_play_store 
GROUP BY category
ORDER BY CAST(paid_amount AS FLOAT) / total_amount DESC
LIMIT 10;

-- 4. Developers with the biggest amount of apps in google play store
SELECT developer_id, COUNT(*) AS total_apps FROM google_play_store
GROUP BY developer_id
ORDER BY total_apps DESC
LIMIT 10;

-- 5. Developers with the most installs 
SELECT developer_id, SUM(installs) AS total_installs FROM google_play_store
GROUP BY developer_id
ORDER BY total_installs DESC
LIMIT 10;

-- 6. Which apps have a high rating but relatiely low install count (underrated apps)?
SELECT app_name, rating_count, maximum_installs
FROM google_play_store
ORDER BY CAST(rating_count AS FLOAT) / maximum_installs DESC
LIMIT 10;

-- 7. Which apps have a massive install count but a poor rating (overhyped apps)? 
--- Check what is the 5% average install rate 324704.19260906
WITH total AS (
  SELECT CAST(COUNT(*) * 0.05 AS INTEGER) as top_n
  FROM google_play_store
)
SELECT AVG(maximum_installs) as average_installs
FROM google_play_store
ORDER BY maximum_installs DESC
LIMIT (SELECT top_n FROM total);

SELECT * FROM google_play_store WHERE maximum_installs > 324704 AND rating_count > 0
ORDER BY rating ASC
LIMIT 10;

-- 8. What percentage of apps have fewer than 100 reviews? 
WITH stat AS (
	SELECT COUNT(*) AS number_of_small_reviews
	FROM google_play_store WHERE rating_count < 100 
)
SELECT number_of_small_reviews, (SELECT COUNT(*) FROM google_play_store) AS total_count,ROUND((CAST(number_of_small_reviews AS FLOAT) / (SELECT COUNT(*) FROM google_play_store)) * 100, 2) AS percentage FROM stat;

-- 9. What are the most common price points for paid apps (e.g., $0.99, $1.99, $2.99)? Is there a "sweet spot"?
SELECT price, COUNT(*) FROM google_play_store  
WHERE price > 0
GROUP BY price
ORDER BY COUNT(*) DESC
LIMIT 10;

-- 10. Which content rating category (Everyone, Teen, Mature 17+) dominates by number of apps?
SELECT content_rating, COUNT(*) FROM google_play_store
GROUP BY content_rating
ORDER BY COUNT(*) DESC;