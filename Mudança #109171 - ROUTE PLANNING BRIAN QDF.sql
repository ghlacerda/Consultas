
--FILEMI.NOME                                                          AS FILIALEMISSAO,                          
--        CIDORIGEM.NOME                                                       AS CIDADEORIGEM,                           
--        A.NUMERO                                                        AS NUMERODOCLOG,                                
--        A.HANDLE                                                        AS HANDLEDOCLOG,                                
--        CTRLSERIE.SERIE                                                      AS SERIEDOC,                               
--        TPDOC.NOME                                                           AS NOMETIPODOCUMENTO,                      
--        TPDOCFRETE.NOME                                                      AS TIPODOCUMENTOFRETE,                     
--        TOMADOR.NOME                                                         AS NOMETOMADOR,                            
--        TOMADOR.CGCCPF                                                       AS CNPJTOMADOR,                            
--        PESSOACONFIG.CLIENTEEPP                                              AS CLIENTEEPP,                             
--        REMETENTE.NOME                                                       AS NOMEREMETENTE,                          
--        REMETENTE.CGCCPF                                                     AS CNPJREMETENTE,                          
--        DESTINATARIO.NOME                                                    AS NOMEDESTINATARIO,                       
--        DESTINATARIO.CGCCPF                                                  AS CNPJDESTINATARIO,                       
--        RECEBEDOR.NOME                                                       AS NOMERECEBEDOR,                          
--        RECEBEDOR.CGCCPF                                                     AS CNPJRECEBEDOR,                          
--        BAIRRODESTINO.NOME                                                   AS BAIRRO,                                 
--        CIDDESTINO.NOME                                                      AS CIDADEDESTINO,                          
--        ESTDESTINO.SIGLA                                                     AS UFDESTINO,                              
--        FILDST.NOME                                                          AS FILIALENTREGA,                          
--        A.DATAEMISSAO + CONVERT(VARCHAR(8),A.HORAEMISSAO,108)      AS DATAEMISSAO,                                      
--        A.PRAZOENTREGADATAINICIAL                                       AS PRAZOENTREGA,                                
--        A.PRAZOENTREGA                                                  AS PRAZOENTREGAHANDLE,                          
--        A.DTPREVISAOENTREGA                                             AS DATAPREVISAOENTREGAATUAL,                    
--        ISNULL(A.DTPREVISAOENTREGAEDI,A.DTPREVISAOENTREGAEMISSAO)  AS DATAPREVISAOENTREGA,                              
--        A.VALORCONTABIL                                                 AS VALORFRETE,                                  
--  		   TIPOTOMA.NOME                                                        AS TIPOFRETE,                              
--        STATUS.NOME                                                          AS STATUSDOCUMENTO,                        
--        A.RECEBIDOPOR                                                   AS RECEBIDOPOR,                                 
--        A.LOCALIDADEENTREGA                                             AS LOCALIDADEENTREGA,                           
--        A.FILIAL                                                        AS HANDLEFILIALEMI,                             
--   LTRIM(CAST( STUFF((SELECT ' / ' + CAST(INF.NUMERO AS VARCHAR(10)) FROM GLGL_DOCUMENTOCLIENTES INF(NOLOCK)     
--                 INNER JOIN GLGL_DOCUMENTOASSOCIADOS IDOCASSOC(NOLOCK) ON (IDOCASSOC.DOCUMENTOCLIENTE=INF.HANDLE)  
--                 WHERE IDOCASSOC.DOCUMENTOLOGISTICA=A.HANDLE FOR XML PATH('')),2,1,'') AS VARCHAR(200)))       
--   AS NFNUMERO,                                                                                                    
--   A.DOCCLIVALORTOTAL                AS NFVALOR,                                                                   
--   A.DOCCLIPESOTOTAL                 AS NFPESO,                                                                    
--   A.DOCCLIPESOCUBADOTOTAL           AS NFPESOCUBADO,                                                              
--   CAST(A.DOCCLIVOLUME AS INTEGER)   AS NFVOLUMES,                                                                 
--   ''                                   AS NFPEDIDO,                                                             
-- (SELECT GLNF.DATAEMISSAO                                                                                          
--         FROM GLGL_DOCUMENTOCLIENTES GLNF                                                                          
--   WHERE GLNF.HANDLE = (SELECT MAX(INF.HANDLE)                                                                     
--                          FROM GLGL_DOCUMENTOCLIENTES INF                                                          
--                          INNER JOIN GLGL_DOCUMENTOASSOCIADOS IDOCASSOC ON (IDOCASSOC.DOCUMENTOCLIENTE=INF.HANDLE) 
--                         WHERE IDOCASSOC.DOCUMENTOLOGISTICA=A.HANDLE))   AS NFDATAEMISSAO,                         
--   ''                                   AS NFSERIE,                                                              
--   0                                      AS HANDLEDOCCLI,                                                         
-- '' AS OCORRENCIAOP,                   
-- '' AS RESPONSAVELOCORRENCIAOP,        
-- GETDATE() AS DATAOCORRENCIAOP  ,        
-- '' AS CLASSIFICACAORESPONSABILIDADE,  
-- CAST('' AS TEXT) AS OBSOCORRENCIAOP,  
-- '' AS OCORRENCIAFAT,                  
--  NULL AS ATRASO,                                 
--  A.DATAENTREGA       AS DATAENTREGA,             
--  A.PRAZOENTREGADIAS AS PRAZOENTREGANUMDIASREAL,  
--  ''                    AS NUMEROVIAGEM,                 
--  ''                    AS PLACA,                        
--  ''                    AS MOTORISTA,                    
--  GETDATE()               AS INICIOVIAGEM,                 
--  ''                         AS SERVICOLOG,
--  REGENTREGA.NOME REGIAOATENDIMENTO,                                                                                                            
--  FILATL.NOME AS FILIALATUAL,IIF(A.TIPODOCUMENTO IN(1,2),DOCTRIB.VALORICMS,DOCTRIB.VALORISS) VALORIMPOSTO,                                      
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
--,
--  CASE WHEN A.FILIALENTREGA IN(A.FILIALATUAL, A.FILIAL) THEN                                                                                    
                                                                                                                                                
--  	 CASE  WHEN A.STATUS NOT IN(230,234,235,313) AND A.FILIALATUAL = A.FILIALENTREGA THEN 90                                                     
--    		   WHEN A.STATUS = 230 AND A.FILIALATUAL = A.FILIALENTREGA THEN 95                                                                       
--    		   WHEN A.STATUS IN(234,235,313)  THEN 100                                                                                               
--    		   END                                                                                                                                   
--   ELSE                                                                                                                                         
--      ((dbo.CalcDistancia(FILEMI.K_LATITUDE,FILEMI.K_LONGITUDE,FILDST.K_LATITUDE,FILDST.K_LONGITUDE)                                            
--  	-                                                                                                                                            
--  	    dbo.CalcDistancia(ISNULL(RST.Latitude,FILATL.K_LATITUDE),ISNULL(RST.Longitude,FILATL.K_LONGITUDE),FILDST.K_LATITUDE,FILDST.K_LONGITUDE)) 
--  	* 90) / dbo.CalcDistancia(FILEMI.K_LATITUDE,FILEMI.K_LONGITUDE,FILDST.K_LATITUDE,FILDST.K_LONGITUDE)                                         
--  		   END PORCENTENTREGA                                                                                                                      
--,''                  AS INFOMOTIVATRASOCOlETA                                                    
--,''                  AS INFOMOTIVATRASOVIAGEM  




DROP TABLE IF EXISTS #TESTE

SELECT                                                                                                                
        STRING_AGG(CAST(DC.NUMERO AS NVARCHAR(MAX)),';') AS NFNUMEROS
		,CASE 
			WHEN CONVERT(VARCHAR(8),A.HORAEMISSAO,108) >= '00:00:000' AND CONVERT(VARCHAR(8),A.HORAEMISSAO,108) < '12:00:000' THEN 'MANHA'
			WHEN CONVERT(VARCHAR(8),A.HORAEMISSAO,108) >= '12:01:000' AND CONVERT(VARCHAR(8),A.HORAEMISSAO,108) < '17:59:000' THEN 'TARDE'
		 ELSE 'NOITE'
		 END AS HORARIO

		,CAST(A.DATAEMISSAO AS DATE) AS DATAEMISSAO
		,M.NOME AS MUNICIPIO
		,RAR.DESCRICAO ROTA
		,TOMADOR.NOME AS TOMADOR
		,CASE
			WHEN 
				CASE
					WHEN PESSOACONFIG.CLIENTEEPP = 'S' THEN 'EPP'
					--WHEN TOMADOR.NOME = 'NATURA COSMETICOS S/A' THEN 'NATURA'
				 ELSE 'FRACIONADO'
				 END = 'EPP' AND TOMADOR.NOME = 'NATURA COSMETICOS S/A' THEN 'NATURA'
			ELSE 
				CASE
					WHEN PESSOACONFIG.CLIENTEEPP = 'S' THEN 'EPP'
					--WHEN TOMADOR.NOME = 'NATURA COSMETICOS S/A' THEN 'NATURA'
				 ELSE 'FRACIONADO'
				 END
		 END AS TIPOCLIENTE
		,A.PRAZOENTREGADIAS AS PRAZOENTREGA
		,SUM(A.DOCCLIPESOTOTAL)                 AS PESOREAL                                                                
		,SUM(A.DOCCLIPESOCUBADOTOTAL)           AS PESOCUBADO
		,SUM(CAST(A.DOCCLIVOLUME AS INTEGER))   AS NFVOLUMES
		,COUNT(DC.NUMERO) AS QTDPEDIDOS
  
                                           
  FROM                                                                                                                
  GLGL_DOCUMENTOS A                                                                                                   
  INNER JOIN GLGL_TIPODOCUMENTOS      TPDOC            ON (A.TIPODOCUMENTO             = TPDOC.HANDLE)  
  LEFT JOIN GLGL_PESSOAS             GLPREC           ON (GLPREC.HANDLE                    = A.RECEBEDOR                                 )
  LEFT JOIN GN_PESSOAS               RECEBEDOR        ON (RECEBEDOR.HANDLE                 = GLPREC.PESSOA                               )
  LEFT JOIN GLGL_PESSOAS             GLTOMADOR        ON (A.TOMADORSERVICOPESSOA           = GLTOMADOR.HANDLE                            )
  LEFT JOIN GLGL_PESSOACONFIGURACOES PESSOACONFIG     ON (PESSOACONFIG.PESSOALOGISTICA     = GLTOMADOR.HANDLE                            )
  LEFT JOIN GN_PESSOAS               TOMADOR          ON (GLTOMADOR.PESSOA                 = TOMADOR.HANDLE                              )
  LEFT JOIN GLGL_ENUMERACAOITEMS     TPDOCFRETE       ON (A.TIPODOCUMENTOFRETE             = TPDOCFRETE.HANDLE                           )
  LEFT JOIN GLGL_ENUMERACAOITEMS     STATUS           ON (A.STATUS                         = STATUS.HANDLE                               )
  LEFT JOIN GLGL_CONTROLESERIEDOCS   CTRLSERIE        ON (CTRLSERIE.HANDLE                 = A.SERIE                                     )
  LEFT JOIN FILIAIS                  FILEMI           ON (FILEMI.HANDLE                    = A.FILIAL                                    )
  LEFT JOIN FILIAIS                  FILDST           ON (FILDST.HANDLE                    = A.FILIALENTREGA                             )
  LEFT JOIN FILIAIS                  FILATL           ON (FILATL.HANDLE                    = A.FILIALATUAL                               )
  LEFT JOIN GLOP_REGIAOATENDIMENTOS  LOCALENTR        ON (LOCALENTR.HANDLE                 = A.REGIAOATENDIMENTOENTREGA                  )
  LEFT JOIN GLGL_LOCALIDADES         REGENTREGA       ON (LOCALENTR.LOCALIDADE             = REGENTREGA.HANDLE                           
                                                                                             AND REGENTREGA.EHREGIAOATENDIMENTO = 'S' )
  LEFT JOIN GLGL_PESSOAENDERECOS     ENDDESTINO       ON (A.DESTINOCONSIDERADO             = ENDDESTINO.HANDLE                                                                 )
  LEFT JOIN BAIRROS                  BAIRRODESTINO    ON (ENDDESTINO.BAIRRO                = BAIRRODESTINO.HANDLE                                                              )
  LEFT JOIN MUNICIPIOS               CIDDESTINO       ON (CIDDESTINO.HANDLE                = ENDDESTINO.MUNICIPIO                                                              )
  LEFT JOIN ESTADOS                  ESTDESTINO       ON (ESTDESTINO.HANDLE                = CIDDESTINO.ESTADO                                                                 )
  LEFT JOIN GLGL_PESSOAENDERECOS     ENDORIGEM        ON (A.ORIGEMCONSIDERADO              = ENDORIGEM.HANDLE                                                                  )
  LEFT JOIN MUNICIPIOS               CIDORIGEM        ON (CIDORIGEM.HANDLE                 = ENDORIGEM.MUNICIPIO                                                               )
  LEFT JOIN ESTADOS                  ESTORIGEM        ON (ESTORIGEM.HANDLE                 = CIDORIGEM.ESTADO                                                                  )
  LEFT JOIN GN_PESSOAS               REMETENTE        ON (REMETENTE.HANDLE                 = A.REMETENTE                                                                       )
  LEFT JOIN GN_PESSOAS               DESTINATARIO     ON (DESTINATARIO.HANDLE              = A.DESTINATARIO                                                                    )
  LEFT JOIN GLGL_ENUMERACAOITEMS     TIPOTOMA         ON (TIPOTOMA.HANDLE                  = A.TOMADORSERVICO                                                                  )
  LEFT JOIN GLGL_DOCUMENTOTRIBUTOS   DOCTRIB          ON (DOCTRIB.DOCUMENTO                = A.HANDLE                                                                          )
  LEFT JOIN GLOP_VIAGENS             VIAGEMATUAL      ON (VIAGEMATUAL.HANDLE               = A.VIAGEMATUAL AND VIAGEMATUAL.TIPOVIAGEM = 172)                                    
  LEFT JOIN MA_RECURSOS              VEICULOATUAL     ON (VEICULOATUAL.HANDLE              = VIAGEMATUAL.VEICULO1                               )                               
  LEFT JOIN K_GLOP_VEICULOPOSICOES RST                ON (RST.HANDLE = (SELECT MAX(AUX.HANDLE) FROM K_GLOP_VEICULOPOSICOES AUX WHERE AUX.VEICULO = VEICULOATUAL.HANDLE)        )
  LEFT JOIN GLGL_DOCUMENTOCLIENTES DC				  ON A.HANDLE = DC.DOCUMENTOLOGISTICA 
  LEFT JOIN GLGL_DOCUMENTOASSOCIADOS DOCASSOC(NOLOCK) ON (DOCASSOC.DOCUMENTOCLIENTE = DC.HANDLE)
  INNER JOIN GLOP_REGIAOATENDIMENTOROTAS RAR     	  ON A.ROTAENTREGA = RAR.HANDLE
  LEFT JOIN MUNICIPIOS M							  ON ENDDESTINO.MUNICIPIO = M.HANDLE
  WHERE A.EMPRESA = 1                                                                                                       
  	AND A.STATUS NOT IN(236,237,417,220,221,222,223,224,399,404,416,418,419,420,609,743,890)     
  	AND (A.TIPODOCUMENTO IN(1,2) OR (A.TIPODOCUMENTO = 6 AND A.TIPORPS <> 324) )      
 AND A.DATAEMISSAO >= DATEADD(DD,-2,CAST(GETDATE() AS DATE))
 AND A.DATAEMISSAO < DATEADD(DD,-1,CAST(GETDATE() AS DATE))--CAST(GETDATE() AS DATE)
 AND (A.TIPODOCUMENTO = 2 AND A.TIPODOCUMENTOFRETE IN(153) OR A.TIPODOCUMENTO = 6) 
AND  NOT(A.DATAENTREGA IS NULL AND (A.STATUS  IN(235,313,418,419,420,421) OR A.RECUSADO = 'S'))
AND DC.NUMERO IS NOT NULL


GROUP BY 
		CAST(A.DATAEMISSAO AS DATE) --+ CONVERT(VARCHAR(8),A.HORAEMISSAO,108)
		,M.NOME
		,RAR.DESCRICAO
		,CASE 
			WHEN CONVERT(VARCHAR(8),A.HORAEMISSAO,108) >= '00:00:000' AND CONVERT(VARCHAR(8),A.HORAEMISSAO,108) < '12:00:000' THEN 'MANHA'
			WHEN CONVERT(VARCHAR(8),A.HORAEMISSAO,108) >= '12:01:000' AND CONVERT(VARCHAR(8),A.HORAEMISSAO,108) < '17:59:000' THEN 'TARDE'
		 ELSE 'NOITE'
		 END
		,TOMADOR.NOME
		,PESSOACONFIG.CLIENTEEPP
		,A.PRAZOENTREGADIAS


SELECT 
	A.NFNUMEROS
	,A.DATAEMISSAO
	,A.HORARIO
	,A.MUNICIPIO
	,A.ROTA
	,A.TOMADOR
	,A.TIPOCLIENTE
	,A.PRAZOENTREGA
	,A.PESOREAL                                                                
	,A.PESOCUBADO
	,A.NFVOLUMES
	,A.QTDPEDIDOS
	,B.TOTALPEDIDOS
	,B.TOTALVOLUMES
	,CAST(GETDATE() AS DATE) AS DATAINSERÇÃO


FROM [SQLAZGERAL].[BI_PATRUS].[dbo].[BI_ROUTE_PLANNING]
LEFT JOIN 
	(SELECT DATAEMISSAO,SUM(NFVOLUMES) AS TOTALVOLUMES, SUM(QTDPEDIDOS) AS TOTALPEDIDOS FROM [dbo].[TEMP_ROUTE_PLANNING] GROUP BY DATAEMISSAO) B ON A.DATAEMISSAO = B.DATAEMISSAO
LEFT JOIN 
	[SQLAZGERAL].[BI_PATRUS].[dbo].[BI_ROUTE_PLANNING] C ON A.NFNUMEROS COLLATE SQL_Latin1_General_CP850_CI_AS = C.NFNUMEROS AND A.DATAEMISSAO = C.DATAEMISSAO 

WHERE C.DATAEMISSAO IS NULL

ORDER BY MUNICIPIO
