SELECT  *
--c.Name,
----CAST(s.StartDate AS DATE) AS StartDate,
--s.NextRunTime,
--CAST(s.LastRunTime AS DATE) AS LastRunTime,
--CAST(s.EndDate AS DATE) AS EndDate,
--c.[Path] AS Localidade,
----s.RecurrenceType,
----s.LastRunStatus,
----s.MinutesInterval,
----s.DaysInterval,
----s.WeeksInterval,
----s.DaysOfWeek,
----s.DaysOfMonth,
----s.[Month],
----s.MonthlyWeek,
--SUB.LastStatus

FROM dbo.catalog c with (nolock)

INNER JOIN dbo.ReportSchedule rs
	ON rs.ReportID = c.ItemID

INNER JOIN dbo.Schedule s with (nolock)
	ON rs.ScheduleID = s.ScheduleID

INNER JOIN [ReportServer].[dbo].[Subscriptions] SUB
	ON c.ItemID = SUB.Report_OID

WHERE s.LastRunTime >= dateadd(mm,-1,CAST(GETDATE() AS DATE))
AND LastStatus LIKE '%Mail sent%'
--and c.Name not in (
--'Analise de veiculos por filial',
--'Analise Emissoes de CTe',
--'Documentos disponiveis transferencia',
--'Grau_de_Risco_Natura',
--'Grau_de_Risco_Natura_Dia_Atual',
--'Informa��es de entrega Alpargatas',
--'Grau_de_Risco_Natura - Contagem',
--'Informa��es de entrega cliente',
--'Movimenta��o Di�ria SBF e-Commerce',
--'Relat�rio Analitico NF por Fatura',
--'Relat�rio Bloqueio por Inadimplencia',
--'Relat�rio chave de acesso CTe - SBF',
--'Relat�rio Cinquenta Maiores Clientes - Mes',
--'Relat�rio Cubagem CTe',
--'Relatorio de Carretas Ociosas',
--'Relat�rio de faturamento di�rio EPP',
--'Relatorio de Fretes Tramontina',
--'Relat�rio Desbloqueio - Liberado para Transportar',
--'Relat�rio Di�rio - Cal�ados Furlanetto',
--'Relat�rio Di�rio SBF',
--'Relatorio documentos parados a mais de 12 dias',
--'Relat�rio Documentos pendentes e em Aberto Natura',
--'Relatorio MaryKay - Doc em transito',
--'Relatorio MaryKay - Doc entregue dia anterior'
--)

--and c.Name = 'Relat�rio Mensal Como Chegar - Sync'

ORDER BY c.name
