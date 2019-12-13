declare @BeginDate DATE = DateAdd(mm, DateDiff(mm,0,GetDate()) + 0, 0)
declare @EndDate DATE = GETDATE()

--Indicar documentos que possuem comprovante de entrega integrado, por�m sem integra��o com o cliente
SELECT 1 ORDEM,
	'Doc. Integrado, sem integra��o com cliente' AS TIPO,
        DOC.HANDLE,
	FILIAIS.NOME,
	FILIAIS.K_LATITUDE, 
	FILIAIS.K_LONGITUDE,
	CAST(DOC.NUMEROSDOCUMENTOS AS VARCHAR(100))NUMEROSDOCUMENTOS,
	DOC.NUMERO DOCUMENTO,
	DOC.DATAENTREGA,
	ANEXO.K_INTEGRADOCLIENTE INTEGRADO,
	ANEXO.K_DTINTEGRACAOCLIENTE DATAINTEGRACAO,
	ANEXO.ARQUIVO Arquivo,
	ANEXO.DESCRICAO,
	CASE
		WHEN ANEXO.K_INTEGRADOCLIENTE = 'S' THEN 'INTEGRADO'
	ELSE 'N�O INTEGRADO'
	END AS TIPO
FROM GLGL_DOCUMENTOS DOC
INNER JOIN GLGL_DOCUMENTOANEXOS ANEXO ON ANEXO.DOCUMENTO = DOC.HANDLE and ANEXO.CLASSIFICACAO IN(497,1281) --COMPROVANTE DE ENTREGA E COMPROVANTE DE ENTREGA MOBILE
INNER JOIN FILIAIS ON FILIAIS.HANDLE = DOC.FILIAL
INNER JOIN GLCM_REGOPERACIONAIS REG ON DOC.REGOPERACIONAL = REG.HANDLE
INNER JOIN GN_PESSOAS P ON DOC.REMETENTE = P.HANDLE 
WHERE 1=1
AND ((DOC.TIPODOCUMENTO IN (2)) OR ((DOC.TIPODOCUMENTO = 6 AND DOC.TIPORPS IN (322))))
AND ANEXO.K_INTEGRADOCLIENTE = 'N'
AND REG.K_ARQUIVAMENTODIGITAL = 'S'
AND DOC.DATAENTREGA >= DateAdd(mm, DateDiff(mm,0,GetDate()) + 0, 0)
AND DOC.DATAENTREGA < GETDATE()
AND P.CGCCPF LIKE '%71.673.990%'
AND NOT EXISTS (Select 1
					From GLGL_DOCUMENTOANEXOS DLA
				Where 1=1 
				AND DLA.K_INTEGRADOCLIENTE = 'S'
				--AND DLA.DOCUMENTO = 41218891
				AND DLA.DOCUMENTO = DOC.HANDLE 
				AND DLA.CLASSIFICACAO IN(497,1281))
UNION ALL
--* Alerta de arquivos recusados
SELECT 2 ORDEM,
	   'Alerta de arquivos recusados' AS TIPO,
        DOC.HANDLE,
	FILIAIS.NOME,
	FILIAIS.K_LATITUDE, 
	FILIAIS.K_LONGITUDE,
	CAST(DOC.NUMEROSDOCUMENTOS AS VARCHAR(100))NUMEROSDOCUMENTOS,
	DOC.NUMERO DOCUMENTO,
	DOC.DATAENTREGA,
	'' AS INTEGRADO,
	'' AS DATAINTEGRACAO,
	'' AS Arquivo,
	'' AS DESCRICAO,
	'RECUSADOS' AS TIPO
FROM GLGL_DOCUMENTOS DOC
--INNER JOIN GLGL_DOCUMENTOANEXOS ANEXO ON ANEXO.DOCUMENTO = DOC.HANDLE and ANEXO.CLASSIFICACAO IN(497,1281) --COMPROVANTE DE ENTREGA E COMPROVANTE DE ENTREGA MOBILE
INNER JOIN FILIAIS ON FILIAIS.HANDLE = DOC.FILIAL
INNER JOIN GLCM_REGOPERACIONAIS REG ON DOC.REGOPERACIONAL = REG.HANDLE
INNER JOIN GN_PESSOAS P ON DOC.REMETENTE = P.HANDLE 
WHERE 1=1
AND ((DOC.TIPODOCUMENTO IN (2)) OR ((DOC.TIPODOCUMENTO = 6 AND DOC.TIPORPS IN (322))))
--AND ANEXO.K_INTEGRADOCLIENTE = 'N'
AND REG.K_ARQUIVAMENTODIGITAL = 'S'
AND DOC.DATAENTREGA >= DateAdd(mm, DateDiff(mm,0,GetDate()) + 0, 0)
AND DOC.DATAENTREGA < GETDATE()
--AND P.CGCCPF LIKE '%71.673.990%'
AND NOT EXISTS (Select 1
					From GLGL_DOCUMENTOANEXOS DLA
				Where 1=1 
				--AND DLA.K_INTEGRADOCLIENTE = 'S'
				AND DLA.DOCUMENTO = DOC.HANDLE 
				AND DLA.CLASSIFICACAO IN(497,1281))
AND DOC.DEVOLUCAO = 'N'

UNION ALL

--* Documentos finalizados sem comprovante de entrega
SELECT 3 ORDEM,
	'Documentos finalizados sem comprovante de entrega' AS TIPO,
        DOC.HANDLE,
	FILIAIS.NOME,
	FILIAIS.K_LATITUDE, 
	FILIAIS.K_LONGITUDE,
	CAST(DOC.NUMEROSDOCUMENTOS AS VARCHAR(100))NUMEROSDOCUMENTOS,
	DOC.NUMERO DOCUMENTO,
	DOC.DATAENTREGA,
	ANEXO.K_INTEGRADOCLIENTE INTEGRADO,
	ANEXO.K_DTINTEGRACAOCLIENTE DATAINTEGRACAO,
	ANEXO.ARQUIVO Arquivo,
	ANEXO.DESCRICAO,
	'DOC. ENTREGUE, SEM COMPROVANTE' AS TIPO
FROM GLGL_DOCUMENTOS DOC
INNER JOIN GLGL_DOCUMENTOANEXOS ANEXO ON ANEXO.DOCUMENTO = DOC.HANDLE 
INNER JOIN FILIAIS ON FILIAIS.HANDLE = DOC.FILIAL
INNER JOIN GLCM_REGOPERACIONAIS REG ON DOC.REGOPERACIONAL = REG.HANDLE
INNER JOIN GN_PESSOAS P ON DOC.REMETENTE = P.HANDLE 
WHERE 1=1
AND ((DOC.TIPODOCUMENTO IN (2)) OR ((DOC.TIPODOCUMENTO = 6 AND DOC.TIPORPS IN (322))))
--AND ANEXO.K_INTEGRADOCLIENTE = 'N'
--AND REG.K_ARQUIVAMENTODIGITAL = 'S'
AND DOC.DATAENTREGA >= DateAdd(mm, DateDiff(mm,0,GetDate()) + 0, 0)
AND DOC.DATAENTREGA < GETDATE()
AND P.CGCCPF LIKE '%71.673.990%'
AND ANEXO.CLASSIFICACAO NOT IN(497,1281) --COMPROVANTE DE ENTREGA E COMPROVANTE DE ENTREGA MOBILE


--------------------------------------------------------------------------------------------------------------------------------------
--Monitoramento de ocorr�ncias EDI represadas
--SET ANSI_NULLS ON
DROP TABLE IF EXISTS #TEMPOCC

SELECT 
	OCORREN.HANDLE
	,K_DATAALTERACAO
	,EDIDATAHORAENVIO
	,ENVIAEDIMANUAL
	,DATAENVIOEDIMANUAL
	,ESTORNADO
	,DOCUMENTO
	,NOTAFISCAL
	,ENVIAEDI
	,OCORREN.FILIAL
	,OCORREN.OCORRENCIA
	,1 AS TIPO 
INTO #TEMPOCC
FROM GLOP_OCORRENCIAS OCORREN  
INNER JOIN GLOP_MOTIVOOCORRENCIAS MOTIV ON MOTIV.HANDLE = OCORREN.OCORRENCIA   
LEFT JOIN GLOP_OCORRENCIALOGS LOG ON LOG.OCORRENCIA = OCORREN.HANDLE AND LOG.DESCRICAO = 'Inclus�o'            
WHERE  (((MOTIV.ENVIAEDI = 'S' AND OCORREN.ENVIAEDIMANUAL = 'S') 
AND OCORREN.ESTORNADO = 'N'                                              
AND (CAST(OCORREN.K_DATAALTERACAO AS DATE) BETWEEN DateAdd(mm, DateDiff(mm,0,GetDate()) + 0, 0) AND GETDATE()))                               
AND OCORREN.EDIDATAHORAENVIO IS NULL)

UNION ALL

SELECT 
	OCORREN.HANDLE
	,K_DATAALTERACAO
	,EDIDATAHORAENVIO
	,ENVIAEDIMANUAL
	,DATAENVIOEDIMANUAL
	,ESTORNADO
	,DOCUMENTO
	,NOTAFISCAL
	,ENVIAEDI
	,OCORREN.FILIAL
	,OCORREN.OCORRENCIA
	,2 AS TIPO
FROM GLOP_OCORRENCIAS OCORREN  
INNER JOIN GLOP_MOTIVOOCORRENCIAS MOTIV ON MOTIV.HANDLE = OCORREN.OCORRENCIA   
LEFT JOIN GLOP_OCORRENCIALOGS LOG ON LOG.OCORRENCIA = OCORREN.HANDLE AND LOG.DESCRICAO = 'Inclus�o'            
WHERE  (((OCORREN.ENVIAEDIMANUAL = 'S')                                                                             
    AND (CAST(OCORREN.DATAENVIOEDIMANUAL AS DATE) BETWEEN DateAdd(mm, DateDiff(mm,0,GetDate()) + 0, 0) AND GETDATE())))  
AND OCORREN.EDIDATAHORAENVIO IS NULL 
AND OCORREN.ESTORNADO = 'N'  

DROP TABLE IF EXISTS #TEMPSTATUS

SELECT DISTINCT
	    DOCCLI.NUMERO NUMERONF                                                     
	   ,DOCCLI.PEDIDO                                                              
	   ,DOCCLI.SERIE                        
	   ,CASE DOC.TIPODOCUMENTO          
					WHEN 1 THEN 'CTRC'    
					WHEN 2 THEN 'CT-e'  
					WHEN 6 THEN 'RPS' 
		END as TIPODOC
		,DATEDIFF(MINUTE,K_DATAALTERACAO,GETDATE()) DIFERENCA
	  ,FLOCORRENCIA.NOME FILIALOCORREN 
	  ,#TEMPOCC.EDIDATAHORAENVIO
	  ,#TEMPOCC.ENVIAEDI
	  ,#TEMPOCC.ENVIAEDIMANUAL
	  ,#TEMPOCC.DATAENVIOEDIMANUAL
	  ,DOC.STATUS
	  ,#TEMPOCC.ESTORNADO
	  ,TB2.NOME AS TESTE
	  ,TB2.HANDLE
	  ,#TEMPOCC.HANDLE AS NUMEROOCORRENCIA
	

INTO #TEMPSTATUS 

FROM #TEMPOCC                                                                               
LEFT  JOIN GLGL_DOCUMENTOS DOC ON DOC.HANDLE = #TEMPOCC.DOCUMENTO                                               
LEFT JOIN GLGL_DOCUMENTOASSOCIADOS DA ON DA.DOCUMENTOLOGISTICA = DOC.HANDLE                                    
left JOIN GLGL_DOCUMENTOCLIENTES DOCCLI ON DOCCLI.HANDLE = #TEMPOCC.NOTAFISCAL                                  
INNER JOIN GN_PESSOAS PESSOA ON PESSOA.HANDLE = DOCCLI.REMETENTE                                               
INNER JOIN GLCM_REGOPERACIONAIS REGOP ON REGOP.CONTRATO = DOCCLI.CONTRATO                                      
INNER JOIN FILIAIS FL ON FL.HANDLE = DOCCLI.FILIAL
INNER JOIN FILIAIS FLOCORRENCIA ON FLOCORRENCIA.HANDLE = #TEMPOCC.FILIAL                                                             
INNER JOIN GLCM_REGOPEDI TB1 ON REGOP.HANDLE = TB1.REGOPERACIONAL AND TB1.GRUPOEMPRESARIALPESSOA = DOCCLI.REMETENTE
INNER JOIN Z_AGENDAMENTOS TB2 ON TB1.OEAGENDAMENTO = TB2.HANDLE
--INNER JOIN Z_AGENDAMENTOPARAMETROS TB3 ON TB2.HANDLE = TB3.AGENDAMENTO

WHERE DOC.STATUS NOT IN (236,237)                                                                                
AND DOCCLI.PEDIDO IS NOT NULL                                                                                  
--AND PESSOA.HANDLE in (83768345,295201,523309,308986,83831491,77164697,451280,480985,82480219,5829821)                                                                                        
AND #TEMPOCC.EDIDATAHORAENVIO IS NULL                                                                        
AND dbo.BL_EDIDevolvidoOrigem(DOCCLI.HANDLE,#TEMPOCC.OCORRENCIA) = 1     
--AND TB3.NOME IN ('ALERTAVERMELHO','ALERTAAMARELO')

--UPDATE #TESTESTATUS
--SET DIFERENCA = 115
--WHERE NUMERONF = 23510103

DROP TABLE IF EXISTS #TEMPPIVOTSTATUS

SELECT * 
INTO #TEMPPIVOTSTATUS
FROM (
SELECT NUMERONF
	   ,PEDIDO
	   ,DIFERENCA
	   ,FILIALOCORREN
	   ,TESTE
	   ,AGENDAMENTO
	   ,NOME
	   ,TB2.NUMEROOCORRENCIA
	   ,CONVERT(INT, CAST(TB3.VALOR AS VARCHAR(50))) AS VALOR
	--,CASE
	--	WHEN ((TB3.NOME = 'ALERTAAMARELO' AND DIFERENCA >= CONVERT(INT, CAST(TB3.VALOR AS VARCHAR(50))))
	--		   OR TB3.NOME = 'ALERTAVERMELHO' AND DIFERENCA < CONVERT(INT, CAST(TB3.VALOR AS VARCHAR(50)))) THEN MAX(CONVERT(INT, CAST(TB3.VALOR AS VARCHAR(50))))
	--	WHEN TB3.NOME IN ('ALERTAVERMELHO', 'ALERTAAMARELO') AND DIFERENCA >= CONVERT(INT, CAST(TB3.VALOR AS VARCHAR(50))) THEN MAX(CONVERT(INT, CAST(TB3.VALOR AS VARCHAR(50))))
	--ELSE 'VERDE'
	--END AS TESTE

FROM #TEMPSTATUS TB2
INNER JOIN Z_AGENDAMENTOPARAMETROS TB3 
	ON TB2.HANDLE = TB3.AGENDAMENTO

WHERE TB3.NOME IN ('ALERTAVERMELHO','ALERTAAMARELO')
) T

PIVOT(
    SUM(VALOR) 
    FOR NOME IN (
        [ALERTAVERMELHO], 
        [ALERTAAMARELO]
        )
) AS pivot_table;



SELECT 
	NUMERONF
	   ,PEDIDO
	   ,NUMEROOCORRENCIA
	   ,DIFERENCA
	   ,FILIALOCORREN
	   ,TESTE
	   ,AGENDAMENTO
	,[ALERTAAMARELO]
	,[ALERTAVERMELHO]
	,CASE 
		WHEN DIFERENCA < [ALERTAAMARELO] THEN 'VERDE'
		WHEN DIFERENCA >= [ALERTAAMARELO] AND DIFERENCA < [ALERTAVERMELHO] THEN 'AMARELO'
		WHEN DIFERENCA >= [ALERTAVERMELHO] THEN 'VERMELHO'
	ELSE 'AZUL'
	END AS TIPOALERTA


FROM #TEMPPIVOTSTATUS

---------------------------------------------------------------------------------------------------------------------------------------------------------
--* Indicar alerta de execu��o de agendamentos.

DROP TABLE IF EXISTS #TEMPSTATUSAGENDAMENTO

SELECT * 
INTO #TEMPSTATUSAGENDAMENTO
FROM (
SELECT 
	TB1.AGENDAMENTO
	,DESCRICAO
	,MAX(INICIO) AS [DATA]
	,CASE
		WHEN STATUS = 1 THEN 'EXECUTANDO'
		WHEN STATUS = 2 THEN 'FINALIZADO COM SUCESSO'
		WHEN STATUS = 3 THEN 'FINALIZADO COM ERRO'
	ELSE ''
	END AS STATUSAGENDAMENTO
	,1 AS QTD
FROM Z_AGENDAMENTOLOG TB1
LEFT JOIN Z_AGENDAMENTOS TB2 ON TB1.AGENDAMENTO = TB2.HANDLE
LEFT JOIN Z_AGENDAMENTOPARAMETROS TB3 ON TB2.HANDLE = TB3.AGENDAMENTO 
WHERE TB1.AGENDAMENTO IS NOT NULL
AND TB3.NOME = 'MONITORAR'

GROUP BY TB1.AGENDAMENTO
	,DESCRICAO
	,CASE
		WHEN STATUS = 1 THEN 'EXECUTANDO'
		WHEN STATUS = 2 THEN 'FINALIZADO COM SUCESSO'
		WHEN STATUS = 3 THEN 'FINALIZADO COM ERRO'
	ELSE ''
	END) AS A1

pivot
(
  max([DATA])
  for STATUSAGENDAMENTO in ([EXECUTANDO], [FINALIZADO COM SUCESSO],[FINALIZADO COM ERRO])
) piv

SELECT 
    AGENDAMENTO
	,DESCRICAO
	,EXECUTANDO
	,CASE 
		WHEN EXECUTANDO < GETDATE() OR EXECUTANDO IS NULL THEN GETDATE()
	 ELSE EXECUTANDO
	 END AS EXECUTANDOALTER
	 ,[FINALIZADO COM SUCESSO]
	 ,[FINALIZADO COM ERRO]
	 ,QTD
FROM #TEMPSTATUSAGENDAMENTO