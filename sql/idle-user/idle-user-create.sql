
create user idle_user identified by idle_user;

grant resource, create session, connect to idle_user;

alter user idle_user quota 32m on users;

grant execute on dbms_lock to idle_user;

