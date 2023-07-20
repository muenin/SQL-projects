--Amsterdam AirBnB Listings Exploration
--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

SELECT *
FROM ProjectA..AmsterdamAirBnB

--Select data to be used

SELECT host_id,neighbourhood_cleansed,room_type,price,minimum_nights
FROM ProjectA..AmsterdamAirBnB
ORDER BY 1,2

-- Room type vs average minimum nights

SELECT room_type, round(AVG(minimum_nights),2) as avg_min_nights
FROM ProjectA..AmsterdamAirBnB
group by room_type
order by 1,2

--Neighbourhood vs average minimum nights

SELECT neighbourhood_cleansed, round(AVG(minimum_nights),2) as avg_min_nights
FROM ProjectA..AmsterdamAirBnB
group by neighbourhood_cleansed
order by 1,2

--Average price based on type of room

select room_type, AVG(price ) as avg_price
from ProjectA..AmsterdamAirBnB
group by room_type
order by avg_price desc

--Average Price against neighbourhood

select neighbourhood_cleansed, AVG(price ) as avg_price
from ProjectA..AmsterdamAirBnB
where room_type not like 'Private room' and room_type not like 'Shared room'
group by neighbourhood_cleansed
order by avg_price desc

--Joins between tables
--InnerJoin

SELECT *
FROM ProjectA..AmsterdamAirBnB ba
JOIN ProjectA..AmsterdamReviews ra
on ba.neighbourhood_cleansed=ra.neighbourhood_cleansed


--Average number of reviews for host id

SELECT ra.host_id, round(AVG(ba.minimum_nights),2) as avg_min_nights, round(AVG(ra.number_of_reviews),2) as avg_number_reviews, round(AVG(ra.price),2) as avg_price
FROM ProjectA..AmsterdamAirBnB ba
JOIN ProjectA..AmsterdamReviews ra
on ba.host_id=ra.host_id
GROUP BY ra.host_id
order by avg_price desc

--Review of host accuracy

SELECT ra.host_name, round(AVG(ba.minimum_nights),2) as avg_min_nights, round(AVG(ra.review_scores_accuracy),2) as reviewaccuracy, round(AVG(ra.price),2) as avg_price
FROM ProjectA..AmsterdamAirBnB ba
JOIN ProjectA..AmsterdamReviews ra
on ba.host_name=ra.host_name
GROUP BY ra.host_name
order by avg_price desc

--Review of host cleanliness

SELECT ra.host_name, round(AVG(ba.minimum_nights),2) as avg_min_nights, round(AVG(ra.review_scores_cleanliness),2) as reviewcleanliness, round(AVG(ra.price),2) as avg_price
FROM ProjectA..AmsterdamAirBnB ba
JOIN ProjectA..AmsterdamReviews ra
on ba.host_name=ra.host_name
GROUP BY ra.host_name
order by avg_price desc

--Review of host communication

SELECT ra.host_name, round(AVG(ba.minimum_nights),2) as avg_min_nights, round(AVG(ra.review_scores_communication),2) as reviewcommunication, round(AVG(ra.price),2) as avg_price
FROM ProjectA..AmsterdamAirBnB ba
JOIN ProjectA..AmsterdamReviews ra
on ba.host_name=ra.host_name
GROUP BY ra.host_name
order by avg_price desc

--Percentage of host response rate

SELECT ra.host_name, round(AVG(ba.minimum_nights),2) as avg_min_nights, round(AVG(ra.host_response_rate),2) as responserate, round(AVG(ra.price),2) as avg_price
FROM ProjectA..AmsterdamAirBnB ba
JOIN ProjectA..AmsterdamReviews ra
on ba.host_name=ra.host_name
GROUP BY ra.host_name
order by avg_price desc

--Creating CTE
WITH Bnb(host_id,neighbourhood_cleansed,room_type,price,minimum_nights,responserate)
AS
(SELECT ba.host_id,ba.neighbourhood_cleansed,ba.room_type,round(AVG(ba.minimum_nights),2) as avg_min_nights,AVG(ba.price) as avg_price,round(AVG(ra.host_response_rate),2) as responserate
FROM ProjectA..AmsterdamAirBnB ba
JOIN ProjectA..AmsterdamReviews ra
on ba.neighbourhood_cleansed=ra.neighbourhood_cleansed and
ba.room_type =ra.room_type
and ba.host_id=ra.host_id
GROUP BY ba.neighbourhood_cleansed,ba.host_id , ba.room_type
)

SELECT *
FROM Bnb

--Creating Temp Table

DROP TABLE IF EXISTS #RespHost
CREATE TABLE #RespHost
(host_id numeric,
neighbourhood_cleansed varchar(300),
room_type varchar(250),
price numeric,
minimum_nights int,
responserate int)

INSERT INTO #RespHost
SELECT ba.host_id,ba.neighbourhood_cleansed,ba.room_type,round(AVG(ba.minimum_nights),2) as avg_min_nights,AVG(ba.price) as avg_price,round(AVG(ra.host_response_rate),2) as responserate
FROM ProjectA..AmsterdamAirBnB ba
JOIN ProjectA..AmsterdamReviews ra
on ba.neighbourhood_cleansed=ra.neighbourhood_cleansed and
ba.room_type =ra.room_type
and ba.host_id=ra.host_id
GROUP BY ba.neighbourhood_cleansed,ba.host_id , ba.room_type

SELECT*
FROM #RespHost

-- Creating View to store data for later visualizations

CREATE VIEW RespHost as
SELECT ba.host_id,ba.neighbourhood_cleansed,ba.room_type,round(AVG(ba.minimum_nights),2) as avg_min_nights,AVG(ba.price) as avg_price,round(AVG(ra.host_response_rate),2) as responserate
FROM ProjectA..AmsterdamAirBnB ba
JOIN ProjectA..AmsterdamReviews ra
on ba.neighbourhood_cleansed=ra.neighbourhood_cleansed and
ba.room_type =ra.room_type
and ba.host_id=ra.host_id
GROUP BY ba.neighbourhood_cleansed,ba.host_id , ba.room_type