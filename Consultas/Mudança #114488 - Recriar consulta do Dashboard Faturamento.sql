DROP TABLE IF EXISTS #TempTesteFaturamento     
	  
SELECT  
	  
	  CAST(DATAEMISSAO AS DATE) AS [DATA]
	  ,FILIALGL.SIGLA AS FILIAL
	  ,ROUND(SUM(DOCLOG.VALORCONTABIL),2)  AS TOTALFATURAMENTO
	  ,0 AS [RPSTotalLiberadoeNaoLiberado]
	  ,0 AS [Disponiveis Para faturar]
	  ,0 AS [Não dispoivel para faturar]

INTO #TempTesteFaturamento                                             
FROM GLGL_DOCUMENTOS AS DOCLOG  with(nolock)                                                                                              
           LEFT JOIN GLGL_FILIAIS AS FILIALGL with(nolock) ON DOCLOG.FILIAL = FILIALGL.HANDLE                                                    
           LEFT JOIN FILIAIS AS FILIAL with(nolock) ON  FILIALGL.FILIAL = FILIAL.HANDLE                                                              
           LEFT JOIN GLGL_TIPODOCUMENTOS AS TPDOC with(nolock) ON DOCLOG.TIPODOCUMENTO = TPDOC.HANDLE                                            
           LEFT JOIN GLGL_ENUMERACAOITEMS AS TPDOCFRE with(nolock) ON DOCLOG.TIPODOCUMENTOFRETE = TPDOCFRE.HANDLE  AND TPDOCFRE.ENUMERACAO = 29  
           LEFT JOIN GLGL_ENUMERACAOITEMS AS TPDOCSER with(nolock) ON DOCLOG.TIPOSERVICOFRETE = TPDOCSER.HANDLE  AND TPDOCSER.ENUMERACAO = 30    
           LEFT JOIN GLGL_ENUMERACAOITEMS AS DOCSTATUS with(nolock) ON DOCLOG.STATUS = DOCSTATUS.HANDLE  AND DOCSTATUS.ENUMERACAO = 42           
           LEFT JOIN GLGL_CONTROLESERIEDOCS AS SERIE with(nolock) ON DOCLOG.SERIE = SERIE.HANDLE                                                 
           LEFT JOIN GLOP_OPERACOES AS OPERACAO with(nolock) ON DOCLOG.TIPOOPERACAO = OPERACAO.HANDLE                                            
           LEFT JOIN GLGL_PESSOAS AS TOMADORGL with(nolock) ON DOCLOG.TOMADORSERVICOPESSOA = TOMADORGL.HANDLE                                    
           LEFT JOIN GN_PESSOAS AS TOMADOR with(nolock) ON TOMADORGL.PESSOA = TOMADOR.HANDLE                                                        
           LEFT JOIN GLGL_PESSOAENDERECOS AS ENDORIGEM with(nolock) ON DOCLOG.ORIGEMENDERECO = ENDORIGEM.HANDLE                                  
           LEFT JOIN MUNICIPIOS AS CIDORIGEM with(nolock) ON ENDORIGEM.MUNICIPIO = CIDORIGEM.HANDLE                                                 
           LEFT JOIN ESTADOS AS ESTORIGEM with(nolock) ON CIDORIGEM.ESTADO = ESTORIGEM.HANDLE                                                       
           LEFT JOIN GLGL_PESSOAENDERECOS AS ENDDESTINO with(nolock) ON DOCLOG.DESTINOENDERECO = ENDDESTINO.HANDLE                               
           LEFT JOIN MUNICIPIOS AS CIDDESTINO with(nolock) ON ENDDESTINO.MUNICIPIO = CIDDESTINO.HANDLE                                              
           LEFT JOIN ESTADOS AS ESTDESTINO with(nolock) ON CIDDESTINO.ESTADO = ESTDESTINO.HANDLE                                                    
           LEFT JOIN GLGL_DOCUMENTOTRIBUTOS AS DOCTRIB with(nolock) ON DOCTRIB.DOCUMENTO = DOCLOG.HANDLE                                         
           LEFT JOIN GLGL_ENUMERACAOITEMS AS ITEMRPS with(nolock) ON DOCLOG.TIPORPS = ITEMRPS.HANDLE AND ITEMRPS.ENUMERACAO =56                  
           LEFT JOIN GLGL_ENUMERACAOITEMS AS ITEMSTATUSFATURA with(nolock) ON DOCLOG.STATUSFATURA = ITEMSTATUSFATURA.HANDLE AND ITEMSTATUSFATURA.ENUMERACAO IN( 65, 57)  
           LEFT JOIN FILIAIS FILIALNFS with(nolock) ON FILIALNFS.HANDLE = DOCLOG.FILIALNFS                                                      
           LEFT JOIN (SELECT DOCUMENTO FROM GLGL_DOCUMENTOANEXOS with(nolock)  WHERE CLASSIFICACAO = 497 GROUP BY DOCUMENTO ) DOCANEXO ON  DOCANEXO.DOCUMENTO =  DOCLOG.HANDLE     
 WHERE 1=1 AND DOCLOG.VALORCONTABIL > 0                                                                                                    
       AND DOCLOG.STATUS NOT IN (220, 223, 224, 236, 237, 399, 404, 416, 417, 418, 419, 420, 421, 609, 743, 890)                             
  		       AND DOCLOG.FRETECORTESIA = 'N'                                                                                             
  		       AND ISNULL(DOCLOG.TIPODOCUMENTOFRETE, 0) <> 155                                                                                         
     AND DOCLOG.EMPRESA = 1                 
 AND DOCLOG.DATAEMISSAO >= CAST(DATEADD(YYYY, -1, DateAdd(yyyy, DateDiff(yyyy,0,GetDate()), 0)) AS DATE)
 AND DOCLOG.DATAEMISSAO <= EOMONTH(GETDATE())
 --AND DOCLOG.STATUSFATURA IN (388, 391)
 AND ( DOCLOG.TIPODOCUMENTO IN (2,22) )--OR ((DOCLOG.TIPODOCUMENTO = 6 AND DOCLOG.TIPORPS IN( 322,324))  
 --  and not EXISTS  (  SELECT 1                                       
 --         FROM GLGL_DOCLOGASSOCIADOS DLA,                            
 --              GLGL_DOCUMENTOS CT                                    
 --         WHERE DLA.DOCUMENTOLOGISTICAPAI = CT.HANDLE                
 --      	        And CT.FRETECORTESIA	= 'N'                        
 --               AND CT.TIPODOCUMENTO IN(1,2,17,22)                   
 --               AND CT.STATUS not IN ( 417, 236, 237, 416, 418, 421) 
 --         AND DLA.DOCUMENTOLOGISTICAFILHO = DOCLOG.HANDLE)        
 --  ) )   
  	AND DOCLOG.DATACANCELAMENTO IS NULL   

GROUP BY CAST(DATAEMISSAO AS DATE)
		 ,FILIALGL.SIGLA

-----------------------------------------------------------
-- Pega os valores do RPS liberado e não liberados
-----------------------------------------------------------

INSERT INTO #TempTesteFaturamento
Select 
	CAST(DATAEMISSAO AS DATE) AS [DATA]
	,GLGL_FILIAIS.SIGLA AS FILIAL
	,0 AS TOTALFATURAMENTO
	,ROUND(Sum(DOCLOG.VALORCONTABIL),2)						[RPSTotalLiberadoeNaoLiberado]
	,0 AS [Disponiveis Para faturar] 
	,0 AS [Não dispoivel para faturar]

From GLGL_DOCUMENTOS DOCLOG
Inner Join GLGL_FILIAIS	On GLGL_FILIAIS.HANDLE				= DOCLOG.FILIAL
Inner Join FILIAIS			On FILIAIS.HANDLE				= GLGL_FILIAIS.FILIAL
WHERE 1=1 
AND DOCLOG.VALORCONTABIL > 0                                                                                                    
AND DOCLOG.STATUS NOT IN ( 223, 224, 236, 237, 399, 404, 416, 417, 418, 419, 420, 421, 609, 743, 890)                             
  		AND DOCLOG.FRETECORTESIA = 'N'                                                                                             
  		AND ISNULL(DOCLOG.TIPODOCUMENTOFRETE, 0) <> 155                                                                                         
AND DOCLOG.EMPRESA = 1                 
AND DOCLOG.STATUSFATURA IN (327, 388, 391, 389,390,1034)
AND ((DOCLOG.TIPODOCUMENTO = 6 AND DOCLOG.TIPORPS in( 322,324 )) 
and not EXISTS  (  SELECT 1                                       
	FROM GLGL_DOCLOGASSOCIADOS DLA,                            
		GLGL_DOCUMENTOS CT                                    
	WHERE DLA.DOCUMENTOLOGISTICAPAI = CT.HANDLE                
       	And CT.FRETECORTESIA	= 'N'                        
		AND CT.TIPODOCUMENTO IN(1,2,17,22)                   
		AND CT.STATUS not IN ( 417, 236, 237, 416, 418, 421) 
	AND DLA.DOCUMENTOLOGISTICAFILHO = DOCLOG.HANDLE)        
)   
AND DOCLOG.DATACANCELAMENTO IS NULL   
AND DOCLOG.DATAEMISSAO >= CAST(DATEADD(YYYY, -1, DateAdd(yyyy, DateDiff(yyyy,0,GetDate()), 0)) AS DATE)
AND DOCLOG.DATAEMISSAO <= EOMONTH(GETDATE())

GROUP BY CAST(DATAEMISSAO AS DATE)
		 ,GLGL_FILIAIS.SIGLA

-------------------------------------------------------------------
--Pega valores de liberados para faturar
-------------------------------------------------------------------

INSERT INTO #TempTesteFaturamento
Select 
	CAST(DATAEMISSAO AS DATE) AS [DATA]
	,GLGL_FILIAIS.SIGLA AS FILIAL
	,0 AS TOTALFATURAMENTO
	,0 AS [RPSTotalLiberadoeNaoLiberado]
	,ROUND(Sum(DOCLOG.VALORCONTABIL),2) AS [Disponiveis Para faturar]
	,0 AS [Não dispoivel para faturar]

From GLGL_DOCUMENTOS DOCLOG
Inner Join GLGL_FILIAIS	On GLGL_FILIAIS.HANDLE				= DOCLOG.FILIAL
Inner Join FILIAIS			On FILIAIS.HANDLE				= GLGL_FILIAIS.FILIAL
WHERE 1=1 
AND DOCLOG.VALORCONTABIL > 0                                                                                                    
		AND DOCLOG.STATUS NOT IN ( 223, 224, 236, 237, 399, 404, 416, 417, 418, 419, 420, 421, 609, 743, 890)                             
  				AND DOCLOG.FRETECORTESIA = 'N'                                                                                             
  				AND ISNULL(DOCLOG.TIPODOCUMENTOFRETE, 0) <> 155                                                                                         
		AND DOCLOG.EMPRESA = 1                 
		AND DOCLOG.STATUSFATURA IN (327, 388, 391)
		AND ((DOCLOG.TIPODOCUMENTO = 6 AND DOCLOG.TIPORPS in( 322,324 )) 
		and not EXISTS  (  SELECT 1                                       
			FROM GLGL_DOCLOGASSOCIADOS DLA,                            
				GLGL_DOCUMENTOS CT                                    
			WHERE DLA.DOCUMENTOLOGISTICAPAI = CT.HANDLE                
       			And CT.FRETECORTESIA	= 'N'                        
				AND CT.TIPODOCUMENTO IN(1,2,17,22)                   
				AND CT.STATUS not IN ( 417, 236, 237, 416, 418, 421) 
			AND DLA.DOCUMENTOLOGISTICAFILHO = DOCLOG.HANDLE)        
	)   
AND DOCLOG.DATACANCELAMENTO IS NULL   
AND DOCLOG.DATAEMISSAO >= CAST(DATEADD(YYYY, -1, DateAdd(yyyy, DateDiff(yyyy,0,GetDate()), 0)) AS DATE)
AND DOCLOG.DATAEMISSAO <= EOMONTH(GETDATE())

GROUP BY CAST(DATAEMISSAO AS DATE)
		 ,GLGL_FILIAIS.SIGLA

----------------------------------------------------------
--Retorna valores de não disponiveis para faturar
----------------------------------------------------------

INSERT INTO #TempTesteFaturamento
Select 
	CAST(DATAEMISSAO AS DATE) AS [DATA]
	,GLGL_FILIAIS.SIGLA AS FILIAL
	,0 AS TOTALFATURAMENTO
	,0 AS [RPSTotalLiberadoeNaoLiberado]
	,0 AS [Disponiveis Para faturar]
	,Sum(GLGL_DOCUMENTOS.VALORCONTABIL)						[Não dispoivel para faturar]  

From GLGL_DOCUMENTOS
Inner Join GLGL_FILIAIS	On GLGL_FILIAIS.HANDLE				= GLGL_DOCUMENTOS.FILIAL
Inner Join FILIAIS			On FILIAIS.HANDLE					= GLGL_FILIAIS.FILIAL

Where GLGL_DOCUMENTOS.STATUS									Not In (224, 404)
And GLGL_DOCUMENTOS.STATUS									Not In (223, 224, 236, 237, 399, 404, 416, 417, 418, 419, 420, 421, 609, 743, 890) 
And GLGL_DOCUMENTOS.STATUSFATURA							IN (389,390,1034)
And GLGL_DOCUMENTOS.FRETECORTESIA							= 'N'
And (GLGL_DOCUMENTOS.TIPODOCUMENTO							In (6)
And GLGL_DOCUMENTOS.TIPORPS									<> 323)
And Not Exists (Select 1
					From GLGL_DOCLOGASSOCIADOS DLA
				Inner Join GLGL_DOCUMENTOS NFS 
					On (DLA.DOCUMENTOLOGISTICAPAI			= NFS.HANDLE)
				Where DLA.DOCUMENTOLOGISTICAFILHO			= GLGL_DOCUMENTOS.HANDLE
					And NFS.TIPODOCUMENTO						In (1, 2, 17, 22)
					And NFS.FRETECORTESIA						= 'N'
					And NFS.STATUS							Not In (224, 404)
					And NFS.STATUS							Not In (223, 224, 236, 237, 399, 404, 416, 417, 418, 419, 420, 421, 609, 743, 890) )
							
AND GLGL_DOCUMENTOS.DATAEMISSAO >= CAST(DATEADD(YYYY, -1, DateAdd(yyyy, DateDiff(yyyy,0,GetDate()), 0)) AS DATE)
AND GLGL_DOCUMENTOS.DATAEMISSAO <= EOMONTH(GETDATE())

GROUP BY CAST(DATAEMISSAO AS DATE)
		 ,GLGL_FILIAIS.SIGLA

----------------------------------------------------------
--Retorna valores totais
----------------------------------------------------------

SELECT 
	[DATA]
	,FILIAL
	,SUM(TOTALFATURAMENTO) AS TOTALFATURAMENTO
	,SUM([RPSTotalLiberadoeNaoLiberado]) AS [RPSTotalLiberadoeNaoLiberado]
	,SUM([Disponiveis Para faturar]) AS [Disponiveis Para faturar]
	,SUM([Não dispoivel para faturar]) AS [Não dispoivel para faturar]

FROM #TempTesteFaturamento
GROUP BY [DATA], [FILIAL]
ORDER BY [DATA]

