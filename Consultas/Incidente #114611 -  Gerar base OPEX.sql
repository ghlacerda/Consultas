-- DROP TABLE IF EXISTS #TESTE
 
 
--  SELECT                                                                                                                
                                     
--        FILDST.NOME                                                          AS FILIALENTREGA,
--		MONTH(A.DATAENTREGA) AS MES,   
--		YEAR(A.DATAENTREGA) AS ANO,                    
                                         
-- CASE                                                                                                                                    
-- 		WHEN (                                                                                                                          
-- 				 A.DATAENTREGA IS NOT NULL AND CAST(ISNULL(A.DTPREVISAOENTREGAEDI,A.DTPREVISAOENTREGAEMISSAO) AS DATE) < CAST(A.DATAENTREGA AS DATE)                                  
-- 				)                                                                                                                       
-- 			AND NOT EXISTS (                                                                                                            
--			            SELECT 1																										    
--			            FROM GLOP_OCORRENCIAS O																							    
--			            	INNER JOIN GLGL_DOCUMENTOASSOCIADOS T1 ON T1.DOCUMENTOCLIENTE = O.NOTAFISCAL								    
--			            	INNER JOIN GLOP_TIPORESPONOCORRENCIA T2 ON T2.RESPONSABILIDADE = O.RESPONSABILIDADE							    
--			            WHERE O.ESTORNADO = 'N'																							    
--			            	AND T1.DOCUMENTOLOGISTICA = A.HANDLE																		    
--			            	AND T2.CLASSIFICACAO = 2   																					    
--			            	AND CAST(O.INCLUIDOEM AS DATE) <= CAST(ISNULL(A.DTPREVISAOENTREGAEDI, A.DTPREVISAOENTREGAEMISSAO) AS DATE)	
-- 				)                                                                                                                       
-- 			THEN 'Entregue Fora do Prazo'                                                                                        
-- 		WHEN (                                                                                                                          
-- 			(                                                                                                                           
-- 				 A.DATAENTREGA IS NOT NULL                                                                                                   
-- 		        AND CAST(ISNULL(ISNULL(A.DTPREVISAOENTREGAEDI,A.DTPREVISAOENTREGAEMISSAO), GETDATE()) AS DATE) >= CAST(A.DATAENTREGA AS DATE)                                    
-- 				)                                                                                                                       
-- 			OR (                                                                                                                        
-- 				(                                                                                                                       
-- 					 A.DATAENTREGA IS NOT NULL                                                                                               
-- 					AND CAST(ISNULL(A.DTPREVISAOENTREGAEDI,A.DTPREVISAOENTREGAEMISSAO) AS DATE) < CAST(A.DATAENTREGA AS DATE)                                                    
-- 					)                                                                                                                   
-- 				AND EXISTS (                                                                                                            
--			            SELECT 1																										    
--			            FROM GLOP_OCORRENCIAS O																							    
--			            	INNER JOIN GLGL_DOCUMENTOASSOCIADOS T1 ON T1.DOCUMENTOCLIENTE = O.NOTAFISCAL								    
--			            	INNER JOIN GLOP_TIPORESPONOCORRENCIA T2 ON T2.RESPONSABILIDADE = O.RESPONSABILIDADE							    
--			            WHERE O.ESTORNADO = 'N'																							    
--			            	AND T1.DOCUMENTOLOGISTICA = A.HANDLE																		    
--			            	AND T2.CLASSIFICACAO = 2   																					    
--			            	AND CAST(O.INCLUIDOEM AS DATE) <= CAST(ISNULL(A.DTPREVISAOENTREGAEDI, A.DTPREVISAOENTREGAEMISSAO) AS DATE)	
-- 					)                                                                                                                   
-- 				)                                                                                                                       
-- 		    )                                                                                                                           
-- 					THEN 'Entregue no Prazo'                                                                                  
-- 		WHEN  A.DATAENTREGA IS NULL AND (A.STATUS  IN(235,313,418,419,420,421) OR A.RECUSADO = 'S') THEN 'Finalizado Com Restrição'                                                                      
-- 		WHEN CAST(ISNULL(A.DTPREVISAOENTREGAEDI,A.DTPREVISAOENTREGAEMISSAO) AS DATE) < CAST(GETDATE() AS DATE)                                                                     
-- 			 AND NOT EXISTS (                                                                                                           
--			            SELECT 1																										    
--			            FROM GLOP_OCORRENCIAS O																							    
--			            	INNER JOIN GLGL_DOCUMENTOASSOCIADOS T1 ON T1.DOCUMENTOCLIENTE = O.NOTAFISCAL								    
--			            	INNER JOIN GLOP_TIPORESPONOCORRENCIA T2 ON T2.RESPONSABILIDADE = O.RESPONSABILIDADE							    
--			            WHERE O.ESTORNADO = 'N'																							    
--			            	AND T1.DOCUMENTOLOGISTICA = A.HANDLE																		    
--			            	AND T2.CLASSIFICACAO = 2   																					    
--			            	AND CAST(O.INCLUIDOEM AS DATE) <= CAST(ISNULL(A.DTPREVISAOENTREGAEDI, A.DTPREVISAOENTREGAEMISSAO) AS DATE)	
-- 				)                                                                                                                       
-- 									THEN 'Em Aberto em Atraso'                                                                  
-- 		ELSE 'Em Aberto no Prazo'                                                                                                
-- 	END AS SITUACAO 
--	,1 AS QTD                                                                                                                   
-- INTO #TESTE                                        
--  FROM                                                                                                                
--  GLGL_DOCUMENTOS A                                                                                                   
--  INNER JOIN GLGL_TIPODOCUMENTOS      TPDOC            ON (A.TIPODOCUMENTO             = TPDOC.HANDLE              )  
--  LEFT JOIN GLGL_PESSOAS             GLPREC           ON (GLPREC.HANDLE                    = A.RECEBEDOR                                 )
--  LEFT JOIN GN_PESSOAS               RECEBEDOR        ON (RECEBEDOR.HANDLE                 = GLPREC.PESSOA                               )
--  LEFT JOIN GLGL_PESSOAS             GLTOMADOR        ON (A.TOMADORSERVICOPESSOA           = GLTOMADOR.HANDLE                            )
--  LEFT JOIN GLGL_PESSOACONFIGURACOES PESSOACONFIG     ON (PESSOACONFIG.PESSOALOGISTICA     = GLTOMADOR.HANDLE                            )
--  LEFT JOIN GN_PESSOAS               TOMADOR          ON (GLTOMADOR.PESSOA                 = TOMADOR.HANDLE                              )
--  LEFT JOIN GLGL_ENUMERACAOITEMS     TPDOCFRETE       ON (A.TIPODOCUMENTOFRETE             = TPDOCFRETE.HANDLE                           )
--  LEFT JOIN GLGL_ENUMERACAOITEMS     STATUS           ON (A.STATUS                         = STATUS.HANDLE                               )
--  LEFT JOIN GLGL_CONTROLESERIEDOCS   CTRLSERIE        ON (CTRLSERIE.HANDLE                 = A.SERIE                                     )
--  LEFT JOIN FILIAIS                  FILEMI           ON (FILEMI.HANDLE                    = A.FILIAL                                    )
--  LEFT JOIN FILIAIS                  FILDST           ON (FILDST.HANDLE                    = A.FILIALENTREGA                             )
--  LEFT JOIN FILIAIS                  FILATL           ON (FILATL.HANDLE                    = A.FILIALATUAL                               )
--  LEFT JOIN GLOP_REGIAOATENDIMENTOS  LOCALENTR        ON (LOCALENTR.HANDLE                 = A.REGIAOATENDIMENTOENTREGA                  )
--  LEFT JOIN GLGL_LOCALIDADES         REGENTREGA       ON (LOCALENTR.LOCALIDADE             = REGENTREGA.HANDLE                           
--                                                                                             AND REGENTREGA.EHREGIAOATENDIMENTO = 'S' )
--  LEFT JOIN GLGL_PESSOAENDERECOS     ENDDESTINO       ON (A.DESTINOCONSIDERADO             = ENDDESTINO.HANDLE                                                                 )
--  LEFT JOIN BAIRROS                  BAIRRODESTINO    ON (ENDDESTINO.BAIRRO                = BAIRRODESTINO.HANDLE                                                              )
--  LEFT JOIN MUNICIPIOS               CIDDESTINO       ON (CIDDESTINO.HANDLE                = ENDDESTINO.MUNICIPIO                                                              )
--  LEFT JOIN ESTADOS                  ESTDESTINO       ON (ESTDESTINO.HANDLE                = CIDDESTINO.ESTADO                                                                 )
--  LEFT JOIN GLGL_PESSOAENDERECOS     ENDORIGEM        ON (A.ORIGEMCONSIDERADO              = ENDORIGEM.HANDLE                                                                  )
--  LEFT JOIN MUNICIPIOS               CIDORIGEM        ON (CIDORIGEM.HANDLE                 = ENDORIGEM.MUNICIPIO                                                               )
--  LEFT JOIN ESTADOS                  ESTORIGEM        ON (ESTORIGEM.HANDLE                 = CIDORIGEM.ESTADO                                                                  )
--  LEFT JOIN GN_PESSOAS               REMETENTE        ON (REMETENTE.HANDLE                 = A.REMETENTE                                                                       )
--  LEFT JOIN GN_PESSOAS               DESTINATARIO     ON (DESTINATARIO.HANDLE              = A.DESTINATARIO                                                                    )
--  LEFT JOIN GLGL_ENUMERACAOITEMS     TIPOTOMA         ON (TIPOTOMA.HANDLE                  = A.TOMADORSERVICO                                                                  )
--  LEFT JOIN GLGL_DOCUMENTOTRIBUTOS   DOCTRIB          ON (DOCTRIB.DOCUMENTO                = A.HANDLE                                                                          )
--  LEFT JOIN GLOP_VIAGENS             VIAGEMATUAL      ON (VIAGEMATUAL.HANDLE               = A.VIAGEMATUAL AND VIAGEMATUAL.TIPOVIAGEM = 172)                                    
--  LEFT JOIN MA_RECURSOS              VEICULOATUAL     ON (VEICULOATUAL.HANDLE              = VIAGEMATUAL.VEICULO1                               )                               
--  LEFT JOIN K_GLOP_VEICULOPOSICOES RST                ON (RST.HANDLE = (SELECT MAX(AUX.HANDLE) FROM K_GLOP_VEICULOPOSICOES AUX WHERE AUX.VEICULO = VEICULOATUAL.HANDLE)        )
--  WHERE A.EMPRESA = 1                                                                                                       
--  	AND A.STATUS NOT IN(236,237,417,220,221,222,223,224,399,404,416,418,419,420,609,743,890)     
--  	AND (A.TIPODOCUMENTO IN(1,2) OR (A.TIPODOCUMENTO = 6 AND A.TIPORPS <> 324) )      
-- AND A.DATAENTREGA >= '2018-01-01 00:00:00'
-- AND A.DATAENTREGA < '2019-12-01 00:00:00'
-- --AND A.FILIALENTREGA IN(329)
-- AND (A.TIPODOCUMENTO = 2 AND A.TIPODOCUMENTOFRETE IN(153) OR A.TIPODOCUMENTO = 6) 
--AND  NOT(A.DATAENTREGA IS NULL AND (A.STATUS  IN(235,313,418,419,420,421) OR A.RECUSADO = 'S'))
-- ORDER BY A.DATAEMISSAO 


SELECT * 
INTO #TESTE2
FROM   
(
    SELECT 
        FILIALENTREGA, 
        MES,
        ANO,
		SITUACAO,
		SUM(QTD) AS QTD
    FROM 
       #TESTE
	GROUP BY 
		FILIALENTREGA, 
        MES,
        ANO,
		SITUACAO
) t 
PIVOT(
    SUM(QTD) 
    FOR SITUACAO IN (
        [Entregue no Prazo], 
        [Entregue Fora do Prazo] 
        )
) AS pivot_table;


SELECT * FROM  #TESTE2
ORDER BY ANO, MES