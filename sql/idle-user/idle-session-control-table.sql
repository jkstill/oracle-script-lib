
create table idle_user.idle_session_control ( control_command varchar2(4) check (control_command in ('DIE','LIVE')));


insert into  idle_user.idle_session_control values ('LIVE');

commit;



