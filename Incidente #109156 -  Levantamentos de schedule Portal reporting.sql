SELECT DISTINCT 
c.Name,
s.StartDate,
s.NextRunTime,
s.LastRunTime,
s.EndDate,
s.RecurrenceType,
s.LastRunStatus,
s.MinutesInterval,
s.DaysInterval,
s.WeeksInterval,
s.DaysOfWeek,
s.DaysOfMonth,
s.[Month],
s.MonthlyWeek,
SUB.LastStatus

FROM dbo.catalog c with (nolock)

INNER JOIN dbo.ReportSchedule rs
	ON rs.ReportID = c.ItemID

INNER JOIN dbo.Schedule s with (nolock)
	ON rs.ScheduleID = s.ScheduleID

INNER JOIN [ReportServer].[dbo].[Subscriptions] SUB
	ON c.ItemID = SUB.Report_OID

WHERE s.LastRunTime >= CAST(GETDATE() AS DATE)
AND LastStatus LIKE '%Mail sent%'

ORDER BY c.name