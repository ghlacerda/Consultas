  SELECT                                                                                                                
        
		CASE                                                                                                                                    
 		WHEN (                                                                                                                          
 				 A.DATAENTREGA IS NOT NULL AND CAST(ISNULL(A.DTPREVISAOENTREGAEDI,A.DTPREVISAOENTREGAEMISSAO) AS DATE) < CAST(A.DATAENTREGA AS DATE)                                  
 				)                                                                                                                       
 			AND NOT EXISTS (                                                                                                            
			            SELECT 1																										    
			            FROM GLOP_OCORRENCIAS O																							    
			            	INNER JOIN GLGL_DOCUMENTOASSOCIADOS T1 ON T1.DOCUMENTOCLIENTE = O.NOTAFISCAL								    
			            	INNER JOIN GLOP_TIPORESPONOCORRENCIA T2 ON T2.RESPONSABILIDADE = O.RESPONSABILIDADE							    
			            WHERE O.ESTORNADO = 'N'																							    
			            	AND T1.DOCUMENTOLOGISTICA = A.HANDLE																		    
			            	AND T2.CLASSIFICACAO = 2   																					    
			            	AND CAST(O.INCLUIDOEM AS DATE) <= CAST(ISNULL(A.DTPREVISAOENTREGAEDI, A.DTPREVISAOENTREGAEMISSAO) AS DATE)	
 				)                                                                                                                       
 			THEN 'Entregue Fora do Prazo'                                                                                        
 		WHEN (                                                                                                                          
 			(                                                                                                                           
 				 A.DATAENTREGA IS NOT NULL                                                                                                   
 		        AND CAST(ISNULL(ISNULL(A.DTPREVISAOENTREGAEDI,A.DTPREVISAOENTREGAEMISSAO), GETDATE()) AS DATE) >= CAST(A.DATAENTREGA AS DATE)                                    
 				)                                                                                                                       
 			OR (                                                                                                                        
 				(                                                                                                                       
 					 A.DATAENTREGA IS NOT NULL                                                                                               
 					AND CAST(ISNULL(A.DTPREVISAOENTREGAEDI,A.DTPREVISAOENTREGAEMISSAO) AS DATE) < CAST(A.DATAENTREGA AS DATE)                                                    
 					)                                                                                                                   
 				AND EXISTS (                                                                                                            
			            SELECT 1																										    
			            FROM GLOP_OCORRENCIAS O																							    
			            	INNER JOIN GLGL_DOCUMENTOASSOCIADOS T1 ON T1.DOCUMENTOCLIENTE = O.NOTAFISCAL								    
			            	INNER JOIN GLOP_TIPORESPONOCORRENCIA T2 ON T2.RESPONSABILIDADE = O.RESPONSABILIDADE							    
			            WHERE O.ESTORNADO = 'N'																							    
			            	AND T1.DOCUMENTOLOGISTICA = A.HANDLE																		    
			            	AND T2.CLASSIFICACAO = 2   																					    
			            	AND CAST(O.INCLUIDOEM AS DATE) <= CAST(ISNULL(A.DTPREVISAOENTREGAEDI, A.DTPREVISAOENTREGAEMISSAO) AS DATE)	
 					)                                                                                                                   
 				)                                                                                                                       
 		    )                                                                                                                           
 					THEN 'Entregue no Prazo'                                                                                  
 		WHEN  A.DATAENTREGA IS NULL AND (A.STATUS  IN(235,313,418,419,420,421) OR A.RECUSADO = 'S') THEN 'Finalizado Com Restrição'                                                                      
 		WHEN CAST(ISNULL(A.DTPREVISAOENTREGAEDI,A.DTPREVISAOENTREGAEMISSAO) AS DATE) < CAST(GETDATE() AS DATE)                                                                     
 			 AND NOT EXISTS (                                                                                                           
			            SELECT 1																										    
			            FROM GLOP_OCORRENCIAS O																							    
			            	INNER JOIN GLGL_DOCUMENTOASSOCIADOS T1 ON T1.DOCUMENTOCLIENTE = O.NOTAFISCAL								    
			            	INNER JOIN GLOP_TIPORESPONOCORRENCIA T2 ON T2.RESPONSABILIDADE = O.RESPONSABILIDADE							    
			            WHERE O.ESTORNADO = 'N'																							    
			            	AND T1.DOCUMENTOLOGISTICA = A.HANDLE																		    
			            	AND T2.CLASSIFICACAO = 2   																					    
			            	AND CAST(O.INCLUIDOEM AS DATE) <= CAST(ISNULL(A.DTPREVISAOENTREGAEDI, A.DTPREVISAOENTREGAEMISSAO) AS DATE)	
 				)                                                                                                                       
 									THEN 'Em Aberto em Atraso'                                                                  
 		ELSE 'Em Aberto no Prazo'                                                                                                
 	END AS SITUACAO 
	,FILEMI.NOME                                                          AS FILIALEMISSAO	
	,CIDORIGEM.NOME                                                       AS CIDADEORIGEM	
	,A.NUMERO															  AS NUMERODOCLOG
	,CTRLSERIE.SERIE                                                      AS SERIEDOC
	,TPDOC.NOME                                                           AS NOMETIPODOCUMENTO
	,TPDOCFRETE.NOME                                                      AS TIPODOCUMENTOFRETE
	,TOMADOR.NOME                                                         AS NOMETOMADOR
	,TOMADOR.CGCCPF                                                       AS CNPJTOMADOR
	,PESSOACONFIG.CLIENTEEPP                                              AS CLIENTEEPP
	,DESTINATARIO.NOME                                                    AS NOMEDESTINATARIO
	,DESTINATARIO.CGCCPF                                                  AS CNPJDESTINATARIO
	,RECEBEDOR.NOME                                                       AS NOMERECEBEDOR
	,RECEBEDOR.CGCCPF                                                     AS CNPJRECEBEDOR
	,BAIRRODESTINO.NOME                                                   AS BAIRRO                              
    ,CIDDESTINO.NOME													  AS CIDADEDESTINO                          
    ,ESTDESTINO.SIGLA                                                     AS UFDESTINO                              
    ,FILDST.NOME                                                          AS FILIALENTREGA
	,A.DATAENTREGA														  AS DATAENTREGA
    ,A.DATAEMISSAO + CONVERT(VARCHAR(8),A.HORAEMISSAO,108)				  AS DATAEMISSAO
	,A.PRAZOENTREGADATAINICIAL											  AS PRAZOENTREGADIAS
	,0																	  AS PRAZOENTREGAUTEIS
	,0																	  AS PRAZOREALIZADO
	,0																	  AS DIASAPOSPRAZO
	,0																	  AS DIASUTEISAPOSPRAZO
	,A.DTPREVISAOENTREGA												  AS DATAPREVISAOENTREGAATUAL                    
    ,ISNULL(A.DTPREVISAOENTREGAEDI,A.DTPREVISAOENTREGAEMISSAO)			  AS DATAPREVISAOENTREGA
	,A.RECEBIDOPOR														  AS RECEBIDOPOR
	,A.VALORCONTABIL													  AS VALORFRETE
	,IIF(A.TIPODOCUMENTO IN(1,2),DOCTRIB.VALORICMS,DOCTRIB.VALORISS)	  AS VALORIMPOSTO
	,TIPOTOMA.NOME                                                        AS TIPOFRETE
	,STATUS.NOME                                                          AS STATUSDOCUMENTO
	,FILATL.NOME														  AS FILIALATUAL
	,A.DOCCLIVALORTOTAL													  AS VALOR
	,A.DOCCLIPESOTOTAL													  AS PESO
	,A.DOCCLIPESOCUBADOTOTAL											  AS PESOCUBADO
	,CAST(A.DOCCLIVOLUME AS INTEGER)									  AS VOLUMES
	,LTRIM(CAST( STUFF((SELECT ' / ' + CAST(INF.NUMERO AS VARCHAR(10)) FROM GLGL_DOCUMENTOCLIENTES INF(NOLOCK)     
                 INNER JOIN GLGL_DOCUMENTOASSOCIADOS IDOCASSOC(NOLOCK) ON (IDOCASSOC.DOCUMENTOCLIENTE=INF.HANDLE)  
                 WHERE IDOCASSOC.DOCUMENTOLOGISTICA=A.HANDLE FOR XML PATH('')),2,1,'') AS VARCHAR(200))) AS NFNUMERO
	,(SELECT GLNF.DATAEMISSAO                                                                                          
         FROM GLGL_DOCUMENTOCLIENTES GLNF                                                                          
		WHERE GLNF.HANDLE = (SELECT MAX(INF.HANDLE)                                                                     
                          FROM GLGL_DOCUMENTOCLIENTES INF                                                          
                          INNER JOIN GLGL_DOCUMENTOASSOCIADOS IDOCASSOC ON (IDOCASSOC.DOCUMENTOCLIENTE=INF.HANDLE) 
                         WHERE IDOCASSOC.DOCUMENTOLOGISTICA=A.HANDLE))   AS NFDATAEMISSAO
	,(SELECT  G.DESCRICAO   AS OCORRENCIA   FROM GLOP_OCORRENCIAS O                                                   
  			INNER JOIN GLOP_MOTIVOOCORRENCIAS     G   ON G.HANDLE           = O.OCORRENCIA                                  
  			WHERE O.HANDLE=(SELECT MAX(OCOR.HANDLE)                                                                         
  			FROM GLOP_OCORRENCIAS OCOR                                                                                      
  			INNER JOIN GLOP_MOTIVOOCORRENCIAS MOCOR ON (OCOR.OCORRENCIA=MOCOR.HANDLE)                                       
		   INNER JOIN GLGL_DOCUMENTOASSOCIADOS DA ON (DA.DOCUMENTOCLIENTE = OCOR.NOTAFISCAL)                               
  			WHERE DA.DOCUMENTOLOGISTICA = A.HANDLE AND OCOR.OCORRENCIAVINCULADA IS NULL AND OCOR.ESTORNADO = 'N'     
  			AND MOCOR.CLASSIFICACAO IN(274,275,277) AND MOCOR.ABRIRPENDENCIA = 'S')) AS OCORRENCIAOP
	,(SELECT O.INCLUIDOEM  AS OCORRENCIA   FROM GLOP_OCORRENCIAS O                                                    
  			WHERE O.HANDLE=(SELECT MAX(OCOR.HANDLE)                                                                         
  			FROM GLOP_OCORRENCIAS OCOR                                                                                      
  			INNER JOIN GLOP_MOTIVOOCORRENCIAS MOCOR ON (OCOR.OCORRENCIA=MOCOR.HANDLE)                                       
		   INNER JOIN GLGL_DOCUMENTOASSOCIADOS DA ON (DA.DOCUMENTOCLIENTE = OCOR.NOTAFISCAL)                               
  			WHERE DA.DOCUMENTOLOGISTICA = A.HANDLE AND OCOR.OCORRENCIAVINCULADA IS NULL AND OCOR.ESTORNADO = 'N'     
  			AND MOCOR.CLASSIFICACAO IN(274,275,277) AND MOCOR.ABRIRPENDENCIA = 'S')) AS DATAOCORRENCIAOP
	,(SELECT  G.NOME        AS RESPONSAVEL  FROM GLOP_OCORRENCIAS O                                                   
  			INNER JOIN GLGL_ENUMERACAOITEMS       G   ON G.HANDLE           = O.RESPONSABILIDADE                            
  			WHERE O.HANDLE=(SELECT MAX(OCOR.HANDLE)                                                                         
  			FROM GLOP_OCORRENCIAS OCOR                                                                                      
  			INNER JOIN GLOP_MOTIVOOCORRENCIAS MOCOR ON (OCOR.OCORRENCIA=MOCOR.HANDLE)                                       
		   INNER JOIN GLGL_DOCUMENTOASSOCIADOS DA ON (DA.DOCUMENTOCLIENTE = OCOR.NOTAFISCAL)                               
  			WHERE DA.DOCUMENTOLOGISTICA = A.HANDLE AND OCOR.OCORRENCIAVINCULADA IS NULL AND OCOR.ESTORNADO = 'N'     
  			AND MOCOR.CLASSIFICACAO IN(274,275,277) AND MOCOR.ABRIRPENDENCIA = 'S')) AS RESPONSAVELOCORRENCIAOP
	,(SELECT  CASE WHEN G.CLASSIFICACAO = 1 THEN 'Transportadora'        ELSE 'Cliente' END        AS RESPONSAVEL 
  			FROM GLOP_OCORRENCIAS O                                                                                         
  			INNER JOIN GLOP_TIPORESPONOCORRENCIA  G   ON G.RESPONSABILIDADE = O.RESPONSABILIDADE                            
  			WHERE O.HANDLE=(SELECT MAX(OCOR.HANDLE) FROM GLOP_OCORRENCIAS OCOR                                              
  			INNER JOIN GLOP_MOTIVOOCORRENCIAS MOCOR ON (OCOR.OCORRENCIA=MOCOR.HANDLE)                                       
		   INNER JOIN GLGL_DOCUMENTOASSOCIADOS DA ON (DA.DOCUMENTOCLIENTE = OCOR.NOTAFISCAL)                               
  			WHERE DA.DOCUMENTOLOGISTICA = A.HANDLE AND OCOR.OCORRENCIAVINCULADA IS NULL AND OCOR.ESTORNADO = 'N'     
  			AND MOCOR.CLASSIFICACAO IN(274,275,277) AND MOCOR.ABRIRPENDENCIA = 'S')) AS CLASSIFICACAORESPONSABILIDADE
	,(SELECT  CAST(O.OBSERVACAO AS VARCHAR(MAX))  AS OBSERVACAO   FROM GLOP_OCORRENCIAS O                             
  			WHERE O.HANDLE=(SELECT MAX(OCOR.HANDLE) FROM GLOP_OCORRENCIAS OCOR                                              
  			INNER JOIN GLOP_MOTIVOOCORRENCIAS MOCOR ON (OCOR.OCORRENCIA=MOCOR.HANDLE)                                       
		   INNER JOIN GLGL_DOCUMENTOASSOCIADOS DA ON (DA.DOCUMENTOCLIENTE = OCOR.NOTAFISCAL)                               
  			WHERE DA.DOCUMENTOLOGISTICA = A.HANDLE AND OCOR.OCORRENCIAVINCULADA IS NULL  AND OCOR.ESTORNADO = 'N'    
  			AND MOCOR.CLASSIFICACAO IN(274,275,277) AND MOCOR.ABRIRPENDENCIA = 'S')) AS OBSOCORRENCIAOP
	,(SELECT  G.DESCRICAO   AS OCORRENCIA   FROM GLOP_OCORRENCIAS O                                                   
  			INNER JOIN GLOP_MOTIVOOCORRENCIAS     G   ON G.HANDLE           = O.OCORRENCIA                                  
  			WHERE O.HANDLE=(SELECT MAX(OCOR.HANDLE) FROM GLOP_OCORRENCIAS OCOR                                              
  			INNER JOIN GLOP_MOTIVOOCORRENCIAS MOCOR ON (OCOR.OCORRENCIA=MOCOR.HANDLE)                                       
		   INNER JOIN GLGL_DOCUMENTOASSOCIADOS DA ON (DA.DOCUMENTOCLIENTE = OCOR.NOTAFISCAL)                               
  			WHERE DA.DOCUMENTOLOGISTICA = A.HANDLE AND OCOR.OCORRENCIAVINCULADA IS NULL  AND OCOR.ESTORNADO = 'N'    
  			AND MOCOR.CLASSIFICACAO=276)) AS OCORRENCIAFAT
	,VIAGEM.NUMEROVIAGEM															  AS NUMEROVIAGEM
	,VEIC.PLACANUMERO																  AS PLACA         
	,MOTORISTA.NOME																	  AS MOTORISTA
	,VIAGEM.INICIOEFETIVO															  AS INICIOVIAGEM
	,REGENTREGA.NOME																  AS REGIAOATENDIMENTO
	,PARADAENTREGA.CHEGADA															  AS DTCHEGADAFILIAL                         
	,VIAGEMDOCENTREGA.DATADESCARREGAMENTO											  AS DTDESCARGAFILIAL
	,OPERACOES.DESCRICAO															  AS TIPOOPERACOES

FROM                                                                                                                
  GLGL_DOCUMENTOS A                                                                                                   
  INNER JOIN GLGL_TIPODOCUMENTOS      TPDOC            ON (A.TIPODOCUMENTO             = TPDOC.HANDLE              )  
 LEFT JOIN GLOP_VIAGENS  VIAGEM ON VIAGEM.HANDLE = (SELECT MAX(VIAGEM) 										                         
													 FROM  GLOP_VIAGEMDOCUMENTOS 														                                   
													 WHERE DOCUMENTOLOGISTICA = ISNULL((SELECT Max(RPS.HANDLE)                                 
  																						FROM GLGL_DOCUMENTOS RPS                                               
  																						WHERE RPS.DOCUMENTOLOGISTICA = A.HANDLE                                
  																						AND RPS.STATUS NOT IN (236)                                            
  																						And Exists (Select 1                                                   
  																						      From GLOP_VIAGEMDOCUMENTOS X                                     
  																						      Where X.DOCUMENTOLOGISTICA = RPS.HANDLE)                         
  																				),A.HANDLE)                                                                
 ) 				                                                                                                         
  LEFT JOIN GLGL_PESSOAS             GLMOTORISTA      ON (GLMOTORISTA.HANDLE            = VIAGEM.MOTORISTA          )
  LEFT JOIN GN_PESSOAS               MOTORISTA        ON (MOTORISTA.HANDLE              = GLMOTORISTA.PESSOA        )
  LEFT JOIN MA_RECURSOS              VEIC             ON (VIAGEM.VEICULO1               = VEIC.HANDLE               )
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
  LEFT JOIN GLOP_VIAGEMDOCUMENTOS VIAGEMDOCENTREGA ON VIAGEMDOCENTREGA.HANDLE = (                        
  						SELECT MAX(TB.HANDLE)                                                                       
  						FROM (                                                                                      
  								SELECT XVD.HANDLE                                                                       
  								FROM GLOP_VIAGEMDOCUMENTOS XVD                                                          
  								INNER JOIN GLOP_VIAGEMPARADAS XP ON XP.HANDLE = XVD.PARADA                              
  								WHERE XP.FILIAL = A.FILIALENTREGA                                                
  									AND XVD.TIPOSERVICO = 198                                                             
  									AND XVD.DOCUMENTOLOGISTICA = A.HANDLE                                                 
  									AND XVD.SITUACAO <> 211                                                               
  								UNION ALL                                                                               
  								SELECT XVD.HANDLE                                                                       
  								FROM GLOP_VIAGEMDOCUMENTOS XVD                                                          
  								INNER JOIN GLOP_VIAGEMPARADAS XP ON XP.HANDLE = XVD.PARADA                              
  								WHERE XP.FILIAL = A.FILIALENTREGA                                                
  									AND XVD.TIPOSERVICO = 198                                                             
  									AND XVD.SITUACAO <> 211                                                               
  									AND XVD.DOCUMENTOLOGISTICA = (                                                        
  											                            SELECT MAX(RPS.HANDLE)                                
  											                            FROM GLGL_DOCUMENTOS RPS                              
  											                            WHERE RPS.DOCUMENTOLOGISTICA = A.HANDLE               
  											                            	AND RPS.STATUS NOT IN (236, 237)                    
  											                            	AND RPS.TIPODOCUMENTO = 6                           
  											                            	AND RPS.TIPORPSSERVICO = 324                        
  											                            	AND EXISTS (                                        
  											                            		SELECT 1                                          
  											                            		FROM GLOP_VIAGEMDOCUMENTOS X                      
  											                            		WHERE X.DOCUMENTOLOGISTICA = RPS.HANDLE           
  											                            			AND X.TIPOSERVICO = 198                         
  											                            			AND X.SITUACAO <> 211                           
  											                            		)                                                 
  											                            )                                                     
  								) AS TB                                                                                 
  		)                                                                                                   
  LEFT JOIN GLOP_VIAGEMPARADAS PARADAENTREGA ON PARADAENTREGA.HANDLE = VIAGEMDOCENTREGA.PARADA                                                                               
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
  LEFT JOIN GLOP_OPERACOES OPERACOES				  ON A.TIPOOPERACAO = OPERACOES.HANDLE
  WHERE A.EMPRESA = 1                                                                                                       
  	AND A.STATUS NOT IN(236,237,417,220,221,222,223,224,399,404,416,418,419,420,609,743,890)     
  	AND (A.TIPODOCUMENTO IN(1,2) OR (A.TIPODOCUMENTO = 6 AND A.TIPORPS <> 324) )      
 AND A.DTPREVISAOENTREGA >= DATEADD(DD, -15, CAST(GETDATE() AS DATE))
 AND A.DTPREVISAOENTREGA < DATEADD(DD, 15, CAST(GETDATE() AS DATE))
 AND (A.TIPODOCUMENTO = 2 AND A.TIPODOCUMENTOFRETE IN(153) OR A.TIPODOCUMENTO = 6) 
AND  NOT(A.DATAENTREGA IS NULL AND (A.STATUS  IN(235,313,418,419,420,421) OR A.RECUSADO = 'S'))
 ORDER BY A.DATAEMISSAO
