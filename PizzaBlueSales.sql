-- Retrieve the total number of orders placed

SELECT 
    COUNT(*) AS TOTAL_ORDERS
FROM
    ORDERS;

-- Calculate the total revenue generated from pizza sales

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS TOTAL_REVENUE
FROM
    order_details
        JOIN
    pizzas USING (pizza_id);
    
-- Identify the highest priced pizza

SELECT 
    pizza_typeS.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas USING (pizza_type_id)
ORDER BY price DESC
LIMIT 1;

-- Identify the most common pizza size orderd

SELECT
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_details USING (pizza_id)
GROUP BY pizzas.size
ORDER BY order_count DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities

SELECT 
    pizza_types.name,
    SUM(order_details.quantity) AS pizza_quantity
FROM
    pizza_types
        JOIN
    pizzas USING (pizza_type_id)
        JOIN
    order_details USING (pizza_id)
GROUP BY pizza_types.name
ORDER BY pizza_quantity DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category

SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas USING (pizza_type_id)
        JOIN
    order_details USING (pizza_id)
GROUP BY pizza_types.category
ORDER BY quantity DESC;

-- Determine the distribution of orders by hour of the day

SELECT 
    HOUR(order_time), COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time)
ORDER BY order_count DESC;

-- Group the orders by date and calculate the average number of pizzas ordered per day

SELECT 
    ROUND(AVG(quantity), 0) AS average_pizzas_ordered_per_day
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details USING (order_id)
    GROUP BY orders.order_date) AS order_quantity;
    
    -- Determine the top 3 most ordered pizza types based on revenue

SELECT 
    pizza_types.name,
    SUM((order_details.quantity * pizzas.price)) AS revenue
FROM
    pizza_types
        JOIN
    pizzas USING (pizza_type_id)
        JOIN
    order_details USING (pizza_id)
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue

SELECT 
    pizza_types.category,
    ROUND((SUM((order_details.quantity * pizzas.price)) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2)
                FROM
                    order_details
                        JOIN
                    pizzas USING (pizza_id))) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas USING (pizza_type_id)
        JOIN
    order_details USING (pizza_id)
GROUP BY pizza_types.category
ORDER BY revenue DESC;


-- Analyze the cumulative revenue generated over time

SELECT order_date, ROUND(SUM(revenue) over(order by order_date), 2) as cumulative_revenue
FROM
(SELECT orders.order_date, SUM(order_details.quantity*pizzas.price) AS revenue
FROM orders
JOIN order_details
USING(order_id)
JOIN pizzas
USING(pizza_id)
GROUP BY orders.order_date) as sales;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category

SELECT name, revenue, rn
FROM
(SELECT category, name, revenue, rank() over(PARTITION BY category order by revenue desc) as rn
FROM
(SELECT pizza_types.category, pizza_types.name, SUM((order_details.quantity * pizzas.price)) as revenue
FROM pizza_types
JOIN pizzas
USING(pizza_type_id)
JOIN order_details
USING(pizza_id)
GROUP BY pizza_types.category, pizza_types.name) as a) as b
WHERE rn <= 3;


