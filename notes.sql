select date,count(*) as p from missed group by date order by p desc

-- what sessions have people who will be at saturday missed in decreasing order (and their names)
select m.date,p.firstname from missed m,person p,available a, day d where p.id=m.person_id and p.id=a.person_id and d.id=a.day_id and d.name='Sunday'

select m.date,count(p.firstname) pax from missed m,person p,available a, day d where p.id=m.person_id and p.id=a.person_id and d.id=a.day_id and d.name='Sunday' group by date order by pax desc;


-- descending order of
   -- days by number of available people by sessions missed
-- this appears to have been abandoned
select d.name,p.firstname,count(a.person_id),m.date from 
 day d, available a,person p,missed m where d.name='Friday' and d.id=a.day_id and p.id=a.person_id and p.id=m.person_id and d.name not in('Saturday','Sunday') group by d.name order by d.id;
 
 
 -- more thinking before the action
-- 2 nested group bys to make it work - first to get availability then to get sessions missed
select m.date,p.firstname,d.name,count(m.person_id) pax from day d, available a,person p,missed m where d.id=a.day_id and p.id=a.person_id and p.id=m.person_id and d.name not in('Saturday','Sunday') group by d.name order by pax desc;
 
 


-- Days by sessions missed by available people
 select d.name,m.date,count(distinct m.person_id) pax from person p,missed m,available a,day d where p.id=m.person_id and p.id=a.person_id and a.day_id=d.id group by d.name,m.date order by d.id, pax desc;

-- Days by available people by sessions missed
 select d.name, p.firstname, count(distinct m.date) ses from person p,missed m,available a,day d where p.id=m.person_id and p.id=a.person_id and a.day_id=d.id group by d.name,a.person_id order by d.id, ses desc;
 
 select d.name,m.date,p.firstname from person p,missed m, day d, available a where p.id=m.person_id and a.person_id=p.id and a.day_id=d.id order by m.sort_id
 
 -- Final product for weekend scheduling
 select d.name,m.date,count(p.firstname) avail from person p,missed m, day d, available a where p.id=m.person_id and a.person_id=p.id and a.day_id=d.id and m.complete is null and d.name in('Saturday','Sunday') group by d.name,m.date order by d.id, avail desc
 
 -- Final - days in decreasing order of people's need and availability, and total number of missed sessions for those ppl (not considering whether sessions are in common)
 select d.name, count(z.firstname) num_ppl, sum(z.miss) num_sess from day d,
(select d.name,p.firstname,count(m.date) miss from person p,missed m,available a,day d where p.id=m.person_id and p.id=a.person_id and a.day_id=d.id group by d.name,p.firstname) z
where d.name=z.name group by d.name order by num_ppl desc, num_sess desc

-- From here - days in decreasing order of availability and # sessions which at least 50% of ppl missed
select d.name, count(z.firstname) num_ppl, sum(z.miss) num_sess from day d,
(select d.name,p.firstname,count(m.date) miss from person p,missed m,available a,day d where p.id=m.person_id and p.id=a.person_id and a.day_id=d.id group by d.name,p.firstname) z
where d.name=z.name group by d.name order by num_ppl desc, num_sess desc

select d.name,p.firstname,count(m.date) miss from person p,missed m,available a,day d where p.id=m.person_id and p.id=a.person_id and a.day_id=d.id group by d.name,p.firstname
-- want session day, catch up day, num ppl avail on that day
select z.date, z.name, max(num_ppl) num_ppl from
(select m.date,d.name,count(a.person_id) num_ppl from missed m,day d,available a where m.person_id=a.person_id and a.day_id=d.id group by m.date,d.name) z,
missed m, day d where z.date=m.date and z.name=d.name
group by z.date,z.name order by d.id,num_ppl desc

-- And a grand total of num_ppl per night (although isn't that what I did above? :/)
select x.name,count(x.date) sessions,sum(num_ppl) people from(
select z.date, z.name, max(num_ppl) num_ppl from
(select m.date,d.name,count(a.person_id) num_ppl from missed m,day d,available a where m.complete is null and m.person_id=a.person_id and a.day_id=d.id group by m.date,d.name) z,
missed m, day d where z.date=m.date and z.name=d.name
group by z.date,z.name) x, day d where x.name=d.name
group by x.name order by people desc,sessions desc;

, missed m, day d where x.name=d.name and m.sort_id=(select min(sort_id) from missed m2 where m2.date=x.date)
group by x.name 
-- sat, sess 35, ppl 115?
-- x has date, day name
 x, missed m, day d where x.date=m.date and x.name=d.name
 order by d.id,num_ppl desc
 
 update missed set complete=1 where person_id in(select person_id from available a,day d where a.day_id=d.id and d.name='Saturday') and date in('16/9','2/9','26/8','19/8')
 
 - Who is available Saturday & missed 16/9 -- select firstname, date, d.name from person p,available a,missed m,day d where p.id=a.person_id and p.id=m.person_id and a.day_id=d.id and d.name='Saturday' and date='16/9';
 select d.name, m.date, count(p.firstname) num_ppl from person p,available a,missed m,day d where p.id=a.person_id and p.id=m.person_id and a.day_id=d.id and d.name='Saturday' and date in('16/9','2/9','26/8','19/8') group by date order by num_ppl desc
 
 Who has no availability?
 select * from person where id in (select distinct person_id from missed where person_id not in (select distinct person_id from available));
 id          firstname   lastname  
----------  ----------  ----------
1           Andrew      Krupa     
9           Matt        Robinson  
14          Ronnie      Cargill   
 
 -- Who is available one of Saturday or Sunday?:
 select p.firstname, count(*) wknd from person p inner join available a on p.id=a.person_id inner join day d on a.day_id=d.id where p.id=a.person_id and d.name in ('Saturday','Sunday') group by p.firstname having wknd<2;

-- What sessions have they missed?
select firstname,date from person p,missed m where p.id=m.person_id and firstname in(select firstname from (
  select p.firstname, count(*) wknd from person p inner join available a on p.id=a.person_id inner join day d on a.day_id=d.id where p.id=a.person_id and d.name in ('Saturday','Sunday') group by p.firstname having wknd<2
)) order by sort_id

-- available by session missed by day
select d.name, date, firstname from person p,missed m,available a,day d where a.day_id=d.id and p.id=m.person_id and p.id=a.person_id and a.day_id in(select id from day where name in('Saturday','Sunday')) and date in('16/9','2/9','26/8','19/8')


select d.name, date, firstname from person p,missed m,available a,day d where a.day_id=d.id and p.id=m.person_id and p.id=a.person_id and a.day_id in(select id from day where name in('Saturday','Sunday')) and date in('16/9','2/9','26/8','19/8') and p.firstname in
(select firstname from (select p.firstname, count(*) wknd from person p inner join available a on p.id=a.person_id inner join day d on a.day_id=d.id where p.id=a.person_id and d.name in ('Saturday','Sunday') group by p.firstname having wknd<2))


 - For those that can only attend Sat 
  select date,p.firstname from missed m,person p where p.id=m.person_id and p.id in(2,13,15,17) order by sort_id;
  select date,count(*) tot from missed where person_id in(2,13,15,17) group by date order by tot desc;

== Most valuable sessions to run over weekend based on availability
seelect date,avg(pax) foo from (
  select d.name,m.date,count(distinct m.person_id) pax from person p,missed m,available a,day d where d.name in('Saturday','Sunday') and p.id=m.person_id and p.id=a.person_id and a.day_id=d.id group by d.name,m.date order by d.id, pax desc)
group by date order by foo desc;
  

   - Impact of completing thtru to 23/9
   update missed set complete=1 where date in('2/9','16/9','26/8','23/9') and person_id in(select person_id from available a,day d where a.day_id=d.id and name='Sunday');
   -- Who is avail Sun and missed sessions being run
   select a.person_id,firstname,count(date) sessions from person p,available a,day d, missed m where p.id=a.person_id and p.id=m.person_id and d.id=a.day_id and m.date in('2/9','16/9','26/8','23/9') and d.name='Sunday' group by a.person_id,firstname

-- Schedule for those attending part of the day (once session filled with topic info)
select firstname,start,end,s.date,details from person p,available a,missed m,day d,session s where p.id=a.person_id and p.id=m.person_id and a.day_id=d.id and s.day_id=d.id and s.date=m.date order by start,firstname;
-- As well as what times individuals need to attend
select firstname,start,end,s.date,details from person p,available a,missed m,day d,session s where p.id=a.person_id and p.id=m.person_id and a.day_id=d.id and s.day_id=d.id and s.date=m.date order by firstname,start;

   -- At this point confirm the night most are available, & numm soessions, etc
   -- basic availability
   select d.name, m.date, p.firstname from day d,missed m,available a,person p where p.id=m.person_id and p.id=a.person_id and d.id=a.day_id
   
   -- Tuesday remains the best night
   select name, count(date) dates,sum(foo) bar, (sum(foo)+count(date))/2 ave from (
      select d.name, m.date, count(p.firstname) foo from day d,missed m,available a,person p where p.id=m.person_id and p.id=a.person_id and d.id=a.day_id group by d.name,m.date
   ) group by name order by ave desc

-- After going through Sunday what are the most useful sessions to cover on Tuesday?
-- available tuesday, date by reducing number of people
select m.date,count(p.firstname) num from person p,missed m,available a,day d where p.id=m.person_id and p.id=a.person_id and a.day_id=d.id and d.name='Tuesday' group by date order by num desc
-- What if we do 2 nights on a Tuesday? 23/9 and 9/9 
update missed set complete=1 where date in('23/9','9/9') and person_id in(select person_id from available a,day d where a.day_id=d.id)
-- What is the best day now, based on who has what left to do?
select name, count(date) dates,sum(foo) bar, (sum(foo)+count(date))/2 ave from (
      select d.name, m.date, count(p.firstname) foo from day d,missed m,available a,person p where p.id=m.person_id and p.id=a.person_id and d.id=a.day_id and m.complete is null and d.name not in('Saturday','Sunday','Tuesday') group by d.name,m.date
   ) group by name order by ave desc
-- Monday sessions not worthwhile
select m.date,count(p.firstname) num from person p,missed m,available a,day d where p.id=m.person_id and p.id=a.person_id and a.day_id=d.id and d.name='Monday' and m.complete is null group by date order by num desc
-- urgh.

-- Is anything?
select m.date,d.name,firstname from person p,missed m,available a, day d where p.id=a.person_id and a.person_id=m.person_id and complete is null and d.id=a.day_id group by m.date,d.name,firstname order by shared desc
--......
--

select date,d.name,count(*) shared from missed m,available a,day d where d.id=a.day_id and a.person_id=m.person_id and complete is null group by date,a.day_id;
select d.name, date, count(*) shared from missed m,available a,day d where d.id=a.day_id and a.person_id=m.person_id and complete is null group by d.name,date order by shared desc;
-- Next best option is another tuesday where 2 can attend :) 26/8
update missed set complete=1 where date='26/8' and person_id in(select person_id from available a,day d where a.day_id=d.id and d.name='Tuesday')

-- What do things look like from there?
-- Down 14 sessions across 7 people
select firstname,count(*) total from person p,missed m where p.id=m.person_id and complete is null group by firstname order by total desc;
firstname   total     
----------  ----------
Andrew      4         
Gary        3         
Matt        2         
Ronnie      2         
Bernd       1         
Sam         1         
Shawn       1    

firstname   date      
----------  ----------
Andrew      26/8      
Andrew      2/9       
Andrew      16/9      
Andrew      23/9      
Bernd       19/8      
Gary        12/8      
Gary        19/8      
Gary        2/9       
Matt        19/8      
Matt        16/9      
Ronnie      26/8      
Ronnie      2/9       
Sam         16/9      
Shawn       12/8      

select firstname,d.name,count(*) total from person p,missed m,available a,day d where p.id=a.person_id and a.day_id=d.id and p.id=m.person_id and complete is null group by firstname order by total desc;
select * from available a,missed m where a.person_id=m.person_id 


-- confirm all is bunk from here
-- can't group by day ... person too much effort
select d.name,m.date,p.firstname,count(*) ppl from available a,missed m,person p,day d where a.person_id=m.person_id and p.id=a.person_id and d.id=a.day_id and complete is null group by d.name,m.date,firstname ;

select name,date,count(firstname) from(
select d.name,m.date,p.firstname,count(*) ppl from available a,missed m,person p,day d where a.person_id=m.person_id and p.id=a.person_id and d.id=a.day_id and complete is null group by d.name,m.date,firstname
) group by name,date;

select name,date,count(firstname) from(
select d.name,m.date,p.firstname,count(*) ppl from available a,missed m,person p,day d where a.person_id=m.person_id and p.id=a.person_id and d.id=a.day_id and complete is null group by d.name,m.date,firstname
) group by name,date;

-- Outstanding sessions sorted by person
select firstname,date from person p,missed m where p.id=m.person_id and complete is null order by firstname;