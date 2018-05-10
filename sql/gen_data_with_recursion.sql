
-- gen_data_with_recursion.sql
-- generate row without connect by
-- using: 
--    Recursive Sub Factored Queries (Oracle term)
--    Recursive Common Table Expression (ANSI term)

with gen (id) as (
        select 1 id from dual
        union all
        select gen.id + 1 as id
        from gen
        where id < 500
)
select count(id) from gen
/


