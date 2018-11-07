use ebd
go

/* get index list for reference purposes */

select * 
from sys.indexes
where index_id >= 1
and object_id not in (
	select object_id
	from sys.objects
	where is_ms_shipped = 1
	)
order by object_id, index_id
go

/* get list of tables/objects that are referenced in missing index dmv */

select left( statement, 48 ) as 'statement', count( statement )
from sys.dm_db_missing_index_details
where database_id = db_id( 'ebd' )
group by statement
go

/*
statement                                        
------------------------------------------------ -----------
[EBD].[dbo].[EventCharge]                        14
[EBD].[dbo].[MLR]                                9
[EBD].[dbo].[Order]                              1
[EBD].[dbo].[Usage]                              64
[EBD].[dbo].[Usage_Error]                        4
*/

/* get list of usage stats for each missing index reference */

select left( a.[statement], 64 ) as 'object', c.user_seeks, c.user_scans, c.last_user_seek, 
	a.equality_columns, a.inequality_columns, a.included_columns
from sys.dm_db_missing_index_details a
join sys.dm_db_missing_index_groups b
on a.index_handle = b.index_handle
join sys.dm_db_missing_index_group_stats c
on b.index_group_handle = c.group_handle
where a.database_id = db_id( 'ebd' )
and a.statement = '[EBD].[dbo].[Usage]'
order by c.user_seeks desc
go