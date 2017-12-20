use adventureworks

select db_name() as 'db name', a.name, b.text
from sys.objects a
right outer join sys.syscomments b
on a.object_id = b.id
where a.type = 'P'
and (
	b.text like '%insert%'
or	b.text like '%update%'
or	b.text like '%delete%'
	)
and DB_NAME() not in ( 'master', 'model', 'msdb', 'tempdb', 'distribution' )
and ( left( a.name, 5 ) != 'maint' or LEFT( a.name, 3 ) != 'dt_' )
order by a.name

exec master.sys.sp_MSforeachdb 
	'use [?]; select db_name() as ''db name'', a.name as ''proc name'', 
		b.text from sys.objects a 
		right outer join sys.syscomments b 
		on a.object_id = b.id where a.type = ''P'' and ( 
			b.text like ''%insert%'' or b.text like ''%update%'' or b.text like ''%delete%'' ) 
		and db_name() not in ( ''master'', ''msdb'', ''model'', ''tempdb'', ''distribution'' ) 
		and ( left( a.name, 5 ) != ''maint'' or LEFT( a.name, 3 ) != ''dt_'' )
	order by a.name'