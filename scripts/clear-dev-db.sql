begin
    for r in ( select table_name, constraint_name
               from user_constraints
               where constraint_type = 'R' )
    loop
        execute immediate 'alter table '|| r.table_name
                          ||' drop constraint '|| r.constraint_name;
    end loop;
end;
/

BEGIN
    FOR ind IN 
    (
        SELECT index_name
        FROM user_indexes
        WHERE table_name = 'my_table'
        AND index_name NOT IN
       (
            SELECT unique index_name
            FROM user_constraints
            WHERE table_name = 'my_table'
            AND index_name IS NOT NULL
       )
    )
    LOOP
        execute immediate 'DROP INDEX '||ind.index_name;
    END LOOP;
END;
/

begin
    for t in (select table_name from user_tables) loop
        execute immediate 'drop table '|| t.table_name ||' cascade constraints';
    end loop;
end;
/

drop user qbot cascade;
create user qbot identified by QueryBotPassword1;
grant connect, resource to qbot;
grant create session to qbot;
grant create table to qbot;
grant create sequence to qbot;
grant unlimited tablespace to qbot;
