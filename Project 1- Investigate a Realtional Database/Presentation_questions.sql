/* 1st_presentation_question */
/* What family movie category was rented out the most?*/
WITH t1 AS (
  SELECT
    f.title film_title,
    c.name category_name,
    COUNT(*) rental_count
  FROM
    film f
    JOIN film_category fc ON f.film_id = fc.film_id
    JOIN category c ON c.category_id = fc.category_id
    JOIN inventory i ON f.film_id = i.film_id
    JOIN rental r ON i.inventory_id = r.inventory_id
  GROUP BY
    1,
    2
),
t2 AS (
  SELECT
    *
  FROM
    t1
  WHERE
    t1.category_name IN (
      'Animation',
      'Children',
      'Classics',
      'Comedy',
      'Family',
      'Music'
    )
  ORDER BY
    t1.category_name,
    t1.film_title
)
SELECT
  DISTINCT category_name family_category,
  SUM(rental_count) OVER(PARTITION BY category_name) sum_rental
FROM
  t2
ORDER BY
  2 DESC;

/* 2nd_presentation_question */
/* What was the rental_distribution for each category?*/
WITH t1 AS (
  SELECT
    c.name,
    f.rental_duration,
    NTILE(4) OVER(
      ORDER BY
        rental_duration
    ) standard_quartile
  FROM
    category c
    JOIN film_category fc ON c.category_id = fc.category_id
    AND c.name IN (
      'Animation',
      'Children',
      'Classics',
      'Comedy',
      'Family',
      'Music'
    )
    JOIN film f ON f.film_id = fc.film_id
)
SELECT
  t1.name,
  t1.standard_quartile,
  COUNT(*)
FROM
  t1
GROUP BY
  1,
  2
ORDER BY
  1,
  2;

/* Question 3 */
WITH top_cust AS(
  SELECT
    c.customer_id id,
    c.first_name || ' ' || c.last_name fn,
    SUM(P.amount) tot_amt
  FROM
    customer c
    JOIN payment p ON c.customer_id = p.customer_id
  GROUP BY
    1,
    2
  ORDER BY
    3 DESC
  LIMIT
    10
), t2 AS(
  SELECT
    top_cust.fn full_name,
    p.amount,
    DATE_TRUNC('month', payment_date) pay_month
  FROM
    top_cust
    JOIN customer c ON top_cust.id = c.customer_id
    JOIN payment p ON c.customer_id = p.customer_id
)
SELECT
  t2.full_name,
  LEFT(t2.pay_month :: TEXT, 7) pay_month,
  SUM(amount)
FROM
  t2
GROUP BY
  1,
  2
ORDER BY
  1,
  2;

/* Questioin 4: What is the monthly rental order for each store */
SELECT
  DATE_PART('month', r1.rental_date) AS rental_month,
  DATE_PART('year', r1.rental_date) AS rental_year,
  ('Store ' || s1.store_id) AS store,
  COUNT(*)
FROM
  store AS s1
  JOIN staff AS s2 ON s1.store_id = s2.store_id
  JOIN rental r1 ON s2.staff_id = r1.staff_id
GROUP BY
  1,
  2,
  3
ORDER BY
  2,
  1;