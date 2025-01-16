
-- cf-size.sql - Display the size of the control file in MB

select (file_size_blks * block_size) / power(2,20) from v$controlfile;

