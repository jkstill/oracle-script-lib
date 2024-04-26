
<html>
<body>
<pre>
</pre>
<h3>TUNING: scripts to aid with Tuning and SQL Performance</h3>
<pre>
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dbms-sqltune-sqlid.sql'>dbms-sqltune-sqlid.sql</a> - call with SQL_ID, create and execute a tuning task, run the report
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/find-expensive-sql.sql'>find-expensive-sql.sql</a> - AWR - find expensive SQL in terms of high LIO
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/get-expensive-sqlid-sts.sql'>get-expensive-sqlid-sts.sql</a> - AWR - find expensive SQL in terms of high LIO
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/profile_from_awr.sql'>profile_from_awr.sql</a> - create a SQL Profile from plan in AWR
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sql-performance/sql-buffer-ratios-awr.sql'>sql-performance/sql-buffer-ratios-awr.sql</a> - report on rows returned per execution
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sql-performance/sql-buffer-ratios.sql'>sql-performance/sql-buffer-ratios.sql</a> - report on buffers
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sql-performance/sql-exe-times-awr-rpt.pl'>sql-performance/sql-exe-times-awr-rpt.pl</a> - a Perl script that generates a report on SQL Execution time
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sql-exe-events-ash.sql'>sql-exe-events-ash.sql</a> - show events per execution of SQL_ID in ASH
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sql-exe-events-awr.sql'>sql-exe-events-awr.sql</a> - show events per execution of SQL_ID in AWR
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sql-exe-times-ash-rpt.sql'>sql-exe-times-ash-rpt.sql</a> - ASH report of execution times for a SQL_ID
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sql-exe-times-awr-rpt.sql'>sql-exe-times-awr-rpt.sql</a> - AWR report of execution times for a SQL_ID
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sql-exe-times-ash.sql'>sql-exe-times-ash.sql</a> - stats and histograms of execution times for a SQL_ID
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sql-exe-times-awr.sql'>sql-exe-times-awr.sql</a> - stats and histograms of execution times for a SQL_ID for past 30 days
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sql-exe-times-awr-histogram.sql'>sql-exe-times-awr-histogram.sql</a> - histogram of execution times for a SQL_ID
</pre>
<h3>APEX: Anything to do with Apex</h3>
<pre>
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/apex-version.sql'>apex-version.sql</a> - Get the version of Apex. For CDB/PDB, run from both.
</pre>
<h3>LIB ADMIN:</h3>
<pre>
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/distribution.sh'>distribution.sh</a> - the script that builds the linux tar and windows zips files
</pre>
<h3>BACKUP and RECOVERY:</h3>
<pre>
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/rman-bkup-status.sql'>rman-bkup-status.sql</a> - Status of backups
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/rman-bkup-details.sql'>rman-bkup-details.sql</a> - Details for a backup set
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/rman-recovery-scn.sql'>rman-recovery-scn.sql</a> - determine the SCN from which the database must be restored and recovered
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/rman-recovery-min-scn.sql'>rman-recovery-min-scn.sql</a> - determine minimum restore and recover SCN values
</pre>
<h3>PARALLEL PROCESSING:</h3>
<pre>
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/px.sql'>px.sql</a> - query gv$px_process to see all parallel slaves clusterwide-works for single node too
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/pq-ash-all.sql'>pq-ash-all.sql</a> - aggregate PQ query counts per time period
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/pq-ash-sqlid.sql'>pq-ash-sqlid.sql</a> - aggregate PQ per sqlid and time
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/pq-awr-all.sql'>pq-awr-all.sql</a> - aggregate PQ per time period
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/pq-awr-sqlid.sql'>pq-awr-sqlid.sql</a> - aggregate PQ per sqlid and time
</pre>
<h3>SUPPORTING SCRIPTS:</h3>
<pre>
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/ascii.sql'>ascii.sql</a> - generate a simple ascii table
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/bad-date.sql'>bad-date.sql</a> - Oracle believes there is a year zero
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/bitwalk.sql'>bitwalk.sql</a> - discover which bits are set in a bitmap column
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/clears.sql'>clears.sql</a> - clear sqlplus settings
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/clear_for_spool.sql'>clear_for_spool.sql</a> - set sqlplus for spooling output without headers,etc
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/colors.sql'>colors.sql</a> - define values for sqlprompt colors
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/columns.sql'>columns.sql</a> - several sqlplus column settings
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/enqueue-bitand.sql'>enqueue-bitand.sql</a> - Demonstrate how to decode v$session.p1 values for enqueue waits
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/get_date_range.sql'>get_date_range.sql</a> - get begin and end date, put in vars - also date format var
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/get-schema-name.sql'>get-schema-name.sql</a> - prompt for schema name - schema name can be passed as a parameter
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/get-table-name.sql'>get-table-name.sql</a> - prompt for table name - table name can be passed as a parameter
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/opcodes.sql'>opcodes.sql</a> - list of SQL opcodes for use in 10g-. See cpu-busy.sql
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/oversion_minor.sql'>oversion_minor.sql</a> - get the XX.xx version of oracle and store in &v_oversion_minor
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/oversion_major.sql'>oversion_major.sql</a> - get the XX version of oracle and store in &v_oversion_major
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/ttitle.sql'>ttitle.sql</a> - set title and width
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/title.sql'>title.sql</a> - set title and width
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/title80.sql'>title80.sql</a> - set title and width to 80
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/title132.sql'>title132.sql</a> - title and width to 132
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/nls_date_format.sql'>nls_date_format.sql</a> - set custom date and time formats, several options available at runtime
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/nls_time_format.sql'>nls_time_format.sql</a> - set custom (fixed) date and time formats
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/spool_example.sql'>spool_example.sql</a> - spool log template
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/spool-example-2.sql'>spool-example-2.sql</a> - another spool template - log file with timestamp
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/scott.sql'>scott.sql</a> - create the scott tables
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sql_trick_1.sql'>sql_trick_1.sql</a> - demonstrates a very useful technique for conditionally executing SQL
</pre>
<h3>RDBMS UTILITIES:</h3>
<pre>
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/10046.sql'>10046.sql</a> - Set event 10046 in a session
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/10046_off.sql'>10046_off.sql</a> - Stop event 10046 in a session
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/block_decode.sql'>block_decode.sql</a> - find which object a block belongs to
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/bootstrap_objects.sql'>bootstrap_objects.sql</a> - report objects from sys.bootstrap$ that may not be modified
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/cluster-factor.sql'>cluster-factor.sql</a> - get the clustering factor for all indexes on a table
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/cores.sql'>cores.sql</a> - report the number of CPU cores from v$osstat - may be subject to hyperthreading
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dirs.sql'>dirs.sql</a> - show database directories
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dp-filter-types.sql'>dp-filter-types.sql</a> - show the filters available for expdp/impdp
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dual_data_gen.sql'>dual_data_gen.sql</a> - generate many rows from dual - uses a lot of memory for large number of rows
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dual_data_gen-low-mem.sql'>dual_data_gen-low-mem.sql</a> - generate many rows without using extra PGA
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dbms_log.sql'>dbms_log.sql</a> - use sys.dbms_log to write to log and trace files - 11.2.0.4+
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dbms_output-allow-blank-lines.sql'>dbms_output-allow-blank-lines.sql</a> - just a demo of how to create blank lines via 'set format wrapped'
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dbms_system_undoc_calls.sql'>dbms_system_undoc_calls.sql</a> - some undocumented dbms_system calls - how to write to alert.log
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dumptrace_off.sql'>dumptrace_off.sql</a> - Turn on SQL_trace in a session
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dumptrace_on.sql'>dumptrace_on.sql</a> - Turn off SQL_trace in a session
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dumptracem_off.sql'>dumptracem_off.sql</a> - Turn on SQL_trace for all sessions for a user
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dumptracem_on.sql'>dumptracem_on.sql</a> - Turn off SQL_trace for all sessions for a user
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dup-user-profile.sql'>dup-user-profile.sql</a> - Duplicate a user profile
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dup_role.sql'>dup_role.sql</a> - Generate SQL script to duplicate a database role
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dup_role_users.sql'>dup_role_users.sql</a> - Generate SQL script to duplicate all users of a role
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dup_user.sql'>dup_user.sql</a> - Generate SQL script to duplicate a database user
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dump.sql'>dump.sql</a> - Dump a table to a CSV file, generate SQL Loader parameter and control files.
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/find-index-sql.sql'>find-index-sql.sql</a> - find SQL where an index has been used - uses AWR
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/gen_data_with_recursion.sql'>gen_data_with_recursion.sql</a> - use a recursive subfactored query to generate rows
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/gen_fk_from-11.1.sql'>gen_fk_from-11.1.sql</a> - generate existing foreign key constraints from data dictionary
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/gen_fk_from-11.2.sql'>gen_fk_from-11.2.sql</a> - generate existing foreign key constraints from data dictionary
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/gen_fk_to-11.1.sql'>gen_fk_to-11.1.sql</a> - generate existing foreign key constraints from data dictionary
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/gen_fk_to-11.2.sql'>gen_fk_to-11.2.sql</a> - generate existing foreign key constraints from data dictionary
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/gen_list_data_with_dual.sql'>gen_list_data_with_dual.sql</a> - generating test data with dual
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/gen_list_data_without_dual.sql'>gen_list_data_without_dual.sql</a> - generating test data without dual - 10g+
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/generate-sql.sql'>generate-sql.sql</a> - generate a basic SELECT SQL script for owner and table
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/get-schema-size.sql'>get-schema-size.sql</a> - estimate size for export of each non-system schema
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/gethostname.sql'>gethostname.sql</a> - get the hostname into substitution variable uhostname
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/getinstance.sql'>getinstance.sql</a> - get the instance name into substitution variable uinstance
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/getinstanceowner.sql'>getinstanceowner.sql</a> - get the instance owner into substitution variable uinstanceowner
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/getpid.sql'>getpid.sql</a> - get the session PID into substitution variable upid
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/gettracefile.sql'>gettracefile.sql</a> - copy the current sessions tracefile from the host
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/gettrcname.sql'>gettrcname.sql</a> - get the name of the current sessions tracefile into substitution variable utracefile
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/hash-function.sql'>hash-function.sql</a> - create a PL/SQL package 'hash' containing digest functions using dbms_crypto
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/hwm-df.sql'>hwm-df.sql</a> - Find the high water mark for each datafile and determine how much each file can be shrunk
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/oracle-data-types.sql'>oracle-data-types.sql</a> - show oracle data types with id# and name
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/oradebug_doc.sql'>oradebug_doc.sql</a> - dump the documentation for oradebug
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/print_table_2.sql'>print_table_2.sql</a> - Tom Kytes print_table, but as an anonymous block
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/pt.sql'>pt.sql</a> - similar to Tom Kytes print_table, but no stored procedure required and better quoting
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/q_quote.sql'>q_quote.sql</a> - demo for the q[] quoting mechanism in SQL - 10g+ I think
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/remove-sqlplus-settings.sql'>remove-sqlplus-settings.sql</a> - remove the 'store set' temp file
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/restore-sqlplus-settings.sql'>restore-sqlplus-settings.sql</a> - restore sqlplus settings from a temp flie
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/save-sqlplus-settings.sql'>save-sqlplus-settings.sql</a> - save sqlplus settings to a temp file
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/set-default-profile-unlimited.sql'>set-default-profile-unlimited.sql</a> - Used to elimnate password timeouts in test databases
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/set_events.sql'>set_events.sql</a> - various methods to set events, including per sql_id
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/show_event_messages.sql'>show_event_messages.sql</a> - List events 1000-10999
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/spacemap.sql'>spacemap.sql</a> - create a map of segments and free space
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/spacemap_rpt.sql'>spacemap_rpt.sql</a> - report on spacemap created by spacemap.sql
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/spacemap_sum.sql'>spacemap_sum.sql</a> - create a summary of space as created by spacemap.sql
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/spacemap_sum_rpt.sql'>spacemap_sum_rpt.sql</a> - report on space summary table created by spacemap_sum.sql
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sqlid-trace.sql'>sqlid-trace.sql</a> - set 10046 or 10053 trace per sqlid regardless of session
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sql-command-types.sql'>sql-command-types.sql</a> - list all sql available commands
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/tracefile.sql'>tracefile.sql</a> - get the name of the tracefile for your session
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/tracefile-dump.sql'>tracefile-dump.sql</a> - dumot the tracefile for your session to a local tracefile
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/troff.sql'>troff.sql</a> - Turn off SQL tracing for all sessions of an account
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/tron.sql'>tron.sql</a> - Turn on SQL tracing for all sessions of an account
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/oracle-object-types.txt'>oracle-object-types.txt</a> - a text file of the object types recognized by dbms_metadata.get_ddl
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/table_ddl.sql'>table_ddl.sql</a> - generate DDL for owner.table, with indexes, constraints, etc
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/user_ddl.sql'>user_ddl.sql</a> - Generate SQL script to duplicate a database user using DBMS_METADATA
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/utl_file-test.sql'>utl_file-test.sql</a> - Test the use of a database directory and file.
</pre>
<h3>TEMPORARY SEGMENTS/SORTS:</h3>
<pre>
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showtemp.sql'>showtemp.sql</a> - show who owns TEMP segments and type of segment
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/whotmp8i.sql'>whotmp8i.sql</a> - show who owns TEMP segments - more info than showtemp.sql
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showsort.sql'>showsort.sql</a> - Show sort activity
</pre>
<h3>IO:</h3>
<pre>
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/avg_disk_times.sql'>avg_disk_times.sql</a> - Show avg physical read/write times
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/who5.sql'>who5.sql</a> - physical IO per session
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/io_begin.sql'>io_begin.sql</a> - Save snapshot of current file IO statistics
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/io_end.sql'>io_end.sql</a> - Save snapshot of current file IO statistics
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/io_order.sql'>io_order.sql</a> - Shows snapshot of IO stats based on io_begin and io_end
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/io_stat2.sql'>io_stat2.sql</a> - Shows snapshot of IO stats based on io_begin and io_end
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/io_stat3.sql'>io_stat3.sql</a> - Shows snapshot of IO stats based on io_begin and io_end
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/io_stat.sql'>io_stat.sql</a> - Shows snapshot of IO stats based on io_begin and io_end
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/io_tbs.sql'>io_tbs.sql</a> - Shows snapshot of IO stats based on io_begin and io_end
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/lfsdiag.sql'>lfsdiag.sql</a> - diagnose logfile sync
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/ioweight.sql'>ioweight.sql</a> - Show IO per tablespace order by weight
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/redo-per-second.sql'>redo-per-second.sql</a> - show min/max redo per second
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/redo-rate.sql'>redo-rate.sql</a> - show real time redo rates at the db level
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showtrans.sql'>showtrans.sql</a> - Show current transactions with IO
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/trans_per_hour.sql'>trans_per_hour.sql</a> - Transactions per hour with statistics per xaction
</pre>
<h3>EVENTS:</h3>
<pre>
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/my-events.sql'>my-events.sql</a> - display session stats
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/event-names.sql'>event-names.sql</a> - display wait_class, name and parameters from v$event_name
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/idle-events.sql'>idle-events.sql</a> - show events marked as 'idle'
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/set_events.sql'>set_events.sql</a> - various methods of generating trace and dump info with events
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sysevent_begin.sql'>sysevent_begin.sql</a> - Beginning snapshot of system events
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sysevent_end.sql'>sysevent_end.sql</a> - Ending snapshot of system events
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sysevent_rpt.sql'>sysevent_rpt.sql</a> - Report on system event snapshots
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sessevent2.sql'>sessevent2.sql</a> - Show events from v$session_event
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sessevent.sql'>sessevent.sql</a> - Show events from v$session_event
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/session_fix.sql'>session_fix.sql</a> - Show fix_control_settings for session
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/system_fix.sql'>system_fix.sql</a> - Show fix_control_settings for system
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/system_fix_all.sql'>system_fix_all.sql</a> - Show all fix_control_settings for system
</pre>
<h3>WAITS/LOCKS/LATCHES and PERFORMANCE:</h3>
<pre>
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/active_status.sql'>active_status.sql</a> - show which current active sessions are on CPU
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/cpu-killer.sql'>cpu-killer.sql</a> - max out a CPU. Do Not use in production!
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/extproc-sessions.sql'>extproc-sessions.sql</a> - show extproc information when sessions are waiting extproc processes
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/itl_waits.sql'>itl_waits.sql</a> - show itl waits - increase initrans
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/itl_waits_hist.sql'>itl_waits_hist.sql</a> - show itl waits history
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showlatch.sql'>showlatch.sql</a> - Show latches and stats
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showlock.sql'>showlock.sql</a> - Show locks in database with waiters and blockers
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showlock2.sql'>showlock2.sql</a> - Replaces showlock.sql. Works much better for recent (12c+) Oracle versions
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/getstat.sql'>getstat.sql</a> - called by getstats.sql
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/getstats.sql'>getstats.sql</a> - Get stats from v$sysstat
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/getstatu2.sql'>getstatu2.sql</a> - Get stats from v$sesstat
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/latch_statsa.sql'>latch_statsa.sql</a> -
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/latch_statss.sql'>latch_statss.sql</a> -
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/segment-space-statistics.sql'>segment-space-statistics.sql</a> - get changes made per segment - currently set for 'db block changes'
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/segment-space-statistics-hist.sql'>segment-space-statistics-hist.sql</a> - get historical changes made per segment - currently set for 'db block changes'
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/segment-statistics.sql'>segment-statistics.sql</a> - show statistics from v$segment_statistics for an object
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sesswait.sql'>sesswait.sql</a> - Show waits from v$session_wait - calls the script linked or copied to sesswaitu.sql
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sesswaitu.sql'>sesswaitu.sql</a> - script called by sesswait.sql - copy or softlink one of the following sesswait scripts
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sesswaitug.sql'>sesswaitug.sql</a> - similar to sesswaitu.sql, but uses gv$ views
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sesswaitp.sql'>sesswaitp.sql</a> - show current waits for a session id - may call as '@sesswaitp SID'
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sesswaitu72.sql'>sesswaitu72.sql</a> - sesswaitu for 72
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sesswaitu73.sql'>sesswaitu73.sql</a> - sesswaitu for 73
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sesswaitu10g.sql'>sesswaitu10g.sql</a> - sesswaitu for 10g
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sesswaitu_112.sql'>sesswaitu_112.sql</a> - sesswaitu for 11.2
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/snapper.sql'>snapper.sql</a> - Tanel Poder script extraordinaire
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dba_kgllock.sql'>dba_kgllock.sql</a> - show waiters/blockers on library cache locks.
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/libcachepin_waits.sql'>libcachepin_waits.sql</a> - if there are waits on Library Cache Pin in v$session_wait this script will show what the waits are for, and which session is causing them
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/mystat.sql'>mystat.sql</a> - query v$mystat
</pre>
<h3>AWR/ASH:</h3>
<pre>
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/aas.sql'>aas.sql</a> - get AAS (average active sessions) from gv$sysmetric
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/aas-awr-calc.sql'>aas-awr-calc.sql</a> - dump AAS calculated from AWR to CSV file
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/aas-ash-calc.sql'>aas-ash-calc.sql</a> - report AAS calculated from ASH
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/aas-awr-pdb-calc.sql'>aas-awr-pdb-calc.sql</a> - calculate AAS per PDB from AWR data. Cuz Oracle does not do it.
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/ash-sql-ops.sql'>ash-sql-ops.sql</a> - show the db operation per row in ASH for each sql, with elapsed time
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/aas-std.sql'>aas-std.sql</a> - dump AAS from dba_hist_sysmetric_history to CSV file
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/aas_hist_metrics.sql'>aas_hist_metrics.sql</a> - get average active sessions along with CPU metrics
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/aas_history.sql'>aas_history.sql</a> - get history of Average Active Sessions
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/ash-all-events-5-pct.sql'>ash-all-events-5-pct.sql</a> - show events per SQL where the event consumes > 5% of db time for the execution of that SQL
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/ash-blocker-waits.sql'>ash-blocker-waits.sql</a> - find top level blockers in ASH
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/ash-enq-obj.sql'>ash-enq-obj.sql</a> - For all enqueue events in ASH, aggregate on block#, generate SQL to Investigate hot blocks
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/ash-events.sql'>ash-events.sql</a> - simple filtered query on ASH events for a SQL_ID
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/ash-itl-waits.sql'>ash-itl-waits.sql</a> - show recent ITL waits
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/ash-sessions.sql'>ash-sessions.sql</a> - frequency of sessions for a user
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/ash-snapshot-define-begin-end.sql'>ash-snapshot-define-begin-end.sql</a> - example of how to bracket snap_id
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/ash-waits-user.sql'>ash-waits-user.sql</a> - summarize ASH all wait time for a user
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/ash_blockers.sql'>ash_blockers.sql</a> - current blocking aggregated by event
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/ash_blockers_10g.sql'>ash_blockers_10g.sql</a> - find top level blockers in ASH for 10g
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/ash_blocking.sql'>ash_blocking.sql</a> - get list of row lock blocks - blocked and blockers with SQL_ID
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/ash_cpu_hist.sql'>ash_cpu_hist.sql</a> - cpu historic usage from dba_hist_sysmetric_history - 12c+
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/ash-current-waits.sql'>ash-current-waits.sql</a> - find the current top wait events per SQL by class and event
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/ash-current-waits-by-sql.sql'>ash-current-waits-by-sql.sql</a> - find the current top 20 SQL by execution time per session that occurred in a single session
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/ash-current-waits-by-sql-event.sql'>ash-current-waits-by-sql-event.sql</a> - find the current top 20 SQL by execution time per event that occurred in a single session
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/ash-sqlid-event-window.sql'>ash-sqlid-event-window.sql</a> - show top SQL within window of time, such as from 1 minute before to 1 minute after the top of each hour
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/ash-top-events.sql'>ash-top-events.sql</a> - top 10 report of waits in ASH - per instance and cluster
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/ash_log_sync.sql'>ash_log_sync.sql</a> - log sync events
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/ashdump.sql'>ashdump.sql</a> - create an ASH Dump - be sure to read the comments in the script
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/ashdump-summary.sql'>ashdump-summary.sql</a> - example script to view ASHDUMP data
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/ashtop.sql'>ashtop.sql</a> - Tanel Poder script for top ASH events
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/awr-blocker-waits.sql'>awr-blocker-waits.sql</a> - find top level blockers in AWR
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/awr-cpu-stats.sql'>awr-cpu-stats.sql</a> - Report on sar like CPU stats from AWR
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/awr-enq-hot-blocks.sql'>awr-enq-hot-blocks.sql</a> - find TX waits (including ITL) waits, sum up the top 10 waits per file and block
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/awr-enq-obj.sql'>awr-enq-obj.sql</a> - For all enqueue events in AWR, aggregate on block#, generate SQL to Investigate hot blocks
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/awr-export.sql'>awr-export.sql</a> - export AWR - useful for pre-migration work
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/awr-get-retention.sql'>awr-get-retention.sql</a> - Display AWR retention and interval
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/awr-hist-model-top10.sql'>awr-hist-model-top10.sql</a> - Show Top 10 Snapshots based on DB Time + DB CPU from DBA_HIST_SYS_TIME_MODEL
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/awr-itl-waits.sql'>awr-itl-waits.sql</a> - find ITL waits
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/awr-resource-limit.sql'>awr-resource-limit.sql</a> - history of processes and sessions from dba_hist_resource_limit
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/awr-set-retention.sql'>awr-set-retention.sql</a> - Example of setting AWR retention and interval
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/awr-top-10-daily.sql'>awr-top-10-daily.sql</a> - list top 10 events per day from AWR
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/awr-top-5-events.sql'>awr-top-5-events.sql</a> - similar to awr-top-events.sql. reports on past 7 days, shows pct of time used
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/awr-top-events.sql'>awr-top-events.sql</a> - get the top events from AWR per instance for a date range
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/awr-top-sqlid-events.sql'>awr-top-sqlid-events.sql</a> - get the top events from AWR per instance and SQL_ID for a date range
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/awr-trans-counts.sql'>awr-trans-counts.sql</a> - show summary of user commits, rollbacks and log sync writes by day
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/awr_RAC_defined.sql'>awr_RAC_defined.sql</a> - Run a non-interactive AWR report on RAC
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/awr_blockers.sql'>awr_blockers.sql</a> - historic blocking aggregated by sql_id
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/awr_bracket_baseline.sql'>awr_bracket_baseline.sql</a> - create a named and self expiring AWR baseline based on event time
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/awr_bracket_snaps.sql'>awr_bracket_snaps.sql</a> - get snap_id values for a pair of days
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/awr_create_snapshot.sql'>awr_create_snapshot.sql</a> - create an AWR snapshot
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/awr_defined.sql'>awr_defined.sql</a> - Run a non-interactive AWR report
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/awr_display_baselines.sql'>awr_display_baselines.sql</a> - display AWR baselines
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/awr_drop_baseline.sql'>awr_drop_baseline.sql</a> - drop an AWR baseline
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/awr_file_io_times.sql'>awr_file_io_times.sql</a> - Historical IO times on ASM files
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/awr_get_snapshots.sql'>awr_get_snapshots.sql</a> - Get AWR snapshots for a date range
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/awr_itl_waits_10g.sql'>awr_itl_waits_10g.sql</a> - find ITL waits in 10g
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/awr_settings.sql'>awr_settings.sql</a> - query the dba_hist_wr_control view
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/cpu-busy.sql'>cpu-busy.sql</a> - Show what SQL Operations were on CPU
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dba_hist_sys_time_model.sql'>dba_hist_sys_time_model.sql</a> - example of querying dba_hist_sys_time_model - set your own stat_name
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dbw-hist.sql'>dbw-hist.sql</a> - DBWR CPU and Wait time from dba_hist_active_sess_history
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/flash-hist-stats.sql'>flash-hist-stats.sql</a> - retrieve recent flash cache stats from AWR
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/get-binds.sql'>get-binds.sql</a> - get bind values from dba_hist_sqlbind
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/getsql-awr.sql'>getsql-awr.sql</a> - call with sql_id to get SQL text from AWR
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/osstat-cpu.sql'>osstat-cpu.sql</a> - dump OS CPU metrics to CSV file
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/osstat-cpu-10g.sql'>osstat-cpu-10g.sql</a> - dump OS CPU metrics to CSV file for 10g
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/osstat-cpu-rpt.sql'>osstat-cpu-rpt.sql</a> - report of OS CPU metrics
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/pdb-awr-enable.sql'>pdb-awr-enable.sql</a> - enable AWR snapshots in a PDB
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/plan-counts-force.sql'>plan-counts-force.sql</a> - count of plans matched with force_matching_signature
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/plan-stats.sql'>plan-stats.sql</a> - compare elapsed execution times per plan for each sql_id
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/resize-ops-metric-awr.sql'>resize-ops-metric-awr.sql</a> - Look back through AWR for excessive SGA resize operations before ORA-4031 occurs
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/resize-ops-metric.sql'>resize-ops-metric.sql</a> - Look in gv$memory_resize_ops for excessive SGA resize operations before ORA-4031 occurs
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/rowlock-hist.sql'>rowlock-hist.sql</a> - rowlock history
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/rowlock-mode-decode.sql'>rowlock-mode-decode.sql</a> - decode rowlocks in AWR
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/rowlock-sqlid-counts.sql'>rowlock-sqlid-counts.sql</a> - count of rowlock enq by sqlid
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/rowlock-sqlid-hist.sql'>rowlock-sqlid-hist.sql</a> - count of rowlock enq by sqlid - full outer join on snapshot
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/session-history.sql'>session-history.sql</a> - history of sessions from dba_hist_active_sess_history
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sql-cache-mem-user.sql'>sql-cache-mem-user.sql</a> - Show current SQL Cache Memory per user
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sql-cache-mem.sql'>sql-cache-mem.sql</a> - Show current SQL Cache Memory per SQL_ID
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sql-cache-projections.sql'>sql-cache-projections.sql</a> - Project SQL Cache memory for 20% and 50% increase based on current usage
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sql-count-ash.sql'>sql-count-ash.sql</a> - count of number rows in ASH per SQL_ID
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sql-counts-fms.sql'>sql-counts-fms.sql</a> - get sql_id where there are 2+ sql_id per force_matching signature from ASH/AWR
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sql-counts.sql'>sql-counts.sql</a> - simple count of SQL_ID from ASH/ASH
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sql-exe-events-ash.sql'>sql-exe-events-ash.sql</a> - show events per execution of SQL_ID in ASH
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sql-exe-events-awr.sql'>sql-exe-events-awr.sql</a> - show events per execution of SQL_ID in AWR
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sql-exe-times-ash-rpt.sql'>sql-exe-times-ash-rpt.sql</a> - ASH report of execution times for a SQL_ID
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sql-exe-times-awr-rpt.sql'>sql-exe-times-awr-rpt.sql</a> - AWR report of execution times for a SQL_ID
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sql-exe-times-ash.sql'>sql-exe-times-ash.sql</a> - stats and histograms of execution times for a SQL_ID
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sql-exe-times-awr.sql'>sql-exe-times-awr.sql</a> - stats and histograms of execution times for a SQL_ID for past 30 days
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sql-exe-times-awr-histogram.sql'>sql-exe-times-awr-histogram.sql</a> - histogram of execution times for a SQL_ID
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sql-plans.sql'>sql-plans.sql</a> - Show plans used by a selected SQL for a date and time range
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sysmetric-hist-matrix.sql'>sysmetric-hist-matrix.sql</a> - crosstab report of several metrics from dba_hist_sysmetric_history
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sysmetric-history.sql'>sysmetric-history.sql</a> - pivot to CSV for several metrics in dba_hist_sysmetric_history
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/top10-sql-ash.sql'>top10-sql-ash.sql</a> - get top (by count) sql statements from ASH
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/top10-sql-awr.sql'>top10-sql-awr.sql</a> - get top (by count) sql statements from AWR for past 30 days
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/wsqlmon.sql'>wsqlmon.sql</a> - Provide SQL-Monitor like report from AWR - based on Tanel Poder script for ASH
</pre>
<h3>STATSPACK:</h3>
<pre>
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/statspack-tables.txt'>statspack-tables.txt</a> - not a script - just a description of statspack tables
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/snapNmin.sql'>snapNmin.sql</a> - start level 7 snapshot, sleep 2 minutes, complete snapshot and create report
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sp_current.sql'>sp_current.sql</a> - get data associated with latest snapshot
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sp_get_date_range.sql'>sp_get_date_range.sql</a> - enter a begin and end date and this script looks up the snap_id for each and sets variables for them
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sp_getsql.sql'>sp_getsql.sql</a> - retrieve the SQL from input is the hash value of the sql statement in stats$sqltext this will be seen in reports created by spreport.sql in 9i+ where the snapshot level is 5+
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sp_io_stat_drive.sql'>sp_io_stat_drive.sql</a> - get statspack data on physical IO per drive and date range aggregated per hour
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sp_io_stat_sys.sql'>sp_io_stat_sys.sql</a> - report on total IO for the system aggregated per the hour
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sp_job_submit.sql'>sp_job_submit.sql</a> - run statspack snapshot every 15 minutes via dbms_job
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sp_lvl_0.sql'>sp_lvl_0.sql</a> - change statspack to level 0
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sp_lvl_5.sql'>sp_lvl_5.sql</a> - change statspack to level 5
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sp_lvl_6.sql'>sp_lvl_6.sql</a> - change statspack to level 6
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sp_lvl_7.sql'>sp_lvl_7.sql</a> - change statspack to level 7
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sp_lvl_current.sql'>sp_lvl_current.sql</a> - get current default snapshot level
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sp_lvl_sql.sql'>sp_lvl_sql.sql</a> - example - change statspack SQL collection levels
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sp_plan.sql'>sp_plan.sql</a> - display historic execution plans from statspack data inputs are number of most recent snapshots to search and the SQL statement to look for (search is case insensitive) the function full_sql_text (full_sql_text.sql) must be created prior to running this script
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/full_sql_text.sql'>full_sql_text.sql</a> - use this to return the full text of a sql statement from statspack data - version dependent - may not be needed.
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sp_plan_hash.sql'>sp_plan_hash.sql</a> - Show execution plans from statspack data. first create view with sp_plan_table.sql - input is the hash value of the sql statement in stats$sqltext this will be seen in reports created by spreport.sql in 9i+ where the snapshot level is 5+
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sp_plan_table.sql'>sp_plan_table.sql</a> - create a view stats_plan_table for use with dbms_xplan.display and stats$sql_plan
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sp_recent.sql'>sp_recent.sql</a> - get the 10 most recent snapshots
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sp_resource_limit.sql'>sp_resource_limit.sql</a> - history of processes and sessions from stats$resource_limit
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sp_snap.sql'>sp_snap.sql</a> - perform a snapshot
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sp_snap_6.sql'>sp_snap_6.sql</a> - perform a level 6 snapshot
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sp_snap_id.sql'>sp_snap_id.sql</a> - example of searching for specific snap_id
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sp_top_sql_io.sql'>sp_top_sql_io.sql</a> - get top 10 SQL from statspack in terms of Disk Reads
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/spreport.sql'>spreport.sql</a> - call ?/rdbms/admin/sprepins statspack report - calls snap_ids.sql to create a text file of snapshot IDs for viewing in another window
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/snap_ids.sql'>snap_ids.sql</a> - called by spreport.sql - generate list of snapshot IDs
</pre>
<h3>USERS LOGGED ON:</h3>
<pre>
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/get-curr-ospid.sql'>get-curr-ospid.sql</a> - get the server PID for your current session
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/idle-sessions-histogram.sql'>idle-sessions-histogram.sql</a> - show histogram of idle users in 10 second buckets
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sess-optimizer-env.sql'>sess-optimizer-env.sql</a> - show the optimizer environment for a session
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/who.sql'>who.sql</a> - summary of users logged on
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/whog.sql'>whog.sql</a> - summary of users for all instances, includes pdbs
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/who2.sql'>who2.sql</a> - detailed info of users logged on
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/who2s.sql'>who2s.sql</a> - shortened version of who2.sql which is called by some scripts
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/who2g.sql'>who2g.sql</a> - detailed info of users logged on - includes all instances and PDB for 12c
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/who5.sql'>who5.sql</a> - IO per session
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/who6.sql'>who6.sql</a> - Show session info for background sessions
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/who7.sql'>who7.sql</a> - Show session info with IO stats per session
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/who8.sql'>who8.sql</a> - similar to who2.sql
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/who_dba_jobs.sql'>who_dba_jobs.sql</a> - show sessions with jobs running (from dba_jobs)
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/who9.sql'>who9.sql</a> - same as who_dba_jobs.sql
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/who_dblink.sql'>who_dblink.sql</a> - sessions using a database link
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/who_protocol.sql'>who_protocol.sql</a> - show connection method for each session
</pre>
<h3>PARAMETERS:</h3>
<pre>
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/check_events.sql'>check_events.sql</a> - Determine if any events are set in database
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/get-alert-log-location.sql'>get-alert-log-location.sql</a> - return the filename for the text based alert log file
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/getallparm.sql'>getallparm.sql</a> - get parameters including hidden
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/getparm.sql'>getparm.sql</a> - get parameters
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/parm-hist-diff.sql'>parm-hist-diff.sql</a> - show difference in parameters from AWR
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/parms_dump_csv.sql'>parms_dump_csv.sql</a> - Dump all parameters to CSV file
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/parms_dump_12c_csv.sql'>parms_dump_12c_csv.sql</a> - Dump all 12c parameters to CSV file
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/parms-version-diff.sql'>parms-version-diff.sql</a> - Generate CSV files of parameters - compare version diffs - details in comments
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/parameter-compare.sql'>parameter-compare.sql</a> - compare parameters between two databases
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/session-parm-diff.sql'>session-parm-diff.sql</a> - show how a sessions setting differ from system settings
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showallparm.sql'>showallparm.sql</a> - Show all database parameters, including .hidden. parameters
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showparm.sql'>showparm.sql</a> - Show database parameters
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showparmchanges.sql'>showparmchanges.sql</a> - show parameters that have changed - uses AWR
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showparmdrvr.sql'>showparmdrvr.sql</a> - Performs the query for getparm.sql and showparm.sql
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showallparm73drvr.sql'>showallparm73drvr.sql</a> - Performs the query for getallparm.sql and showallparm.sql
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showallparm12c-drvr.sql'>showallparm12c-drvr.sql</a> - 12c update for all parms
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/session-parm-diff.sql'>session-parm-diff.sql</a> - show how a sessions setting differ from system settings
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sys-context-all.sql'>sys-context-all.sql</a> - display all sys_context values as of 12c
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sys_context.sql'>sys_context.sql</a> - Demo of getting oracle environment settings with sys_context function
</pre>
<h3>EXECUTION_PLAN:</h3>
<pre>
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/explain_plan_columns.sql'>explain_plan_columns.sql</a> - column settings
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sql_current_plan.sql'>sql_current_plan.sql</a> - get dynamic sql plans for hash value from v$sqlplan - works on 9i - must create view with dynamic_plan_table.sql
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dynamic_plan_table.sql'>dynamic_plan_table.sql</a> - creates view used by sql_current_plan.sql
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/liveplan-9i.sql'>liveplan-9i.sql</a> - get dynamic execution plan from hash value
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/liveplan-hash.sql'>liveplan-hash.sql</a> - get dynamic execution plan from hash value for 10g+
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/liveplan-sqlid.sql'>liveplan-sqlid.sql</a> - get dynamic execution plan from sql_id for 10g+
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/liveplan-9i-hash.sql'>liveplan-9i-hash.sql</a> - a bit of a misnomer - pulls sql and hash value for a session
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showplan72.sql'>showplan72.sql</a> - show execution plans for oracle 7.2
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showplan73.sql'>showplan73.sql</a> - show execution plans for oracle 7.2+
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showplan9i.sql'>showplan9i.sql</a> - show execution plans for oracle 9i+
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showplan-all.sql'>showplan-all.sql</a> - show all execution plans for a SQL
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showplan-awr.sql'>showplan-awr.sql</a> - show execution plans from AWR
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showplan-last.sql'>showplan-last.sql</a> - show execution plan for most recently executed cursor in current session
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/gen_bind_vars.sql'>gen_bind_vars.sql</a> - gather bind values from v$sql_bind and generate SQL
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/gen_bind_vars_awr.sql'>gen_bind_vars_awr.sql</a> - gather bind values from dba_hist_sqltext and generate SQL
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/get_bind_values.sql'>get_bind_values.sql</a> - get the bind values for a sql_id
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/get_awr_bind_values.sql'>get_awr_bind_values.sql</a> - get the bind values for a sql_id from AWR
</pre>
<h3>PL/SQL:</h3>
<pre>
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/build-record.sql'>build-record.sql</a> - generate a PL/SQL record type based on table columns
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/bulk-collect-1.sql'>bulk-collect-1.sql</a> - demo of fetch .. bulk collect into
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dbms_output-abstracted.sql'>dbms_output-abstracted.sql</a> - abstracted procedures and functions for dbms_output
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/get_table_lock.sql'>get_table_lock.sql</a> - runs a tight loop trying to acquire lock on table - use on busy systems to get the lock required - DO NOT LEAVE TABLE LOCKED!
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/package-error.sql'>package-error.sql</a> - show the source lines for a PL/SQL error
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/plsql-return-bool-from-sql.sql'>plsql-return-bool-from-sql.sql</a> - demo of returning a boolean from a function when based on a numeric value
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/raise_error.sql'>raise_error.sql</a> - raise any error in the database
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sqlplus_return_code.sql'>sqlplus_return_code.sql</a> - examples of exiting SQLPlus with an error code
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sqlplus_return_code_2.sql'>sqlplus_return_code_2.sql</a> - more examples of exiting SQLPlus with an error cod
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/user_exit.sql'>user_exit.sql</a> - an example of exiting sqlplus if the current user is not the one expected
</pre>
<h3>DATABASE STATISTICS - DBMS_STATS - OPTIMIZER:</h3>
<pre>
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/chk4incremental.sql'>chk4incremental.sql</a> - check to see if incremental stats were gathered for a table
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/cursor-check.sql'>cursor-check.sql</a> - some detail on open cursors per session
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/cursor-counts.sql'>cursor-counts.sql</a> - simple report on cursors with count of child cursors
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/cursor-invalidation-reasons.sql'>cursor-invalidation-reasons.sql</a> - show reasons for cursor invalidation from v$sql_shared_cursor
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dbms_stats_get_prefs.sql'>dbms_stats_get_prefs.sql</a> - get stats prefs per table and indexes
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dbms_stats_report.sql'>dbms_stats_report.sql</a> - HTML report of dbms_stats activity
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dup-system-stats.sql'>dup-system-stats.sql</a> - Generate PL/SQL to duplicate system statistics to another database
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/gather_table_stats.sql'>gather_table_stats.sql</a> - gather stats on a tables specified in table_list.sql
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/gather_system_stats_iteratively.sql'>gather_system_stats_iteratively.sql</a> - gather OS stats every 10 minutes for 24 hours
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/get_system_stats.sql'>get_system_stats.sql</a> - display Oracle OS statistics
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/global-prefs.sql'>global-prefs.sql</a> - display global dbms_stats prefs
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/get_prefs.sql'>get_prefs.sql</a> - show stats prefs for a schema
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/get_stats_job.sql'>get_stats_job.sql</a> - get name of stored procedure used for autotask stats job - 10g+, maybe 9i
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/get_stats_task.sql'>get_stats_task.sql</a> - get the name of the autotask task used to run the auto stats job - 11g+
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/getobj_stats.sql'>getobj_stats.sql</a> - show stats for a table down to subpartition level
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/histogram_values.sql'>histogram_values.sql</a> - show the actual values for histograms
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/histo_types.sql'>histo_types.sql</a> - get type of histograms for a schema
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/histo_dist.sql'>histo_dist.sql</a> - show distribution for frequency histograms for schema,table, column
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/histo_hist.sql'>histo_hist.sql</a> - show historical histogram info for schema,table, column
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/histo_hist_dist.sql'>histo_hist_dist.sql</a> - show distribution of values for historical histograms for schema,table, column
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/locked_stats.sql'>locked_stats.sql</a> - show tables and indexes with locked statistics
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/logsetup.sql'>logsetup.sql</a> - called by some scripts to create a log - create logs dir first
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/ndv.sql'>ndv.sql</a> - show NDV for a table
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/os-stats-avgs.sql'>os-stats-avgs.sql</a> - averages of OS IO stats - trying to reduce SAN cache effect
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/partstats.sql'>partstats.sql</a> - Show basic stats info on table and partitions
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/partstats_sum.sql'>partstats_sum.sql</a> - Summary of partition stats
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sampled_size.sql'>sampled_size.sql</a> - show sample size used to collect stats
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sampled_size_details.sql'>sampled_size_details.sql</a> - show sample size used to collect stats
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/session-cursor-metrics.sql'>session-cursor-metrics.sql</a> - show histograms for open and cached cursors
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/set_avg_stats.sql'>set_avg_stats.sql</a> - set average stats on empty partitions - uses table_list.sql
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/set_table_prefs.sql'>set_table_prefs.sql</a> - set table preferences - uses table_list.sql
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/show_os_stats.sql'>show_os_stats.sql</a> - Show stats from v$aux_stats$
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/show_os_stats_hist.sql'>show_os_stats_hist.sql</a> - Show stats from wri$_optstat_aux_history
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/stale-stats.sql'>stale-stats.sql</a> - Show stats that are stale and at least 7 days old
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/stat.sql'>stat.sql</a> - get stats info for a table - see comments
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/stat-names.sql'>stat-names.sql</a> - show names from v$statname, with aggegrated class descriptions
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/stat-classes.sql'>stat-classes.sql</a> - show the class descriptions for all distinct class values in v$statname
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/stats_config.sql'>stats_config.sql</a> - set the schema name for some stats scripts
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/stats_mod.sql'>stats_mod.sql</a> - show stats being gathered by gather_table_stats.sql
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/stats_prefs.sql'>stats_prefs.sql</a> - show dbms_stats preferences
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/stats-sqlid.sql'>stats-sqlid.sql</a> - show basic stats infor for tables and indexes associated with a SQL_ID
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/stats_trace.sql'>stats_trace.sql</a> - show how to trace dbms_stats - comments only
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/stats_trace_test.sql'>stats_trace_test.sql</a> - show that settings to trace stats are not persistent
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/stats_wait.sql'>stats_wait.sql</a> - show waits on stats collection
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sysaux_free.sql'>sysaux_free.sql</a> - show free space in sysaux
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/table_list.sql'>table_list.sql</a> - list of tables for gather_table_stats.sql
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/unlock_stats.sql'>unlock_stats.sql</a> - unlocks stats - uses table_list.sql
</pre>
<h3>AUTOTASK and SCHEDULER:</h3>
<pre>
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/all_sched_jobs.sql'>all_sched_jobs.sql</a> - show all_scheduler_jobs
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/autotask_auto_stats_disable.sql'>autotask_auto_stats_disable.sql</a> - disable automatic stats gathering
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/autotask_auto_stats_enable.sql'>autotask_auto_stats_enable.sql</a> - enable automatic stats gathering
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/autotask_auto_tasks_disable.sql'>autotask_auto_tasks_disable.sql</a> - disable all autotasks
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/autotask_auto_tasks_enable.sql'>autotask_auto_tasks_enable.sql</a> - enable all autotasks
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/autotask_client_attributes.sql'>autotask_client_attributes.sql</a> - call dbms_auto_task_admin.get_client_attributes
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/autotask_client_history.sql'>autotask_client_history.sql</a> - show dba_autotask_client_history
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/autotask_client_job.sql'>autotask_client_job.sql</a> - show dba_autotask_client_job
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/autotask_clients.sql'>autotask_clients.sql</a> - show dba_autotask_client
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/autotask_job_history.sql'>autotask_job_history.sql</a> - show dba_autotask_job_history
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/autotask_operation.sql'>autotask_operation.sql</a> - show dba_autotask_operation
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/autotask_resources.sql'>autotask_resources.sql</a> - call dbms_auto_task_admin.get_p1_resources
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/autotask_sched.sql'>autotask_sched.sql</a> - show dba_autotask_schedule
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/autotask_sql_setup.sql'>autotask_sql_setup.sql</a> - set env for autotask scripts
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/autotask_task.sql'>autotask_task.sql</a> - show dba_autotask_task
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/autotask_window_clients.sql'>autotask_window_clients.sql</a> - show dba_autotask_window_clients
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/autotask_window_hist.sql'>autotask_window_hist.sql</a> - show dba_autotask_window_history
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/cdb_sched_jobs.sql'>cdb_sched_jobs.sql</a> - show all scheduler jobs from CDB Root Level
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dba_sched_jobs.sql'>dba_sched_jobs.sql</a> - show dba_scheduler_jobs
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dba_sched_jobs_hist.sql'>dba_sched_jobs_hist.sql</a> - show scheduler jobs history
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/opthist.sql'>opthist.sql</a> - show values of dba_stats prefs from the source table
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/schedcols.sql'>schedcols.sql</a> - col commands for scripts
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/scheduler_programs.sql'>scheduler_programs.sql</a> - show dba_scheduler_programs
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/scheduler_windows.sql'>scheduler_windows.sql</a> - show dba_scheduler_windows
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/test_calendar_string.sql'>test_calendar_string.sql</a> - provide a scheduler calendar string and number of iterations to see when job runs in dbms_scheduler. Courtesy of oracle-base.com
</pre>
<h3>timezone specific:</h3>
<pre>
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/tz_set.sql'>tz_set.sql</a> - set the nls_timezone_tz_format for autotask scripts
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/get_sched_tz.sql'>get_sched_tz.sql</a> - get the default timezone for the scheduler
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/set_sess_tz.sql'>set_sess_tz.sql</a> - set session timezone the same as scheduler default timezone
</pre>
<h3>RESOURCE MANAGER:</h3>
<pre>
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/disable_resource_manager.sql'>disable_resource_manager.sql</a> - the correct method to disable the resource manager
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/resmgr-columns.sql'>resmgr-columns.sql</a> - configure report columns
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/resmgr-consumer-groups.sql'>resmgr-consumer-groups.sql</a> - show consumer groups
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/resmgr-group-privs.sql'>resmgr-group-privs.sql</a> - show group privs
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/resmgr-plan-directives.sql'>resmgr-plan-directives.sql</a> - show resource manager plan directives
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/resmgr-resource-plans.sql'>resmgr-resource-plans.sql</a> - show resource manager plans
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/resmgr-setup.sql'>resmgr-setup.sql</a> - set pagesize and linesizes
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/resmgr-user-consumer-groups.sql'>resmgr-user-consumer-groups.sql</a> - show consumer group per user
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/resmgr-waits-pdb.sql'>resmgr-waits-pdb.sql</a> - show resmgr waits per pdb
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/resmgr-waits.sql'>resmgr-waits.sql</a> - show resmgr waits
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/resmgr-who.sql'>resmgr-who.sql</a> - show resmgr waits per user
</pre>
<h3>INSTANCE and/or DATABASE:</h3>
<pre>
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/all-ini-trans.sql'>all-ini-trans.sql</a> - report on on the IN_TRANS values for all non-system owners
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/average_active_sessions.sql'>average_active_sessions.sql</a> - show average active sessions - does not use ASH
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/archived_log_hist_matrix.sql'>archived_log_hist_matrix.sql</a> - show matrix of archive log switch activity for 2 weeks
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/archived_log_sums.sql'>archived_log_sums.sql</a> - show rolling total of archive logs for N days
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/archived_log_dest.sql'>archived_log_dest.sql</a> - show archived log destination and status for active destinations
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/bct_bufsz.sql'>bct_bufsz.sql</a> - current size of block change tracking buffers
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/bct_status.sql'>bct_status.sql</a> - show status of block change tracking file
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/blocker-tree.sql'>blocker-tree.sql</a> - show tree of blocked sessions
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/col-diff.sql'>col-diff.sql</a> - compare column_names for two tables
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/colcomm.sql'>colcomm.sql</a> - show columns in common between a set of tables in a CSV list
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/csv-split.sql'>csv-split.sql</a> - Demo of using recursive subfactored query to split CSV list from sqlplus command line
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/csv-split-2.sql'>csv-split-2.sql</a> - Demo of using regular expressions to conver a CSV list to rows - both SQL and PL/SQL
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/csv-split-bind.sql'>csv-split-bind.sql</a> - Demo of passing a comma delimited variable into an IN clause of a SELECT statement
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dice-roll.sql'>dice-roll.sql</a> - Roll the dice a few times
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/iot_segments.sql'>iot_segments.sql</a> - show segments for IOT objects. These are actually index segments
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/data-growth-db.sql'>data-growth-db.sql</a> - show growth of database over time
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/data-growth-tbs.sql'>data-growth-tbs.sql</a> - show growth of tablespaces over time
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/data-growth-db-predict-regr.sql'>data-growth-db-predict-regr.sql</a> - predict future database size to 5 years out
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/data-growth-tbs-predict-regr.sql'>data-growth-tbs-predict-regr.sql</a> - predict future database size to 5 years out, per tablespace
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/db_corrupt.sql'>db_corrupt.sql</a> - report on corrupt database blocks and objects
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dba_dependencies.sql'>dba_dependencies.sql</a> - find all dependencies for owner/object
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dba_jobs_running.sql'>dba_jobs_running.sql</a> - Show db jobs currently running
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dba_jobs.sql'>dba_jobs.sql</a> - Show all scheduled db jobs
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dba_feature_usage.sql'>dba_feature_usage.sql</a> - report on used features from dba_feature_usage_statistics
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dba-registry.sql'>dba-registry.sql</a> - current registered components
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dba-registry-history.sql'>dba-registry-history.sql</a> - report on upgrade and PSU history
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/database_properties.sql'>database_properties.sql</a> - show properties from database_properties
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dbms_application.sql'>dbms_application.sql</a> - example of dbms_applicatoin_info usage
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/default_tablespace.sql'>default_tablespace.sql</a> - show default tablespace properties 10g+
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dml-log-errors-test.sql'>dml-log-errors-test.sql</a> - demo of INSERT INTO Log Table, with Reject Limit
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/findobj.sql'>findobj.sql</a> - Find an object in the data dictionary
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/findcol.sql'>findcol.sql</a> - Find a column for a user in the data dictionary
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/fk_hierarchy.sql'>fk_hierarchy.sql</a> - Display hierarchy of tables related by Foreign Key (use fktree.sql or fktree-rcte.sql instead)
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/fk-circular-ref.sql'>fk-circular-ref.sql</a> - Find any examples of tables that reference each other via foeign key
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/fktree.sql'>fktree.sql</a> - Display a hierarchy of tables related by Foreign Key (new script - old one broken)
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/fktree-rcte.sql'>fktree-rcte.sql</a> - Display a hierarchy of tables related by Foreign Key (RCTE Version - needs work - still broken)
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/fra_config.sql'>fra_config.sql</a> - show FRA location and size
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/get-missing-tablenames.sql'>get-missing-tablenames.sql</a> - given a list of tables, determine if any are missing
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/getsid.sql'>getsid.sql</a> - Get current session SID via sys_context()
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/get-sql-for-table.sql'>get-sql-for-table.sql</a> - get all non DML (easily changed) sql that includes a table
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/getsql.sql'>getsql.sql</a> - call with sql_id to get sql_fulltext
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/incarnations.sql'>incarnations.sql</a> - Show database incarnations
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/index-col-use-ratios.sql'>index-col-use-ratios.sql</a> - Show ratio of table columns to columns indexed
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/index-correlate.sql'>index-correlate.sql</a> - find indexes that appear in a list of plan_hash values
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/index-usage-awr.sql'>index-usage-awr.sql</a> - Query AWR to try and determine which indexes are unused
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/all_jobs.sql'>all_jobs.sql</a> - Show all scheduled db jobs
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/show_jobs.sql'>show_jobs.sql</a> - does the work for dba_jobs.sql and all_jobs.sql
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/supp-col-info.sql'>supp-col-info.sql</a> - show column level supplemental logging info for a user
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/supp-db-info.sql'>supp-db-info.sql</a> - show database supplemental logging parameters
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/supp-tab-info.sql'>supp-tab-info.sql</a> - show table level supplemental logging info for a user
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/kglh-growth.sql'>kglh-growth.sql</a> - monitor for unbounded growth of shared pool memory structures
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/kglh-growth-awr.sql'>kglh-growth-awr.sql</a> - check AWR for unbounded growth of shared pool memory structures
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/la8.sql'>la8.sql</a> - Shows last analyzed dates for database objects . 8.0+
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/la.sql'>la.sql</a> - Shows last analyzed dates for database objects . 7.3
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/login.sql'>login.sql</a> - set prompt and editor on login
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/log-switch-histogram.sql'>log-switch-histogram.sql</a> - Display a histogram of redo log switch times
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/loghistory_8.sql'>loghistory_8.sql</a> - show archive logs with time between switches
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/loghist-csv.sql'>loghist-csv.sql</a> - dump history of archive logs (with timing) to CSV
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/obj-privs.sql'>obj-privs.sql</a> - object privileges granted per object
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/options.sql'>options.sql</a> - report from v$option
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/oracle-exclude-demo.sql'>oracle-exclude-demo.sql</a> - demonstrate the use of oracle-exclude-inline.sql
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/oracle-exclude-inline.sql'>oracle-exclude-inline.sql</a> - inline version of oracle-exclude-schema.sql
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/oracle-exclude-schema.sql'>oracle-exclude-schema.sql</a> - show schemas owned by Oracle and are frequently excluded from queries
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/oracle-naming-inconsistencies.sql'>oracle-naming-inconsistencies.sql</a> - highlight some of the inconsistencies oracle data dictionary column names
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/pivot.sql'>pivot.sql</a> - Simple demo of PIVOT
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/purge_cursors.sql'>purge_cursors.sql</a> - purge a list of SQL cursors from shared_pool - 10g+ see Oracle Note 457309.1
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/redo-log-mirrors.sql'>redo-log-mirrors.sql</a> - show log groups with mirror sides identified. Experimental, and requires sysdba access.
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/reserved-words.sql'>reserved-words.sql</a> - List reserved words from v$reserved_words
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/setc.sql'>setc.sql</a> - automatically or interactively set 'do alter session set container'
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sql_spawned_reasons.sql'>sql_spawned_reasons.sql</a> - Show reasons for creating new child of SQL
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/shared-pool-top-sql.sql'>shared-pool-top-sql.sql</a> - show top SQL consumers of shared_pool
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/shared-pool-top-users.sql'>shared-pool-top-users.sql</a> - show top SCHEMA/USER consumers of shared_pool
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/show_check_cons.sql'>show_check_cons.sql</a> - Show non-system generated check constraints
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/show-pdbs.sql'>show-pdbs.sql</a> - Show the con_id and con_name for available PDBs
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/show_data_types.sql'>show_data_types.sql</a> - Show non-system column data types
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/show-fk.sql'>show-fk.sql</a> - Show foreign keys for a user
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/show-pk.sql'>show-pk.sql</a> - Show all primary keys for a user
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/show-uk.sql'>show-uk.sql</a> - Show all unique keys for a user
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showsga.sql'>showsga.sql</a> - Show SGA breakdown
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showuser.sql'>showuser.sql</a> - Show user info
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showpriv.sql'>showpriv.sql</a> - Show privileges granted to a role or user
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showrole.sql'>showrole.sql</a> - Show roles for a grantee
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showroles.sql'>showroles.sql</a> - Show all roles and privileges granted
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showprofile.sql'>showprofile.sql</a> - Show resources for a profile from dba_profiles
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showrbs.sql'>showrbs.sql</a> - Show RBS and info
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showrbslock.sql'>showrbslock.sql</a> - Show RBS locks
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showsnapshot_logs.sql'>showsnapshot_logs.sql</a> - Show snapshot logs
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showsnapshots.sql'>showsnapshots.sql</a> - Show snapshots
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/show_supp_logs.sql'>show_supp_logs.sql</a> - Show supplemental logs for replication
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showdiscon.sql'>showdiscon.sql</a> - Show all disabled constraints
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showdistrg.sql'>showdistrg.sql</a> - Show all disabled triggers
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showlog.sql'>showlog.sql</a> - Show redo logs
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/show_logon_triggers.sql'>show_logon_triggers.sql</a> - Show logon triggers
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showindex.sql'>showindex.sql</a> - Show indexes for a user
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showtab.sql'>showtab.sql</a> - Show tables for a user
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showcol.sql'>showcol.sql</a> - Show column details for OWNER.TABLE
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/invalid.sql'>invalid.sql</a> - Show invalid objects
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showinv.sql'>showinv.sql</a> - soft link to invalid.sql
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/shownls.sql'>shownls.sql</a> - Show database NLS parameters
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showview.sql'>showview.sql</a> - Show the text for views - opens up view.txt in editor
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showdblink.sql'>showdblink.sql</a> - Show database links
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showdis.sql'>showdis.sql</a> - Show disabled constraints
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showkey.sql'>showkey.sql</a> - Show primary and unique keys and unique indexes for a table
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showmem.sql'>showmem.sql</a> - Show memory usage per session
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showobjprivs.sql'>showobjprivs.sql</a> - Show privileges granted on an owners objects
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showpin.sql'>showpin.sql</a> - Show objects pinned in the shared pool
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showpipes.sql'>showpipes.sql</a> - Show database pipes
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showsrc.sql'>showsrc.sql</a> - show source of PL/SQL stored objects
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/show-x-dollar-tables.sql'>show-x-dollar-tables.sql</a> - list of all x$tables
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sql-patch-report.sql'>sql-patch-report.sql</a> - report on SQL Patches created via dbms_sqldiag
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sql-version-counts.sql'>sql-version-counts.sql</a> - top 10 count of versions of SQL_ID
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/tabcols.sql'>tabcols.sql</a> - list of columns in alpha order for owner and table_name
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/tabidx.sql'>tabidx.sql</a> - show indexes and columns for owner and table_name
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/plsql_called_objects.sql'>plsql_called_objects.sql</a> - Shows entry PL/SQL object and current PL/SQL object for a session
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/plsql-init.sql'>plsql-init.sql</a> - example initialization for PL/SQL flags
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/rbs_no_optimal.sql'>rbs_no_optimal.sql</a> - Set all rollback segments to have no OPTIMAL size
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/rbs_optimal.sql'>rbs_optimal.sql</a> - Set all rollback segments to have an OPTIMAL size of 2xInitial
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/rbs_shrink.sql'>rbs_shrink.sql</a> - Shrink all rollback segments to OPTIMAL
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/uifk.sql'>uifk.sql</a> - Select from view creatdd in uifk_v.sql
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/uifk_gen.sql'>uifk_gen.sql</a> - Uses the view created in uifk_v.sql to generate index DDL
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/uifk_v.sql'>uifk_v.sql</a> - Creates a view find all unindexed foreign key contraints
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showdb.sql'>showdb.sql</a> - show database info
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/show_active_log_dest.sql'>show_active_log_dest.sql</a> - show active log dest if available
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dba_recyclebin_purge_gen.sql'>dba_recyclebin_purge_gen.sql</a> - generate code to purge individual objects from dba_recyclebin
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/restricted_session_disable.sql'>restricted_session_disable.sql</a> - everyone can login
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/restricted_session_enable.sql'>restricted_session_enable.sql</a> - only DBA can login
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sess_longops.sql'>sess_longops.sql</a> - query v$session_longops
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/recompile.sql'>recompile.sql</a> - Recompile invalid objects. Still works better than DBMSU_UILITY.COMPILE_SCHEMA
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/reverse_role_lookup.sql'>reverse_role_lookup.sql</a> - Find all users granted a role
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/undo-active.sql'>undo-active.sql</a> - Show active undo blocks - RAC aware
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/undo-active-12c.sql'>undo-active-12c.sql</a> - Show active undo blocks in 12c - RAC aware
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/undo-mon-fast.sql'>undo-mon-fast.sql</a> - monitor undo from v$fast_start_transactions - useful for when a proccess/session has been killed
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/undo-mon-trans.sql'>undo-mon-trans.sql</a> - monitor rollback for transactions
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/unrevorable-files.sql'>unrevorable-files.sql</a> - report of files that are unrecoverable, likely due to nologging inserts
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/wait_chains.sql'>wait_chains.sql</a> - Troubleshooting Database Contention With V$Wait_Chains (Doc ID 1428210.1)
</pre>
<h3>SNAPSHOTS and MATERIALIZED_VIEWS:</h3>
<pre>
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/show_mview_status.sql'>show_mview_status.sql</a> - show status from dba_mview_analysis
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showregistered_snapshots.sql'>showregistered_snapshots.sql</a> - Show all snapshots registered at master site
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/deregister_snapshots.sql'>deregister_snapshots.sql</a> - Degister a snapshot - see script comments
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showsnapshot_logs.sql'>showsnapshot_logs.sql</a> - Show snapshot/mview logs
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showsnapshot_sites.sql'>showsnapshot_sites.sql</a> - run from the master site-shows databases that have snapshots based on-tables/logs in master database
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showsnapshots.sql'>showsnapshots.sql</a> - Show snapshots/mviews in database
</pre>
<h3>SECURITY:</h3>
<pre>
</pre>
<h3>Legacy Auditing</h3>
<pre>
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/audit-actions.sql'>audit-actions.sql</a> - A query of dba_audit_trail
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dba_audit_session.sql'>dba_audit_session.sql</a> - Report session audit trail per user
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dba_audit_session_recent.sql'>dba_audit_session_recent.sql</a> - Report session audit trail per user, most recent only
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dba_audit_trail.sql'>dba_audit_trail.sql</a> - Report on full audit trail
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dba_audit_trail_persons.sql'>dba_audit_trail_persons.sql</a> - Report on audit trail per user
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dba_table_audit_flags.sql'>dba_table_audit_flags.sql</a> - This script creates a SYS view against SYS tables to show all audit flags per object
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/show_session_audit.sql'>show_session_audit.sql</a> - select all from session_audit - lots of rows
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/getaud.sql'>getaud.sql</a> - generate SQL to reproduce current audit settings
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/privmaps.sql'>privmaps.sql</a> - Show all privileges granted to a user, and whether direct or through a role
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/orapwdhash.sql'>orapwdhash.sql</a> - Determine the 10g password hash for username and password. Good for detecting accounts where username = password
</pre>
<h3>Unified Auditing</h3>
<pre>
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/options.sql'>options.sql</a> - report from v$option - check for 'Unified Auditing'
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/ua-actions.sql'>ua-actions.sql</a> - All possible Unified Auditing Actions
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/ua-audit-log-cleanup-job.sql'>ua-audit-log-cleanup-job.sql</a> - simple example of creating a scheduler job to purge the unified audit trail
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/ua-policies.sql'>ua-policies.sql</a> - A report of UA policies
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/ua-sessions.sql'>ua-sessions.sql</a> - Report on LOGON and LOGOFF auditing
</pre>
<h3>STORAGE:</h3>
<pre>
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dfshrink-gen-9i.sql'>dfshrink-gen-9i.sql</a> - report of space savings by shrinking datafiles - generate df shrink code
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dfshrink-gen.sql'>dfshrink-gen.sql</a> - generate code to shrink datafiles - improved script for 10g+
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/dbms_space_asa_rpt.sql'>dbms_space_asa_rpt.sql</a> - Show report from Auto Space Advisor
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showdf.sql'>showdf.sql</a> - Show all database tablespace files and file info
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showdf8i.sql'>showdf8i.sql</a> - Show all database tablespace files and file info oracle 8i
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showdf7.sql'>showdf7.sql</a> - Show all database tablespace files and file info oracle 7
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showfreemax.sql'>showfreemax.sql</a> - Show size of maximum chunk of free space per tablespace
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showfree.sql'>showfree.sql</a> - Show all free space per tablespace
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showfreesum.sql'>showfreesum.sql</a> - Show sum of all free space per tablespace
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showtbs.sql'>showtbs.sql</a> - Show all tablespaces and info
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/showspace.sql'>showspace.sql</a> - Use DBMS_SPACE to display space stats for an object
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/maxext3.sql'>maxext3.sql</a> - Locates database objects that will be unable to extend based on next extent size and available space, and/or due to maximum number of extents.
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/undo_blocks_required.sql'>undo_blocks_required.sql</a> - calculate the number bytes of UNDO space required to satisfy the undo requirements based on the UNDO_RETENTION paramter (seconds), block size and UNDO block requests per second
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/undo_retention_available.sql'>undo_retention_available.sql</a> - calculate how long undo retention should be good for based on the the bytes available in the UNDO tablespace block size and UNDO block requests per second
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/undo_stats.sql'>undo_stats.sql</a> - used to see if ORA-1555 occurred. also shows maxquerylen and undo_retention - should not be ora-1555 if maxquerylen lt undo_retention
</pre>
<h3>ASM:</h3>
<pre>
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/asm_copyblock.sql'>asm_copyblock.sql</a> - copy ASM blocks to an datafile format file
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/asm_disks.sql'>asm_disks.sql</a> - show ASM disks
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/asm_disk_errors.sql'>asm_disk_errors.sql</a> - show ASM disk errors
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/asm_disk_stats.sql'>asm_disk_stats.sql</a> - show ASM disk statistics
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/asm_diskgroups.sql'>asm_diskgroups.sql</a> - show diskgroups
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/asm_diskgroup_attributes.sql'>asm_diskgroup_attributes.sql</a> - show diskgroup attributes
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/asm_diskgroup_templates.sql'>asm_diskgroup_templates.sql</a> - show diskgroup template values
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/asm_failgroup_members.sql'>asm_failgroup_members.sql</a> - show diskgroups by failgroup and members
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/asm_extent_distribution.sql'>asm_extent_distribution.sql</a> - show extent distribution across disks
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/asm_files.sql'>asm_files.sql</a> - show files in ASM
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/asm_files_path.sql'>asm_files_path.sql</a> - show files in ASM with full path
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/asm_extent_multi_au.sql'>asm_extent_multi_au.sql</a> - show asm file extents that have AU count GT 1
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/asm_partners.sql'>asm_partners.sql</a> - show ASM disk partners - must be run from ASM instance
</pre>
<h3>DRCP: Database Resident Connection Pooling</h3>
<pre>
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/drcp_show_config.sql'>drcp_show_config.sql</a> - show current DRCP config
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/drcp_set_connections_per_broker.sql'>drcp_set_connections_per_broker.sql</a> - set number of connections managed per broker
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/drcp_set_num_brokers.sql'>drcp_set_num_brokers.sql</a> - set the number of DRCP brokers
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/drcp_pool_cc_stats.sql'>drcp_pool_cc_stats.sql</a> - show connection class statistics
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/drcp_pool_ratio.sql'>drcp_pool_ratio.sql</a> - show ratio of connection requests to number of pools
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/drcp_pool_stats.sql'>drcp_pool_stats.sql</a> - show aggregate DRCP pool stats
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/drcp_start.sql'>drcp_start.sql</a> - start DRCP
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/drcp_stop.sql'>drcp_stop.sql</a> - stop DRCP
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/whocp.sql'>whocp.sql</a> - like who2.sql - includes DRCP service name
</pre>
<h3>DATES: Dates and Date Math</h3>
<pre>
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/between-trunc-demo.sql'>between-trunc-demo.sql</a> - demo of using dates and timestamps with BETWEEN or similar so that indexes can be used
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/date_math.sql'>date_math.sql</a> - how to get the minutes between to dates of the same day
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/date_math_2.sql'>date_math_2.sql</a> - how to get the minutes between to dates of the same day
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/date_math_3.sql'>date_math_3.sql</a> - cause a job to run at exactly 00
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/date_math_4.sql'>date_math_4.sql</a> - round timestamps to previous interval of N minutes
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/date_math_epoch.sql'>date_math_epoch.sql</a> - get epoch to the millisecond using timestamp
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/job_submit.sql'>job_submit.sql</a> - controlling run_time of dbms_jobs
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/e2ts.sql'>e2ts.sql</a> - Convert epoch value to oracle timestamp
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/e2ts-hires.sql'>e2ts-hires.sql</a> - Convert epoch value to oracle timestamp
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/timestamp_to_millisecond.sql'>timestamp_to_millisecond.sql</a> - convert timestamp to millisecond demo
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/timestamp-day-boundaries.sql'>timestamp-day-boundaries.sql</a> - determine the beginning and ending timestamps for a day in SQL and PL/SQL
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/timestamp-diff-seconds.sql'>timestamp-diff-seconds.sql</a> - convert the difference between 2 timestamps to seconds. Preserves fractional seconds
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/timestamp-trunc.sql'>timestamp-trunc.sql</a> - demonstrates how to truncate a timestamp to remove the time portion
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/timestamp-types.sql'>timestamp-types.sql</a> - simple demo of timestamp data types via dump()
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/ts2e.sql'>ts2e.sql</a> - Convert oracle timestamp to epoch value
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/ts2e-hires.sql'>ts2e-hires.sql</a> - Convert oracle timestamp to epoch value
</pre>
<h3>timezone specific:</h3>
<pre>
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/na-std-timezones.sql'>na-std-timezones.sql</a> - get North America timezones
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/numeric-timezone-abbrev.sql'>numeric-timezone-abbrev.sql</a> - get all timezones with numeric abbreviation
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/timezone-abbrev.sql'>timezone-abbrev.sql</a> - get all timezone abbreviations and offsets
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/timezone-names.sql'>timezone-names.sql</a> - get all timezone abbreviations, names and offsets
</pre>
<h3>MEMORY: Memory Settings and/or Advisors</h3>
<pre>
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/db_cache_advice.sql'>db_cache_advice.sql</a> - run db cache advisor
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/mem-leak-detect.sql'>mem-leak-detect.sql</a> - discover sessions that may be leaking memory
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/mem-subpool-mgt.sql'>mem-subpool-mgt.sql</a> - parameters used to manage memory subpools - requires SYSDBA
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/ora-4031-info-shared-pool.sql'>ora-4031-info-shared-pool.sql</a> - displays several memory related configuration settings
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/pgacols.sql'>pgacols.sql</a> - column formatting
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/pga_advice.sql'>pga_advice.sql</a> - run pga cache advisor
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/pga_advice_hist.sql'>pga_advice_hist.sql</a> - pga cached advice history
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/pga_advice_selective.sql'>pga_advice_selective.sql</a> - reports on pga cache advice only if min_pct gains achieved
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/pga_history_sum.sql'>pga_history_sum.sql</a> - pga cached advice summary
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/pga_history_week.sql'>pga_history_week.sql</a> - pga history per week
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/pga_workarea_active.sql'>pga_workarea_active.sql</a> - show active pga workareas
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/pga_workarea_hist.sql'>pga_workarea_hist.sql</a> - history of active pga workarea
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/pgastat.sql'>pgastat.sql</a> - PGA stats from gv$pgastat
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/pgastat_hist.sql'>pgastat_hist.sql</a> - PGA stats from dba_hist_pgastat
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/process-memory.sql'>process-memory.sql</a> - combined 2 external scripts to get memory report of v$process per session
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sga_advice_selective.sql'>sga_advice_selective.sql</a> - reports on sga cache advice only if min_pct gains achieved
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/shared_pool_advice.sql'>shared_pool_advice.sql</a> - shared pool advisor
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/shared_pool_advice_selective.sql'>shared_pool_advice_selective.sql</a> - reports on shared pool advice only if min_pct gains achieved
</pre>
<h3>METRICS: Metrics reported by oracle - v$sysmetric, v$sysmetric_history ...</h3>
<pre>
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/cpu-bucket-histogram.sql'>cpu-bucket-histogram.sql</a> - histogram of number of minutes per CPU usage values
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/cpu-minute-histogram.sql'>cpu-minute-histogram.sql</a> - histogram of CPU by minute for a single instance
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/metrics-available.sql'>metrics-available.sql</a> - show which metrics are actually being recorded. call with the following 2 scripts
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/metrics-available-awr.sql'>metrics-available-awr.sql</a> - metrics that are recorded in v$sysmtetric_history
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/metrics-available-ash.sql'>metrics-available-ash.sql</a> - metrics that are recorded in dba_hist_sysmetric_history
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/metric-names.sql'>metric-names.sql</a> - detail of metrics reported along with collection intervals
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/os-load.sql'>os-load.sql</a> - OS Load as reported by oracle for past hour
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sql-read-write-size.sql'>sql-read-write-size.sql</a> - get the read and write sizes per sql where write size > 0
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sql-read-write-size-sql.sql'>sql-read-write-size-sql.sql</a> - get the read and write sizes per sql, with sql_text, where write size > 0
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sysmetric-cpu-seconds-hist.sql'>sysmetric-cpu-seconds-hist.sql</a> - get CPU seconds per second from dba_hist_sysmetrics_history (all metrics)
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/sysmetric-cpu-seconds-summary.sql'>sysmetric-cpu-seconds-summary.sql</a> - get CPU seconds per second (maxval) from dba hist sysmetrics ("System Metrics Long Duration" only)
</pre>
<h3>CDB-PDB: Scripts that are specific to Container and Pluggable databases</h3>
<pre>
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/cdb-containers-query.sql'>cdb-containers-query.sql</a> - Example of using the containers() clause to execute a query across all open PDBs
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/cdb_sched_jobs.sql'>cdb_sched_jobs.sql</a> - show all scheduler jobs from CDB Root Level
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/pdb-awr-enable.sql'>pdb-awr-enable.sql</a> - enable AWR snapshots in a PDB
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/pdb-modifiable-params-dump.sql'>pdb-modifiable-params-dump.sql</a> - Dump the parameters from v$system_parameter that can be modified on a PDB
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/pdb-violations.sql'>pdb-violations.sql</a> - show sqlpatch violations for PDBs
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/setc.sql'>setc.sql</a> - automatically or interactively do 'alter session set container'
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/show_container.sql'>show_container.sql</a> - display the current container database name
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/show-pdbs.sql'>show-pdbs.sql</a> - Show the con_id and con_name for available PDBs
</pre>
<h3>XML: Scripts for use with XML and or XMLDB</h3>
<pre>
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/xmldb-status.sql'>xmldb-status.sql</a> - check status of XMLDB
</pre>
<h3>X$ Tables: Some reporting on Oracle Internal Tables</h3>
<pre>
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/x-dollar/xdesc-all.sql'>x-dollar/xdesc-all.sql</a> - generate a report of all X$ tables and columns
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/x-dollar/xdesc.sql'>x-dollar/xdesc.sql</a> - lookup the columns for an X$ table and show relevant info
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/x-dollar/README.md'>x-dollar/README.md</a> - X$ Readme
</pre>
<h3>RESULT-CACHE: Scripts for result cane and client result cache</h3>
<pre>
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/crc-stats.sql'>crc-stats.sql</a> - statistics for client result cache
<a href='https://github.com/jkstill/oracle-script-lib/blob/master/sql/table-annotations.sql'>table-annotations.sql</a> - show tables annotated with MODE FORCE|MANUAL
</pre>
</body>
</html>
