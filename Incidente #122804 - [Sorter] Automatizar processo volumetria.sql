--==============================================================================================================================================================
--Cria tabela temporaria de volumetria
--==============================================================================================================================================================
DECLARE @DATAINI DATETIME = getdate()
DECLARE @DATAFIM DATETIME = getdate ()
DECLARE @FILIAL INT = 2

SELECT 
       A.DATA 
       ,SUM(A.VOLUMES) TOT_VOLUMES
       ,SUM(A.CLASSIFICADOS) TOT_SORTER 
into #TempVolumetria
FROM (

       SELECT 
               ETIQUETA.HANDLE ETIQUETA
             ,CAST(VD.DATADESCARREGAMENTO AS DATE) DATA
             ,ETIQUETA.VOLUMES
             ,(
                    SELECT COUNT(DISTINCT SORTER.IDITEM)
                    FROM GLGV_ETIQUETAVOLUMES VOLUME
                    INNER JOIN [SORTER_TBCLASSIFICACAO] SORTER ON SORTER.IDITEM = VOLUME.HANDLE
                    WHERE VOLUME.ETIQUETA = ETIQUETA.HANDLE
                           AND SORTER.IDCLASSIFICACAOSTATUS = 2
                    ) CLASSIFICADOS
       FROM GLOP_VIAGEMDOCUMENTOS VD
       INNER JOIN GLOP_VIAGENS VIAGEM ON VIAGEM.HANDLE = VD.VIAGEM
       INNER JOIN GLOP_VIAGEMPARADAS PARADA ON PARADA.HANDLE = VD.PARADA
       INNER JOIN GLGL_DOCUMENTOS DL ON DL.HANDLE = VD.DOCUMENTOLOGISTICA
       INNER JOIN GLGL_DOCUMENTOASSOCIADOS DA ON DA.DOCUMENTOLOGISTICA = DL.HANDLE
       INNER JOIN GLGL_DOCUMENTOCLIENTES DC ON DC.HANDLE = DA.DOCUMENTOCLIENTE
       INNER JOIN GLGV_ETIQUETAS ETIQUETA ON ETIQUETA.DOCUMENTOCLIENTE = DC.HANDLE
       WHERE ETIQUETA.TIPO = 1
       AND ETIQUETA.TIPOEMISSAO = 'N'
       AND ETIQUETA.SITUACAO = 1
       AND VD.SITUACAO <> 210
       AND PARADA.FILIAL = @FILIAL
       AND VD.FILIALORIGEM <> PARADA.FILIAL
       AND VD.DATADESCARREGAMENTO >= DATEADD(DD, -1, CAST(@DATAINI AS DATE))
	   AND VD.DATADESCARREGAMENTO < CAST(@DATAFIM AS DATE)

       UNION ALL

       SELECT 
              NULL ETIQUETA
             ,CAST(VD.DATADESCARREGAMENTO AS DATE) DATA
             ,DC.VOLUME VOLUMES         
             ,(
                    SELECT COUNT(DISTINCT SORTER.IDITEM)
                    FROM GLGV_ETIQUETAVOLUMES VOLUME
                    INNER JOIN [SORTER_TBCLASSIFICACAO] SORTER ON SORTER.IDITEM = VOLUME.HANDLE
                    WHERE VOLUME.ETIQUETA = ETIQUETA.HANDLE
                           AND SORTER.IDCLASSIFICACAOSTATUS = 2
                    ) CLASSIFICADOS
       FROM GLOP_VIAGEMDOCUMENTOS VD
       INNER JOIN GLOP_VIAGENS VIAGEM ON VIAGEM.HANDLE = VD.VIAGEM
       INNER JOIN GLOP_VIAGEMPARADAS PARADA ON PARADA.HANDLE = VD.PARADA
       INNER JOIN GLGL_DOCUMENTOS DL ON DL.HANDLE = VD.DOCUMENTOLOGISTICA
       INNER JOIN GLGL_DOCUMENTOASSOCIADOS DA ON DA.DOCUMENTOLOGISTICA = DL.HANDLE
       INNER JOIN GLGL_DOCUMENTOCLIENTES DC ON DC.HANDLE = DA.DOCUMENTOCLIENTE
       LEFT JOIN GLGV_ETIQUETAS ETIQUETA ON ETIQUETA.DOCUMENTOCLIENTE = DC.HANDLE
                    AND ETIQUETA.TIPO = 1
                    AND ETIQUETA.TIPOEMISSAO = 'N'
                    AND ETIQUETA.SITUACAO = 1
       WHERE VD.SITUACAO <> 210
       AND PARADA.FILIAL = @FILIAL
       AND VD.FILIALORIGEM <> PARADA.FILIAL
       AND ETIQUETA.HANDLE IS NULL
       AND VD.DATADESCARREGAMENTO >= DATEADD(DD, -1, CAST(@DATAINI AS DATE))
	   AND VD.DATADESCARREGAMENTO < CAST(@DATAFIM AS DATE)

       UNION ALL

       SELECT 
              ETIQUETA.HANDLE ETIQUETA
             ,CAST(ETIQUETA.DATAEMISSAO AS DATE) DATA
             ,ETIQUETA.VOLUMES
             ,(
                    SELECT COUNT(DISTINCT SORTER.IDITEM)
                    FROM GLGV_ETIQUETAVOLUMES VOLUME
                    INNER JOIN [SORTER_TBCLASSIFICACAO] SORTER ON SORTER.IDITEM = VOLUME.HANDLE
                    WHERE VOLUME.ETIQUETA = ETIQUETA.HANDLE
                           AND SORTER.IDCLASSIFICACAOSTATUS = 2
                    ) CLASSIFICADOS
       FROM GLGV_ETIQUETAS ETIQUETA
       INNER JOIN GLGL_DOCUMENTOCLIENTES DC ON DC.HANDLE = ETIQUETA.DOCUMENTOCLIENTE
       WHERE ETIQUETA.TIPO = 1
       AND ETIQUETA.TIPOEMISSAO = 'N'
       AND ETIQUETA.FILIAL = @FILIAL
       AND DC.FILIAL = ETIQUETA.FILIAL
       --AND ETIQUETA.DATAEMISSAO BETWEEN @DATAINI AND @DATAFIM
	   AND ETIQUETA.DATAEMISSAO >= DATEADD(DD, -1, CAST(@DATAINI AS DATE))
	   AND ETIQUETA.DATAEMISSAO < CAST(@DATAFIM AS DATE)

) A
GROUP BY A.DATA
ORDER BY 1 DESC


--==============================================================================================================================================================
--Envia emails
--==============================================================================================================================================================

DECLARE @QYERY VARCHAR(MAX) 
DECLARE @ASSUNTO VARCHAR (MAX)
SET @QYERY = 'marcusvinicius@patrus.com.br; silviocesar@patrus.com.br'
SET @ASSUNTO = 'Volumetria Sorter'


DECLARE @MAIL_BODY VARCHAR(8000)
 
/* HEADER */
SET @MAIL_BODY = '<table border="1" align="left" cellpadding="2" cellspacing="0" style="color:black;font-family:consolas;text-align:center;">' +
    '<tr>
    <th>DATA</th>
    <th>TOT_VOLUMES</th>
    <th>TOT_SORTER</th>
    </tr>'
 
/* ROWS */
SELECT
    @MAIL_BODY = @MAIL_BODY +
        '<tr>' +
        '<td>' + convert(varchar, DATA, 105)  + '</td>' +
        '<td>' + convert(varchar, TOT_VOLUMES) + '</td>' +
        '<td>' + convert(varchar, TOT_SORTER) + '</td>' +
       
        '</tr>'
FROM
    #TempVolumetria


SELECT @MAIL_BODY = 
	'<tr>' +
        '<td>' + 'Prezados,' + '</td>' + '<br>' +
        '<td>' + 'Segue as volumetrias :' + '</td>' + '<br>' + '<br>' +

        

@MAIL_BODY + '</table>' + '<br>' + '<br>'

		+ '</tr>' + '<br>' + '<br>'+

		'<td>' + 'Atenciosamente,' + '</td>' + '<br>' +

		'<td>' + '<b>'+ 'Sorter' +'</b>' + '</td>' + '<br>' +

		'<td>' + '<b>' +'Patrus Transportes Urgentes' + '</b>' + '</td>' + '<br>' 

EXEC msdb.dbo.sp_send_dbmail  
			@profile_name = 'MonitoramentoSQL',  
			@recipients = @QYERY,  
			@body = @MAIL_BODY,  
			@subject = @ASSUNTO,
			@body_format='HTML',
			@blind_copy_recipients = 'gustavolacerda@patrus.com.br';
