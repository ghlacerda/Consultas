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
--'Informações de entrega Alpargatas',
--'Grau_de_Risco_Natura - Contagem',
--'Informações de entrega cliente',
--'Movimentação Diária SBF e-Commerce',
--'Relatório Analitico NF por Fatura',
--'Relatório Bloqueio por Inadimplencia',
--'Relatório chave de acesso CTe - SBF',
--'Relatório Cinquenta Maiores Clientes - Mes',
--'Relatório Cubagem CTe',
--'Relatorio de Carretas Ociosas',
--'Relatório de faturamento diário EPP',
--'Relatorio de Fretes Tramontina',
--'Relatório Desbloqueio - Liberado para Transportar',
--'Relatório Diário - Calçados Furlanetto',
--'Relatório Diário SBF',
--'Relatorio documentos parados a mais de 12 dias',
--'Relatório Documentos pendentes e em Aberto Natura',
--'Relatorio MaryKay - Doc em transito',
--'Relatorio MaryKay - Doc entregue dia anterior'
--)

--and c.Name = 'Relatório Mensal Como Chegar - Sync'

ORDER BY c.name
