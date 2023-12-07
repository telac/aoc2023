CREATE OR REPLACE TABLE cards (
    card VARCHAR,
    value INTEGER
);

CREATE OR REPLACE TABLE hand_values (
    count BIGINT,
    value BIGINT
);

INSERT INTO hand_values VALUES(1, 1); -- "high card -> 5" [5]
INSERT INTO hand_values VALUES(2, 3); -- pair (1 pair -> 6, 2 pair -> 7) [6, 7]
INSERT INTO hand_values VALUES(3, 7); -- three + 2 solo -> 9. three + pair -> 11 [9,11]
INSERT INTO hand_values VALUES(4, 11); -- four + solo -> 12
INSERT INTO hand_values VALUES(5, 15); -- all same -> 15


insert into cards VALUES('J', 1);
insert into cards VALUES('2', 2);
insert into cards VALUES('3', 3);
insert into cards VALUES('4', 4);
insert into cards VALUES('5', 5);
insert into cards VALUES('6', 6);
insert into cards VALUES('7', 7);
insert into cards VALUES('8', 8);
insert into cards VALUES('9', 9);
insert into cards VALUES('T', 10);
insert into cards VALUES('Q', 12);
insert into cards VALUES('K', 13);
insert into cards VALUES('A', 14);

create or replace table results as
with input as(
SELECT *, ROW_NUMBER() over() as id
from read_csv("input.txt", delim=" ", columns={"hand": "VARCHAR", "bid": "INT"})
),
hand as (
    SELECT
    id,
    hand[1] as c1,
    hand[2] as c2,
    hand[3] as c3,
    hand[4] as c4,
    hand[5] as c5,
    bid
    FROM input
),
cards_unioned as (
        select id, c1 as c from hand
    UNION ALL
        select id, c2 as c from hand
    UNION ALL
        select id, c3 as c from hand
    UNION ALL
        select id, c4 as c from hand
    UNION ALL
        select id, c5 as c from hand
), values as (
    select id, c, count(1) as count from cards_unioned
    group by 1,2
    order by id
), individual_values_lookup as (
    select id, cards.value
    from cards_unioned
    inner join cards on cards_unioned.c = cards.card
), 
--- part 2
jokers_count as (
    select id, c, count as num_jokers
    from values
    where c = 'J'
),
jokers_max as (
    select 
    t1.id, t1.count, t1.c, jokers_count.num_jokers, coalesce(t1.count + jokers_count.num_jokers, t1.count) as new_highest
        FROM (
            select *, 
            row_number() over(partition by id order by count desc) as rn
            from values
            where c <> 'J'
        ) t1
        left join jokers_count on t1.id = jokers_count.id
        where rn = 1 and t1.c <> 'J'
),
new_hands as (
    select t1.id, t1.c, coalesce(t2.new_highest, t1.count) as count from values t1
    left join jokers_max t2
        on t1.id = t2.id
        and t1.c = t2.c
    where t1.c <> 'J'
),
player_hand_values as (
    select t1.id, sum(t2.value) as hand_value
    from new_hands t1
    left join hand_values t2 on t1.count = t2.count
    group by id
    UNION ALL
    SELECT id, 15 from hand where hand.c1 = 'J' AND hand.c2 = 'J' and hand.c3 = 'J' and hand.c4 = 'J' and hand.c5 = 'J'
),
sorted as (
    select *, row_number() over(order by
            lk1.value desc,
            lk2.value desc,
            lk3.value desc,
            lk4.value desc,
            lk5.value desc) as sort_value
    from hand
    inner join cards as lk1
        on hand.c1 = lk1.card
    inner join cards  lk2
        on hand.c2 = lk2.card
    inner join cards lk3
        on hand.c3 = lk3.card
    inner join cards lk4
        on hand.c4 = lk4.card
    inner join cards lk5
        on hand.c5 = lk5.card
), setup as (
select hand.id,
 hand.bid as bid,
 hand.bid * row_number() over(
    order by player_hand_values.hand_value asc,
    sorted.sort_value desc) as final_value,
row_number() over(
    order by player_hand_values.hand_value asc,
    sorted.sort_value desc) as rn,
    *
from hand
inner join player_hand_values on hand.id = player_hand_values.id
inner join sorted on hand.id = sorted.id

)
select * from setup;


select sum(final_value) from results;
