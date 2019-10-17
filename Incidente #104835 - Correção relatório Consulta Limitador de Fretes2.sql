SELECT DISTINCT 
--SUBSELECT PARA COMAR TUDO 
		[NUMEROVIAGEM] AS [N�mero Viagem],
        [INICIOEFETIVO] AS [In�cio Efetivo],
        [STATUSVIAGEM] AS [Status Viagem],
        [TIPOVIAGEM] AS [Tipo viagem],                                                        
        [NUMEROCONTRATOFRETE] AS [N�mero Contrato de Frete],
        [DATACONTRATOFRETE] AS [Data Contrato de Frete],
        [STATUSCONTRATOFRETE] AS [Status Contrato de Frete],                                                           
        [ORIGEM] AS [Origem],                                                                               
        [DESTINO] AS [Destino],                                                                              
        [BENEFICIARIO] AS [Benefici�rio],                                                                        
        [MOTORISTA] AS [Motorista],  
		[TIPOFROTA] AS [Tipo Frota],                                                                  
        ISNULL([LINHA],'') AS [Linha],                                                                               
        [FRETEMINIMO] AS [Frete M�nimo], 
		SUM(ISNULL([TOTALFRETET2],TOTALFRETED)) AS [Total Frete],  
		(SUM(ISNULL([TOTALFRETET2],TOTALFRETED))-SUM(ISNULL([FRETEMINIMO],0))) AS [Diferen�a Frete],
		ISNULL((SUM(ISNULL([TOTALFRETET2],TOTALFRETED))/SUM(NULLIF([FRETEMINIMO],0))),0) AS [Diferen�a Frete %],
        ISNULL([VEICULOPUXADOR],'') AS [Ve�culo Puxador],
        ISNULL([REBOQUE1],'') AS [Reboque 01],
        ISNULL([REBOQUE2],'') AS [Reboque 02],
        ISNULL([TIPOCLASSIFICACAOROTA],'') AS [Tipo Classifica��o Rota],
		[KMCONSIDERADO] AS [KM Considerado],
		ROUND(CASE
			WHEN (SUM(ISNULL([RECEITACOLETA],0)) + ISNULL([RECEITAENTREGA],0)) = 0 THEN SUM(ISNULL([TOTALFRETET2],TOTALFRETED))
		ELSE (SUM(ISNULL([RECEITACOLETA],0)) + ISNULL([RECEITAENTREGA],0))
		END,2) AS [Total Receita], 
		SUM(ISNULL([RECEITACOLETA],0)) AS [Receita Coleta],
		CAST([RECEITAENTREGA] AS NUMERIC(10,2)) AS [Receita Entrega],
		ROUND(SUM(ISNULL([PESOREAL],0)),2) AS [Peso Real],
		ROUND(SUM(ISNULL([PESOCUBADO],0)),2) AS [Peso Cubado],
		IIF(ISNULL(PESOCONSIDERADOT4,0) + ROUND(SUM(ISNULL([PESOCOLETAREALIZADO],0)),2) = 0,SUM(ISNULL([PESOREAL],0)), ISNULL(PESOCONSIDERADOT4,0) + ROUND(SUM(ISNULL([PESOCOLETAREALIZADO],0)),2))  AS PESOCONSIDERADO,
		--ROUND(IIF(SUM([PESOCONSIDERADO]) = 0, SUM(ISNULL([PESOREAL],0)),SUM([PESOCONSIDERADO])),2) AS [Peso Considerado],
		SUM(ISNULL([QUANTIDADECOLETA],0)) AS [Quantidade Coleta],		
		ISNULL([QUANTIDADEENTREGA],0) AS [Quantidade de Entrega],
		ROUND(SUM([PESOCONSIDERADOENTREGA]),2) AS [Peso Considerado Entrega],
		SUM(ISNULL([QUANTIDADECOLETAREALIZADA],0)) AS [Quantidade de Coleta Realizada],
		ISNULL([QUANTIDADEENTREGAREALIZADA],0) AS [Quantidade de Entrega Realizada],		
		ROUND(SUM(ISNULL([PESOCOLETAREALIZADO],0)),2) AS [Peso Coleta Realizada],		
		ROUND(SUM(ISNULL([PESOENTREGAREALIZADO],0)),2) AS [Peso Entrega Realizada],
		[CAPACIDADE] AS [Capacidade],
		--Ocupa��o % (formula:  Peso coleta realizada + peso entrega realizada)/capacidade) e 
		ROUND(((ROUND(SUM(ISNULL([PESOCOLETAREALIZADO],0)),2) + ROUND(SUM(ISNULL([PESOENTREGAREALIZADO],0)),2))/NULLIF([CAPACIDADE],0)),2) AS [Ocupa��o %],
		[VALORCONTRATOFRETE] AS [Valor Contrato Frete],
		ROUND(((NULLIF(ISNULL(VALORCONTRATOFRETE,0),0)/NULLIF(SUM(ISNULL(PESOCOLETAREALIZADO,0)) + SUM(ISNULL([PESOENTREGAREALIZADO],0)),0))*SUM(ISNULL(PESOCOLETAREALIZADO,0))),2) AS [Custo Coleta],
		ROUND(((NULLIF(ISNULL(VALORCONTRATOFRETE,0),0)/NULLIF(SUM(ISNULL(PESOCOLETAREALIZADO,0)) + SUM(ISNULL([PESOENTREGAREALIZADO],0)),0))*SUM(ISNULL([PESOENTREGAREALIZADO],0))),2) AS [Custo Entrega],
		--�Custo Total por Receita %� (formula: valor contrato frete/Total frete) tabela abaixo com valores calculados 
		ROUND((ISNULL(VALORCONTRATOFRETE,0)/SUM(ISNULL(NULLIF([TOTALFRETET2],0),NULLIF(TOTALFRETED,0)))),2) AS [Custo Total por Receita %],
		--SUM(ISNULL([TOTALFRETET2],TOTALFRETED))),2) AS [Custo Total por Receita %],
		--SUM(ISNULL([TOTALFRETET2],TOTALFRETED))),2) AS [Custo Total por Receita %],
		(SUM(ISNULL(VOLUME, 0))+ ISNULL([VOLUMEENTREGA],0)) AS [Volume realizado],
		SUM(ISNULL([VOLUMECOLETA],0)) AS [Volume Coleta Realizada],
		ISNULL([VOLUMEENTREGA],0) AS [Volume Entrega Realizada],
		ISNULL(SUM([VOLUMECARREGADO]),0) AS [Volume Carregado Sem Coleta],
		[BLOQUEADA] AS [Bloqueada],
		SUM(ISNULL(VALORMERCADORIA,0)) AS [Valor Mercadoria],
		VALORBLOQUEIO AS [Valor Bloqueio],		                                                                                                                                                                                                                  
        [MOTIVO] AS [Motivo],
        [OBSERVACAO] AS [Observa��o],
        [USUARIO] AS [Usu�rio],
        ISNULL([SUBTIPOVIAGEM],'') AS [SubTipo],
        ISNULL([TIPOVEICULO],'') AS [Tipo Ve�culo],
		[ITINERANTE] AS [Itinerante],
		[VALORKM] AS [CF KM],
		GENERALIDADES AS [CF Generalidades],
		DIARIA AS [CF Diaria],
		PRODUTIVIDADE AS [CF Produtividade],
		TARIFAADD AS [CF Tarifa ADD],
		FRETEVEICULO AS [CF Frete Veiculo],
		DESCONTOS AS [CF Desconto],
		ISNULL(OBSERVACAOCONTRATOFRETE,'') AS [CF Observa��o Tarifa ADD]

FROM (

SELECT  DISTINCT 
		V.NUMEROVIAGEM AS [NUMEROVIAGEM],                                                                        
        V.INICIOEFETIVO AS [INICIOEFETIVO],                                                                
        STATUSVIAGEM.NOME AS [STATUSVIAGEM],
        TPV.NOME AS [TIPOVIAGEM],  
		T5.OBSERVACAO AS OBSERVACAOCONTRATOFRETE,                                                                  
        FRETE.NUMERO AS [NUMEROCONTRATOFRETE],                                                           
        FRETE.DATAEMISSAO AS [DATACONTRATOFRETE],                                                      
        STFRETE.NOME AS [STATUSCONTRATOFRETE],                                                           
        FO.SIGLA AS [ORIGEM],                                                                               
        FD.SIGLA AS [DESTINO],                                                                              
        BENEFICIARIO.NOME AS [BENEFICIARIO],                                                                        
        VMOT.NOME AS [MOTORISTA],                                                                    
        CASE VEICULO01.ORIGEM                                                                                                                                                                                                             
                    WHEN 1 Then 'Pr�prio'                                                                                                                                                                                                         
                    WHEN 2 Then 'Terceiro/Agregado'                                                                                                                                                                                        
                    WHEN 3 Then 'N�o integra frota'                                                                                                                                                                                        
        END AS [TIPOFROTA],                                                                     
        LINHA.NOME AS [LINHA],                                                                               
        ISNULL(V.K_VALORMINIMOFRETE,0) AS [FRETEMINIMO], 
		T2.VALORFRETE  as [TOTALFRETET2],
		SUM(D.VALORCONTABIL) AS [TOTALFRETED],	
        VEICULO01.PLACANUMERO AS [VEICULOPUXADOR],
        VEICULO02.PLACANUMERO AS [REBOQUE1],
        VEICULO03.PLACANUMERO AS [REBOQUE2],
        CLASSFROTA.NOME AS [TIPOCLASSIFICACAOROTA],
		ISNULL(V.DISTANCIACONSIDERADA, V.DISTANCIATOTAL) AS [KMCONSIDERADO],
		(ISNULL(T2.VALORFRETE, 0) + ISNULL(SUM(DISTINCT T3.VALORTOTALRECEBER),0)) AS [TOTALRECEITA],
		SUM(T2.VALORFRETE) AS [RECEITACOLETA],
		SUM(DISTINCT ISNULL(T3.VALORTOTALRECEBER,0)) AS [RECEITAENTREGA],
		(SUM(ISNULL(D.DOCCLIPESOTOTAL,0)) + SUM(ISNULL(T2.PESO,0))) AS [PESOREAL],
		(SUM(ISNULL(D.DOCCLIPESOCUBADOTOTAL,0)) + SUM(ISNULL(T2.PESOCUBADO,0))) AS [PESOCUBADO],
		CAST((IsNull(T3.TOTAL, 0) + SUM(ISNULL(T2.PESOCONSIDERADO,0))) AS DECIMAL(10,3)) AS [PESOCONSIDERADO], 	
		ISNULL(T4.TOTALPESOCONSIDERADOT4,0) AS PESOCONSIDERADOT4,	
		SUM(T2.QUANTIDADECOLETA) AS [QUANTIDADECOLETA],
		T3.HANDLE  AS [QUANTIDADEENTREGAREALIZADA],
		IsNull(SUM(IIF(D.DOCCLIPESOCUBADOTOTAL > D.DOCCLIPESOTOTAL, D.DOCCLIPESOCUBADOTOTAL, D.DOCCLIPESOTOTAL)), 0) AS [PESOCONSIDERADOENTREGA],	
		COUNT(DISTINCT T2.COLETA) AS [QUANTIDADECOLETAREALIZADA],
		T4.QUANTIDADEDEENTREGA AS [QUANTIDADEENTREGA],
		SUM(T2.PESOCONSIDERADO) AS [PESOCOLETAREALIZADO],
		CASE
			WHEN DV.SITUACAO = 209 THEN IsNull(SUM(IIF(D.DOCCLIPESOCUBADOTOTAL > D.DOCCLIPESOTOTAL, D.DOCCLIPESOCUBADOTOTAL, D.DOCCLIPESOTOTAL)), 0)
		ELSE 0
		END AS [PESOENTREGAREALIZADO],
		VEICULO01.CAPACIDADE AS [CAPACIDADE],
		CONVERT(DECIMAL(14,2),(ISNULL(SUM(D.DOCCLIPESOCONSIDERADO),0) / NULLIF(VEICULO01.CAPACIDADE, 0))*100) AS [OCUPACAOPESOCONSIDERADOPERCENT],
		FRETE.VALORTOTAL AS [VALORCONTRATOFRETE],
		SUM(T10.VOLUMECOLETA) AS [VOLUME],
		SUM(T10.VOLUMECOLETA) AS [VOLUMECOLETA],
		T11.VOLUMEENTREGA AS [VOLUMEENTREGA],

		--ISNULL(T4.VOLUMECARREGADOS,0) AS [VOLUMECARREGADO],
		(SUM(ISNULL(T2.VOLUME,0)) + SUM(ISNULL(D.DOCCLIVOLUME,0))) AS [VOLUMECARREGADO],
		
		IIF(VB.HANDLE Is Null, 'N�o', 'Sim') AS [BLOQUEADA],
		(SUM(ISNULL(D.DOCCLIVALORTOTAL,0))+SUM(ISNULL(T2.VALORMERCADORIA,0))) AS VALORMERCADORIA,
		ISNULL(VB.VALORBLOQUEIO,0) AS VALORBLOQUEIO,		                                                                                                                                                                                                                  
        ISNULL(VCM.DESCRICAO,'') AS [MOTIVO],
        ISNULL(VB.OBSERVACAOAUTORIZACAO,'') AS [OBSERVACAO],
        ISNULL(USUARIO.NOME,'') AS [USUARIO],
        SBV.NOME AS [SUBTIPOVIAGEM],
        VEICTIPO.NOME AS [TIPOVEICULO],
		IIF(CALC.QUILOMETRAGEM>0, 'Sim', 'N�o') [ITINERANTE],
		CALC.QUILOMETRAGEM AS [VALORKM],
		CALC.GENERALIDADES AS GENERALIDADES,
		CALC.DIARIA AS DIARIA,
		CALC.PRODUTIVIDADE AS PRODUTIVIDADE,
		CALC.QUILOMETRAGEM AS QUILOMETRAGEM,
		CALC.TARIFAADD AS TARIFAADD,
		CALC.FRETEVEICULO AS FRETEVEICULO,
		CALC.DESCONTOS AS DESCONTOS

FROM GLOP_VIAGENS V                                                                                                                                                                                     
LEFT JOIN GLGL_SUBTIPOVIAGENS SBV
	ON SBV.HANDLE = V.SUBTIPOVIAGEM  

INNER JOIN GLOP_VIAGEMDOCUMENTOS DV
	ON DV.VIAGEM = V.HANDLE

LEFT JOIN GLGL_DOCUMENTOS D
	ON DV.DOCUMENTOLOGISTICA = D.HANDLE
	                                                                                  
JOIN GLGL_ENUMERACAOITEMS TPV
	ON TPV.HANDLE = V.TIPOVIAGEM                                                                                             

JOIN GLGL_ENUMERACAOITEMS STATUSVIAGEM    
	ON STATUSVIAGEM.HANDLE = V.STATUS

JOIN GN_PESSOAS VMOT                
	ON VMOT.HANDLE = V.MOTORISTA 
	                                                                                       
LEFT JOIN GLOP_CONTRATOFRETEVIAGENS VFRETE       
	ON VFRETE.VIAGEM = V.Handle
                                                                                                                                                                    
INNER JOIN GLOP_CONTRATOFRETES FRETE               
	ON FRETE.HANDLE = VFRETE.CONTRATOFRETE                                                                               
    AND FRETE.Status Not In (262, 433, 731)   
                                                                                                                                                                                                               
LEFT JOIN 
	(
			SELECT 
					CONTRATOFRETE,
					SUM(GENERALIDADES) AS GENERALIDADES,
					SUM(DIARIA) AS DIARIA,
					SUM(PRODUTIVIDADE) AS PRODUTIVIDADE,
					SUM(QUILOMETRAGEM) AS QUILOMETRAGEM,
					SUM(TARIFAADD) AS TARIFAADD,
					SUM(FRETEVEICULO) AS FRETEVEICULO,
					SUM(DESCONTOS) AS DESCONTOS
			FROM (
			SELECT DISTINCT 
					CONTRATOFRETE,
					CASE
						WHEN CLASSIFICACAO = 7 THEN SUM(VALORFINAL)
					ELSE 0
					END AS GENERALIDADES,
					CASE
						WHEN CLASSIFICACAO = 8 THEN SUM(VALORFINAL)
					ELSE 0
					END AS DIARIA,
					CASE
						WHEN CLASSIFICACAO = 9 THEN SUM(VALORFINAL)
					ELSE 0
					END AS PRODUTIVIDADE,
					CASE
						WHEN CLASSIFICACAO = 10 THEN SUM(ISNULL(VALORFINAL,0))
					ELSE 0
					END AS QUILOMETRAGEM,
					CASE
						WHEN CLASSIFICACAO = 13 THEN SUM(VALORFINAL)
					ELSE 0
					END AS TARIFAADD,
					CASE
						WHEN CLASSIFICACAO = 14 THEN SUM(VALORFINAL)
					ELSE 0
					END AS FRETEVEICULO,
					CASE
						WHEN CLASSIFICACAO = 15 THEN SUM(VALORFINAL)
					ELSE 0
					END AS DESCONTOS


			FROM GLOP_CONTRATOFRETCALCULOS

			GROUP BY CONTRATOFRETE, CLASSIFICACAO
			) AS T1

			GROUP BY CONTRATOFRETE
	)AS CALC						 
	ON CALC.CONTRATOFRETE = FRETE.HANDLE



LEFT JOIN GLGL_ENUMERACAOITEMS STFRETE                    
	ON STFRETE.HANDLE = FRETE.STATUS  
	                                                                                            
JOIN GLGL_FILIAIS FO                         
	ON FO.HANDLE = V.FILIALORIGEM   
	                                                                                  
JOIN GLGL_FILIAIS FD                         
	ON FD.HANDLE = V.FILIALDESTINO   
	                                                                                 
JOIN MA_RECURSOS VEICULO01           
	ON VEICULO01.HANDLE = V.VEICULO1                                                                                         

LEFT JOIN MF_VEICULOTIPOS VEICTIPO            
	ON VEICTIPO.HANDLE = VEICULO01.TIPOVEICULO                                                                              

LEFT JOIN K_MF_TIPOCLASSIFICACAOFROTA CLASSFROTA
	ON CLASSFROTA.HANDLE = VEICULO01.K_TIPOCLASSIFICACAO
	                                                               
LEFT JOIN MA_RECURSOS VEICULO02           
	ON VEICULO02.HANDLE           = V.VEICULO2                                                                                         

LEFT JOIN MA_RECURSOS VEICULO03           
	ON VEICULO03.HANDLE = V.VEICULO3   
	                                                                                      
JOIN GN_PESSOAS BENEFICIARIO  
	ON BENEFICIARIO.HANDLE = FRETE.BENEFICIARIO 
	                                                                   
LEFT JOIN GLOP_LINHAVIAGENS LINHA               
	ON LINHA.HANDLE = V.LINHAVIAGEM   
	                                                                                          
LEFT JOIN K_GLOP_LINHAVIAGEMLIMITES LVL                        
	ON LVL.LINHAVIAGEM            = LINHA.HANDLE                                                                                              
	AND LVL.TIPOTERCEIRO = VEICULO01.TIPOFROTAAGREGADA                                                                  
	AND LVL.TIPOVEICULO = VEICULO01.TIPOVEICULO
                                                                              
LEFT JOIN K_GLOP_VIAGEMBLOQUEIOS VB 
	ON VB.VIAGEM = V.HANDLE                                                                                                  
	AND NOT VB.STATUS = 61                                                                                                       

LEFT JOIN K_GLOP_VIAGEMCUSTOMOTIVOS VCM                        
	ON VCM.HANDLE = VB.MOTIVOLIBERACAO
	                                                                        
LEFT JOIN Z_GRUPOUSUARIOS USUARIO 
	ON USUARIO.HANDLE = VB.USUARIOAPROVACAO 

LEFT JOIN (
				
				SELECT
					 COLETA,  
					 SUM(VALORFRETE) AS VALORFRETE,
					 SUM(PESO) AS PESO,
					 SUM(PESOCUBADO) AS PESOCUBADO, 
					 SUM(PESOCONSIDERADO) AS PESOCONSIDERADO,
					 SUM(QUANTIDADECOLETA) AS QUANTIDADECOLETA,
					 SUM(PESOCOLETAREALIZADO) AS PESOCOLETAREALIZADO,
					 SUM([VOLUME]) AS [VOLUME],
					 SUM([VALORMERCADORIA]) AS [VALORMERCADORIA]

				FROM(

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
									--AND CP.HANDLE = 2177518
					                                                                                                      
								GROUP BY CP.HANDLE,  
										 DL.NUMERO,                                                                                                                                                                                     
										 DL.VALORTOTALRECEBER,
										 DL.DOCCLIPESOTOTAL,
										 DL.DOCCLIPESOCUBADOTOTAL, 
										 DL.DOCCLIPESOCONSIDERADO,
										 DL.DOCCLIPESOCONSIDERADO,
										 DL.DOCCLIVOLUME,
										 DL.DOCCLIVALORTOTAL
				) T

				GROUP BY COLETA

		  ) AS T2 ON T2.COLETA = DV.DOCUMENTOCOLETA
		  AND DV.SITUACAO = 209
			

LEFT JOIN (
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
				AND PAGARFORNECEDOR = 'S'  
				                                                                                                                  
			INNER JOIN GLGL_DOCUMENTOS DL     
				ON DL.HANDLE = VD.DOCUMENTOLOGISTICA                                                                                            

			WHERE VD.TIPOSERVICO = 197       

			GROUP BY VD.VIAGEM
		  ) AS T3 ON T3.VIAGEM = V.HANDLE
LEFT JOIN 
		(
			SELECT 
					VD.VIAGEM,
					COUNT(DISTINCT DL.HANDLE) AS QUANTIDADEDEENTREGA,
					SUM(DL.DOCCLIVOLUME) AS VOLUMECARREGADOS,
					SUM(DL.DOCCLIVALORTOTAL) AS [VALORMERCADORIAENTREGA],
					SUM(IIF(DOCCLIPESOCUBADOTOTAL > DOCCLIPESOTOTAL, DOCCLIPESOCUBADOTOTAL, DOCCLIPESOTOTAL))  AS TOTALPESOCONSIDERADOT4
			FROM GLOP_VIAGEMDOCUMENTOS VD

			INNER JOIN GLOP_OCORRENCIAS OC     
				ON OC.HANDLE = VD.OCORRENCIA 

			INNER JOIN GLOP_MOTIVOOCORRENCIAS MOC 
				ON MOC.HANDLE = OC.OCORRENCIA                                                                                                          
				--AND PAGARFORNECEDOR = 'S'  
				                                                                                                                  
			INNER JOIN GLGL_DOCUMENTOS DL     
				ON DL.HANDLE = VD.DOCUMENTOLOGISTICA                                                                                            

			WHERE VD.TIPOSERVICO = 197     

			GROUP BY VD.VIAGEM
		) AS T4 ON T4.VIAGEM = V.HANDLE
LEFT JOIN 
		(
			SELECT  
				MAX(HANDLE) AS HANDLE
				,CONTRATOFRETE
				--,OBSERVACAO
				,MAX(DATAHORA) AS [DATA] 
	
			FROM GLOP_FRETECOMBINADOLOGS T
			GROUP BY CONTRATOFRETE
		) AS FRETECOMBINADOLOGS
	ON FRETE.HANDLE = FRETECOMBINADOLOGS.CONTRATOFRETE

LEFT JOIN GLOP_FRETECOMBINADOLOGS T5
	ON FRETECOMBINADOLOGS.CONTRATOFRETE = T5.CONTRATOFRETE
	AND FRETECOMBINADOLOGS.HANDLE = T5.HANDLE

LEFT JOIN
		(
			SELECT
				 COLETA,  
				 SUM([VOLUME]) AS [VOLUMECOLETA]

			FROM(

			SELECT		CP.HANDLE COLETA,  
							
										DL.DOCCLIVOLUME AS [VOLUME]                                                                                                               
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
								
					                                                                                                      
							GROUP BY CP.HANDLE,  
									 DL.NUMERO,                                                                                                                                                                                     
									 DL.VALORTOTALRECEBER,
									 DL.DOCCLIPESOTOTAL,
									 DL.DOCCLIPESOCUBADOTOTAL, 
									 DL.DOCCLIPESOCONSIDERADO,
									 DL.DOCCLIPESOCONSIDERADO,
									 DL.DOCCLIVOLUME,
									 DL.DOCCLIVALORTOTAL
			) T

			GROUP BY COLETA
		) AS T10
	ON T10.COLETA = DV.DOCUMENTOCOLETA

LEFT JOIN (
			SELECT  
						VIAGEM
						,SUM(VOLUMEENTREGA) AS VOLUMEENTREGA

				FROM (
					SELECT 
										VD.VIAGEM,
										DL.DOCCLIVOLUME AS VOLUMEENTREGA

								FROM GLOP_VIAGEMDOCUMENTOS VD

								INNER JOIN GLOP_OCORRENCIAS OC     
									ON OC.HANDLE = VD.OCORRENCIA 

								INNER JOIN GLOP_MOTIVOOCORRENCIAS MOC 
									ON MOC.HANDLE = OC.OCORRENCIA                                                                                                          
									AND PAGARFORNECEDOR = 'S'  
				                                                                                                                  
								INNER JOIN GLGL_DOCUMENTOS DL     
									ON DL.HANDLE = VD.DOCUMENTOLOGISTICA   

								WHERE VD.TIPOSERVICO = 197     
						) AS T

					GROUP BY VIAGEM
		   ) AS T11
	ON T11.VIAGEM = V.HANDLE 

WHERE 1 = 1                                                                                                                                                                                                                                       
And Convert(Date, v.INICIOEFETIVO) >= '2019-07-03' 
And Convert(Date, v.INICIOEFETIVO) < '2019-07-04'
--AND V.NUMEROVIAGEM IN 
--													(
--													'2019/159690-27'
--													,'2019/204046-363'
--													,'2019/205100-2'
--													,'2019/207382-7'
--													,'2019/208659-7'
--													,'2019/209934-38'
--													)
GROUP BY 
		V.NUMEROVIAGEM,                                                                        
		V.INICIOEFETIVO,                                                                
		STATUSVIAGEM.NOME,
		TPV.NOME,
		T5.OBSERVACAO,                                                                    
		FRETE.NUMERO,                                                           
		FRETE.DATAEMISSAO,                                                      
		STFRETE.NOME,                                                           
		FO.SIGLA,                                                                               
		FD.SIGLA,                                                                              
		BENEFICIARIO.NOME,                                                                        
		VMOT.NOME,                                                                    
		CASE VEICULO01.ORIGEM                                                                                                                                                                                                             
					WHEN 1 Then 'Pr�prio'                                                                                                                                                                                                         
					WHEN 2 Then 'Terceiro/Agregado'                                                                                                                                                                                        
					WHEN 3 Then 'N�o integra frota'                                                                                                                                                                                        
		END,                                                                     
		LINHA.NOME,          
		LVL.VALOR,                                                                     
		ISNULL(V.K_VALORMINIMOFRETE,0), 
		VEICULO01.PLACANUMERO,
		VEICULO02.PLACANUMERO,
		VEICULO03.PLACANUMERO,
		CLASSFROTA.NOME,
		ISNULL(V.DISTANCIACONSIDERADA, V.DISTANCIATOTAL),
		DV.SITUACAO,
		VEICULO01.CAPACIDADE,
		FRETE.VALORTOTAL,
		T3.TOTAL,
		T3.HANDLE,
		V.TIPOVIAGEM,
		T3.PESOTOTALCONSIDERADO,
		T3.VALORTOTALRECEBER,
		IIF(VB.HANDLE Is Null, 'N�o', 'Sim'),
		 VB.VALORBLOQUEIO,                                                                                                                                                                                                            
         VCM.DESCRICAO,
         VB.OBSERVACAOAUTORIZACAO,
         USUARIO.NOME,
         SBV.NOME,
         VEICTIPO.NOME,
		 CALC.QUILOMETRAGEM,
		 CALC.GENERALIDADES,
		 CALC.DIARIA,
		 CALC.PRODUTIVIDADE,
		 CALC.QUILOMETRAGEM,
		 CALC.TARIFAADD,
		 CALC.FRETEVEICULO,
		 CALC.DESCONTOS,
		 V.HANDLE,
		 T2.VALORFRETE,
		 T4.QUANTIDADEDEENTREGA,
		 T4.VALORMERCADORIAENTREGA,
		 T11.VOLUMEENTREGA,
		 ISNULL(T4.VOLUMECARREGADOS,0),
		 ISNULL(T4.TOTALPESOCONSIDERADOT4,0)
) AS T1

GROUP BY
[NUMEROVIAGEM],                                                                        
        [INICIOEFETIVO],                                                                
        [STATUSVIAGEM],
        [TIPOVIAGEM],
		OBSERVACAOCONTRATOFRETE,                                                                   
        [NUMEROCONTRATOFRETE],                                                           
        [DATACONTRATOFRETE],                                                      
        [STATUSCONTRATOFRETE],                                                           
        [ORIGEM],                                                                               
        [DESTINO],                                                                              
        [BENEFICIARIO],                                                                        
        [MOTORISTA], 
		[TIPOFROTA],                                                                   
        [LINHA],                                                                               
        [FRETEMINIMO], 
        [VEICULOPUXADOR],
        [REBOQUE1],
        [REBOQUE2],
        [TIPOCLASSIFICACAOROTA],
		[KMCONSIDERADO],
		[RECEITAENTREGA],
		[QUANTIDADEENTREGAREALIZADA],
		[CAPACIDADE],
		[VALORCONTRATOFRETE],
		[BLOQUEADA],
		VALORBLOQUEIO,                                                                                                                                                                                                                  
        [MOTIVO],
        [OBSERVACAO],
        [USUARIO],
        [SUBTIPOVIAGEM],
        [TIPOVEICULO],
		[ITINERANTE],
		[VALORKM],
		GENERALIDADES,
		DIARIA,
		PRODUTIVIDADE,
		TARIFAADD,
		FRETEVEICULO,
		DESCONTOS,
		ISNULL([QUANTIDADEENTREGA],0),
		[VOLUMEENTREGA],
		ISNULL(PESOCONSIDERADOT4,0)