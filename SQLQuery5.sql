SELECT		CP.HANDLE COLETA,  
											DL.NUMERO,                                                                                                                                                 
											DL.VALORTOTALRECEBER           VALORFRETE,
											DL.DOCCLIPESOTOTAL AS PESO,
											DL.DOCCLIPESOCUBADOTOTAL AS PESOCUBADO, 
											DL.DOCCLIPESOCONSIDERADO AS PESOCONSIDERADO,
											COUNT(DISTINCT CP.HANDLE) AS QUANTIDADECOLETA,
											DL.DOCCLIPESOCONSIDERADO AS PESOCOLETAREALIZADO,
											DL.DOCCLIVOLUME AS [VOLUME],
											DL.DOCCLIVALORTOTAL AS [VALORMERCADORIA]                                                                                                                  
								FROM GLGL_DOCUMENTOASSOCIADOS DA   
                                                                                                                                                                   
								INNER JOIN GLGL_DOCUMENTOCLIENTES DC 
									ON DC.HANDLE = DA.DOCUMENTOCLIENTE
	                                                                                       
								INNER JOIN GLGL_DOCUMENTOS DL 
									ON DA.DOCUMENTOLOGISTICA = DL.HANDLE 
	                                                                                                     
								INNER JOIN GLOP_COLETAPEDIDOS CP 
									ON CP.HANDLE = DC.PEDIDOCOLETA     
	                                                                                     
	                                                                                                       
								WHERE  1=1                                                                                                                                                                                                            
									And ((DL.TIPODOCUMENTO In (1, 2)                                                                                                         
									And   DL.TIPODOCUMENTOFRETE = 153)                                                                                                            
									Or  (DL.TIPODOCUMENTO In (6)                                                                                                            
									And   DL.TIPORPS <> 324))   
									AND DL.STATUS <> 236
									AND CP.HANDLE = 2175574
					                                                                                                      
								GROUP BY CP.HANDLE,  
										 DL.NUMERO,                                                                                                                                                                                     
										 DL.VALORTOTALRECEBER,
										 DL.DOCCLIPESOTOTAL,
										 DL.DOCCLIPESOCUBADOTOTAL, 
										 DL.DOCCLIPESOCONSIDERADO,
										 DL.DOCCLIPESOCONSIDERADO,
										 DL.DOCCLIVOLUME,
										 DL.DOCCLIVALORTOTAL