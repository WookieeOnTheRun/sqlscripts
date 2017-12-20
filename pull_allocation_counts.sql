/* select name, type_desc, is_ms_shipped
from master.sys.all_objects
where name like '%interna%'
order by type_desc, name; */

set nocount on

select object_name( a.object_id ) as 'table_name', a.index_id, a.rows, a.data_compression_desc, 
	b.total_pages, b.used_pages, b.data_pages
into ##alloc_report
from sys.partitions a
join sys.allocation_units b
on b.container_id = CASE
	when ( b.type = 1 or b.type = 3 ) then a.hobt_id
	when b.type = 2 then a.partition_id
end
join (
	select object_id( '' ) as 'object_id'
	-- union
	-- select object_id( '' )
) c
on a.object_id = c.object_id

select table_name, index_id, sum( rows )
from ##alloc_report
group by table_name, index_id

drop table ##alloc_report

set nocount off

go