/*

performance monitor capture process - the goal is to determine, over a long period of time, values for key perfmon
metrics on an instance of SQL Server. These values, along with captured metrics related to experienced waits, 
will allow for baseline capture along with additional troubleshooting data as issues arise.

*/

if not exists ( select name from sys.tables where name = 'perfmon_objects_lookup' and type_desc = 'user_table' )
	begin
	declare @inst varchar( 64 )
	select @inst = CASE
		when cast( ( SERVERPROPERTY( 'instancename' ) ) as varchar( 64 ) ) is null then 'MSSQL'
		else 'MSSQL$' + cast( ( SERVERPROPERTY( 'instancename' ) ) as varchar( 64 ) )
		end
	create table dbo.perfmon_objects_lookup (
		object_name varchar( 64 ) not null ,
		counter_name varchar( 64 ) not null ,
		instance_name varchar( 64 ) null
		)
	create clustered index cidx_perfmon_objects_lookup on dbo.perfmon_objects_lookup ( object_name, counter_name )
	insert into dbo.perfmon_objects_lookup values( @inst + ':Access Methods', 'Forwarded Records/sec', NULL )
	insert into dbo.perfmon_objects_lookup values( @inst + ':Access Methods', 'Full Scans/sec', NULL )
	insert into dbo.perfmon_objects_lookup values( @inst + ':Access Methods', 'Index Searches/sec', NULL )
	insert into dbo.perfmon_objects_lookup values( @inst + ':Access Methods', 'Page Splits/sec', NULL )
	insert into dbo.perfmon_objects_lookup values( @inst + ':Buffer Manager', 'Buffer cache hit ratio', NULL )
	insert into dbo.perfmon_objects_lookup values( @inst + ':Buffer Manager', 'Buffer cache hit ratio base', NULL )
	insert into dbo.perfmon_objects_lookup values( @inst + ':Buffer Manager', 'Free pages', NULL )
	insert into dbo.perfmon_objects_lookup values( @inst + ':Buffer Manager', 'Lazy writes/sec', NULL )
	insert into dbo.perfmon_objects_lookup values( @inst + ':Buffer Manager', 'Page life expectancy', NULL )
	insert into dbo.perfmon_objects_lookup values( @inst + ':Buffer Manager', 'Target Pages', NULL )
	insert into dbo.perfmon_objects_lookup values( @inst + ':Buffer Manager', 'Total Pages', NULL )
	insert into dbo.perfmon_objects_lookup values( @inst + ':General Statistics', 'Processes blocked', NULL )
	insert into dbo.perfmon_objects_lookup values( @inst + ':Locks', 'Average Wait Time (ms)', '_Total' )
	insert into dbo.perfmon_objects_lookup values( @inst + ':Locks', 'Lock Timeouts/sec', '_Total' )
	insert into dbo.perfmon_objects_lookup values( @inst + ':Locks', 'Lock Waits/sec', '_Total' )
	insert into dbo.perfmon_objects_lookup values( @inst + ':Locks', 'Number of Deadlocks/sec', '_Total' )
	insert into dbo.perfmon_objects_lookup values( @inst + ':Memory Manager', 'Memory Grants Pending', NULL )
	insert into dbo.perfmon_objects_lookup values( @inst + ':SQL Errors', 'Errors/sec', '_Total' )
	insert into dbo.perfmon_objects_lookup values( @inst + ':SQL Statistics', 'Batch Requests/sec', NULL )
	insert into dbo.perfmon_objects_lookup values( @inst + ':SQL Statistics', 'SQL Re-Compilations/sec', NULL )
	end

-- select * from dbo.perfmon_objects_lookup

if not exists ( select name from sys.tables where name = 'perfmon_capture_log' and type_desc = 'user_table' )
	begin
	create table dbo.perfmon_capture_log (
		counter_name varchar( 64 ) not null ,
		instance_name varchar( 64 ) null ,
		collected_value bigint not null ,
		date_collected datetime not null default( getdate() )
		)
	create clustered index cidx_perfmon_capture_log_date on dbo.perfmon_capture_log( date_collected )
	create nonclustered index cidx_perfmon_capture_log on dbo.perfmon_capture_log( counter_name, instance_name )
	end

insert into dbo.perfmon_capture_log
select a.counter_name, a.instance_name, a.cntr_value, getdate()
from sys.dm_os_performance_counters a
inner join dbo.perfmon_objects_lookup b
on a.counter_name = b.counter_name
and a.object_name = b.object_name

-- little bit of data cleanup
delete from dbo.perfmon_capture_log where instance_name not in ( '', '_total' )

go