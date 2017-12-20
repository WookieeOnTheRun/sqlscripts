use adventureworks

create table dbo.blah (
	blah_id int ,
	blah_vc varchar( 255 )
	)
	
go

alter table adventureworks.dbo.blah add 
	blah_date datetime
	
go

with tablecheck as (
	select a.name as 'table_name', b.name as 'column_name'
	from adventureworks.sys.objects a
	left outer join adventureworks.sys.columns b
	on a.object_id = b.object_id
	and OBJECTPROPERTY( a.object_id , 'IsUserTable' ) = 1
	)
select * from tablecheck where column_name is not null
go