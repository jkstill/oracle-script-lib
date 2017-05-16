

-- between 07:00 and 23:59 repeat every 15 minutes on the 15 minute mark
@@test_calendar_string 'FREQ=DAILY;BYHOUR=7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23;BYMINUTE=00,15,30,45' 50


-- between 07:00 and 23:59 repeat every 15 minutes on the 15 minute mark and 0 second mark
@@test_calendar_string 'FREQ=DAILY;BYHOUR=7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23;BYMINUTE=00,15,30,45;BYSECOND=0' 50

-- between 00:00 and 06:00 every 2 hours at the top of the hour
-- midnight, 2, 4 and 6
-- note - bug in 12.1 may cause this to be 1 hour off
@@test_calendar_string 'FREQ=HOURLY;BYHOUR=0,1,2,3,4,5,6;BYMINUTE=00;INTERVAL=2' 30

-- this example is incorrect as it is run every other day - the interval applies to the frequency
--@@test_calendar_string 'FREQ=DAILY;BYHOUR=0,1,2,3,4,5,6;BYMINUTE=00;INTERVAL=2' 30

-- between 00:00 and 06:00 every 2 hours at the top of the hour and second
-- midnight, 2, 4 and 6
@@test_calendar_string 'FREQ=HOURLY;BYHOUR=0,1,2,3,4,5,6;INTERVAL=2;BYMINUTE=00;BYSECOND=0' 30
@@test_calendar_string 'FREQ=HOURLY;BYHOUR=0,2,4,6;BYMINUTE=00;BYSECOND=0' 30

-- this example is incorrect as it is run every other day - the interval applies to the frequency
--@@test_calendar_string 'FREQ=DAILY;BYHOUR=0,1,2,3,4,5,6;BYMINUTE=00;INTERVAL=2;BYSECOND=0' 30

-- every minute on the 42 second mark
@@test_calendar_string 'freq=minutely; bysecond=42;' 5

-- every 15 minutes at 0, 15, 45 and 60 on the 0 second mark
@@test_calendar_string 'freq=hourly; byminute=0,15,30,45; bysecond=0;' 13
