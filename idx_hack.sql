use <db of interest>
go

select left( object_name( object_id ), 48 ) as '[table]', left( statement, 64 ) as 'statement', 
	left( equality_columns, 96 ) as 'equality', left( inequality_columns, 64 ) as 'inequality', 
	included_columns
from sys.dm_db_missing_index_details
where object_name( object_id ) is not null
order by object_id;

select left( ( object_name( a.object_id ) ), 32 ) as 'table name', left( a.name, 48 ) as 'index name', 
	left( a.type_desc, 24 ) as 'index type', left( ( col_name( b.object_id, b.column_id ) ), 48 ) as 'idx column name', 
	case when b.is_included_column = 1 then 'Yes' else 'No' end as 'Included Column?'
from sys.indexes a
left outer join sys.index_columns b
on (
	a.object_id = b.object_id
and a.index_id = b.index_id
	)
where object_name( a.object_id ) = ''
order by a.index_id, b.index_column_id;