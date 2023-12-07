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


insert into cards VALUES('2', 2);
insert into cards VALUES('3', 3);
insert into cards VALUES('4', 4);
insert into cards VALUES('5', 5);
insert into cards VALUES('6', 6);
insert into cards VALUES('7', 7);
insert into cards VALUES('8', 8);
insert into cards VALUES('9', 9);
insert into cards VALUES('T', 10);
insert into cards VALUES('J', 11);
insert into cards VALUES('Q', 12);
insert into cards VALUES('K', 13);
insert into cards VALUES('A', 14);

create table results as
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
), player_hand_values as (
    select id, sum(hand_values.value) as hand_value
    from values
    inner join hand_values on values.count = hand_values.count
    group by id
), individual_values_lookup as (
    select id, cards.value
    from cards_unioned
    inner join cards on cards_unioned.c = cards.card
), sorted as (
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
select id, bid, final_value, rn, c1, c2, c3, c4,c5, hand_value from setup
order by hand_value asc,
    sort_value desc;

select * from results;

COPY results TO 'output.csv' (HEADER, DELIMITER '\t');

select sum(final_value) from results;
