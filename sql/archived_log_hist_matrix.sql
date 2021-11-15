
-- archived_log_hist_matrix.sql
-- acquired from Patricia Shea @ 

/*
 values of 0 are normal at the beginning and as there is likely no data

DAY			 DOW	  00	 01	02	  03	 04	05	  06	 07	08	  09	 10	11	  12	 13	14	  15	 16	17	  18	 19	20	  21	 22	23
------------ ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
2018-MAR-02	 FRI		0	  0	 0		0	  0	 0		0	  0	 0		0	  0	 0		0	  0	 0		0	  0	 6	  20	 19	15	  19	 46	13
2018-MAR-03	 SAT	  16	 14	22	  18	 13	12	  14	 22	14	  14	 15	18	  14	 14	14	  16	 15	15	  17	 19	79	  81	 45	13
2018-MAR-04	 SUN	  14	 13	14	  12	 14	12	  14	 18	17	  13	 15	16	  17	 13	16	  14	 16	17	  15	 13	15	  14	 42	12
2018-MAR-05	 MON	  15	 13	13	  13	 14	13	  13	 20	16	  14	 15	22	  16	 14	16	  14	 16	17	  16	 13	41	  18	 53	14
2018-MAR-06	 TUE	  15	 17	27	  17	 13	12	  14	 22	16	  13	 24	24	  17	 14	16	  13	 17	24	  32	 28	15	  20	 54	14
2018-MAR-07	 WED	  18	 26	19	  12	 14	12	  13	 20	19	  17	 19	23	  17	 15	16	  15	 16	18	  22	 27	26	  35	 61	19
2018-MAR-08	 THU	  23	 22	21	  13	 13	12	  15	 21	22	  17	 16	23	  17	 15	18	  15	 18	22	  54	 27	16	  19	 15	14
2018-MAR-09	 FRI	  18	 20	20	  12	 13	12	  14	 21	15	  14	 17	22	  17	 13	17	  14	 16	18	  22	 17	14	  19	 46	13
2018-MAR-10	 SAT	  16	 12	14	  20	 15	12	  14	 21	13	  13	 16	18	  14	 13	14	  13	 15	14	  18	 14	14	  16	 19	27
2018-MAR-11	 SUN	  30	 12	 0	  14	 13	12	  14	 19	17	  12	 14	19	  15	 13	16	  15	 15	17	  16	 13	15	  15	 40	12
2018-MAR-12	 MON	  15	 13	13	  12	 14	12	  14	 20	14	  19	 17	20	  17	 13	17	  14	 15	18	  16	 17	46	  23	 53	13
2018-MAR-13	 TUE	  16	 19	26	  15	 13	12	  14	 22	25	  21	 20	23	  17	 14	18	  15	 17	28	  27	 30	17	  22	 53	15
2018-MAR-14	 WED	  16	 21	18	  12	 14	12	  14	 22	16	  13	 17	24	  17	 14	17	  14	 15	18	  19	 24	28	  35	 66	18
2018-MAR-15	 THU	  19	 15	14	  22	 15	12	  13	 22	15	  13	 17	23	  17	 13	17	  13	 16	18	  21	 16	14	  18	 30	34
2018-MAR-16	 FRI	  16	 18	19	  12	 14	12	  13	 21	17	  17	 17	22	  17	 14	16	  14	 17	18	  21	 18	14	  19	 15	13
2018-MAR-17	 SAT	  16	 16	23	  12	 14	12	  14	 21	13	  12	 16	20	  16	 12	15	  13	 15	 9		0	  0	 0		0	  0	 0

16 rows selected.

0 in other locations would indicate no log switches and hence no archive logs


*/

set linesize 200 trimspool on
set pagesize 100
set tab off

col day format a12
col dow format a4

col 00 format a4 head '	 00'
col 01 format a4 head '	 01'
col 02 format a4 head '	 02'
col 03 format a4 head '	 03'
col 04 format a4 head '	 04'
col 05 format a4 head '	 05'
col 06 format a4 head '	 06'
col 07 format a4 head '	 07'
col 08 format a4 head '	 08'
col 09 format a4 head '	 09'
col 10 format a4 head '	 10'
col 11 format a4 head '	 11'
col 12 format a4 head '	 12'
col 13 format a4 head '	 13'
col 14 format a4 head '	 14'
col 15 format a4 head '	 15'
col 16 format a4 head '	 16'
col 17 format a4 head '	 17'
col 18 format a4 head '	 18'
col 19 format a4 head '	 19'
col 20 format a4 head '	 20'
col 21 format a4 head '	 21'
col 22 format a4 head '	 22'
col 23 format a4 head '	 23'

SELECT
	to_char(first_time,'YYYY-MON-DD') day,
	to_char(first_time,'DY') dow,
	to_char(sum(decode(to_char(first_time,'HH24'),'00',1,0)),'990') "00",
	to_char(sum(decode(to_char(first_time,'HH24'),'01',1,0)),'990') "01",
	to_char(sum(decode(to_char(first_time,'HH24'),'02',1,0)),'990') "02",
	to_char(sum(decode(to_char(first_time,'HH24'),'03',1,0)),'990') "03",
	to_char(sum(decode(to_char(first_time,'HH24'),'04',1,0)),'990') "04",
	to_char(sum(decode(to_char(first_time,'HH24'),'05',1,0)),'990') "05",
	to_char(sum(decode(to_char(first_time,'HH24'),'06',1,0)),'990') "06",
	to_char(sum(decode(to_char(first_time,'HH24'),'07',1,0)),'990') "07",
	to_char(sum(decode(to_char(first_time,'HH24'),'08',1,0)),'990') "08",
	to_char(sum(decode(to_char(first_time,'HH24'),'09',1,0)),'990') "09",
	to_char(sum(decode(to_char(first_time,'HH24'),'10',1,0)),'990') "10",
	to_char(sum(decode(to_char(first_time,'HH24'),'11',1,0)),'990') "11",
	to_char(sum(decode(to_char(first_time,'HH24'),'12',1,0)),'990') "12",
	to_char(sum(decode(to_char(first_time,'HH24'),'13',1,0)),'990') "13",
	to_char(sum(decode(to_char(first_time,'HH24'),'14',1,0)),'990') "14",
	to_char(sum(decode(to_char(first_time,'HH24'),'15',1,0)),'990') "15",
	to_char(sum(decode(to_char(first_time,'HH24'),'16',1,0)),'990') "16",
	to_char(sum(decode(to_char(first_time,'HH24'),'17',1,0)),'990') "17",
	to_char(sum(decode(to_char(first_time,'HH24'),'18',1,0)),'990') "18",
	to_char(sum(decode(to_char(first_time,'HH24'),'19',1,0)),'990') "19",
	to_char(sum(decode(to_char(first_time,'HH24'),'20',1,0)),'990') "20",
	to_char(sum(decode(to_char(first_time,'HH24'),'21',1,0)),'990') "21",
	to_char(sum(decode(to_char(first_time,'HH24'),'22',1,0)),'990') "22",
	to_char(sum(decode(to_char(first_time,'HH24'),'23',1,0)),'990') "23"
from v$log_history
where first_time > sysdate - 15
GROUP by
to_char(first_time,'YYYY-MON-DD'),to_char(first_time,'DY')
order by 1
/
