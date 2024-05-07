/*
Table: Candidate
+-----+---------+
| id  | Name    |
+-----+---------+
| 1   | A       |
| 2   | B       |
| 3   | C       |
| 4   | D       |
| 5   | E       |
+-----+---------+  

Table: Vote
+-----+--------------+
| id  | CandidateId  |
+-----+--------------+
| 1   |     2        |
| 2   |     4        |
| 3   |     3        |
| 4   |     2        |
| 5   |     5        |
+-----+--------------+
id is the auto-increment primary key,
CandidateId is the id appeared in Candidate table.
id는 자동 증가 기본 키입니다.
CandidateId는 Candidate 테이블에 나타나는 ID입니다.

Write a sql to find the name of the winning candidate.
The above example will return the winner B.
우승 후보의 이름을 찾는 SQL을 작성하세요.
위의 예에서는 우승자 B를 반환됩니다.


Output: 
+------+
| Name |
+------+
| B    |
+------+
Notes: You may assume there is no tie, in other words there will be at most one winning candidate.
노트: 동률이 없다고 가정할 수도 있습니다. 즉, 최대 한 명의 우승 후보가 있을 것입니다.
*/

# [SETTING]
USE PRACTICE;
DROP TABLE CANDIDATE;
CREATE TABLE CANDIDATE (ID INT, NAME VARCHAR(255));
INSERT INTO
	CANDIDATE (ID, NAME)
VALUES
('1', 'A')
,('2', 'B')
,('3', 'C')
,('4', 'D')
,('5', 'E');
SELECT * FROM CANDIDATE;

# [SETTING]
USE PRACTICE;
DROP TABLE VOTE;
CREATE TABLE VOTE (ID INT, CANDIDATEID INT);
INSERT INTO
	VOTE (ID, CANDIDATEID)
VALUES
('1', '2')
,('2', '4')
,('3', '3')
,('4', '2')
,('5', '5');
SELECT * FROM VOTE;

# [PRACRICE1]
SELECT CANDIDATEID,
COUNT(CANDIDATEID) CNT
FROM VOTE 
GROUP BY CANDIDATEID;

# [ERROR]
# 참고: https://stackoverflow.com/questions/2436820/can-i-do-a-maxcount-in-sql
SELECT MAX(COUNT(CANDIDATEID))
FROM VOTE 
GROUP BY CANDIDATEID;

# [PRACTICE1]
SELECT MAX(CNT)
FROM (
	SELECT COUNT(CANDIDATEID) CNT
	FROM VOTE 
	GROUP BY CANDIDATEID
) A;

# [MYSQL1]
# max 사용 가능: 'You may assume there is no tie'
# 동률이 있다면, rank로 풀이해야됨
SELECT C.NAME
FROM CANDIDATE C
INNER JOIN VOTE V
ON C.ID = V.CANDIDATEID
GROUP BY C.NAME
HAVING COUNT(V.CANDIDATEID) = (
								SELECT MAX(CNT)
								FROM (SELECT COUNT(CANDIDATEID) CNT FROM VOTE GROUP BY CANDIDATEID) A
							  );
    
# [PRACTICE2]
SELECT CANDIDATEID,
COUNT(CANDIDATEID) CNT
FROM VOTE 
GROUP BY CANDIDATEID
ORDER BY CNT DESC
LIMIT 1;
    
# [MYSQL2]
# order by, limit 1: 'You may assume there is no tie'
SELECT C.NAME
FROM CANDIDATE C
INNER JOIN 
(
	SELECT CANDIDATEID,
	COUNT(CANDIDATEID) CNT
	FROM VOTE 
	GROUP BY CANDIDATEID
	ORDER BY CNT DESC
	LIMIT 1
) V
ON C.ID = V.CANDIDATEID;

# [PRACTICE3]
# rank: 동률이 있다면, rank로 풀이해야됨

# [ERROR]
#Error Code: 1140. In aggregated query without GROUP BY, expression
# -> group by 필요
SELECT CANDIDATEID,
RANK() OVER (ORDER BY COUNT(CANDIDATEID) DESC) RNK
FROM VOTE;

# [PRACTICE3]
SELECT CANDIDATEID,
COUNT(CANDIDATEID),
RANK() OVER (ORDER BY COUNT(CANDIDATEID) DESC) RNK
FROM VOTE
GROUP BY CANDIDATEID;

# [MYSQL3]
# rank
SELECT C.NAME
FROM CANDIDATE C
INNER JOIN
(
	SELECT CANDIDATEID
	FROM
	(
		SELECT CANDIDATEID,
		COUNT(CANDIDATEID),
		RANK() OVER (ORDER BY COUNT(CANDIDATEID) DESC) RNK
		FROM VOTE
		GROUP BY CANDIDATEID
	) A
	WHERE RNK=1
) V
ON C.ID = V.CANDIDATEID;