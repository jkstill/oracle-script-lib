
create or replace package datemath is

  function get_epoch (timestamp_in timestamp) return number;
  -- works with systimestamp, which is of type timestamp with time zone
  function get_epoch (timestamp_in timestamp with time zone ) return number;
  function get_epoch (date_in date) return number;

  function get_timestamp_from_epoch(p_epoch in number) return timestamp;
  function get_date_from_epoch(p_epoch in number) return date;

end datemath;
/

show errors package datemath

create or replace package body datemath is

/*

systimestamp is not of type timestamp 
calling datemath.get_epoch(systimestamp) will raise an error
ORA-06553: PLS-307: too many declarations of 'GET_EPOCH' match this call

Calling with cast(systimestamp as timestamp) works fine
SQL# select datemath.get_epoch(cast(systimestamp as timestamp)) epoch from dual;

                EPOCH
---------------------
 1756916442.311440000

calling with localtimestamp also works fine
SQL# select datemath.get_epoch(localtimestamp) epoch from dual;

                EPOCH
---------------------
 1756916469.492191000

This is because of the internal representation of systimestamp - it is of type TIMESTAMP WITH TIME ZONE

SQL# select dump(systimestamp) from dual;

DUMP(SYSTIMESTAMP)
----------------------------------------------------------------------
Typ=188 Len=20: 233,7,9,3,16,21,48,0,48,36,211,40,249,0,5,0,0,0,0,0

The type code for TIMESTAMP WITH TIME ZONE is 188, while for TIMESTAMP it is 187

SQL# select dump(TIMESTAMP '1997-01-31 09:26:56.66 +02:00') from dual;

DUMP(TIMESTAMP'1997-01-3109:26:56.66+02:00')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Typ=188 Len=20: 205,7,1,31,7,26,56,0,0,205,86,39,2,0,5,0,0,0,0,0


SQL# select dump(cast(systimestamp as timestamp)) from dual;

DUMP(CAST(SYSTIMESTAMPASTIMESTAMP))
----------------------------------------------------------------------
Typ=187 Len=20: 233,7,9,3,9,22,4,0,72,202,248,43,249,0,3,0,0,0,0,0

1 row selected.

SQL# select dump(localtimestamp) from dual;

DUMP(LOCALTIMESTAMP)
----------------------------------------------------------------------
Typ=187 Len=20: 233,7,9,3,9,22,13,0,96,23,186,20,249,0,3,0,0,0,0,0

1 row selected.

*/


  function get_epoch (timestamp_in timestamp) return number
  is
	 epoch number(16,6);
  begin

	 epoch := (extract(day from(sys_extract_utc(timestamp_in) - to_timestamp('1970-01-01', 'YYYY-MM-DD SSSSSFF9'))) * 86400)
     + to_number(to_char(sys_extract_utc(timestamp_in), 'sssss.ff9')) ;

	 return epoch;

  end;

  -- works with systimestamp
  function get_epoch (timestamp_in timestamp with time zone) return number
  is
	 epoch number(16,6);
  begin

	 epoch := (extract(day from(sys_extract_utc(timestamp_in) - to_timestamp('1970-01-01', 'YYYY-MM-DD SSSSSFF9'))) * 86400)
     + to_number(to_char(sys_extract_utc(timestamp_in), 'sssss.ff9')) ;

	 return epoch;

  end;

  function get_epoch (date_in date) return number
  is
	 epoch number(16);
  begin

	 epoch := (extract(day from(sys_extract_utc(cast(date_in as timestamp)) - to_timestamp('1970-01-01', 'YYYY-MM-DD SSSSS'))) * 86400)
     + to_number(to_char(sys_extract_utc(cast(date_in as timestamp)), 'sssss')) ;

	 return epoch;

  end;

  function get_timestamp_from_epoch(p_epoch in number) return timestamp
  is
  begin
	return to_timestamp('1970-01-01', 'YYYY-MM-DD SSSSSFF9') + numtodsinterval( p_epoch / 86400,'DAY');
  end;

  function get_date_from_epoch(p_epoch in number) return date
  is
  begin
	return to_date('1970-01-01', 'YYYY-MM-DD') + numtodsinterval( p_epoch / 86400,'DAY');
  end;

end datemath;
/

--show errors package body datemath 

prompt check for errors in datemath package
@plsql-error datemath

