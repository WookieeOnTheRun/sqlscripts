/*

query plan capture process - the goal is to determine, over a long period of time, consistenly executed queries
on an instance of SQL Server that may qualify as optimization candidates. These values, along with captured metrics 
related to experienced waits and perfmon data, will allow for baseline capture along with additional 
troubleshooting data as issues arise.

*/

set nocount on
go

if not exists ( select name from sys.tables where name = 'scanning_query_capture' and type_desc = 'user_table' )
	begin
	create table dbo.scanning_query_capture (
		objectname varchar( max ) null ,
		operation varchar( 50 ) null ,
		scannedtable varchar( 1000 ) null ,
		scannedobject varchar( 1000 ) null ,
		date_captured datetime not null default( getdate() )
	)
	create clustered index cidx_scanning_query_capture_date on dbo.scanning_query_capture( date_captured )
	end

with xmlnamespaces ( 
	default 'http://schemas.microsoft.com/sqlserver/2004/07/showplan' ,
	'http://schemas.microsoft.com/sqlserver/2004/07/showplan' as p1 
	)
insert into dbo.scanning_query_capture
select case when (objectid is null) then (select text from sys.dm_exec_sql_text(sql_handle)) else object_name(objectid,dbid) end ObjectName
, tScan.value('(./../@PhysicalOp)[1]','Varchar(50)') Operation
, tScan.value('(./p1:Object/@Database)[1]','sysname') + '.' + tScan.value('(./p1:Object/@Schema)[1]','sysname') + '.' + tScan.value('(./p1:Object/@Table)[1]','sysname') 'ScannedTable'
, tScan.value('(./p1:Object/@Database)[1]','sysname') + '.' + tScan.value('(./p1:Object/@Schema)[1]','sysname') + '.' + tScan.value('(./p1:Object/@Table)[1]','sysname') 'ScannedObject'
, getdate()
from sys.dm_exec_query_stats
cross apply sys.dm_exec_query_plan(plan_handle)
cross apply query_plan.nodes('//RelOp[@PhysicalOp = "Table Scan"]/TableScan') T(tScan)
union 
select case when (objectid is null) then (select text from sys.dm_exec_sql_text(sql_handle)) else object_name(objectid,dbid) end
, tScan.value('(./../@PhysicalOp)[1]','Varchar(50)')
, tScan.value('(./p1:Object/@Database)[1]','sysname') + '.' + tScan.value('(./p1:Object/@Schema)[1]','sysname') + '.' + tScan.value('(./p1:Object/@Table)[1]','sysname') 'ScannedTable'
, tScan.value('(./p1:Object/@Database)[1]','sysname') + '.' + tScan.value('(./p1:Object/@Schema)[1]','sysname') + '.' + tScan.value('(./p1:Object/@Table)[1]','sysname') + ' ( ' + tScan.value('(./p1:Object/@Index)[1]','sysname')+ ' )' 
, getdate()
from sys.dm_exec_query_stats
cross apply sys.dm_exec_query_plan(plan_handle)
cross apply query_plan.nodes('//RelOp[contains(@PhysicalOp , "Index Scan")]/IndexScan') T(tScan)
order by Operation DESC

set nocount off

go