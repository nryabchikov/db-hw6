-- 1) Вывести к каждому самолету класс обслуживания и количество мест этого класса

select model, fare_conditions, count(seat_no) as seat_amount
from seats
         join aircrafts_data using (aircraft_code)
group by fare_conditions, model;

-- 2) Найти 3 самых вместительных самолета (модель + кол-во мест)

select model, count(seat_no) as seat_amount
from seats
         join aircrafts_data using (aircraft_code)
group by fare_conditions, model
order by seat_amount desc limit 3;

-- 3) Найти все рейсы, которые задерживались более 2 часов

select flight_no, scheduled_departure, actual_departure
from flights
where status like 'Arrived'
  and actual_departure - scheduled_departure > '2 hours';

-- 4) Найти последние 10 билетов, купленные в бизнес-классе (fare_conditions = 'Business'),
-- с указанием имени пассажира и контактных данных

select book_date, passenger_name, contact_data, fare_conditions
from tickets
         join bookings using (book_ref)
         join ticket_flights using (ticket_no)
where fare_conditions like 'Business'
order by book_date desc limit 10;

-- 5) Найти все рейсы, у которых нет забронированных мест в бизнес-классе (fare_conditions = 'Business')

select flight_id,
       flight_no,
       scheduled_departure,
       scheduled_arrival
from flights
where not exists (select 1
                  from ticket_flights
                  where ticket_flights.flight_id = flights.flight_id
                    and ticket_flights.fare_conditions = 'Business');

-- 6) Получить список аэропортов (airport_name) и городов (city), в которых есть рейсы с задержкой по вылету

select airport_name, city, scheduled_departure, actual_departure
from flights
         join airports on flights.departure_airport = airports.airport_code
where actual_departure > scheduled_departure;

-- 7) Получить список аэропортов (airport_name) и количество рейсов, вылетающих из каждого аэропорта,
-- отсортированный по убыванию количества рейсов

select airport_name, count(flight_id)
from flights
         join airports on flights.departure_airport = airports.airport_code
group by airport_name
order by count(flight_id) desc;

-- 8) Найти все рейсы, у которых запланированное время прибытия (scheduled_arrival) было изменено
-- и новое время прибытия (actual_arrival) не совпадает с запланированным

select scheduled_arrival, actual_arrival
from flights
where scheduled_arrival != actual_arrival;

-- 9) Вывести код, модель самолета и места не эконом класса для самолета "Аэробус A321-200" с сортировкой по местам

select aircraft_code, model, seat_no
from aircrafts_data
         join seats using (aircraft_code)
where aircraft_code = '321'
  and fare_conditions not like 'Economy';

-- 10) Вывести города, в которых больше 1 аэропорта (код аэропорта, аэропорт, город)

SELECT airport_code, airport_name, city
FROM airports
where city in
      (select city
       from airports
       group by city
       having count(airport_code) > '1');

-- 11) Найти пассажиров, у которых суммарная стоимость бронирований превышает среднюю сумму всех бронирований

select passenger_name, contact_data
from tickets
         join bookings using (book_ref)
where total_amount > (select avg(total_amount)
                      from bookings);

-- 12) Найти ближайший вылетающий рейс из Екатеринбурга в Москву, на который еще не завершилась регистрация

select departure_airport,
       arrival_airport,
       departure.city as departure_city,
       arrival.city   as arrival_city,
       scheduled_departure,
       status
from flights
         join airports departure on flights.departure_airport = departure.airport_code
         join airports arrival on flights.arrival_airport = arrival.airport_code
where departure.city = 'Екатеринбург'
  and arrival.city = 'Москва'
  and status IN ('On Time', 'Delayed')
order by scheduled_departure LIMIT 1;

-- 13) Вывести самый дешевый и дорогой билет и стоимость (в одном результирующем ответе)

(select ticket_no, amount
 from ticket_flights
 where amount = (select min(amount)
                 from ticket_flights) limit 1)
union all
(select ticket_no, amount
 from ticket_flights
 where amount = (select max(amount)
                 from ticket_flights) limit 1);

-- 14) Написать DDL таблицы Customers, должны быть поля id, firstName,
-- LastName, email, phone. Добавить ограничения на поля (constraints)

create table customers
(
    id         serial primary key,
    first_name varchar(50)        not null,
    last_name  varchar(50)        not null,
    email      varchar(50) unique not null,
    phone      varchar(20)        not null
);

-- 15) Написать DDL таблицы Orders, должен быть id, customerId, quantity.
-- Должен быть внешний ключ на таблицу customers + constraints

create table orders
(
    id          serial primary key,
    customer_id int not null,
    quantity    int not null check (quantity > 0),
    foreign key (customer_id) references customers (id) on delete cascade
);

-- 16) Написать 5 insert в эти таблицы

insert into customers (first_name, last_name, email, phone)
values ('Nikita', 'Ryabchikov', 'nik123@gmail.com', '123456'),
       ('Viktor', 'Danilov', 'vitek123@gmail.com', '12345678'),
       ('Lexa', 'Demidov', 'lexich321@gmail.com', '567788'),
       ('Vova', 'Ivanov', 'vovka5790@gmail.com', '098843'),
       ('Egor', 'Borovikov', 'borovik1234@gmail.com', '5237332');

-- 17) Удалить таблицы

drop table if exists customers cascade;
drop table if exists orders cascade;