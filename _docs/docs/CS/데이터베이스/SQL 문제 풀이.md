---
created_date: 2024-11-12
modified_date: 2024-11-12
copyright: © 2024 reudekx · CC BY 4.0
---

# SQL 문제 풀이

## 개요

해결한 SQL 문제들의 풀이를 모아놓았다.
주로 프로그래머스의 [SQL 고득점 Kit](https://school.programmers.co.kr/learn/challenges?tab=sql_practice_kit)
문제들을 MySQL로 풀이하였음.

## 참고

* MySQL의 SQL 실행 순서

```sql
FROM - WHERE - GROUP BY - HAVING - SELECT - ORDER BY
```

* WITH절을 이용한 재귀 쿼리
    * 재귀적 부분의 매 반복은 이전 반복에서 생성된 행들에 대해서만 작동한다는 점을 인지하자.

```sql
-- 2024년의 날짜를 모두 구한다.
WITH RECURSIVE date_range AS (
    -- base part
    SELECT DATE('2024-01-01') AS date

    UNION ALL

    -- recursive part
    SELECT date + INTERVAL 1 DAY
    FROM date_range
    WHERE date < '2024-12-31'
)
SELECT * FROM date_range;
```

## [SQL 고득점 Kit](https://school.programmers.co.kr/learn/challenges?tab=sql_practice_kit)

### [SELECT](https://school.programmers.co.kr/learn/courses/30/parts/17042)

#### [평균 일일 대여 요금 구하기](https://school.programmers.co.kr/learn/courses/30/lessons/151136) (Level 1)

```sql
SELECT round(avg(daily_fee)) AS average_fee
FROM car_rental_company_car
WHERE car_type = 'SUV';
```

#### [과일로 만든 아이스크림 구하기](https://school.programmers.co.kr/learn/courses/30/lessons/133025) (Level 1)

```sql
SELECT i.flavor
FROM icecream_info AS i
    INNER JOIN first_half AS f
        ON i.flavor = f.flavor
WHERE f.total_order > 3000
    AND i.ingredient_type = 'fruit_based'
ORDER BY f.total_order DESC;
```

코드 실행시 예시 결과와 다른 결과가 조회되었는데
제출하니까 정답 처리되었다.

또한 조건을 모두 ON절에 적을지 아니면 두 테이블을 연결하는 핵심 조건만 ON절에 적고
나머지는 WHERE절에 적을지 고민이 되었는데,
처음에는 전자가 성능상 더 좋은 것이 아닌가 생각하였지만
웬만하면 옵티마이저가 최적화해준다는 정보를 찾아본 후 후자의 방식을 택하기로 하였다.

#### [조건에 부합하는 중고거래 댓글 조회하기](https://school.programmers.co.kr/learn/courses/30/lessons/164673) (Level 1)

```sql
SELECT b.title, b.board_id, r.reply_id, r.writer_id, r.contents, 
    DATE_FORMAT(r.created_date, '%Y-%m-%d') AS created_date
FROM used_goods_board AS b
    INNER JOIN used_goods_reply AS r
        ON b.board_id = r.board_id
WHERE b.created_date BETWEEN '2022-10-01' AND '2022-10-31'
ORDER BY created_date, title;
```

`b.created_date` 대신 `r.created_date`의 값이 2022년 10월인 행을 조회하는 실수를 저질렀다.
문제를 주의 깊게 읽도록 하자.

#### [조건에 맞는 회원수 구하기](https://school.programmers.co.kr/learn/courses/30/lessons/131535) (Level 1)

```sql
SELECT COUNT(*) as users
FROM user_info
WHERE YEAR(joined) = 2021
    AND AGE BETWEEN 20 AND 29;
```
#### [특정 형질을 가지는 대장균 찾기](https://school.programmers.co.kr/learn/courses/30/lessons/301646) (Level 1)

```sql
SELECT COUNT(*) as count
FROM ecoli_data
WHERE (genotype & (1 << 1)) = 0
    AND (
        (genotype & (1 << 0)) > 0
        OR (genotype & (1 << 2)) > 0
    );
```

#### [부모의 형질을 모두 가지는 대장균 찾기](https://school.programmers.co.kr/learn/courses/30/lessons/301647) (Level 2)

```sql
SELECT c.id, c.genotype, p.genotype AS parent_genotype
FROM ecoli_data AS c
    INNER JOIN ecoli_data AS p
        ON c.parent_id = p.id
WHERE (c.genotype & p.genotype) = p.genotype
ORDER BY c.id;
```

처음에는 LEFT JOIN을 하려고 했으나 부모가 존재하는 행만 구해지므로 INNER JOIN으로 교체했다.

#### [대장균들의 자식의 수 구하기](https://school.programmers.co.kr/learn/courses/30/lessons/299305) (Level 3)

```sql
SELECT p.id, COUNT(c.id) AS child_count
FROM ecoli_data AS p
    LEFT JOIN ecoli_data AS c
        ON p.id = c.parent_id
GROUP BY p.id
ORDER BY p.id;
```

만약 자식이 없는 개체는 제외하고 세기 위해 INNER JOIN을 했다면
COUNT(\*)이 더 효율적이었겠지만, 자식이 없는 개체도 포함해야 하기 때문에
COUNT(c.id)를 통해 자식이 없는 경우(c.id가 NULL인 경우)에는 0이 나타나도록 하였다.
(이 경우 COUNT(\*)를 사용하면 c.id가 NULL이여도 행이 1개 존재하므로 1로 세진다.)

#### [대장균의 크기에 따라 분류하기 1](https://school.programmers.co.kr/learn/courses/30/lessons/299307) (Level 3)

```sql
SELECT id, 
    CASE
        WHEN size_of_colony <= 100 THEN 'LOW'
        WHEN size_of_colony <= 1000 THEN 'MEDIUM'
        ELSE 'HIGH'
    END AS size
FROM ecoli_data
ORDER BY id;
```

#### [대장균의 크기에 따라 분류하기 2](https://school.programmers.co.kr/learn/courses/30/lessons/301649) (Level 3)

```sql
SELECT id, 
    CASE NTILE(4) OVER (ORDER BY size_of_colony DESC)
        WHEN 1 THEN 'CRITICAL'
        WHEN 2 THEN 'HIGH'
        WHEN 3 THEN 'MEDIUM'
        WHEN 4 THEN 'LOW'
    END AS colony_name
FROM ecoli_data
ORDER BY id;
```

#### [특정 세대의 대장균 찾기](https://school.programmers.co.kr/learn/courses/30/lessons/301650) (Level 4)

```sql
WITH RECURSIVE ecoli_generation AS (
    SELECT id, 1 AS generation
    FROM ecoli_data
    WHERE parent_id IS NULL
    
    UNION ALL
    
    SELECT e.id, g.generation + 1
    FROM ecoli_data AS e
        JOIN ecoli_generation AS g
            ON e.parent_id = g.id
    WHERE g.generation < 3
)
SELECT id
FROM ecoli_generation
WHERE generation = 3
ORDER BY id;
```

WITH 다음의 AS를 빼먹어서 오류가 발생했었다.

#### [멸종위기의 대장균 찾기](https://school.programmers.co.kr/learn/courses/30/lessons/301651) (Level 5)

```sql
WITH RECURSIVE ecoli_generation AS (
    SELECT id, 1 AS generation
    FROM ecoli_data
    WHERE parent_id IS NULL
    
    UNION ALL
    
    SELECT e.id, g.generation + 1
    FROM ecoli_data AS e
        JOIN ecoli_generation AS g
            ON e.parent_id = g.id
)
SELECT COUNT(*) AS count, g.generation
FROM ecoli_generation AS g
    LEFT JOIN ecoli_data AS e
        ON g.id = e.parent_id
WHERE e.id IS NULL
GROUP BY g.generation
ORDER BY g.generation;
```
