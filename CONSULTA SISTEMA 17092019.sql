SELECT  DISTINCT 
		V.NUMEROVIAGEM AS [NUMEROVIAGEM],                                                                        
        V.INICIOEFETIVO AS [INICIOEFETIVO],                                                                
        STATUSVIAGEM.NOME AS [STATUSVIAGEM],
        TPV.NOME AS [TIPOVIAGEM],                                                                    
        FRETE.NUMERO AS [NUMEROCONTRATOFRETE],                                                           
        FRETE.DATAEMISSAO AS [DATACONTRATOFRETE],                                                      
        STFRETE.NOME AS [STATUSCONTRATOFRETE],                                                           
        FO.SIGLA AS [ORIGEM],                                                                               
        FD.SIGLA AS [DESTINO],                                                                              
        BENEFICIARIO.NOME AS [BENEFICIARIO],                                                                        
        VMOT.NOME AS [MOTORISTA],                                                                    
        CASE VEICULO01.ORIGEM                                                                                                                                                                                                             
                    WHEN 1 Then 'Próprio'                                                                                                                                                                                                         
                    WHEN 2 Then 'Terceiro/Agregado'                                                                                                                                                                                        
                    WHEN 3 Then 'Não integra frota'                                                                                                                                                                                        
        END AS [TIPOFROTA],                                                                     
        LINHA.NOME AS [LINHA],                                                                               
        ISNULL(LVL.VALOR,0) AS [FRETEMINIMO], 
		SUM(D.VALORCONTABIL) as [TOTALFRETE], 
		ISNULL(Convert(Decimal(14, 2), (LVL.VALOR - SUM(D.VALORCONTABIL))),0) AS [DIFERENCAFRETE],
	    ISNULL(Convert(Decimal(14, 2), (LVL.VALOR - SUM(D.VALORCONTABIL))*100),0) AS [DIFERENCAFRETEPERCENT],
        VEICULO01.PLACANUMERO AS [VEICULOPUXADOR],
        VEICULO02.PLACANUMERO AS [REBOQUE1],
        VEICULO03.PLACANUMERO AS [REBOQUE2],
        CLASSFROTA.NOME AS [TIPOCLASSIFICACAOROTA],
		ISNULL(LINHA.HANDLE, ISNULL(V.DISTANCIACONSIDERADA, V.DISTANCIATOTAL)) AS [KMCONSIDERADO],
		(SUM(T2.VALORFRETE) + SUM(DISTINCT T3.VALORTOTALRECEBER)) AS [TOTALRECEITA],
		SUM(T2.VALORFRETE) AS [RECEITACOLETA],
		SUM(DISTINCT T3.VALORTOTALRECEBER) AS [RECEITAENTREGA],
		(SUM(D.DOCCLIPESOTOTAL) + SUM(T2.PESO)) AS [PESOREAL],
		(SUM(D.DOCCLIPESOCUBADOTOTAL) + SUM(T2.PESOCUBADO)) AS [PESOCUBADO],

		CAST((IsNull(T3.TOTAL, 0) + SUM(T2.PESOCONSIDERADO)) AS DECIMAL(10,3)) AS [PESOCONSIDERADO], 
		
		SUM(T2.QUANTIDADECOLETA) AS [QUANTIDADECOLETA],

		T3.HANDLE  AS [QUANTIDADEENTREGA],
				

		IIF(SUM(T2.PESOCUBADO)>SUM(T2.PESO), SUM(T2.PESOCUBADO), SUM(T2.PESO)) AS [PESOCONSIDERADOCOLETA],

		IsNull(T3.TOTAL, 0) AS [PESOCONSIDERADOENTREGA],
		
		COUNT(DISTINCT T2.COLETA) AS [QUANTIDADECOLETAREALIZADA],

		CASE
			WHEN DV.SITUACAO = 209 THEN T3.HANDLE
		ELSE 0
		END AS [QUANTIADADEENTREGAREALIZADA],

		SUM(T2.PESOCONSIDERADO) AS [PESOCOLETAREALIZADO],
		
		CASE
			WHEN DV.SITUACAO = 209 THEN T3.TOTAL
		ELSE 0
		END AS [PESOENTREGAREALIZADO],

		VEICULO01.CAPACIDADE AS [CAPACIDADE],

		CONVERT(DECIMAL(14,2),(ISNULL(SUM(D.DOCCLIPESOCONSIDERADO),0) / NullIf(VEICULO01.CAPACIDADE, 0))*100) AS [OCUPACAOPESOCONSIDERADOPERCENT],

		FRETE.VALORTOTAL AS [VALORCONTRATOFRETE],


		CONVERT(DECIMAL(14,2),((FRETE.VALORTOTAL/((IIF(V.TIPOVIAGEM = 173, Sum(T2.PESO), Count(Distinct T2.COLETA))+ T3.TOTAL)))*(IIF(V.TIPOVIAGEM = 173, Sum(T2.PESO), Count(Distinct T2.COLETA))))) AS CUSTOCOLETA,
		
		CONVERT(DECIMAL(14,2),((FRETE.VALORTOTAL/((IIF(V.TIPOVIAGEM = 173, Sum(T2.PESO), Count(Distinct T2.COLETA))+ T3.TOTAL)))*(IIF(V.TIPOVIAGEM = 173, T3.TOTAL, Count(Distinct T2.COLETA))))) AS CUSTOENTREGA,

		CONVERT(DECIMAL(14,2),((FRETE.VALORTOTAL/(SUM(T2.VALORFRETE)+(T3.VALORTOTALRECEBER)))*100)) AS [CUSTOTOTALRECEITAPERCENT],

		SUM(T2.VOLUME) AS [VOLUME],

		IIF(VB.HANDLE Is Null, 'Não', 'Sim') AS [BLOQUEADA],

		(SUM(D.DOCCLIVALORTOTAL)+SUM(T2.VALORMERCADORIA)) AS VALORMERCADORIA,

		VB.VALORBLOQUEIO AS VALORBLOQUEIO,
		                                                                                                                                                                                                                  
        VCM.DESCRICAO AS [MOTIVO],

        VB.OBSERVACAOAUTORIZACAO AS [OBSERVACAO],

        USUARIO.NOME AS [USUARIO],

        SBV.NOME AS [SUBTIPOVIAGEM],

        VEICTIPO.NOME AS [TIPOVEICULO],

		IIF(EXISTS (
					SELECT 1                                                                                                                                                                
                    FROM GLOP_CONTRATOFRETCALCULOS CFC                                                                                                                                      
						INNER JOIN GLCM_LEIAUTETACOMPONENTES LC 
							ON LC.HANDLE = CFC.COMPONENTETARIFA
						INNER JOIN GLCM_COMPONENTECALCULOS CC       
							ON CC.HANDLE = LC.COMPONENTECALCULO                                                                 
						INNER JOIN GLOP_CONTRATOFRETES CF       
							ON CF.HANDLE = CFC.CONTRATOFRETE                                                                    
						INNER JOIN GLOP_CONTRATOFRETEVIAGENS CFV 
							ON CFV.CONTRATOFRETE   = CF.HANDLE                                                                                   
                    WHERE CC.CLASSIFICACAO = 10                                                                  
                    AND CFV.VIAGEM = V.HANDLE), 'Sim', 'Não') [ITINERANTE],


		CALC.QUILOMETRAGEM AS [VALORKM],

		CALC.GENERALIDADES AS GENERALIDADES,

		CALC.DIARIA AS DIARIA,

		CALC.PRODUTIVIDADE AS PRODUTIVIDADE,

		CALC.QUILOMETRAGEM AS QUILOMETRAGEM,

		CALC.TARIFAADD AS TARIFAADD,

		CALC.FRETEVEICULO AS FRETEVEICULO,

		CALC.DESCONTOS AS DESCONTOS,

		CALC.VALORFINAL AS VALORFINAL


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
                                                                                                                                                                                                               
JOIN 
	(
			SELECT 
					CONTRATOFRETE,
					SUM(GENERALIDADES) AS GENERALIDADES,
					SUM(DIARIA) AS DIARIA,
					SUM(PRODUTIVIDADE) AS PRODUTIVIDADE,
					SUM(QUILOMETRAGEM) AS QUILOMETRAGEM,
					SUM(TARIFAADD) AS TARIFAADD,
					SUM(FRETEVEICULO) AS FRETEVEICULO,
					SUM(DESCONTOS) AS DESCONTOS,
					SUM(VALORFINAL) AS VALORFINAL
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
						WHEN CLASSIFICACAO = 10 THEN SUM(VALORFINAL)
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
					END AS DESCONTOS,
					CASE
						WHEN CLASSIFICACAO = 10 THEN SUM(VALORFINAL)
					ELSE 0
					END AS VALORFINAL


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
	AND NOT VB.STATUS            = 61                                                                                                       

LEFT JOIN K_GLOP_VIAGEMCUSTOMOTIVOS VCM                        
	ON VCM.HANDLE = VB.MOTIVOLIBERACAO
	                                                                        
LEFT JOIN Z_GRUPOUSUARIOS USUARIO 
	ON USUARIO.HANDLE = VB.USUARIOAPROVACAO                                                                                                                                                                                                                                                                                      
               
LEFT JOIN GLOP_LINHAVIAGEMFILIAIS KM
	ON KM.LINHAVIAGEM = ISNULL(LINHA.HANDLE, ISNULL(V.DISTANCIACONSIDERADA, V.DISTANCIATOTAL))

--LEFT JOIN (
--			SELECT	
--				DISTINCT DA.DOCUMENTOLOGISTICA, DC.PEDIDOCOLETA 
			 
--			FROM [DBRodo].[dbo].[GLGL_DOCUMENTOASSOCIADOS] DA WITH(NOLOCK)
--			LEFT JOIN [DBRodo].[dbo].[GLGL_DOCUMENTOCLIENTES] DC WITH(NOLOCK)
--					ON DA.DOCUMENTOCLIENTE = DC.HANDLE
--			) AS T1 
--	ON D.HANDLE = T1.DOCUMENTOLOGISTICA

--LEFT JOIN GLOP_COLETAPEDIDOS CP 
--	ON CP.HANDLE = T1.PEDIDOCOLETA 

LEFT JOIN (
				SELECT		CP.HANDLE COLETA,                                                                                                                                                   
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
				GROUP BY CP.HANDLE,                                                                                                                                                                                       
						 DL.VALORTOTALRECEBER,
						 DL.DOCCLIPESOTOTAL,
						 DL.DOCCLIPESOCUBADOTOTAL, 
						 DL.DOCCLIPESOCONSIDERADO,
						 DL.DOCCLIPESOCONSIDERADO,
						 DL.DOCCLIVOLUME,
						 DL.DOCCLIVALORTOTAL


		  ) AS T2 ON T2.COLETA = DV.DOCUMENTOCOLETA
		          AND DV.SITUACAO = 209

INNER JOIN (
			SELECT 
					VD.VIAGEM,
					SUM(CONVERT(DECIMAL(14,3),DL.VALORTOTALRECEBER)) AS VALORTOTALRECEBER,
					SUM(CONVERT(DECIMAL(14,3),DL.DOCCLIPESOTOTAL)) AS DOCCLIPESOTOTAL,                                                                                                                                                                                           
                    SUM(CONVERT(DECIMAL(14,3),DL.DOCCLIPESOCUBADOTOTAL)) AS DOCCLIPESOCUBADOTOTAL,
					SUM(CONVERT(DECIMAL(14,3),DL.DOCCLIPESOCONSIDERADO)) AS PESOTOTALCONSIDERADO,
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



WHERE 1 = 1                                                                                                                                                                                                                                       
And Convert(Date, v.INICIOEFETIVO) Between '2019-07-01' And '2019-07-02'
AND V.NUMEROVIAGEM = '2019/178155-27'


GROUP BY 

		V.NUMEROVIAGEM,                                                                        
		V.INICIOEFETIVO,                                                                
		STATUSVIAGEM.NOME,
		TPV.NOME,                                                                    
		FRETE.NUMERO,                                                           
		FRETE.DATAEMISSAO,                                                      
		STFRETE.NOME,                                                           
		FO.SIGLA,                                                                               
		FD.SIGLA,                                                                              
		BENEFICIARIO.NOME,                                                                        
		VMOT.NOME,                                                                    
		CASE VEICULO01.ORIGEM                                                                                                                                                                                                             
					WHEN 1 Then 'Próprio'                                                                                                                                                                                                         
					WHEN 2 Then 'Terceiro/Agregado'                                                                                                                                                                                        
					WHEN 3 Then 'Não integra frota'                                                                                                                                                                                        
		END,                                                                     
		LINHA.NOME,          
		LVL.VALOR,                                                                     
		ISNULL(LVL.VALOR,0), 
		VEICULO01.PLACANUMERO,
		VEICULO02.PLACANUMERO,
		VEICULO03.PLACANUMERO,
		CLASSFROTA.NOME,
		ISNULL(LINHA.HANDLE, ISNULL(V.DISTANCIACONSIDERADA, V.DISTANCIATOTAL)),
		DV.SITUACAO,
		VEICULO01.CAPACIDADE,
		FRETE.VALORTOTAL,
		T3.TOTAL,
		T3.HANDLE,
		V.TIPOVIAGEM,
		T3.PESOTOTALCONSIDERADO,
		T3.VALORTOTALRECEBER,
		IIF(VB.HANDLE Is Null, 'Não', 'Sim'),
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
		 CALC.VALORFINAL,
		 V.HANDLE