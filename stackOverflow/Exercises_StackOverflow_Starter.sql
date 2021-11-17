-- Exercise 1
-- Find the best way to select id, body and lasteditordisplayname
-- for all posts created in 2008.

-- How many posts?
SELECT COUNT(ID) from posts

--> 6 seconden
SELECT id, body, lasteditordisplayname
FROM posts
WHERE YEAR(LastEditDate) = 2008

--> 5 seconden
SELECT id, body, lasteditordisplayname
FROM posts
WHERE LastEditDate >= '2008-01-01' AND LastEditDate < '2009-01-01'



CREATE NONCLUSTERED INDEX id1 ON Posts(LastEditDate)
INCLUDE (id, body, lasteditordisplayname)

DROP index id1 on Posts
-- Exercise 2

-- Order posts by score and (in case of equal score) commentcount 
-- both in descending order. 
-- Show id, score, commentcount and title in the most efficient way. 
-- How can you check if your result is executed in the most efficient way? 
-- Is the actual table used?
SELECT id, score, commentcount, title
FROM Posts
Order BY score Desc, CommentCount desc

CREATE NONCLUSTERED INDEX id2 ON Posts(score desc, commentcount desc)
INCLUDE (id, title)

-- Exercise 3

-- Create an index on title. Then explain the difference (in the execution plan) 
-- between following queries:

select id,title
from posts
where title like '%php%';


select id,title
from posts
where title like 'php%';

CREATE NONCLUSTERED INDEX id3 ON Posts(Title)

DROP index id3 on posts