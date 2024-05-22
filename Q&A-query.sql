--  * Basic *
--1: Retrieve the total number of orders placed.
SELECT COUNT(order_id) AS Total_order FROM pizza_sales

--2: Calculate the total revenue generated from pizza sales.
SELECT ROUND((SUM(total_price))::numeric, 2) AS Total_revenue FROM pizza_sales

--3: Identify the highest-priced pizza.
SELECT pizza_name, total_price
FROM pizza_sales
ORDER BY total_price DESC LIMIT 1

--4: Identify the most common pizza size ordered.
SELECT pizza_size, COUNT(order_id) as order_count
FROM pizza_sales GROUP BY pizza_size
ORDER BY order_count DESC

--5: List the top 5 most ordered pizza types along with their quantities.
SELECT pizza_name, SUM(quantity) AS quantity
FROM pizza_sales GROUP BY pizza_name
ORDER BY quantity DESC LIMIT 5

--  * Intermediate *
--1: Determine the distribution of orders by hour of the day.
SELECT EXTRACT(HOUR FROM order_time) AS order_time_hour, COUNT(order_id) AS order_count
FROM pizza_sales 
GROUP BY EXTRACT(HOUR FROM order_time)
ORDER BY EXTRACT(HOUR FROM order_time) ASC;

--2: Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT ROUND(AVG(quantity),0) AS avg_pizza_ordered_per_day FROM
(SELECT order_date, SUM(quantity) AS quantity
FROM pizza_sales
GROUP BY order_date) AS order_quantity

--3: Determine the top 3 most ordered pizza types based on revenue.
SELECT pizza_name,
SUM(quantity * unit_price) AS revenue
FROM pizza_sales
GROUP BY pizza_name
ORDER BY revenue DESC LIMIT 3

--Advanced:
--1: Calculate the percentage contribution of each pizza type to total revenue.
SELECT pizza_category, ROUND((SUM(quantity * total_price) / (SELECT ROUND((SUM(total_price))::numeric, 2) AS Total_revenue 
FROM pizza_sales)*100)::numeric,2) AS revenue
FROM pizza_sales
GROUP BY pizza_category ORDER BY revenue DESC

--2: Analyze the cumulative revenue generated over time.
SELECT order_date, SUM(revenue) OVER(ORDER BY order_date) AS cum_revenue
FROM
(SELECT order_date,
SUM(quantity * total_price) AS revenue
FROM pizza_sales
GROUP BY order_date) AS sales

--3: Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT pizza_category, pizza_name, revenue 
FROM(
SELECT pizza_name, pizza_category, revenue,
RANK() OVER(PARTITION BY pizza_category ORDER BY revenue DESC) AS "rank"
FROM(
SELECT pizza_name, pizza_category, 
SUM(quantity * total_price) AS revenue
FROM pizza_sales 
GROUP BY pizza_name, pizza_category) AS subquery) AS b
WHERE "rank" <= 3