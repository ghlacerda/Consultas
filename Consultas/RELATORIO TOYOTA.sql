	SELECT D.DIA DIAS_TRABALHADOS,																																					 
	 		D.DIAS DIAS_TRABALHADOS_REAL,                                                                                                                                            
		 	D.BENEFICIARIO,								                                                                                                                             
		 	SUM(D.QTDE_COLETAS) QTDE_COLETAS,                                                                                                                                        
		 	SUM(D.QTDE_ENTREGAS) QTDE_ENTREGAS,                                                                                                                                      
		 	SUM(D.QTDE_VIAGENS) QTDE_VIAGENS,				                                                                                                                         
		 	SUM(D.DOCM3) DOCM3,																															                             
	 	 	SUM(D.DOCPESOCONSID) DOCPESOCONSID,																											                             
	 	 	SUM(D.DOCPESOREAL) DOCPESOREAL,																												                             
		 	SUM(D.KM_TOTAL) KM_TOTAL,                                                                                                                                                
		 	SUM(D.PESO_CONSID_COLETA) PESO_CONSID_COLETA,                                                                                                                            
		 	SUM(D.PESO_CONSID_ENTREGA) PESO_CONSID_ENTREGA,                                                                                                                          
		 	SUM(D.RECEITA_COLETA) RECEITA_COLETA,                                                                                                                                    
		 	SUM(D.RECEITA_ENTREGA) RECEITA_ENTREGA,                                                                                                                                  
		 	SUM(D.VOLUMES) VOLUMES,                                                                                                                                                  
		 	(SELECT CAPACIDADE FROM MA_RECURSOS WHERE HANDLE = D.HANDLEVEICULO) CAPACIDADEKG,                                                                                        
		 	(SELECT CAPACIDADEM3 FROM MA_RECURSOS WHERE HANDLE = D.HANDLEVEICULO) CAPACIDADEM3,                                                                                        
		 	D.PLACA,				                                                                                                                                                 
		 	D.MOTORISTA,                                                                                                                                                             
		 	D.TIPOVEICULO,                                                                                                                                                           
		 	D.HANDLEVEICULO,                                                                                                                                                         
		 	D.HANDLEMOTORISTA,			                                                                                                                                             
		 	D.HANDLEBENEFICIARIO,                                                                                                                                                    
		 	D.FILIALORIGEM,                                                                                                                                                          
		 	D.FILIALORIGEMNOME,                                                                                                                                                          
		 	D.ORIGEM,                                                                                                                                                                
		 	SUM(D.VALORTOTALFRETEENTREGA) VALORTOTALFRETEENTREGA,                                                                                                                    
		 	SUM(D.VALORTOTALFRETECOLETA) VALORTOTALFRETECOLETA,			                                                                                                             
		 	SUM(D.VALORTOTALFRETEMISTA) VALORTOTALFRETEMISTA,			                                                                                                             
		 	SUM(D.OCUP_PESO_CONSID) OCUP_PESO_CONSID,																									                             
		 	SUM(D.OCUP_PESO_REAL) OCUP_PESO_REAL,																										                             
		 	SUM(D.PESO_TOTAL) PESO_TOTAL,																												                             
		 	SUM(D.OCUP_M3) OCUP_M3,																														                             
			SUM(D.CUSTO_COLETA) CUSTO_COLETA,                                                                                                                                        
			SUM(D.CUSTO_ENTREGA) CUSTO_ENTREGA,		                                                                                                                                 
			SUM(D.RECEITA_TOTAL) RECEITA_TOTAL,                                                                                                                                      
		 	CASE WHEN D.ORIGEM = 1 THEN 0 ELSE (SUM(D.CUSTO_COLETA) + SUM(D.CUSTO_ENTREGA)) END CUSTO_TOTAL,                                                                         
			CAST(IIF(SUM(D.RECEITA_TOTAL) > 0, (CASE WHEN D.ORIGEM = 1 THEN 0 ELSE (SUM(D.CUSTO_COLETA) + SUM(D.CUSTO_ENTREGA)) END/SUM(D.RECEITA_TOTAL))*100, 0) AS DECIMAL(10,2)) AS PORCENTAGEM_CUSTO				 
		 FROM (                                                                                                                                                                      
		 	SELECT C.*,                                                                                                                                                              
		 		(C.RECEITA_COLETA + C.RECEITA_ENTREGA) RECEITA_TOTAL,		                                                                                                         
		 		(C.PESO_CONSID_COLETA + C.PESO_CONSID_ENTREGA) PESO_TOTAL,		                                                                                                     
				(																																			                         
		 		CASE																																		                         
		 			WHEN C.DOCPESOCONSID = 0																												                         
		 				OR C.CAPACIDADEKG = 0																												                         
		 				THEN 0																																                         
		 			ELSE IIF((C.CAPACIDADEKG * C.QTDE_VIAGENS) > 0, (((C.PESO_CONSID_COLETA + C.PESO_CONSID_ENTREGA) * 100) / (C.CAPACIDADEKG * C.QTDE_VIAGENS)), 0)																		                         
		 			END																																		                         
		 		) OCUP_PESO_CONSID,																															                         
		 		(																																			                         
		 		CASE																																		                         
		 			WHEN C.DOCPESOREAL = 0																													                         
		 				OR C.CAPACIDADEKG = 0																												                         
		 				THEN 0																																                         
		 			ELSE IIF((C.CAPACIDADEKG * C.QTDE_VIAGENS) > 0, ((C.DOCPESOREAL * 100) / (C.CAPACIDADEKG * C.QTDE_VIAGENS)), 0)																	                         
		 			END																																		                         
		 		) OCUP_PESO_REAL,																															                         
		 		(																																			                         
		 		CASE																																		                         
		 			WHEN C.DOCM3 = 0																														                         
		 				OR C.CAPACIDADEM3 = 0																												                         
		 				THEN 0																																                         
		 			ELSE IIF((C.CAPACIDADEM3 * C.QTDE_VIAGENS) > 0, ((C.DOCM3 * 100) / (C.CAPACIDADEM3 * C.QTDE_VIAGENS)), 0)																				                         
		 			END																																		                         
		 		) OCUP_M3,																																	                         
		 		TDIAS.DIA,                                                                                                                                                           
		 		SUM(TDIASREAL.DIAS) DIAS,		                                                                                                                                     
		 		CASE WHEN C.TIPOVIAGEM = 173 THEN                                                                                                                                    
		 			(IIF((C.QTDE_COLETAS + C.QTDE_ENTREGAS) > 0, (C.VALORTOTALFRETEMISTA/(C.QTDE_COLETAS + C.QTDE_ENTREGAS)), 0) * C.QTDE_ENTREGAS)                                                                                
		 		ELSE                                                                                                                                                                 
		 			C.VALORTOTALFRETEENTREGA                                                                                                                                         
		 		END CUSTO_ENTREGA,				                                                                                                                                     
		 		CASE WHEN C.TIPOVIAGEM = 173 THEN                                                                                                                                    
		 			(IIF((C.QTDE_COLETAS + C.QTDE_ENTREGAS) > 0, (C.VALORTOTALFRETEMISTA/(C.QTDE_COLETAS + C.QTDE_ENTREGAS)), 0) * C.QTDE_COLETAS)                                                                                  
		 		ELSE                                                                                                                                                                 
		 			SUM(C.VALORTOTALFRETECOLETA)                                                                                                                                     
		 		END CUSTO_COLETA				                                                                                                                                     
		 	FROM (                                                                                                                                                                   
		 		SELECT B.BENEFICIARIO,								                                                                                                                 
		 				SUM(B.QTDE_COLETAS) QTDE_COLETAS,                                                                                                                            
		 				SUM(B.QTDE_ENTREGAS) QTDE_ENTREGAS,                                                                                                                          
		 				COUNT(DISTINCT(B.HANDLE)) QTDE_VIAGENS,		                                                                                                                 
		 				SUM(B.DOCM3) DOCM3,																													                         
		 				SUM(B.DOCPESOCONSID) DOCPESOCONSID,																									                         
		 				SUM(B.DOCPESOREAL) DOCPESOREAL,																										                         
		 				SUM(B.KM_TOTAL) AS KM_TOTAL,				                                                                                                                 
		 				SUM(B.PESO_CONSID_COLETA) PESO_CONSID_COLETA,                                                                                                                
		 				SUM(B.PESO_CONSID_ENTREGA) PESO_CONSID_ENTREGA,                                                                                                              
		 				SUM(B.RECEITA_COLETA) RECEITA_COLETA,                                                                                                                        
		 				SUM(B.RECEITA_ENTREGA) RECEITA_ENTREGA,                                                                                                                      
		 				SUM(B.VOLUMES) VOLUMES,                                                                                                                                      
		 				B.CAPACIDADEKG,                                                                                                                                              
		 				B.CAPACIDADEM3,                                                                                                                                              
		 				B.PLACA,				                                                                                                                                     
		 				B.MOTORISTA,                                                                                                                                                 
		 				B.TIPOVEICULO,                                                                                                                                               
		 				B.HANDLEVEICULO,                                                                                                                                             
		 				B.HANDLEMOTORISTA,			                                                                                                                                 
		 				B.HANDLEBENEFICIARIO,                                                                                                                                        
		 				B.FILIALORIGEM,                                                                                                                                              
		 				B.FILIALORIGEMNOME,                                                                                                                                              
		 				B.ORIGEM,                                                                                                                                                    
		 				B.TIPOVIAGEM,                                                                                                                                                
		 				SUM(B.VALORTOTALFRETEENTREGA)  VALORTOTALFRETEENTREGA,                                                                                                       
		 				SUM(B.VALORTOTALFRETECOLETA) VALORTOTALFRETECOLETA,                                                                                                           
		 				SUM(B.VALORTOTALFRETEMISTA) VALORTOTALFRETEMISTA                                                                                                           
		 			FROM (				                                                                                                                                             
		 				SELECT A.HANDLE,                                                                                                                                             
		 				 		UPPER(VEICULO.PLACANUMERO) PLACA,                                                                                                                    
		 				 		UPPER(MOTORISTA.NOME) MOTORISTA,                                                                                                                     
		 				 		UPPER(ISNULL(BENEFICIARIO.NOME, MOTORISTA.NOME)) BENEFICIARIO,                                                                                       
		 				 		UPPER(TIPO.NOME) TIPOVEICULO, 		                                                                                                                 
								ISNULL(COLETA.QTDE_COLETAS, 0) QTDE_COLETAS,                                                                                                         
								ISNULL(ENTREGA.QTDE_ENTREGAS, 0) QTDE_ENTREGAS,                                                                                                      
								ISNULL(ENTREGA.PESO_CONSID_ENTREGA, 0) PESO_CONSID_ENTREGA,                                                                                          
								ISNULL(COLETA.PESO_CONSID_COLETA, 0) PESO_CONSID_COLETA,                                                                                             
								(ISNULL(COLETA.VOLUMES,0) + ISNULL(ENTREGA.VOLUMES, 0)) VOLUMES,                                                                                     
								ISNULL(COLETA.RECEITA_COLETA, 0) RECEITA_COLETA,                                                                                                     
								ISNULL(ENTREGA.RECEITA_ENTREGA, 0) RECEITA_ENTREGA,                                                                                                     
 								ISNULL(SUM(DISTINCT(CAST(DOC.VALORTOTALRECEBER AS DECIMAL(10,2)))),0) RECEITA_ENTREGA,                                                               
								ISNULL(VEICULO.CAPACIDADE, 0) CAPACIDADEKG,                                                                                                          
		 				 		ISNULL(VEICULO.CAPACIDADEM3, 0) CAPACIDADEM3,                                                                                                        
		 				 		IsNull(SUM(DOC.DOCCLIATUALPESOCONSIDERADO),0) DOCCLIATUALPESOCONSIDERADO,													                         
		 				 		(IsNull(SUM(DOC.DOCCLIATUALPESOCONSIDERADO), 0) + IsNull(SUM(DOCCLI.PESOCONSIDERADO), 0)) DOCPESOCONSID,					                         
		 				 		(IsNull(SUM(DOC.DOCCLIATUALPESOTOTAL), 0) + IsNull(SUM(DOCCLI.PESOCONSIDERADO), 0)) DOCPESOREAL,							                         
		 				 		(IsNull(SUM(DOC.DOCCLIPESOCUBADOTOTAL), 0) + IsNull(SUM(DOCCLI.PESOCUBADO),0)) DOCM3,										                         
		 				 		CAST((ISNULL(A.DISTANCIACONSIDERADA, ISNULL(A.DISTANCIATOTAL, ISNULL(A.DISTANCIAPREVISTA, 0)))) AS FLOAT) KM_TOTAL,                                  
		 				 		VEICULO.HANDLE HANDLEVEICULO,                                                                                                                        
		 				 		MOTORISTA.HANDLE HANDLEMOTORISTA, 		                                                                                                             
		 				 		VEICULO.PROPRIETARIO HANDLEBENEFICIARIO,                                                                                                             
		 				 		A.FILIALORIGEM,                                                                                                                                      
		 				 		VEICULO.ORIGEM,                                                                                                                                      
		 				 		FILIAIS.NOME FILIALORIGEMNOME,                                                                                                                                      
		 						ISNULL(EFRETE.VALORTOTAL,0) VALORTOTALFRETEENTREGA,                                                                                                  
		 						ISNULL(CFRETE.VALORTOTAL,0) VALORTOTALFRETECOLETA,                                                                                                   
		 						ISNULL(MFRETE.VALORTOTAL,0) VALORTOTALFRETEMISTA,                                                                                                   
		 						A.TIPOVIAGEM                                                                                                                                         
		 				 FROM GLOP_VIAGENS A                                                                                                                                         
		 				 	INNER JOIN FILIAIS ON FILIAIS.HANDLE = A.FILIALORIGEM                                                                                            
		 				 	INNER JOIN MA_RECURSOS VEICULO ON VEICULO.HANDLE = A.VEICULO1                                                                                            
		 				 	INNER JOIN MF_VEICULOTIPOS TIPO ON TIPO.HANDLE = VEICULO.TIPOVEICULO                                                                                     
		 				 	INNER JOIN GN_PESSOAS MOTORISTA ON MOTORISTA.HANDLE = A.MOTORISTA                                                                                        
		 				 	LEFT JOIN GN_PESSOAS BENEFICIARIO ON BENEFICIARIO.HANDLE = VEICULO.PROPRIETARIO                                   										 
							LEFT JOIN GLOP_VIAGEMDOCUMENTOS 	VDOCENTS 		ON	VDOCENTS.VIAGEM 	= A.HANDLE 		 AND VDOCENTS.DOCUMENTOLOGISTICA IS NOT NULL                 
							LEFT JOIN GLOP_VIAGEMDOCUMENTOS 	VDOCCOLS		ON	VDOCCOLS.VIAGEM 	= A.HANDLE 		 AND VDOCCOLS.DOCUMENTOCOLETA IS NOT NULL                    
							LEFT JOIN GLOP_COLETAPEDIDOS 		COLS			ON	COLS.HANDLE		 	= VDOCCOLS.DOCUMENTOCOLETA                                                   
							LEFT JOIN GLGL_DOCUMENTOCLIENTES	DOCCLI			ON	DOCCLI.PEDIDOCOLETA = COLS.HANDLE                                                                
							LEFT JOIN GLGL_DOCUMENTOS 			DOC				ON	DOC.HANDLE 			= VDOCENTS.DOCUMENTOLOGISTICA                                                
							LEFT JOIN (                                                                                                                                              
									SELECT V.HANDLE VIAGEM,                                                                                                                              
										FRETE.NEGOCIACAO,                                                                                                                             
										SUM(FRETE.VALORTOTAL) AS VALORTOTAL                                                                                                         
									FROM GLOP_VIAGENS V                                                                                                                  
										INNER JOIN GLOP_CONTRATOFRETEVIAGENS VFRETE ON VFRETE.VIAGEM = V.HANDLE                                                                   
										INNER JOIN GLOP_CONTRATOFRETES 		 FRETE  ON FRETE.HANDLE = VFRETE.CONTRATOFRETE AND FRETE.STATUS NOT IN (262, 433, 731)                   
									WHERE ((V.TIPOVIAGEM = 169) OR ((V.TIPOVIAGEM = 173) AND ((V.VIAGEMMISTA = 1))))                                                               
									AND EXISTS (SELECT HANDLE FROM GLOP_VIAGEMDOCUMENTOS WHERE VIAGEM = V.HANDLE AND DOCUMENTOCOLETA IS NOT NULL )  
									GROUP BY v.HANDLE, FRETE.NEGOCIACAO                                                                                                           
									) CFRETE ON CFRETE.VIAGEM = A.HANDLE                                                                                                             
		 				 	LEFT JOIN (                                                                                                                                              
									SELECT V.HANDLE VIAGEM,                                                                                                                              
										SUM(FRETE.VALORTOTAL) AS VALORTOTAL                                                                                                          
									FROM GLOP_VIAGENS V                                                                                                                  
										INNER JOIN GLOP_CONTRATOFRETEVIAGENS VFRETE ON VFRETE.VIAGEM = V.HANDLE                                                                   
										INNER JOIN GLOP_CONTRATOFRETES 		FRETE 	ON FRETE.HANDLE = VFRETE.CONTRATOFRETE AND	FRETE.STATUS NOT IN (262, 433, 731)                  
									WHERE ((V.TIPOVIAGEM = 170) OR ((V.TIPOVIAGEM = 173) AND ((V.VIAGEMMISTA = 2))))                                             			         
									AND EXISTS (SELECT HANDLE FROM GLOP_VIAGEMDOCUMENTOS WHERE VIAGEM = V.HANDLE AND DOCUMENTOLOGISTICA IS NOT NULL )   
									GROUP BY v.HANDLE                                                                                                                             
									) EFRETE ON EFRETE.VIAGEM = A.HANDLE										                                                                     

		 				 	LEFT JOIN (                                                                                                                                              
									SELECT V.HANDLE VIAGEM,                                                                                                                              
										SUM(FRETE.VALORTOTAL) AS VALORTOTAL                                                                                                          
									FROM GLOP_VIAGENS V                                                                                                                  
										INNER JOIN GLOP_CONTRATOFRETEVIAGENS VFRETE ON VFRETE.VIAGEM = V.HANDLE                                                                   
										INNER JOIN GLOP_CONTRATOFRETES 		FRETE 	ON FRETE.HANDLE = VFRETE.CONTRATOFRETE AND	FRETE.STATUS NOT IN (262, 433, 731)                  
									WHERE ((V.TIPOVIAGEM = 173) AND ((V.VIAGEMMISTA = 3)))                                             			         
									AND EXISTS (SELECT HANDLE FROM GLOP_VIAGEMDOCUMENTOS WHERE VIAGEM = V.HANDLE AND DOCUMENTOLOGISTICA IS NOT NULL UNION ALL SELECT HANDLE FROM GLOP_VIAGEMDOCUMENTOS WHERE VIAGEM = V.HANDLE AND DOCUMENTOCOLETA IS NOT NULL)   
									GROUP BY v.HANDLE                                                                                                                             
									) MFRETE ON MFRETE.VIAGEM = A.HANDLE										                                                                     

							LEFT JOIN (                                                                                                                                              
										SELECT V.HANDLE,                                                                                                                             
											COUNT(VD.HANDLE) QTDE_ENTREGAS, SUM(VD.VOLUMES) VOLUMES, SUM((CASE WHEN DL.DOCCLIATUALPESOTOTAL > DL.DOCCLIATUALPESOCUBADOTOTAL THEN DL.DOCCLIATUALPESOTOTAL ELSE  DL.DOCCLIATUALPESOCUBADOTOTAL END)) PESO_CONSID_ENTREGA, SUM(DL.VALORTOTALRECEBER) RECEITA_ENTREGA  
										FROM GLOP_VIAGEMDOCUMENTOS  VD                                                                                                               
											INNER JOIN GLOP_VIAGENS V ON (VD.VIAGEM = V.HANDLE)                                                                                      
											INNER JOIN GLOP_OCORRENCIAS OC ON (OC.HANDLE = VD.OCORRENCIA)                                                                            
											INNER JOIN GLOP_MOTIVOOCORRENCIAS MOC ON (MOC.HANDLE = OC.OCORRENCIA) AND (PAGARFORNECEDOR = 'S')                                        
											INNER JOIN GLGL_DOCUMENTOS DL ON DL.HANDLE = VD.DOCUMENTOLOGISTICA                                                                       
										WHERE ((V.TIPOVIAGEM = 170) OR ((V.TIPOVIAGEM = 173) AND ((V.VIAGEMMISTA = 3)))) AND VD.TIPOSERVICO = 197                                
										GROUP BY VD.VIAGEM, V.HANDLE                                                                                                                 
										) ENTREGA ON (ENTREGA.HANDLE = A.HANDLE)                                                                                                     
							LEFT JOIN (                                                                                                                                              
                                      SELECT V.HANDLE,                                                                                                                                                       
                                      	COUNT(VD.HANDLE) QTDE_COLETAS, SUM(DAS.VOLUMES) VOLUMES, SUM(DAS.PESOCONSIDERADO) PESO_CONSID_COLETA, SUM(DAS.VALORFRETE) RECEITA_COLETA                             
                                      FROM GLOP_VIAGEMDOCUMENTOS  VD                                                                                                                                         
                                      	INNER JOIN GLOP_VIAGENS V ON (VD.VIAGEM = V.HANDLE)                                                                                                                  
                                      	INNER JOIN GLOP_OCORRENCIAS OC ON (OC.HANDLE = VD.OCORRENCIA)                                                                                                        
                                      	INNER JOIN GLOP_MOTIVOOCORRENCIAS MOC ON (MOC.HANDLE = OC.OCORRENCIA) AND (PAGARFORNECEDOR = 'S')                                                                    
                                          LEFT JOIN (                                                                                                                                                        
                                      		SELECT DL.HANDLE, DC.PEDIDOCOLETA PEDIDOCOLETA,                                                                                                                  
                                      		      (CASE WHEN DL.DOCCLIATUALPESOTOTAL > DL.DOCCLIATUALPESOCUBADOTOTAL THEN DL.DOCCLIATUALPESOTOTAL ELSE  DL.DOCCLIATUALPESOCUBADOTOTAL END) PESOCONSIDERADO,  
                                      			  DL.DOCCLIATUALVOLUME VOLUMES, DL.VALORTOTALRECEBER VALORFRETE                                                                                              
                                      		FROM  GLGL_DOCUMENTOASSOCIADOS DA                                                                                                                                
                                      		INNER Join GLGL_DOCUMENTOCLIENTES DC On DC.Handle = DA.DOCUMENTOCLIENTE                                                                                          
                                      		INNER Join GLGL_DOCUMENTOS DL On DA.DOCUMENTOLOGISTICA = DL.Handle                                                                                               
                                      		GROUP BY DL.HANDLE,                                                                                                                                              
                                      				 DC.PEDIDOCOLETA,                                                                                                                                        
                                      				 DL.VALORTOTALRECEBER,                                                                                                                                   
                                      				 DL.DOCCLIATUALPESOTOTAL,                                                                                                                                
                                      				 DL.DOCCLIATUALPESOCUBADOTOTAL,                                                                                                                          
                                      				 DL.DOCCLIATUALVOLUME,                                                                                                                                   
                                      				 DL.VALORTOTALRECEBER                                                                                                                                    
                                            ) DAS On DAS.PEDIDOCOLETA = VD.DOCUMENTOCOLETA                                                                                                                   
                                      WHERE ((V.TIPOVIAGEM = 169) OR ((V.TIPOVIAGEM = 173) AND ((V.VIAGEMMISTA = 3)))) AND VD.TIPOSERVICO = 196                                                              
                                      GROUP BY V.HANDLE                                                                                                                                                      
										) COLETA ON (COLETA.HANDLE = A.HANDLE)                                                                                                       
						WHERE A.STATUS in (180, 293)                                                                                                                            

	 				 GROUP BY A.HANDLE,                                                                                                                                                      
	 				 	VEICULO.PLACANUMERO,                                                                                                                                                 
	 				 	MOTORISTA.NOME,                                                                                                                                                      
	 				 	BENEFICIARIO.NOME,                                                                                                                                                   
	 				 	TIPO.NOME,                                                                                                                                                           
	 				 	VEICULO.CAPACIDADE,                                                                                                                                                  
	 				 	VEICULO.CAPACIDADEM3,                                                                                                                                                
	 				 	VEICULO.HANDLE,                                                                                                                                                      
	 				 	MOTORISTA.HANDLE,		 	                                                                                                                                         
	 				 	VEICULO.PROPRIETARIO,                                                                                                                                                 
	 				 	A.FILIALORIGEM,                                                                                                                                                      
	 				 	FILIAIS.NOME,                                                                                                                                                      
	 				 	VEICULO.ORIGEM,                                                                                                                                                      
	 					EFRETE.VALORTOTAL,                                                                                                                                                   
	 					CFRETE.VALORTOTAL, MFRETE.VALORTOTAL,                                                                                                                                                   
	 					A.TIPOVIAGEM,                                                                                                                                                        
					IsNull(A.DISTANCIACONSIDERADA, ISNULL(A.DISTANCIATOTAL, ISNULL(A.DISTANCIAPREVISTA, 0))),                                                                               
					COLETA.QTDE_COLETAS,                                                                                                                                                     
					ENTREGA.QTDE_ENTREGAS,                                                                                                                                                   
					ENTREGA.PESO_CONSID_ENTREGA,                                                                                                                                             
					COLETA.PESO_CONSID_COLETA,                                                                                                                                               
					COLETA.VOLUMES,                                                                                                                                                          
					ENTREGA.VOLUMES,                                                                                                                                                         
					COLETA.RECEITA_COLETA,                                                                                                                                                    
					ENTREGA.RECEITA_ENTREGA                                                                                                                                                         
 				) B                                                                                                                                                                          
	 			GROUP BY B.BENEFICIARIO,                                                                                                                                                     
	 					B.CAPACIDADEKG,                                                                                                                                                      
	 					B.CAPACIDADEM3,                                                                                                                                                      
	 					B.MOTORISTA,                                                                                                                                                         
	 					B.PLACA,                                                                                                                                                             
	 					B.TIPOVEICULO,                                                                                                                                                       
	 					B.HANDLEVEICULO,                                                                                                                                                     
	 					B.HANDLEMOTORISTA,                                                                                                                                                   
	 					B.HANDLEBENEFICIARIO,                                                                                                                                                
	 					B.FILIALORIGEM,                                                                                                                                                      
	 					B.FILIALORIGEMNOME,                                                                                                                                                      
	 					B.ORIGEM,                                                                                                                                                            
	 					B.TIPOVIAGEM,                                                                                                                                                        
	 					B.KM_TOTAL																														                                     
	 	) C	                                                                                                                                                                                 
	 	LEFT JOIN (                                                                                                                                                                          
	 				SELECT COUNT(DISTINCT(CONVERT(DATE, V.INICIOEFETIVO, 103))) DIA,                                                                                                         
	 					V.MOTORISTA,                                                                                                                                                         
	 					V.VEICULO1,		                                                                                                                                                     
	 					V.FILIALORIGEM                                                                                                                                                       
	 				FROM GLOP_VIAGENS V                                                                                                                                                      
	 				WHERE V.INICIOEFETIVO IS NOT NULL                                                                                                                                        
	 					AND V.STATUS in (180, 293)                                                                                                                                                   
						AND	CONVERT(DATE, V.PREVISAOSAIDA, 103) BETWEEN :PERIODODE AND DATEADD(HOUR,23,DATEADD(MINUTE,59,DATEADD(SECOND,59,:PERIODOATE)))  	                                                                                     

			GROUP BY V.MOTORISTA,                                                                                                                                                    
				V.VEICULO1,                                                                                                                                                          
				V.FILIALORIGEM                                                                                                                                                       
			) TDIAS ON TDIAS.MOTORISTA		= C.HANDLEMOTORISTA	AND                                                                                                                  
						TDIAS.VEICULO1		= C.HANDLEVEICULO	AND							                                                                                         
						TDIAS.FILIALORIGEM	= C.FILIALORIGEM                                                                                                                         
LEFT JOIN (                                                                                                                                                                          
			SELECT D.DIAS,                                                                                                                                                           
					D.MOTORISTA,                                                                                                                                                     
					D.VEICULO1,		                                                                                                                                                 
					D.FILIALORIGEM,		                                                                                                                                             
					D.INICIOEFETIVO,                                                                                                                                                 
					D.CHEGADAEFETIVA                                                                                                                                                 
			FROM (                                                                                                                                                                   
				SELECT CASE WHEN DATEDIFF(DAY, CONVERT(DATE, V.INICIOEFETIVO, 103), CONVERT(DATE, V.CHEGADAEFETIVA, 103)) IS NULL THEN 0 ELSE	                                     
								 DATEDIFF(DAY, CONVERT(DATE, V.INICIOEFETIVO, 103), CONVERT(DATE, V.CHEGADAEFETIVA, 103)) END +1 DIAS,			                                     
					CONVERT(DATE, V.INICIOEFETIVO, 103) INICIOEFETIVO,                                                                                                               
					CONVERT(DATE, V.CHEGADAEFETIVA, 103) CHEGADAEFETIVA,                                                                                                             
					V.HANDLE,                                                                                                                                                        
					V.MOTORISTA,                                                                                                                                                     
					V.VEICULO1,                                                                                                                                                      
					V.BENEFICIARIO,                                                                                                                                                  
					V.TIPOVIAGEM,                                                                                                                                                    
					V.FILIALORIGEM                                                                                                                                                   
				FROM GLOP_VIAGENS V                                                                                                                                                  
				WHERE V.INICIOEFETIVO IS NOT NULL                                                                                                                                    
					AND V.STATUS in (180, 293)                                                                                                                                                

GROUP BY V.MOTORISTA,                                                                                                                                                
		V.VEICULO1,                                                                                                                                                      
		V.BENEFICIARIO,                                                                                                                                                  
		V.TIPOVIAGEM,                                                                                                                                                    
		V.HANDLE,                                                                                                                                                        
		V.FILIALORIGEM,                                                                                                                                                  
		CONVERT(DATE, V.INICIOEFETIVO, 103),                                                                                                                             
		CONVERT(DATE, V.CHEGADAEFETIVA, 103)                                                                                                                             
	) D                                                                                                                                                                  
GROUP BY D.DIAS,                                                                                                                                                         
		D.MOTORISTA,                                                                                                                                                     
		D.VEICULO1,				                                                                                                                                         
		D.FILIALORIGEM,		                                                                                                                                             
		D.INICIOEFETIVO,                                                                                                                                                 
		D.CHEGADAEFETIVA                                                                                                                                                 
IASREAL ON TDIASREAL.FILIALORIGEM	= C.FILIALORIGEM	AND                                                                                                              
			TDIASREAL.MOTORISTA		= C.HANDLEMOTORISTA	AND                                                                                                              
			TDIASREAL.VEICULO1		= C.HANDLEVEICULO									                                                                                 
ENEFICIARIO,                                                                                                                                                             
DE_COLETAS,                                                                                                                                                              
DE_ENTREGAS,                                                                                                                                                             
DE_VIAGENS,                                                                                                                                                              
CM3,																																                                     
CPESOCONSID,																														                                     
CPESOREAL,																															                                     
_TOTAL,                                                                                                                                                                  
SO_CONSID_COLETA,                                                                                                                                                        
SO_CONSID_ENTREGA,                                                                                                                                                       
CEITA_COLETA,                                                                                                                                                            
CEITA_ENTREGA,                                                                                                                                                           
LUMES,                                                                                                                                                                   
PACIDADEKG,                                                                                                                                                              
PACIDADEM3,                                                                                                                                                              
ACA,                                                                                                                                                                     
TORISTA,                                                                                                                                                                 
POVEICULO,                                                                                                                                                               
NDLEVEICULO,                                                                                                                                                             
NDLEMOTORISTA,                                                                                                                                                           
NDLEBENEFICIARIO,                                                                                                                                                        
LIALORIGEM,                                                                                                                                                              
LIALORIGEMNOME,                                                                                                                                                              
IGEM                                                                                                                                                                     
AS.DIA 	                                                                                                                                                                 
ALORTOTALFRETEENTREGA, C.VALORTOTALFRETEMISTA,                                                                                                                                                   
LORTOTALFRETECOLETA,                                                                                                                                                     
POVIAGEM                                                                                                                                                                 
                                                                                                                                                                         
,																																	                                     
                                                                                                                                                                         
,                                                                                                                                                                        
CIARIO,								                                                                                         		                                     
				                                                                                                                                                         
STA,                                                                                                                                                                     
ICULO,                                                                                                                                                                   
VEICULO,                                                                                                                                                                 
MOTORISTA,			                                                                                                                                                     
BENEFICIARIO,                                                                                                                                                            
ORIGEM,                                                                                                                                                                   
ORIGEMNOME                                                                                                                                                                   
