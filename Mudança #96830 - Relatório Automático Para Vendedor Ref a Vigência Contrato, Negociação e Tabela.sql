--==============================================================================================================================================================
--Envia emails enquanto contador for menor que x
--==============================================================================================================================================================

DECLARE @counter INT = 1;
DECLARE @countx INT
SET @countx = (SELECT COUNT([EMAILVENDEDOR]) FROM [SQLAZGERAL].[BI_PATRUS].[dbo].[BI_EmailVendedores] WHERE [EMAILENVIADO] = 'NAO')

WHILE @countx > @counter AND @countx > 0 and (SELECT COUNT(DISTINCT [EMAILVENDEDOR]) FROM [SQLAZGERAL].[BI_PATRUS].[dbo].[BI_EmailVendedores] WHERE [EMAILENVIADO] = 'NAO') > 0
BEGIN    
--==============================================================================================================================================================
--Retorna os destinatarios dos emails
--==============================================================================================================================================================

IF OBJECT_ID('tempdb..#testeemail') IS NOT NULL DROP TABLE #testeemail  
SELECT TOP (1) [EMAILVENDEDOR] into #testeemail FROM [SQLAZGERAL].[BI_PATRUS].[dbo].[BI_EmailVendedores] 
WHERE [EMAILENVIADO] = 'NAO'

--==============================================================================================================================================================
--Envia emails
--==============================================================================================================================================================


DECLARE @QYERY VARCHAR(MAX) 
DECLARE @ASSUNTO VARCHAR (MAX)
SET @QYERY = (SELECT concat(EMAILVENDEDOR,'; gustavolacerda@patrus.com.br') FROM #testeemail)
SET @ASSUNTO = 'Contratos com vencimento no mês atual'


DECLARE @MAIL_BODY VARCHAR(8000)
 
/* HEADER */
SET @MAIL_BODY = '<table border="1" align="center" cellpadding="2" cellspacing="0" style="color:black;font-family:consolas;text-align:center;">' +
    '<tr>
    <th>Contrato</th>
    <th>Vigencia Contrato</th>
    <th>Vigencia Contrato Negociação</th>
    <th>Negociação</th>
    <th>Vigencia Negociação</th>
	<th>Tabela</th>
	<th>Vigencia Tabela</th>
	<th>Cliente</th>
	<th>Vendedor</th>
	<th>Email Vendedor</th>
    </tr>'
 
/* ROWS */
SELECT 
    @MAIL_BODY = @MAIL_BODY +
        '<tr>' +
        '<td>' + Contrato + '</td>' +
        '<td>' + convert(varchar, VigenciaContrato) + '</td>' +
        '<td>' + VigenciaContratoNegociacao + '</td>' +
        '<td>' + Negociacao + '</td>' +
        '<td>' + VigenciaNegociacao + '</td>' +
        '<td>' + Tabela + '</td>' +
		'<td>' + VigenciaTabela + '</td>' +
		'<td>' + CLIENTE + '</td>' +
		'<td>' + VENDEDOR + '</td>' +
		'<td>' + EMAILVENDEDOR + '</td>' +
        '</tr>'
FROM
    [SQLAZGERAL].[BI_PATRUS].[dbo].[BI_EmailVendedores] 
WHERE EMAILVENDEDOR COLLATE SQL_Latin1_General_CP850_CI_AS = (SELECT EMAILVENDEDOR FROM #testeemail) AND [EMAILENVIADO] = 'NAO'


SELECT @MAIL_BODY = 
	'<tr>' +
        '<td>' + 'Prezado Vendedor,' + '</td>' + '<br>' +
        '<td>' + 'Informamos que os contratos abaixo, estão prestes a vencer.' + '</td>' + '<br>' +

		+ @MAIL_BODY + '</table>' +

		'<td>' + 'Atenciosamente,' + '</td>' + '<br>' +

		'<td>' + '<b>' +'Patrus Transportes Urgentes' + '</b>' + '</td>' + '<br>' +

        '</tr>' + '<br>'

EXEC msdb.dbo.sp_send_dbmail  
			@profile_name = 'MonitoramentoSQL',  
			@recipients = @QYERY,  
			--@blind_copy_recipients = 'tulio@patrus.com.br',
			@body = @MAIL_BODY,  
			@subject = @ASSUNTO,
			@body_format='HTML';

--==============================================================================================================================================================
--Faz delete do email que foi enviado
--==============================================================================================================================================================
UPDATE [SQLAZGERAL].[BI_PATRUS].[dbo].[BI_EmailVendedores]
SET EMAILENVIADO = 'SIM'
WHERE EMAILVENDEDOR COLLATE SQL_Latin1_General_CP850_CI_AS = (SELECT EMAILVENDEDOR FROM #testeemail) AND [EMAILENVIADO] = 'NAO'


    SET @counter = @counter + 1;
END