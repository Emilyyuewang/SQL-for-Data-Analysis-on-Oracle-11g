/* SQL_A   Yue, Wang,114934802 */
drop table AUTHOR;
drop table AUTHORPUBLICATION;
drop table conference;
drop table publication;

@DBLP_populate.sql

/*Q1:List countries that have held both SIGMOD and VLDB*/
select location
from CONFERENCE
where NAME='SIGMOD')
intersect(
select location 
from conference
where NAME='VLDB';

/*Q2:List for each location the total number of conferences held in descending order.*/
select location,count(ID)
FROM CONFERENCE
group by LOCATION
order by count(ID) desc;

/*Q3:How many papers in the dataset contain the word “database” in their title*/
select count(ID)
from PUBLICATION
where TITLE like '%database%';

/*Q4:Among the keywords “network” and “database”, which of them have occurred more in the title of papers
in the database?*/
             
with temp1 as (select count(p.ID) as c1
                from PUBLICATION p
                 where p.TITLE like '%database%'),
temp2 as (select  count(p1.ID) as c2
                from PUBLICATION p1
                 where p1.TITLE like '%network%')
select t1.c1,t2.c2 from temp1 t1, temp2 t2

]
/*Q5:Generate a table containing two columns one containing the year and the second containing the number of
papers in that year containing the term XML in the title. Note that such an output is often referred to as a histogram in data analysis*/
select c.YEAR, count(p.ID) 
from PUBLICATION p, CONFERENCE c
where p.cid=c.id and p.TITLE like'%XML%'
group by c.YEAR;

/*Q6:What are the three conferences (and years) that had the smallest number of papers? (example format of the output: VLDB 2013).*/
with temp as(
select count(p.id),c.NAME, c.YEAR
from publication p,conference c
where p.CID=c.ID 
group by c.name,c.year 
order by count(p.id) asc
) select t.name,t.year from temp t where ROWNUM<=3;

/*Q7:What are the three conferences that had the largest number of papers?*/
select count(p.id),c.NAME
from publication p,conference c
where p.CID=c.ID 
group by c.name
order by count(p.id) desc;

/*Q8:Output VLDB, SIGMOD and ICDE in descending order based on the number of papers that have
published in each of these conferences across the dataset.*/
select c.NAME,count(p.id) as count
from publication p,conference c
where p.CID=c.ID 
group by c.name 
order by count(p.id) desc

/*Q9:Which last name for authors is the most common one in this database?*/
select count(id),lastname
FROM(SELECT a.id, SUBSTR(a.name,instr(a.name,' ',-1)+1,LENGTH(a.name)) as lastname
FROM author a)
group by lastname
order by count(id) desc;

/*Q10:Which country has hosted ICDE the most number of times and how many times? (The output should be
two columns of a single table.)*/
select location,count(ID)
from conference
where name = 'ICDE'
group by location
order by count(ID) desc;

/*Q11:Name the author(s) with the highest total number of publications in both VLDB and SIGMOD.*/
with temp as (Select a.name,count(p.id) as count
From author a, authorpublication d, publication p, conference c
Where a.id=d.aid and d.pid=p.id and p.cid=c.id and C.NAME='SIGMOD' 
      and a.name in (select a.name
      From author a, authorpublication d, publication p, conference c
      Where a.id=d.aid and d.pid=p.id and p.cid=c.id and C.NAME='VLDB')
Group by a.name
Order by count(p.id) desc)
select t.name, t.count from temp t where ROWNUM<=1;


/*Q12:What is the average number of papers published in SIGMOD, VLDB, and ICDE between 2001 and 2005
(including 2001 and 2005)?*/
select count(p.id)/5.0 as avernum,c.NAME
from publication p,conference c
where p.CID=c.ID  and c.year between 2001 and 2005
group by c.name

/*Q13:Which year of SIGMOD has the lowest value of average authors per paper?*/

with temp as (
select year,name,sum(y*NI)/count(y) as ANAP
from (Select c.year,a.name,p.id,count(p.id) as y
From author a, authorpublication d, publication p, conference c
Where a.id=d.aid and d.pid=p.id and p.cid=c.id 
group by a.NAME,p.id,c.year
order by a.name asc) natural join
(Select p.ID,count(a.name)as Ni,c.year
From author a, authorpublication d, publication p, conference c
Where a.id=d.aid and d.pid=p.id and p.cid=c.id 
group by p.id,c.year)
group by year,name
order by ANAP asc) select t.year,t.ANAP from temp t where rownum=1;

/*Q14:Which author has the third highest value of average authors per paper?*/
with temp as (
select name,sum(y*NI)/count(y) as ANAP
from (Select a.name,p.id,count(p.id) as y
From author a, authorpublication d, publication p, conference c
Where a.id=d.aid and d.pid=p.id and p.cid=c.id 
group by a.NAME,p.id
order by a.name asc) natural join
(Select p.ID,count(a.name)as Ni
From author a, authorpublication d, publication p, conference c
Where a.id=d.aid and d.pid=p.id and p.cid=c.id 
group by p.id)
group by name
order by ANAP desc) select t.name, t.ANAP from temp t where ROWNUM<=3;


/*Q15: List the year(s) in which all three of the conferences VLDB, ICDE and SIGMOD, were held outside
USA.*/
select year
from conference
where id not in(select id from conference where location='USA') and name='SIGMOD'
intersect 
select year
from conference
where id not in(select id from conference where location='USA') and name='VLDB'
intersect
select year
from conference
where id not in(select id from conference where location='USA') and name='ICDE';


/*Q16:List the conference(s) held only outside USA*/
select count(p.id) as count,c.NAME
from publication p,conference c
where p.CID=c.ID 
group by c.name 
order by count(p.id) desc;
