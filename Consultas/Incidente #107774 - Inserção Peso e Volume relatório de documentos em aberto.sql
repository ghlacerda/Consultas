Select CASE WHEN (A.DATAENTREGA																					IS NOT NULL 
			 AND  CAST(ISNULL(A.DTPREVISAOENTREGAEDI,A.DTPREVISAOENTREGAEMISSAO) AS DATE)						< CAST(A.DATAENTREGA AS DATE))
 			 AND NOT EXISTS (SELECT 1
 							   FROM GLOP_OCORRENCIAS O
 							  WHERE O.ESTORNADO																	= 'N' 
							    AND O.NOTAFISCAL																IN (SELECT DOCUMENTOCLIENTE                                                                       
 																													  FROM GLGL_DOCUMENTOASSOCIADOS T1                                                              
 																													 WHERE T1.DOCUMENTOLOGISTICA	= A.HANDLE)
 			 AND EXISTS (SELECT 1																				                           
 						   FROM GLOP_TIPORESPONOCORRENCIA T1													                             
 						  WHERE T1.CLASSIFICACAO																= 2 
						    AND O.RESPONSABILIDADE																= T1.RESPONSABILIDADE))
 			THEN 'Entregue Fora do Prazo'                                                                      
 			WHEN ((A.DATAENTREGA IS NOT NULL                                                                     
 			 AND CAST(ISNULL(ISNULL(A.DTPREVISAOENTREGAEDI,A.DTPREVISAOENTREGAEMISSAO), GETDATE()) AS DATE)		>= CAST(A.DATAENTREGA AS DATE))                                                                                         
 			  OR ((A.DATAENTREGA																				IS NOT NULL                                                                 
			 AND CAST(ISNULL(A.DTPREVISAOENTREGAEDI,A.DTPREVISAOENTREGAEMISSAO) AS DATE)						< CAST(A.DATAENTREGA AS DATE))                                                                                     
			 AND EXISTS (SELECT 1                                                                              
 						   FROM GLOP_OCORRENCIAS O                                                               
 						  WHERE O.ESTORNADO																		= 'N' 
						    AND O.NOTAFISCAL																	IN (SELECT DOCUMENTOCLIENTE                                                       
 																													  FROM GLGL_DOCUMENTOASSOCIADOS T1                                              
 																													 WHERE T1.DOCUMENTOLOGISTICA	= A.HANDLE)                                                                             
 			 AND EXISTS (SELECT 1                                                                      
 						   FROM GLOP_TIPORESPONOCORRENCIA T1                                             
 						  WHERE T1.CLASSIFICACAO																= 2 
						    AND O.RESPONSABILIDADE																= T1.RESPONSABILIDADE))))                                                                                             
 		    THEN 'Entregue no Prazo'                                                                
 		    WHEN A.DATAENTREGA																					IS NULL 
			 AND (A.STATUS																						IN (235, 313, 418, 419, 420, 421) 
			  OR A.RECUSADO																						= 'S') 
			THEN 'Finalizado Com Restrição'                                                    
 			WHEN CAST(ISNULL(A.DTPREVISAOENTREGAEDI,A.DTPREVISAOENTREGAEMISSAO) AS DATE)						< CAST(GETDATE() AS DATE)                                                   
			 AND NOT EXISTS (SELECT 1                                                                      
 							   FROM GLOP_OCORRENCIAS O                                                       
 							  WHERE O.ESTORNADO																	= 'N'
								AND cast(O.INCLUIDOEM as date) BETWEEN A.DATAEMISSAO AND CAST(ISNULL(A.DTPREVISAOENTREGAEDI,A.DTPREVISAOENTREGAEMISSAO) AS DATE)  
							    AND O.NOTAFISCAL																IN (SELECT DOCUMENTOCLIENTE                                               
 																													 FROM GLGL_DOCUMENTOASSOCIADOS T1                                      
 																												     WHERE T1.DOCUMENTOLOGISTICA	= A.HANDLE)                                                                     
 			 AND EXISTS (SELECT 1                                                              
 						   FROM GLOP_TIPORESPONOCORRENCIA T1                                     
 						  WHERE T1.CLASSIFICACAO																= 2 
						    AND O.RESPONSABILIDADE																= T1.RESPONSABILIDADE))                                                                             
 			THEN 'Em Aberto em Atraso'
			WHEN CAST(ISNULL(A.DTPREVISAOENTREGAEDI,A.DTPREVISAOENTREGAEMISSAO) AS DATE)						< CAST(GETDATE() AS DATE)                                                   
			 AND EXISTS (SELECT 1                                                                      
 							   FROM GLOP_OCORRENCIAS O                                                       
 							  WHERE O.ESTORNADO																	= 'N'
								AND cast(O.INCLUIDOEM as date) BETWEEN A.DATAEMISSAO AND CAST(ISNULL(A.DTPREVISAOENTREGAEDI,A.DTPREVISAOENTREGAEMISSAO) AS DATE)  
							    AND O.NOTAFISCAL																IN (SELECT DOCUMENTOCLIENTE                                               
 																													 FROM GLGL_DOCUMENTOASSOCIADOS T1                                      
 																												     WHERE T1.DOCUMENTOLOGISTICA	= A.HANDLE)                                                                     
 			 AND EXISTS (SELECT 1                                                              
 						   FROM GLOP_TIPORESPONOCORRENCIA T1                                     
 						  WHERE T1.CLASSIFICACAO																= 2 
						    AND O.RESPONSABILIDADE																= T1.RESPONSABILIDADE))                                                                             
 			THEN 'Em Aberto no Prazo'
			                                              
 		    ELSE 'Em Aberto no Prazo'                                                                              
 	   END																						AS SITUACAO,
	   A.NUMERO																					AS NUMERODOCLOG,                                
       IsNull(IIF(A.TOMADORSERVICOPESSOA	IN (210032, 126029, 116727) 
			  And A.TIPOOPERACAO			IN (16, 19),	
					'S', PESSOACONFIG.CLIENTEEPP), 'N')											AS CLIENTEEPP,                             
       REMETENTE.NOME																			AS NOMEREMETENTE,                          
       REMETENTE.CGCCPF																			AS CNPJREMETENTE,                          
       DESTINATARIO.NOME																	    AS NOMEDESTINATARIO,                          
       DESTINATARIO.CGCCPF														                AS CNPJDESTINATARIO,  
       TOMADOR.NOME																			    AS NOMETOMADOR,                          
       TOMADOR.CGCCPF															                AS CNPJTOMADOR,  
       CIDDESTINO.NOME																			AS CIDADEDESTINO,                          
       ESTDESTINO.SIGLA																			AS UFDESTINO,                              
       FILDST.NOME																				AS FILIALENTREGA,                          
       format(a.dataemissao + cast(cast(a.horaemissao as time) as datetime),'dd/MM/yyyy HH:mm')	AS DATAEMISSAO,            
       Format(IsNull(A.DTPREVISAOENTREGAEDI,A.DTPREVISAOENTREGAEMISSAO), 'dd/MM/yyyy')			AS DATAPREVISAOENTREGA,                              
	   TPDOC.NOME																				AS TPDOC,
	   STATUS.NOME																				As STATUS,
	   (SELECT GLOP_OPERACOES.DESCRICAO 
		  FROM GLOP_OPERACOES 
		 WHERE GLOP_OPERACOES.HANDLE	= A.TIPOOPERACAO)										AS TIPOOPERACAO,
	   FILATL.NOME																				AS FILIALATUAL,
	   PARADAENTREGA.CHEGADA																	AS DTCHEGADAFILIALENTREGA,
	   VIAGEMDOCENTREGA.DATADESCARREGAMENTO														AS DTDESCARGAFILIALENTREGA,
	   A.DATAALTERACAO,
	   CASE WHEN (ISNULL(A.TIPODOCUMENTOFRETE,1) = 153) OR (A.TIPODOCUMENTO = 6) THEN (                           
	     CAST(LTRIM(Stuff(( SELECT ' | ' + DESCRICAO FROM(SELECT DISTINCT SL.DESCRICAO                          
	   						FROM GLOP_SERVICOSREALIZADOS SR                                                                
	   						LEFT JOIN GLOP_SERVICOREALIZADODOCS SD ON SD.SERVICOREALIZADO = SR.HANDLE                      
	   						LEFT JOIN GLOP_SERVICOREALIZADORPS SRPS ON SRPS.SERVICOREALIZADO = SR.HANDLE                   
	   						INNER JOIN GLGL_DOCUMENTOASSOCIADOS DA ON DA.DOCUMENTOCLIENTE = SD.DOCUMENTOCLIENTE            
	   						INNER JOIN GLGL_SERVICOLOGISTICA SL ON SR.SERVICO = SL.HANDLE                                  
	   						WHERE DA.DOCUMENTOLOGISTICA = A.HANDLE                                                         
	   						AND SL.HANDLE NOT IN(6,27,24,5)                                                                
	   						) AS TABELA FOR xml path ('')), 2, 1, '')) AS VARCHAR(100)))                               
	     ELSE (                                                                                                   
	               SELECT TOP 1 SL.DESCRICAO                                                                      
	               FROM   GLOP_SERVICOSREALIZADOS SR                                                              
	               LEFT JOIN GLOP_SERVICOREALIZADORPS SD ON SD.SERVICOREALIZADO = SR.HANDLE                       
	               INNER JOIN GLGL_SERVICOLOGISTICA SL ON SR.SERVICO = SL.HANDLE                                  
	               LEFT JOIN GLGL_DOCLOGASSOCIADOS DLA ON DLA.DOCUMENTOLOGISTICAFILHO = SD.DOCUMENTOLOGISTICARPS  
	               INNER JOIN GLGL_ENUMERACAOITEMS EN ON SR.STATUS = EN.HANDLE                                    
	               WHERE  DLA.DOCUMENTOLOGISTICAPAI = A.HANDLE                                                    
	                      AND SL.HANDLE NOT IN( 6, 27, 24, 5 )                                                    
	               ORDER  BY SR.HANDLE ASC) END													AS SERVICOLOG,
		DOCCLIPESOTOTAL AS [PESOTOTAL],
		DOCCLIVOLUME AS [VOLUME]
  FROM                                                                                                                
  GLGL_DOCUMENTOS A                                                                                                   
  INNER JOIN GLGL_TIPODOCUMENTOS      TPDOC            ON (A.TIPODOCUMENTO             = TPDOC.HANDLE              )  
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
  LEFT JOIN GLGL_DOCUMENTOASSOCIADOS DOCASSOC         ON (DOCASSOC.DOCUMENTOLOGISTICA      = A.HANDLE           )                       
  LEFT JOIN GLGL_DOCUMENTOCLIENTES   DOCCLI           ON (DOCASSOC.DOCUMENTOCLIENTE        = DOCCLI.HANDLE      )                       
  LEFT JOIN GLOP_COLETAPEDIDOS       COLETA           ON (COLETA.HANDLE                    = DOCCLI.PEDIDOCOLETA)                       
  LEFT JOIN GLOP_VIAGEMDOCUMENTOS VIAGEMDOCENTREGA ON VIAGEMDOCENTREGA.HANDLE = (                        
  						SELECT MAX(TB.HANDLE)                                                                       
  						FROM (                                                                                      
  								SELECT XVD.HANDLE                                                                       
  								FROM GLOP_VIAGEMDOCUMENTOS XVD                                                          
  								INNER JOIN GLOP_VIAGEMPARADAS XP ON XP.HANDLE = XVD.PARADA                              
  								WHERE XP.FILIAL = A.FILIALATUAL                                                
  									AND XVD.TIPOSERVICO = 198                                                             
  									AND XVD.DOCUMENTOLOGISTICA = A.HANDLE                                                 
  									AND XVD.SITUACAO <> 211                                                               
  								UNION ALL                                                                               
  								SELECT XVD.HANDLE                                                                       
  								FROM GLOP_VIAGEMDOCUMENTOS XVD                                                          
  								INNER JOIN GLOP_VIAGEMPARADAS XP ON XP.HANDLE = XVD.PARADA                              
  								WHERE XP.FILIAL = A.FILIALATUAL                                                
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
  WHERE A.EMPRESA = 1                                                                                                       
  	AND A.STATUS NOT IN(236,237,417,220,221,222,223,224,399,404,416,418,419,420,609,743,890)     
  	AND (A.TIPODOCUMENTO IN(1,2) OR (A.TIPODOCUMENTO = 6 AND A.TIPORPS <> 324) )      
    AND Cast(A.DATAEMISSAO As Date)	Between Convert(Date, Concat(Format(DateAdd(Year, -1, GetDate()), 'yyyy-'), '01-01'))
										And Convert(Date, GetDate())

 AND (A.TIPODOCUMENTO = 2 AND A.TIPODOCUMENTOFRETE IN(153) OR A.TIPODOCUMENTO = 6) 
 AND NOT EXISTS( SELECT 1                                                                         
  FROM            glop_servicosrealizados SR                                                      
  LEFT JOIN       glop_servicorealizadodocs SD                                                    
  ON              sd.servicorealizado = sr.handle                                                 
  LEFT JOIN       glop_servicorealizadorps SRPS                                                   
  ON              srps.servicorealizado = sr.handle                                               
  INNER JOIN      glgl_documentoassociados DA                                                     
  ON              da.documentocliente = sd.documentocliente                                       
  INNER JOIN      glgl_servicologistica SL                                                        
  ON              sr.servico = sl.handle                                                          
  WHERE           da.documentologistica = A.HANDLE                                           
  AND SL.HANDLE IN (9,46)                                                                         
  UNION ALL                                                                                       
  SELECT  1                                                                                       
    FROM GLOP_SERVICOSREALIZADOS SR                                                               
    LEFT JOIN GLOP_SERVICOREALIZADORPS SD ON SD.SERVICOREALIZADO = SR.HANDLE                      
    INNER JOIN GLGL_SERVICOLOGISTICA SL ON SR.SERVICO = SL.HANDLE                                 
    LEFT JOIN GLGL_DOCLOGASSOCIADOS DLA ON DLA.DOCUMENTOLOGISTICAFILHO = SD.DOCUMENTOLOGISTICARPS 
    WHERE   DLA.DOCUMENTOLOGISTICAPAI = A.HANDLE                                             
    AND SL.HANDLE IN (9,46))                                                                      
AND  A.DATAENTREGA IS NULL AND (A.STATUS NOT IN(235,313,418,419,420,421) AND A.RECUSADO = 'N')
 ORDER BY A.DATAEMISSAO