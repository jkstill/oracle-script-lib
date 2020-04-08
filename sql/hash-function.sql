
set serveroutput on size unlimited

alter session set plsql_ccflags = 'unit_test:true, develop:true';

create or replace package hash
is
	function md5_hash( clobIn in out nocopy clob) return CLOB;
	function sha256_hash( clobIn in out nocopy clob) return CLOB;
	function sha512_hash( clobIn in out nocopy clob) return CLOB;

	$IF $$unit_test $THEN
	procedure unit_test ;
	$END

end;
/

show errors package hash

create or replace package body hash
is

	$IF $$unit_test $THEN
		cTestData clob;
		cDigest clob;
	$END

	/*
	====================================================================
	== Available Hash Types
	== 
	== HASH_MD4           CONSTANT PLS_INTEGER            :=     1;
	== HASH_MD5           CONSTANT PLS_INTEGER            :=     2;
	== HASH_SH1           CONSTANT PLS_INTEGER            :=     3;
	== HASH_SH256         CONSTANT PLS_INTEGER            :=     4;
	== HASH_SH384         CONSTANT PLS_INTEGER            :=     5;
	== HASH_SH512         CONSTANT PLS_INTEGER            :=     6;
	====================================================================
	*/

	/*
	===============================================
	== function digest
	== return a Hash based on CLOB passed
	===============================================
	*/
	function digest(hashTypeIn PLS_INTEGER, clobIn in out nocopy clob) return CLOB
	is
		hashVal CLOB;
	begin 

		hashVal := rawtohex(dbms_crypto.hash(src => clobIn, typ =>hashTypeIn ));

		return hashVal;

		exception
		when others then
			-- error code here if desired
		raise;
	end;

	/*
	===============================================
	== function md5_digest
	== return an MD5 Hash based on CLOB passed
	===============================================
	*/
	function md5_hash( clobIn in out nocopy clob) return CLOB
	is
		hashVal CLOB;
	begin
		hashVal := digest(hashTypeIn => dbms_crypto.hash_md5, clobIn => clobIn);
		return hashVal;
	end;

	/*
	===============================================
	== function sha256_digest
	== return an SHA256 Hash based on CLOB passed
	===============================================
	*/
	function sha256_hash( clobIn in out nocopy clob) return CLOB
	is
		hashVal CLOB;
	begin
		hashVal := digest(hashTypeIn => dbms_crypto.hash_sh256, clobIn => clobIn);
		return hashVal;
	end;

	/*
	===============================================
	== function sha512_digest
	== return an SHA512 Hash based on CLOB passed
	===============================================
	*/
	function sha512_hash( clobIn in out nocopy clob) return CLOB
	is
		hashVal CLOB;
	begin
		hashVal := digest(hashTypeIn => dbms_crypto.hash_sh512, clobIn => clobIn);
		return hashVal;
	end;

	$IF $$unit_test $THEN
	/*
	===============================================
	== when $$unit_test is true just run this
	== exec hash.main
	===============================================
	*/
	procedure unit_test 
	is
	begin

		dbms_output.enable(null);

		cTestData := 'The Quick Brown Fox Jumped Over the Lazy Dog!';

		dbms_output.put_line('Test Data: ' || cTestData);

		cDigest := md5_hash(cTestData);
		dbms_output.put_line('MD5 Digest: ' || cDigest);

		cDigest := sha256_hash(cTestData);
		dbms_output.put_line('SHA256 Digest: ' || cDigest);

		cDigest := sha512_hash(cTestData);
		dbms_output.put_line('SHA512 Digest: ' || cDigest);
	end;

	$END

begin

	null;

end;
/

show errors package body hash

begin
	$IF $$unit_test $THEN
		hash.unit_test;
	$END

	null;

end;
/



