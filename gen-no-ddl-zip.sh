#!/usr/bin/env bash

: << 'DOCS'


Find all sql files that have DDL.

This script is a prototype for use in

/home/jkstill/oracle/sql-environment/create-zip.sh

The goal is to create a zip file that has no SQL scripts containing DDL

Eliminate (most)false positive
Use regex negative lookbehind to assert that this is not a quoted insert/update/delete/drop/etc.
Sometimes there are comments that may say something about 'insert into' 'delete from' etc.

     | xargs grep -HiP "(?<!['\"\w])((insert|merge)\s+into|delete\s+from|(drop|create)\s+(table|index|sequence)|update\s+\w+)" \
	
Eliminate more false positives - commented out lines containing DDL/DML

	  | grep -viE -- '^[[:alnum:][:punct:]/\s]+:\s*(--)' \
     #| grep -iP  "(?<!['\"\w])((insert|merge)\s+into|delete\s+from|(drop|create)\s+(table|index|sequence)|update\s+\w+)" \
     #| cut -f1 -d: | sort -u 

	# deprecated line
	#| grep -viE -- ':\s*(--|#)\s*(((insert|merge)\s+into)|(delete\s+from)|(drop|create)\s+(table|index|sequence)|update\s+\w+)' 

DOCS

find sql -name \*.sql \
   | xargs grep -HiP "(?<!['\"\w])((insert|merge)\s+into|delete\s+from|(drop|create)\s+(table|index|sequence)|update\s+\w+)" \
	| grep -viE -- '^[[:alnum:][:punct:]/\s]+:\s*(--)'  \
   | grep -iP  "(?<!['\"\w])((insert|merge)\s+into|delete\s+from|(drop|create)\s+(table|index|sequence)|update\s+\w+)" \
   | cut -f1 -d: | sort -u 

