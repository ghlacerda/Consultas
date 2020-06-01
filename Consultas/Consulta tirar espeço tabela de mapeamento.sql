USE [BI_PATRUS]
GO

SELECT DISTINCT [ReportsName]
      ,REPLACE(REPLACE(REPLACE(REPLACE(replace(replace(replace([ReportFilters],' ','<>'),'><',''),'<>',' '),'	','<>'),'<>',''), CHAR(13), ''), CHAR(10), '')

  FROM [ReportsDictionary].[BI_ReportsFollow]
  WHERE ReportsName <> ''
  --AND Directory <> ''
  AND ReportFilters <> ''


GO


