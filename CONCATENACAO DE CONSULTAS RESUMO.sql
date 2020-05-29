select 
'Situação' +';'+	
'Filial de Emissão' +';'+ 	
'Documento Logistica' +';'+	
'Serie' +';'+	
'Tipo Doc' +';'+	
'Tomador' +';'+	
'CGC/CPF Tomador' +';'+	
'EPP' +';'+	
'Remetente' +';'+	
'CGC/CPF Destinatario' +';'+
'Destinatario' +';'+	
'Bairro' +';'+	
'Cidade Destino' +';'+	
'UF' +';'+	
'Filial de Entrega' +';'+	
'Data Emissão' +';'+	
'Previsão de Entrega' +';'+	
'Previsão de Entrega(Atual)' +';'+	
'Data de Entrega' +';'+	
'Valor' +';'+ 
'Frete' +';'+	
'Status' +';'+	
'Filial Atual' +';'+	
'Valor NF' +';'+	
'Peso' +';'+	
'Peso Cubado' +';'+	
'Volumes' +';'+	
'Numero NF' +';'+	
'Data Emissão 1º NF' +';'+	
'Ocorrência Operacional' +';'+	
'Data Ocorrência' +';'+	
'Responsavel Ocorrencia' +';'+	
'Classificação Responsabilidade' +';'+	
'Obs ocorrencia' +';'+	
'Ocorrencia Faturamento' +';'+	
'Prazo de Entrega' +';'+	
'Prazo de Entrega Úteis' +';'+	
'Prazo Realizado' +';'+	
'Dias após Prazo' +';'+	
'Dias Úteis após Prazo' +';'+	
'Numero Viagem' +';'+	
'Placa' +';'+	
'Motorista' +';'+	
'Início Efetivo Viagem' +';'+	
'Região de Atendimento' +';'+	
'Chegada Filial Entrega' +';'+	
'Descarga Filial Entrega' +';'+	
'Tipo de Operação' +';'+	
'TipoViagem' as Ta

union all

SELECT    --TOP(10)                                                                                                            
        
		CONVERT(VARCHAR(MAX),
		CONCAT(CASE                                                                                                                                    
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
 	END, ';' --Situação
	,FILEMI.NOME    COLLATE sql_latin1_general_cp1251_ci_as , ';' --Filial de Emissão
	,A.NUMERO , ';' --Documento Logistica
	,CONVERT(VARCHAR(5),CTRLSERIE.SERIE), ';' --Serie
	,TPDOCFRETE.NOME, ';' --Tipo Doc
	,replace((replace(replace(replace(replace(replace(replace(replace(replace(TOMADOR.NOME, '&amp;',''), 'D&#039;',''), '&quot;',''), '&#39;',''), 'D&#34;',''), '&#X26;',''),';16;',' '),';','') COLLATE sql_latin1_general_cp1250_ci_as) COLLATE sql_latin1_general_cp1251_ci_as,',',''), ';' --Tomador
	,TOMADOR.CGCCPF, ';' --CGC/CPF Tomador
	,PESSOACONFIG.CLIENTEEPP, ';' --EPP
	,replace((replace(replace(replace(replace(replace(replace(replace(replace(TOMADOR.NOME, '&amp;',''), 'D&#039;',''), '&quot;',''), '&#39;',''), 'D&#34;',''), '&#X26;',''),';16;',' '),';','') COLLATE sql_latin1_general_cp1250_ci_as) COLLATE sql_latin1_general_cp1251_ci_as,',',''), ';' --Remetente
	,DESTINATARIO.CGCCPF, ';' --CGC/CPF Destinatario
	,replace(replace(replace(replace(replace(replace(replace(replace(replace(DESTINATARIO.NOME, '&amp;',''), 'D&#039;',''), '&quot;',''), '&#39;',''), 'D&#34;',''), '&#X26;',''),';16;',' '),';','') ,',',''), ';' --Destinatario
	,replace(replace(replace(replace(replace(replace(replace(replace(replace(BAIRRODESTINO.NOME, '&amp;',''), 'D&#039;',''), '&quot;',''), '&#39;',''), 'D&#34;',''), '&#X26;',''),';16;',' '),';','')   COLLATE sql_latin1_general_cp1251_ci_as,',',''), ';' --bairro
	,CIDDESTINO.NOME	COLLATE sql_latin1_general_cp1251_ci_as, ';' --Cidade Destino
	,ESTDESTINO.SIGLA, ';' --UF
	,FILDST.NOME     COLLATE sql_latin1_general_cp1251_ci_as, ';' --filial de entrega
	,A.DATAEMISSAO + CONVERT(VARCHAR(8),A.HORAEMISSAO,108), ';' --Data Emissao
	,ISNULL(A.DTPREVISAOENTREGAEDI,A.DTPREVISAOENTREGAEMISSAO), ';' --Previsão de Entrega
	,A.DTPREVISAOENTREGA, ';' --Previsão de Entrega atual
	,A.DATAENTREGA, ';' --Data da entrega
	,ROUND(CAST(A.DOCCLIVALORTOTAL AS NUMERIC(10,2)),1), ';' --valor
	,ROUND(CAST(A.VALORCONTABIL AS NUMERIC(10,2)),1), ';' --frete
	,STATUS.NOME   COLLATE sql_latin1_general_cp1251_ci_as , ';' --status
	,FILATL.NOME	COLLATE sql_latin1_general_cp1251_ci_as, ';' --filial atual
	,ROUND(CAST(A.DOCCLIVALORTOTAL AS NUMERIC(10,2)),1), ';' --valorNF
	,ROUND(CAST(A.DOCCLIPESOTOTAL AS NUMERIC(10,2)),1), ';' --PESO
	,ROUND(CAST(A.DOCCLIPESOCUBADOTOTAL AS NUMERIC(10,2)),1), ';' --PESOCUBADO
	,CAST(A.DOCCLIVOLUME AS INTEGER), ';' --VOLUMES
	,LTRIM(CAST( STUFF((SELECT ' / ' + CAST(INF.NUMERO AS VARCHAR(10)) FROM GLGL_DOCUMENTOCLIENTES INF(NOLOCK)     
                 INNER JOIN GLGL_DOCUMENTOASSOCIADOS IDOCASSOC(NOLOCK) ON (IDOCASSOC.DOCUMENTOCLIENTE=INF.HANDLE)  
                 WHERE IDOCASSOC.DOCUMENTOLOGISTICA=A.HANDLE FOR XML PATH('')),2,1,'') AS VARCHAR(200))), ';' --NUMERONF
	,(SELECT GLNF.DATAEMISSAO                                                                                          
         FROM GLGL_DOCUMENTOCLIENTES GLNF                                                                          
		WHERE GLNF.HANDLE = (SELECT MAX(INF.HANDLE)                                                                     
                          FROM GLGL_DOCUMENTOCLIENTES INF                                                          
                          INNER JOIN GLGL_DOCUMENTOASSOCIADOS IDOCASSOC ON (IDOCASSOC.DOCUMENTOCLIENTE=INF.HANDLE) 
                         WHERE IDOCASSOC.DOCUMENTOLOGISTICA=A.HANDLE)), ';' --NFDATAEMISSAO
	,(SELECT  G.DESCRICAO COLLATE sql_latin1_general_cp1251_ci_as  AS OCORRENCIA   FROM GLOP_OCORRENCIAS O                                                   
  			INNER JOIN GLOP_MOTIVOOCORRENCIAS     G   ON G.HANDLE           = O.OCORRENCIA                                  
  			WHERE O.HANDLE=(SELECT MAX(OCOR.HANDLE)                                                                         
  			FROM GLOP_OCORRENCIAS OCOR                                                                                      
  			INNER JOIN GLOP_MOTIVOOCORRENCIAS MOCOR ON (OCOR.OCORRENCIA=MOCOR.HANDLE)                                       
		   INNER JOIN GLGL_DOCUMENTOASSOCIADOS DA ON (DA.DOCUMENTOCLIENTE = OCOR.NOTAFISCAL)                               
  			WHERE DA.DOCUMENTOLOGISTICA = A.HANDLE AND OCOR.OCORRENCIAVINCULADA IS NULL AND OCOR.ESTORNADO = 'N'     
  			AND MOCOR.CLASSIFICACAO IN(274,275,277) AND MOCOR.ABRIRPENDENCIA = 'S')), ';' --OCORRENCIAOP

	,(SELECT O.INCLUIDOEM  AS OCORRENCIA   FROM GLOP_OCORRENCIAS O                                                    
  			WHERE O.HANDLE=(SELECT MAX(OCOR.HANDLE)                                                                         
  			FROM GLOP_OCORRENCIAS OCOR                                                                                      
  			INNER JOIN GLOP_MOTIVOOCORRENCIAS MOCOR ON (OCOR.OCORRENCIA=MOCOR.HANDLE)                                       
		   INNER JOIN GLGL_DOCUMENTOASSOCIADOS DA ON (DA.DOCUMENTOCLIENTE = OCOR.NOTAFISCAL)                               
  			WHERE DA.DOCUMENTOLOGISTICA = A.HANDLE AND OCOR.OCORRENCIAVINCULADA IS NULL AND OCOR.ESTORNADO = 'N'     
  			AND MOCOR.CLASSIFICACAO IN(274,275,277) AND MOCOR.ABRIRPENDENCIA = 'S')), ';' --DATAOCORRENCIAOP

	,(SELECT  G.NOME COLLATE sql_latin1_general_cp1251_ci_as        AS RESPONSAVEL  FROM GLOP_OCORRENCIAS O                                                   
  			INNER JOIN GLGL_ENUMERACAOITEMS       G   ON G.HANDLE           = O.RESPONSABILIDADE                            
  			WHERE O.HANDLE=(SELECT MAX(OCOR.HANDLE)                                                                         
  			FROM GLOP_OCORRENCIAS OCOR                                                                                      
  			INNER JOIN GLOP_MOTIVOOCORRENCIAS MOCOR ON (OCOR.OCORRENCIA=MOCOR.HANDLE)                                       
		   INNER JOIN GLGL_DOCUMENTOASSOCIADOS DA ON (DA.DOCUMENTOCLIENTE = OCOR.NOTAFISCAL)                               
  			WHERE DA.DOCUMENTOLOGISTICA = A.HANDLE AND OCOR.OCORRENCIAVINCULADA IS NULL AND OCOR.ESTORNADO = 'N'     
  			AND MOCOR.CLASSIFICACAO IN(274,275,277) AND MOCOR.ABRIRPENDENCIA = 'S')), ';' --RESPONSAVELOCORRENCIAOP
	
	,(SELECT  CASE WHEN G.CLASSIFICACAO = 1 THEN 'Transportadora'        ELSE 'Cliente' END        AS RESPONSAVEL 
  			FROM GLOP_OCORRENCIAS O                                                                                         
  			INNER JOIN GLOP_TIPORESPONOCORRENCIA  G   ON G.RESPONSABILIDADE = O.RESPONSABILIDADE                            
  			WHERE O.HANDLE=(SELECT MAX(OCOR.HANDLE) FROM GLOP_OCORRENCIAS OCOR                                              
  			INNER JOIN GLOP_MOTIVOOCORRENCIAS MOCOR ON (OCOR.OCORRENCIA=MOCOR.HANDLE)                                       
		   INNER JOIN GLGL_DOCUMENTOASSOCIADOS DA ON (DA.DOCUMENTOCLIENTE = OCOR.NOTAFISCAL)                               
  			WHERE DA.DOCUMENTOLOGISTICA = A.HANDLE AND OCOR.OCORRENCIAVINCULADA IS NULL AND OCOR.ESTORNADO = 'N'     
  			AND MOCOR.CLASSIFICACAO IN(274,275,277) AND MOCOR.ABRIRPENDENCIA = 'S')), ';' --CLASSIFICACAORESPONSABILIDADE
	
	--,(SELECT  CAST(O.OBSERVACAO AS VARCHAR(20)) COLLATE sql_latin1_general_cp1251_ci_as  AS OBSERVACAO  FROM GLOP_OCORRENCIAS O                             
 -- 			WHERE O.HANDLE=(SELECT MAX(OCOR.HANDLE) FROM GLOP_OCORRENCIAS OCOR                                              
 -- 			INNER JOIN GLOP_MOTIVOOCORRENCIAS MOCOR ON (OCOR.OCORRENCIA=MOCOR.HANDLE)                                       
	--	   INNER JOIN GLGL_DOCUMENTOASSOCIADOS DA ON (DA.DOCUMENTOCLIENTE = OCOR.NOTAFISCAL)                               
 -- 			WHERE DA.DOCUMENTOLOGISTICA = A.HANDLE AND OCOR.OCORRENCIAVINCULADA IS NULL  AND OCOR.ESTORNADO = 'N'    
 -- 			AND MOCOR.CLASSIFICACAO IN(274,275,277) AND MOCOR.ABRIRPENDENCIA = 'S')), ';' --OBSOCORRENCIAOP
	,'', ';' --OBSOCORRENCIAOP
	
	,(SELECT  G.DESCRICAO COLLATE sql_latin1_general_cp1251_ci_as  AS OCORRENCIA   FROM GLOP_OCORRENCIAS O                                                   
  			INNER JOIN GLOP_MOTIVOOCORRENCIAS     G   ON G.HANDLE           = O.OCORRENCIA                                  
  			WHERE O.HANDLE=(SELECT MAX(OCOR.HANDLE) FROM GLOP_OCORRENCIAS OCOR                                              
  			INNER JOIN GLOP_MOTIVOOCORRENCIAS MOCOR ON (OCOR.OCORRENCIA=MOCOR.HANDLE)                                       
		   INNER JOIN GLGL_DOCUMENTOASSOCIADOS DA ON (DA.DOCUMENTOCLIENTE = OCOR.NOTAFISCAL)                               
  			WHERE DA.DOCUMENTOLOGISTICA = A.HANDLE AND OCOR.OCORRENCIAVINCULADA IS NULL  AND OCOR.ESTORNADO = 'N'    
  			AND MOCOR.CLASSIFICACAO=276)), ';' -- OCORRENCIAFAT

	,A.PRAZOENTREGADATAINICIAL, ';' --PRAZOENTREGADIAS
	,0, ';' --PRAZOENTREGAUTEIS
	,0, ';' --PRAZOREALIZADO
	,0, ';' --DIASAPOSPRAZO
	,0, ';' --DIASUTEISAPOSPRAZO
	,VIAGEM.NUMEROVIAGEM, ';' --NUMEROVIAGEM
	,VEIC.PLACANUMERO, ';' --PLACA         
	,MOTORISTA.NOME	COLLATE sql_latin1_general_cp1251_ci_as	, ';' --MOTORISTA
	,VIAGEM.INICIOEFETIVO, ';' --INICIOVIAGEM
	,REGENTREGA.NOME COLLATE sql_latin1_general_cp1251_ci_as, ';' --REGIAOATENDIMENTO
	,PARADAENTREGA.CHEGADA, ';' --DTCHEGADAFILIAL                         
	,VIAGEMDOCENTREGA.DATADESCARREGAMENTO, ';' --DTDESCARGAFILIAL
	,OPERACOES.DESCRICAO	COLLATE sql_latin1_general_cp1251_ci_as, ';' --TIPOOPERACOES
	,TIPOVIAGEM.NOME COLLATE sql_latin1_general_cp1251_ci_as, ';' --TIPOVIAGEM

	)) AS T	

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
  LEFT JOIN GLGL_ENUMERACAOITEMS     TIPOVIAGEM       ON (VIAGEM.TIPOVIAGEM                = TIPOVIAGEM.HANDLE                               )


  WHERE A.EMPRESA = 1                                                                                                       
  	AND A.STATUS NOT IN(236,237,417,220,221,222,223,224,399,404,416,418,419,420,609,743,890)     
  	AND (A.TIPODOCUMENTO IN(1,2) OR (A.TIPODOCUMENTO = 6 AND A.TIPORPS <> 324) )      
 AND A.DTPREVISAOENTREGA >= DATEADD(DD, -15, CAST(GETDATE() AS DATE))
 AND A.DTPREVISAOENTREGA < DATEADD(DD, 15, CAST(GETDATE() AS DATE))
 AND (A.TIPODOCUMENTO = 2 AND A.TIPODOCUMENTOFRETE IN(153) OR A.TIPODOCUMENTO = 6) 
AND  NOT(A.DATAENTREGA IS NULL AND (A.STATUS  IN(235,313,418,419,420,421) OR A.RECUSADO = 'S'))
and A.NUMERO in (992169, 529614)
--2511390,
--1229978,
--23320,
--8957,
--592055,
--34310


--)



 --ORDER BY A.DATAEMISSAO