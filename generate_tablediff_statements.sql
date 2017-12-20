/* 
run this script within the scope of the source database listed 
in the @sourcedb local variable below
take the results and save them to a file with a .bat extension
the log files generated will specify the name of  the .sql file that
contains the "fixing" sql statement
*/

declare @tbl sysname, @sch sysname, @srcinstance varchar( 255 ), @destinstance varchar( 255 ), 
	@sourcedb varchar( 255 ), @destdb varchar( 255 ), @sqlstr varchar( 2048 ), @outputfile varchar( 4096 )

select @srcinstance = '' -- source instance
select @destinstance = '' -- instance where changes could/would be applied

select @sourcedb = '' -- database that will be source of data matching
select @destdb = '' -- where data mismatach updates will be applied

-- this script assumes that we're going to do a match up against all
-- tables in the database - if you want to only match up against published
-- article tables we can update the script

declare tableloop cursor for

select a.name, b.name
from sys.schemas a
inner join sys.tables b
on a.schema_id = b.schema_id
and b.type = 'U'

open tableloop

fetch next from tableloop into @sch, @tbl

while ( @@FETCH_STATUS ) != -1

begin

-- plug in location for where files are to be generated
select @outputfile = '' + '\' + @sch + '_' + @tbl + '_output.txt'

select @sqlstr = 'tablediff -f -o ' + @outputfile + ' -sourceserver ' + @srcinstance + ' -sourcedatabase ' + @sourcedb
select @sqlstr = @sqlstr + ' -sourceschema ' + @sch + ' -sourcetable ' + @tbl + ' -destinationserver ' + @destinstance
select @sqlstr = @sqlstr + ' -destinationdatabase ' + @destdb + ' -destinationschema ' + @sch + ' -destinationtable ' + @tbl

print @sqlstr

fetch next from tableloop into @sch, @tbl

end

deallocate tableloop