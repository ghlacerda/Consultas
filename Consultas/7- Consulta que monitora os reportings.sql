--quantidade de execuções de cada relatório
SELECT
  c.Name,
  c.[Path],
  COUNT(*) AS TimesRun
FROM [dbo].[ExecutionLog] AS l
INNER JOIN [dbo].[Catalog] AS c
  ON l.ReportID = C.ItemID
WHERE c.Type = 2
GROUP BY l.ReportId,
         c.Name,
         c.[Path]
ORDER BY TimesRun DESC


--tempo médio e data da última execução de cada relatório
SELECT
  ReportID,
  C.Name,
  CAST(AVG(
  (TimeDataRetrieval + TimeProcessing + TimeRendering) / 1000.0)
  AS decimal(10, 2)) AS TotalRenderingTime,
  CAST(MAX(l.TimeStart) AS date) AS [LastRun]
FROM dbo.ExecutionLog AS l
INNER JOIN [dbo].[Catalog] AS c
  ON l.ReportID = C.ItemID
WHERE c.Type = 2
GROUP BY l.ReportId,
         C.Name
ORDER BY TotalRenderingTime DESC