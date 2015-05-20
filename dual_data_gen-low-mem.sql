
-- dual_date_gen-low-mem.sql


/*

 set the number of iterations to return
 if d1 and d2 are set to 1e3 then it will be millions
 set d1 and d2 to 1e2 for thousands

 for:

 mcount := 100
 d1: ie1
 d2: ie2
 generate 100k rows

 ------------------------

 mcount := 100
 d1: ie2
 d2: ie2
 generate 1m rows

 ------------------------

 mcount := 1
 d1: ie3
 d2: ie3
 generate 1m rows

 ------------------------

 mcount := 1
 d1: ie1
 d2: ie2
 generate 1k rows

 ------------------------
*/


var mcount number 
exec :mcount := 100

@mystat pga

with rowgen as (
	select d1.id
	from 
		(select level id from dual connect by level <= 1e1) d1,
		(select level id from dual connect by level <= 1e2) d2,
		(select level id from dual connect by level <= :mcount) d3
)
select count(id) from rowgen
/

@mystat pga



