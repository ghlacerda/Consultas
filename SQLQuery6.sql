SELECT 
					VD.VIAGEM,
					SUM(CONVERT(DECIMAL(14,3),DL.VALORTOTALRECEBER)) AS VALORTOTALRECEBER,
					SUM(CONVERT(DECIMAL(14,3),DL.DOCCLIPESOTOTAL)) AS DOCCLIPESOTOTAL,                                                                                                                                                                                           
                    SUM(CONVERT(DECIMAL(14,3),DL.DOCCLIPESOCUBADOTOTAL)) AS DOCCLIPESOCUBADOTOTAL,
					SUM(CONVERT(DECIMAL(14,3),DL.DOCCLIPESOCONSIDERADO)) AS PESOTOTALCONSIDERADO,
					--SUM(DL.DOCCLIVOLUME) AS VOLUMEENTREGA,
					SUM(IIF(DOCCLIPESOCUBADOTOTAL > DOCCLIPESOTOTAL, DOCCLIPESOCUBADOTOTAL, DOCCLIPESOTOTAL))  AS TOTAL,
					COUNT(DL.HANDLE) AS HANDLE
			--INTO #TESTE
			FROM GLOP_VIAGEMDOCUMENTOS VD

			INNER JOIN GLOP_OCORRENCIAS OC     
				ON OC.HANDLE = VD.OCORRENCIA 

			INNER JOIN GLOP_MOTIVOOCORRENCIAS MOC 
				ON MOC.HANDLE = OC.OCORRENCIA                                                                                                          
				--AND PAGARFORNECEDOR = 'S'  
				                                                                                                                  
			INNER JOIN GLGL_DOCUMENTOS DL     
				ON DL.HANDLE = VD.DOCUMENTOLOGISTICA                                                                                            

			WHERE VD.TIPOSERVICO = 197     
			AND VD.VIAGEM = 3041224  

			GROUP BY VD.VIAGEM