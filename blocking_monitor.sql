use master

declare @start datetime, @end datetime, @increment int

select @start = GETDATE()
select @increment = 0 -- number of minutes to run process
select @end = DATEADD( mi, @increment, @start )

while @start <= @end

begin

if ( select count( session_id ) from sys.dm_exec_requests where blocking_session_id > 0 ) > 0

begin

-- should pull head blocker
print '/*    head blocker    */'
select a.session_id, a.start_time, a.status, a.command, b.text
from sys.dm_exec_requests a
inner join sys.dm_exec_requests c
on a.session_id = c.blocking_session_id
cross apply sys.dm_exec_sql_text( a.sql_handle ) b
-- where a.session_id > 50

-- sessions being blocked
print '/*    blocked sessions    */'
select session_id, blocking_session_id, start_time, [status], command, [text]
from sys.dm_exec_requests
cross apply sys.dm_exec_sql_text( sql_handle )
where blocking_session_id > 0

-- head blocker locks held
print '/*    head blocker locks held    */'
select a.request_session_id, a.*
from sys.dm_tran_locks a
inner join sys.dm_exec_requests b
on a.request_session_id = b.blocking_session_id
order by b.blocking_session_id

end

else

begin

print 'no blocking observed'

end

waitfor delay '00:00:30'

select @start = GETDATE()

end

go