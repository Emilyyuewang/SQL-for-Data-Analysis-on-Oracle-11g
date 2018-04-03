/* SQL_B   Yue, Wang,114934802 */
drop table author; drop table authorpublication; drop table conference;  drop table publication;
@/Users/emily/Downloads/DBLP_populate.sql;




/*Q1 */ select count(name1) as count_bigger_than_double from ( select count(p.id)as c1,a.name as name1 from Author a,authorpublication d,publication p,conference c where a.id=d.aid and d.pid=p.id and p.cid=c.id and year between 2005 and 2006 group by a. name), ( select count(p1.id) as c2,a1.name as name2 from Author a1,authorpublication d1,publication p1,conference c1 where a1.id=d1.aid and d1.pid=p1.id and p1.cid=c1.id and c1.year between 2000 and 2004 group by a1.name) where name1=name2 and c1>2*c2;




/*Q2:*/ /*all the authors one rank higher than Samuel Madden*/ 
select name,rank from  (SELECT a.name, count(p.id) as count,DENSE_RANK() over(ORDER BY count(p.id) ASC) as rank FROM Author a,authorpublication d,publication p,conference c where a.id=d.aid and d.pid=p.id and p.cid=c.id and c.name='SIGMOD' group by a.name order by count(p.id) ASC)  where rank-(SELECT RANK FROM( SELECT a.name, count(p.id) as count,DENSE_RANK() over(ORDER BY count(p.id) ASC) as rank FROM Author a,authorpublication d,publication p,conference c where a.id=d.aid and d.pid=p.id and p.cid=c.id and c.name='SIGMOD' group by a.name order by count(p.id) ASC)  WHERE NAME='Samuel Madden')=1 order by rank;
/*all the authors one rank lower than Samuel Madden*/ 
select name,rank from  (SELECT a.name, count(p.id) as count,DENSE_RANK() over(ORDER BY count(p.id) ASC) as rank FROM Author a,authorpublication d,publication p,conference c where a.id=d.aid and d.pid=p.id and p.cid=c.id and c.name='SIGMOD' group by a.name order by count(p.id) ASC)  where rank-(SELECT RANK FROM( SELECT a.name, count(p.id) as count,DENSE_RANK() over(ORDER BY count(p.id) ASC) as rank FROM Author a,authorpublication d,publication p,conference c where a.id=d.aid and d.pid=p.id and p.cid=c.id and c.name='SIGMOD' group by a.name order by count(p.id) ASC)  WHERE NAME='Samuel Madden')=-1 order by rank;



 /*Q3*/ with temp as (
select name1,name2,count(t)as count from (select p.id as id2,a.name as name1,p.title as t from Author a,authorpublication d,publication p where a.id=d.aid and d.pid=p.id), (select p1.id as ID1,a1.name as name2,p1.title as t1 from Author a1,authorpublication d1,publication p1 where a1.id=d1.aid and d1.pid=p1.id) where t=t1 and name1 not in name2 and name1>name2 group by name1,name2 order by count(t) desc) select * from temp where rownum<=10;



/*Q4*/ with temp as( select name2,(sigmod+vldb+icde) as Total, SIGMOD,VLDB,ICDE from( select name2, SIGMOD,VLDB from( select a1.name as name2,count(p1.id)as SIGMOD from Author a1,authorpublication d1,publication p1,conference c1 where a1.id=d1.aid and d1.pid=p1.id and p1.cid=c1.id and year between 2001 and 2005 and c1.name='SIGMOD' group by a1.name) left outer join (select a2.name as name3,count(p2.id)as VLDB from Author a2,authorpublication d2,publication p2,conference c2 where a2.id=d2.aid and d2.pid=p2.id and p2.cid=c2.id and year between 2001 and 2005 and c2.name='VLDB' group by a2.name) on name2=name3)left outer join (select a3.name as name4,count(p3.id)as ICDE from Author a3,authorpublication d3,publication p3,conference c3 where a3.id=d3.aid and d3.pid=p3.id and p3.cid=c3.id and year between 2001 and 2005 and c3.name='ICDE' group by a3.name)on name2=name4 where (sigmod+vldb+icde) is not null order by total desc) select * from temp where rownum<=5;



 /*Q5*/ select round((author/author1),3) as fraction from( select count(name) as author from( SELECT a.name, count(c.id) FROM Author a,authorpublication d,publication p,conference c where a.id=d.aid and d.pid=p.id and p.cid=c.id and year=2005 group by a.name having count(distinct c.id)>2)), (select count(name) as author1 from( SELECT a.name, count(c.id) FROM Author a,authorpublication d,publication p,conference c where a.id=d.aid and d.pid=p.id and p.cid=c.id and year=2005 group by a.name having count(c.id)=1));
 


 /*Q6*/
with temp as ( SELECT a.name as author, count(p.id)as count FROM Author a,authorpublication d,publication p where a.id=d.aid and d.pid=p.id and ((p.title like'%XML%' and p.title like'%data%') or(p.title like'%XML%' and p.title like'%database%')) group by a.name order by count(p.id) desc)  select * from temp where rownum<=2;


 /*Q7*/ /*top 10 author have publication more than 4 authors*/ with temp as(select name1 as author,count(t) as count_publication from( select name1,t,count(name2) as count_author from( select name1,name2, t from (select p.id as id2,a.name as name1,p.title as t from Author a,authorpublication d,publication p where a.id=d.aid and d.pid=p.id), (select p1.id as ID1,a1.name as name2,p1.title as t1 from Author a1,authorpublication d1,publication p1 where a1.id=d1.aid and d1.pid=p1.id) where t=t1 and name1 not in name2) group by name1,t having count(name2)>3) group by name1 order by count(t) desc) select * from temp where rownum<=10;




/*Q8*/ /*collaboration ratio of t718he two*/ with temp as (select author,tnop, w_score,round((tnop/w_score),2) as collaboration from( SELECT a.name as auth, count(distinct p.id) as tnop FROM Author a,authorpublication d,publication p,conference c where a.id=d.aid and d.pid=p.id and p.cid=c.id group by a.name )right outer join( select author,round(sum(weigh_publication), 2) as w_score from (select unique t, (1/count(name1))as weigh_publication from( select a.name as name1,p.title as t from Author a,authorpublication d,publication p where a.id=d.aid and d.pid=p.id) group by t)  RIGHT OUTER JOIN( select a.name as author,p.title as title from Author a,authorpublication d,publication p where a.id=d.aid and d.pid=p.id) on t=title group by author) on auth=author order by tnop desc)  select * from temp where rownum<=10;

