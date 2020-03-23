Select FILIAIS.NOME																	[Filial],
			   ESTADOS.SIGLA																[Estado],
			   dbo.REGIONALASSOCIADA(ESTADOS.SIGLA) AS REGIONAL,
			   c.NOME																	[FilialEntrega],
			   CASE                                                                                                                                    
 		WHEN (                                                                                                                          
 				 GLGL_DOCUMENTOS.DATAENTREGA IS NOT NULL AND CAST(ISNULL(GLGL_DOCUMENTOS.DTPREVISAOENTREGAEDI,GLGL_DOCUMENTOS.DTPREVISAOENTREGAEMISSAO) AS DATE) < CAST(GLGL_DOCUMENTOS.DATAENTREGA AS DATE)                                  
 				)                                                                                                                       
 			AND NOT EXISTS (                                                                                                            
			            SELECT 1																										    
			            FROM GLOP_OCORRENCIAS O																							    
			            	INNER JOIN GLGL_DOCUMENTOASSOCIADOS T1 ON T1.DOCUMENTOCLIENTE = O.NOTAFISCAL								    
			            	INNER JOIN GLOP_TIPORESPONOCORRENCIA T2 ON T2.RESPONSABILIDADE = O.RESPONSABILIDADE							    
			            WHERE O.ESTORNADO = 'N'																							    
			            	AND T1.DOCUMENTOLOGISTICA = GLGL_DOCUMENTOS.HANDLE																		    
			            	AND T2.CLASSIFICACAO = 2   																					    
			            	AND CAST(O.INCLUIDOEM AS DATE) <= CAST(ISNULL(GLGL_DOCUMENTOS.DTPREVISAOENTREGAEDI, GLGL_DOCUMENTOS.DTPREVISAOENTREGAEMISSAO) AS DATE)	
 				)                                                                                                                       
 			THEN 'Entregue Fora do Prazo'                                                                                        
 		WHEN (                                                                                                                          
 			(                                                                                                                           
 				 GLGL_DOCUMENTOS.DATAENTREGA IS NOT NULL                                                                                                   
 		        AND CAST(ISNULL(ISNULL(GLGL_DOCUMENTOS.DTPREVISAOENTREGAEDI,GLGL_DOCUMENTOS.DTPREVISAOENTREGAEMISSAO), GETDATE()) AS DATE) >= CAST(GLGL_DOCUMENTOS.DATAENTREGA AS DATE)                                    
 				)                                                                                                                       
 			OR (                                                                                                                        
 				(                                                                                                                       
 					 GLGL_DOCUMENTOS.DATAENTREGA IS NOT NULL                                                                                               
 					AND CAST(ISNULL(GLGL_DOCUMENTOS.DTPREVISAOENTREGAEDI,GLGL_DOCUMENTOS.DTPREVISAOENTREGAEMISSAO) AS DATE) < CAST(GLGL_DOCUMENTOS.DATAENTREGA AS DATE)                                                    
 					)                                                                                                                   
 				AND EXISTS (                                                                                                            
			            SELECT 1																										    
			            FROM GLOP_OCORRENCIAS O																							    
			            	INNER JOIN GLGL_DOCUMENTOASSOCIADOS T1 ON T1.DOCUMENTOCLIENTE = O.NOTAFISCAL								    
			            	INNER JOIN GLOP_TIPORESPONOCORRENCIA T2 ON T2.RESPONSABILIDADE = O.RESPONSABILIDADE							    
			            WHERE O.ESTORNADO = 'N'																							    
			            	AND T1.DOCUMENTOLOGISTICA = GLGL_DOCUMENTOS.HANDLE																		    
			            	AND T2.CLASSIFICACAO = 2   																					    
			            	AND CAST(O.INCLUIDOEM AS DATE) <= CAST(ISNULL(GLGL_DOCUMENTOS.DTPREVISAOENTREGAEDI, GLGL_DOCUMENTOS.DTPREVISAOENTREGAEMISSAO) AS DATE)	
 					)                                                                                                                   
 				)                                                                                                                       
 		    )                                                                                                                           
 					THEN 'Entregue no Prazo'                                                                                  
 		WHEN  GLGL_DOCUMENTOS.DATAENTREGA IS NULL AND (GLGL_DOCUMENTOS.STATUS  IN(235,313,418,419,420,421) OR GLGL_DOCUMENTOS.RECUSADO = 'S') THEN 'Finalizado Com Restrição'                                                                      
 		WHEN CAST(ISNULL(GLGL_DOCUMENTOS.DTPREVISAOENTREGAEDI,GLGL_DOCUMENTOS.DTPREVISAOENTREGAEMISSAO) AS DATE) < CAST(GETDATE() AS DATE)                                                                     
 			 AND NOT EXISTS (                                                                                                           
			            SELECT 1																										    
			            FROM GLOP_OCORRENCIAS O																							    
			            	INNER JOIN GLGL_DOCUMENTOASSOCIADOS T1 ON T1.DOCUMENTOCLIENTE = O.NOTAFISCAL								    
			            	INNER JOIN GLOP_TIPORESPONOCORRENCIA T2 ON T2.RESPONSABILIDADE = O.RESPONSABILIDADE							    
			            WHERE O.ESTORNADO = 'N'																							    
			            	AND T1.DOCUMENTOLOGISTICA = GLGL_DOCUMENTOS.HANDLE																		    
			            	AND T2.CLASSIFICACAO = 2   																					    
			            	AND CAST(O.INCLUIDOEM AS DATE) <= CAST(ISNULL(GLGL_DOCUMENTOS.DTPREVISAOENTREGAEDI, GLGL_DOCUMENTOS.DTPREVISAOENTREGAEMISSAO) AS DATE)	
 				)                                                                                                                       
 									THEN 'Em Aberto em Atraso'                                                                  
 		ELSE 'Em Aberto no Prazo' END AS SITUACAO,
		PRAZOENTREGA,  
			   DTPREVISAOENTREGA,
			   DATAENTREGA,
			   GLGL_DOCUMENTOS.NUMERO,
			   --DATEDIFF(DD, DTPREVISAOENTREGA, GETDATE()) DIASEMATRASO,
			   CASE
					WHEN DATEDIFF(DD, DTPREVISAOENTREGA, GETDATE()) = 1 THEN '1 DIA EM ATRASO'
					WHEN DATEDIFF(DD, DTPREVISAOENTREGA, GETDATE()) = 2 THEN '2 DIA EM ATRASO'
					WHEN DATEDIFF(DD, DTPREVISAOENTREGA, GETDATE()) = 3 THEN '3 DIA EM ATRASO'
					WHEN DATEDIFF(DD, DTPREVISAOENTREGA, GETDATE()) = 4 THEN '4 DIA EM ATRASO'
			   ELSE '5 OU MAIS DIA EM ATRASO'
			   END AS DIASEMATRASO,
					
			   Case 
					When GLGL_DOCUMENTOS.STATUS In (225, 226, 227, 230, 603)		Then 'Entrega'
					When GLGL_DOCUMENTOS.STATUS In (228, 231, 259, 945)				Then 'Transferência'
					When GLGL_DOCUMENTOS.STATUS In (239)							Then Case (Select GLOP_VIAGENS.TIPOVIAGEM
																								 From GLOP_VIAGENS
																								Inner Join GLOP_VIAGEMDOCUMENTOS
																								   On GLOP_VIAGEMDOCUMENTOS.VIAGEM				= GLOP_VIAGENS.HANDLE
																								Where GLOP_VIAGEMDOCUMENTOS.DOCUMENTOLOGISTICA	= GLGL_DOCUMENTOS.HANDLE)
																							  When 172 Then 'Transferência'
																							  Else 'Entrega'
																						 End
				   When GLGL_DOCUMENTOS.FILIALATUAL = GLGL_DOCUMENTOS.FILIALENTREGA	Then 'Entrega'
				   Else 'Transferência'
			   End																			[Tipo],
			   DateDiff(Day,
			   IsNull((Select Max(GLOP_VIAGEMPARADAS.CHEGADA)
						 From GLOP_VIAGEMDOCUMENTOS 
						Inner Join GLOP_VIAGEMPARADAS
						   On GLOP_VIAGEMPARADAS.HANDLE							= GLOP_VIAGEMDOCUMENTOS.PARADA
						  And GLOP_VIAGEMPARADAS.VIAGEM							= GLOP_VIAGEMDOCUMENTOS.VIAGEM
						Where GLOP_VIAGEMDOCUMENTOS.DOCUMENTOLOGISTICA			= GLGL_DOCUMENTOS.HANDLE
						  And GLOP_VIAGEMPARADAS.FILIAL							= GLGL_DOCUMENTOS.FILIALATUAL
						  And Not GLOP_VIAGEMPARADAS.CHEGADA					Is Null), GLGL_DOCUMENTOS.DATAEMISSAO),
			   GetDate())																	[Tempo],
			   GLGL_DOCUMENTOS.HANDLE AS DOCUMENTO,
			   GLGL_DOCUMENTOS.VALORCONTABIL,
			   GLGL_DOCUMENTOS.DOCCLIVOLUME,
			   GLGL_DOCUMENTOS.DOCCLIVALORTOTAL
		  From GLGL_DOCUMENTOS
		 Inner Join GLGL_FILIAIS
			On GLGL_FILIAIS.HANDLE												= GLGL_DOCUMENTOS.FILIALATUAL
		 
		 Inner Join GLGL_FILIAIS b
			On b.HANDLE												= GLGL_DOCUMENTOS.FILIAL
		 
		 Inner Join FILIAIS c
			On c.HANDLE													= b.FILIAL

		 Inner Join FILIAIS
			On FILIAIS.HANDLE													= GLGL_FILIAIS.FILIAL
		 Inner Join GLGL_ENUMERACAOITEMS
			On GLGL_ENUMERACAOITEMS.HANDLE										= GLGL_DOCUMENTOS.STATUS
		 Inner Join ESTADOS
			On ESTADOS.HANDLE													= FILIAIS.ESTADO
		 Where Not GLGL_DOCUMENTOS.STATUS										In (236, 237, 417, 219, 220, 221, 222, 223, 224, 229, 230, 231,  399, 
																					404, 416, 418, 419, 420, 439, 609, 743, 890, 625)  
		   And Cast(GLGL_DOCUMENTOS.DATAEMISSAO As Date)						>= '2020-01-01'
		   And (GLGL_DOCUMENTOS.DATAENTREGA										Is Null
		   And  Not GLGL_DOCUMENTOS.STATUS										In (234, 235, 313, 314, 418, 419, 420, 421))
		   And GLGL_DOCUMENTOS.SISTEMAORIGEM									= 3
		   And ((GLGL_DOCUMENTOS.TIPODOCUMENTO									In (1, 2)
		   And   GLGL_DOCUMENTOS.TIPODOCUMENTOFRETE								In (153)
		   And GLGL_DOCUMENTOS.RECUSADO											= 'N'
		   And Not Exists (Select 1
							 From GLOP_SERVICOREALIZADORPS
							Inner Join GLOP_SERVICOSREALIZADOS
							   On GLOP_SERVICOSREALIZADOS.HANDLE				= GLOP_SERVICOREALIZADORPS.SERVICOREALIZADO
							Inner Join GLGL_SERVICOLOGISTICA
							   On GLGL_SERVICOLOGISTICA.HANDLE					= GLOP_SERVICOSREALIZADOS.SERVICO
							Where GLOP_SERVICOREALIZADORPS.DOCUMENTOLOGISTICA	= GLGL_DOCUMENTOS.HANDLE
							  And GLGL_SERVICOLOGISTICA.FUNCAO					= 39))

			Or (GLGL_DOCUMENTOS.TIPODOCUMENTO									In (6)
		   And ((Not GLGL_DOCUMENTOS.TIPORPS									In (323, 324))
			Or  (GLGL_DOCUMENTOS.TIPORPS										= 324
		   And Exists (Select 1
						 From GLOP_SERVICOREALIZADORPS
						Inner Join GLOP_SERVICOSREALIZADOS
						   On GLOP_SERVICOSREALIZADOS.HANDLE					= GLOP_SERVICOREALIZADORPS.SERVICOREALIZADO
						Inner Join GLGL_SERVICOLOGISTICA
						   On GLGL_SERVICOLOGISTICA.HANDLE						= GLOP_SERVICOSREALIZADOS.SERVICO
						Where GLOP_SERVICOREALIZADORPS.DOCUMENTOLOGISTICARPS	= GLGL_DOCUMENTOS.HANDLE
						  And GLGL_SERVICOLOGISTICA.FUNCAO						= 39)))))

			AND DTPREVISAOENTREGA <= GETDATE()
			AND DATAENTREGA IS NULL
			AND DATEDIFF(DD, DTPREVISAOENTREGA, GETDATE()) > 0

		   --And (Case ESTADOS.SIGLA
				 --    When 'CE' Then 'Regional Nordeste'
				 --    When 'RN' Then 'Regional Nordeste'
				 --    When 'PB' Then 'Regional Nordeste'
				 --    When 'PE' Then 'Regional BA'
				 --    When 'AL' Then 'Regional Nordeste'
				 --    When 'SE' Then 'Regional Nordeste'
				 --    When 'BA' Then 'Regional BA'
				 --    When 'MG' Then 'Regional MG'
				 --    When 'ES' Then 'Regional Nordeste'
				 --    When 'RJ' Then 'Regional Rio de Janeiro'
				 --    When 'SP' Then 'Regional SP e Sul'
				 --    When 'PR' Then 'Regional SP e Sul'
				 --    When 'SC' Then 'Regional SP e Sul'
				 --    When 'RS' Then 'Regional SP e Sul'
			  --  End																= @REGIONAL
		   -- Or @REGIONAL														= '')
		 --  And (Case 
			--		 When GLGL_DOCUMENTOS.STATUS In (225, 226, 227, 230, 603)			Then 'Entrega'
			--		 When GLGL_DOCUMENTOS.STATUS In (228, 231, 259, 945)				Then 'Transferência'
			--		 When GLGL_DOCUMENTOS.STATUS In (239)								Then Case (Select GLOP_VIAGENS.TIPOVIAGEM
			--		 																				 From GLOP_VIAGENS
			--		 																				Inner Join GLOP_VIAGEMDOCUMENTOS
			--		 																				   On GLOP_VIAGEMDOCUMENTOS.VIAGEM				= GLOP_VIAGENS.HANDLE
			--		 																				Where GLOP_VIAGEMDOCUMENTOS.DOCUMENTOLOGISTICA	= GLGL_DOCUMENTOS.HANDLE)
			--		 																		  When 172 Then 'Transferência'
			--		 																		  Else 'Entrega'
			--		 																	 End
			--	     When GLGL_DOCUMENTOS.FILIALATUAL = GLGL_DOCUMENTOS.FILIALENTREGA	Then 'Entrega'
			--	     Else 'Transferência'
			--     End																= @TIPO
			--Or @TIPO																= '')