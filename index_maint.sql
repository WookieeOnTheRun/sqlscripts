use <>
go

select left( b.name, 32 ) as 'schema', a.object_id, a.name as 'table', stats_date( a.object_id, c.stats_id ) as 'statsdate'
from sys.tables a
join sys.schemas b
on a.schema_id = b.schema_id
join sys.stats c
on a.object_id = c.object_id
where datediff( dd, ( stats_date( a.object_id, c.stats_id ) ), getdate() ) <= 90
order by a.name
go

select top 10 *
from sys.stats

select top 10 *
from sys.indexes

-- select a.object_id, left( b.name, 32 ) as 'schema', a.name as 'table', c.name as 'index', stats_date( a.object_id, c.index_id ) as 'statsdate'

set nocount on

declare @execstr varchar( 8000 )

declare execlist cursor read_only forward_only for

select 'alter index [' + c.name + '] on [' + b.name + '].[' + a.name + '] rebuild partition = all with ( sort_in_tempdb = on );'
from sys.tables a
join sys.schemas b
on a.schema_id = b.schema_id
join sys.indexes c
on (
	a.object_id = c.object_id
	)
where 
-- datediff( dd, ( stats_date( a.object_id, c.index_id ) ), getdate() ) > 90 and 
c.index_id > 0
order by a.name

open execlist

fetch next from execlist into @execstr

while ( @@fetch_status ) != -1

begin

	print 'starting rebuild at ' + cast( getdate() as varchar( 64 ) )

	print @execstr
	--exec( @execstr )

	print 'rebuild finished at ' + cast( getdate() as varchar( 64 ) )

	fetch next from execlist into @execstr

end

deallocate execlist

set nocount off

go