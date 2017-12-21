use msdb
go

set nocount on

declare @relativestr varchar( 8000 ), @schedid int, @freqtype int, @freqint int, @freqrelint int

-- build temp table
select a.name as 'job_name', c.schedule_id, c.name as 'schedule_object_name', c.freq_type, ( case 
	when c.freq_type = 1 then 'One Time Only'
	when c.freq_type = 4 then 'Daily'
	when c.freq_type = 8 then 'Weekly'
	when c.freq_type in ( 16, 32 ) then 'Monthly'
	when c.freq_type = 64 then 'When SQL Agent Starts'
	when c.freq_type = 128 then 'When server is idle'
	end ) as 'frequency', replicate( 'None', 12 ) as 'frequency_interval' , NULL as 'sub_interval', NULL as 'relative_interval'
into ##joblist
from sysjobs a
join sysjobschedules b
on a.job_id = b.job_id
join sysschedules c
on b.schedule_id = c.schedule_id
where a.enabled = 1

declare schedlist cursor forward_only read_only 
for

select schedule_id, freq_type
from ##joblist

open schedlist

fetch next from schedlist into @schedid, @freqtype

while ( @@fetch_status ) != -1

	begin

	select @freqint = freq_interval from msdb..sysschedules where schedule_id = @schedid

	select @freqrelint = freq_relative_interval from msdb..sysschedules where schedule_id = @schedid

	select @relativestr = ''

	select @relativestr = ( case
		when @freqtype = 1 then 'One Time Execution Only'
		when @freqtype = 4 then 'Every ' + cast( @freqint as varchar( 32 ) ) + ' Days'
		when @freqtype = 8 and @freqint & 1 = 1 then @relativestr + 'Sunday, '
		when @freqtype = 8 and @freqint & 2 = 2 then @relativestr + 'Monday, '
		when @freqtype = 8 and @freqint & 4 = 4 then @relativestr + 'Tuesday, '
		when @freqtype = 8 and @freqint & 8 = 8 then @relativestr + 'Wednesday, '
		when @freqtype = 8 and @freqint & 16 = 16 then @relativestr + 'Thursday, '
		when @freqtype = 8 and @freqint & 32 = 32 then @relativestr + 'Friday, '
		when @freqtype = 8 and @freqint & 64 = 64 then @relativestr + 'Saturday'
		when @freqtype = 16 then 'Every ' + cast( @freqint as varchar( 32 ) ) + ' of the Month'
		when @freqtype = 32 and @freqint = 1 and @freqrelint = 1 then 'Every First Sunday of the Month'
		when @freqtype = 32 and @freqint = 1 and @freqrelint = 2 then 'Every Second Sunday of the Month'
		when @freqtype = 32 and @freqint = 1 and @freqrelint = 4 then 'Every Third Sunday of the Month'
		when @freqtype = 32 and @freqint = 1 and @freqrelint = 8 then 'Every Fourth Sunday of the Month'
		when @freqtype = 32 and @freqint = 1 and @freqrelint = 16 then 'Every Last Sunday of the Month'
		when @freqtype = 32 and @freqint = 2 and @freqrelint = 1 then 'Every First Monday of the Month'
		when @freqtype = 32 and @freqint = 2 and @freqrelint = 2 then 'Every Second Monday of the Month'
		when @freqtype = 32 and @freqint = 2 and @freqrelint = 4 then 'Every Third Monday of the Month'
		when @freqtype = 32 and @freqint = 2 and @freqrelint = 8 then 'Every Fourth Monday of the Month'
		when @freqtype = 32 and @freqint = 2 and @freqrelint = 16 then 'Every Last Monday of the Month'
		when @freqtype = 32 and @freqint = 3 and @freqrelint = 1 then 'Every First Tuesday of the Month'
		when @freqtype = 32 and @freqint = 3 and @freqrelint = 2 then 'Every Second Tuesday of the Month'
		when @freqtype = 32 and @freqint = 3 and @freqrelint = 4 then 'Every Third Tuesday of the Month'
		when @freqtype = 32 and @freqint = 3 and @freqrelint = 8 then 'Every Fourth Tuesday of the Month'
		when @freqtype = 32 and @freqint = 3 and @freqrelint = 16 then 'Every Last Tuesday of the Month'
		when @freqtype = 32 and @freqint = 4 and @freqrelint = 1 then 'Every First Wednesday of the Month'
		when @freqtype = 32 and @freqint = 4 and @freqrelint = 2 then 'Every Second Wednesday of the Month'
		when @freqtype = 32 and @freqint = 4 and @freqrelint = 4 then 'Every Third Wednesday of the Month'
		when @freqtype = 32 and @freqint = 4 and @freqrelint = 8 then 'Every Fourth Wednesday of the Month'
		when @freqtype = 32 and @freqint = 4 and @freqrelint = 16 then 'Every Last Wednesday of the Month'
		when @freqtype = 32 and @freqint = 5 and @freqrelint = 1 then 'Every First Thursday of the Month'
		when @freqtype = 32 and @freqint = 5 and @freqrelint = 2 then 'Every Second Thursday of the Month'
		when @freqtype = 32 and @freqint = 5 and @freqrelint = 4 then 'Every Third Thursday of the Month'
		when @freqtype = 32 and @freqint = 5 and @freqrelint = 8 then 'Every Fourth Thursday of the Month'
		when @freqtype = 32 and @freqint = 5 and @freqrelint = 16 then 'Every Last Thursday of the Month'
		when @freqtype = 32 and @freqint = 6 and @freqrelint = 1 then 'Every First Friday of the Month'
		when @freqtype = 32 and @freqint = 6 and @freqrelint = 2 then 'Every Second Friday of the Month'
		when @freqtype = 32 and @freqint = 6 and @freqrelint = 4 then 'Every Third Friday of the Month'
		when @freqtype = 32 and @freqint = 6 and @freqrelint = 8 then 'Every Fourth Friday of the Month'
		when @freqtype = 32 and @freqint = 6 and @freqrelint = 16 then 'Every Last Friday of the Month'
		when @freqtype = 32 and @freqint = 7 and @freqrelint = 1 then 'Every First Saturday of the Month'
		when @freqtype = 32 and @freqint = 7 and @freqrelint = 2 then 'Every Second Saturday of the Month'
		when @freqtype = 32 and @freqint = 7 and @freqrelint = 4 then 'Every Third Saturday of the Month'
		when @freqtype = 32 and @freqint = 7 and @freqrelint = 8 then 'Every Fourth Saturday of the Month'
		when @freqtype = 32 and @freqint = 7 and @freqrelint = 16 then 'Every Last Saturday of the Month'
		when @freqtype = 32 and @freqint = 8 and @freqrelint = 1 then 'Every First Day of the Month'
		when @freqtype = 32 and @freqint = 8 and @freqrelint = 2 then 'Every Second Day of the Month'
		when @freqtype = 32 and @freqint = 8 and @freqrelint = 4 then 'Every Third Day of the Month'
		when @freqtype = 32 and @freqint = 8 and @freqrelint = 8 then 'Every Fourth Day of the Month'
		when @freqtype = 32 and @freqint = 8 and @freqrelint = 16 then 'Every Last Day of the Month'
		when @freqtype = 32 and @freqint = 9 and @freqrelint = 1 then 'Every First Weekday of the Month'
		when @freqtype = 32 and @freqint = 9 and @freqrelint = 2 then 'Every Second Weekday of the Month'
		when @freqtype = 32 and @freqint = 9 and @freqrelint = 4 then 'Every Third Weekday of the Month'
		when @freqtype = 32 and @freqint = 9 and @freqrelint = 8 then 'Every Fourth Weekday of the Month'
		when @freqtype = 32 and @freqint = 9 and @freqrelint = 16 then 'Every Last Weekday of the Month'
		when @freqtype = 32 and @freqint = 10 and @freqrelint = 1 then 'Every First Weekend day of the Month'
		when @freqtype = 32 and @freqint = 10 and @freqrelint = 2 then 'Every Second Weekend day of the Month'
		when @freqtype = 32 and @freqint = 10 and @freqrelint = 4 then 'Every Third Weekend day of the Month'
		when @freqtype = 32 and @freqint = 10 and @freqrelint = 8 then 'Every Fourth Weekend day of the Month'
		when @freqtype = 32 and @freqint = 10 and @freqrelint = 16 then 'Every Last Weekend day of the Month'
		when @freqtype = 64 then 'When SQL Server Agent Starts'
	end )

	-- print( 'Relative String: ' + @relativestr )

	update ##joblist
	set frequency_interval = @relativestr
	where schedule_id = @schedid

	fetch next from schedlist into @schedid, @freqtype

	end

deallocate schedlist

select *
from ##joblist

-- last step
drop table ##joblist

set nocount off

go