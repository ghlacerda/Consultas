SELECT distinct        
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


					   
					   IIF(      EXISTS (SELECT 1                                                                                                                                                                
                                                 FROM GLOP_CONTRATOFRETCALCULOS CFC                                                                                                                                      
                                                INNER JOIN GLCM_LEIAUTETACOMPONENTES    LC     ON LC.HANDLE                  = CFC.COMPONENTETARIFA                                                                        
                                               INNER JOIN GLCM_COMPONENTECALCULOS            CC       ON CC.HANDLE               = LC.COMPONENTECALCULO                                                                 
                                                INNER JOIN GLOP_CONTRATOFRETES                CF       ON CF.HANDLE               = CFC.CONTRATOFRETE                                                                    
                                                INNER JOIN GLOP_CONTRATOFRETEVIAGENS    CFV ON CFV.CONTRATOFRETE   = CF.HANDLE                                                                                   
                                                WHERE CC.CLASSIFICACAO                                                                              = 10                                                                  
                                                  AND CFV.VIAGEM                                                                                    = V.HANDLE), 'Sim', 'Não') [ITINERANTE],                                  
                       ISNULL((SELECT SUM(CALC.VALORFINAL)                                                                                                                                                                                        
                                         FROM GLOP_CONTRATOFRETCALCULOS CALC                                                                                                                                                                      
                                         WHERE CALC.CONTRATOFRETE = FRETE.HANDLE 
										 AND CALC.CLASSIFICACAO = 10),0)                                [VALORKM]                                             
					 --  ,CASE
						--	WHEN CALC.CLASSIFICACAO = 10 THEN SUM(CALC.VALORFINAL)
						--ELSE 0
						--END as a
               FROM GLOP_VIAGENS                                          V                                                                                                                                                                                     
               LEFT JOIN GLGL_SUBTIPOVIAGENS							  SBV                        ON SBV.HANDLE                 = V.SUBTIPOVIAGEM                                                                                    
               JOIN GLGL_ENUMERACAOITEMS                                  TPV                        ON TPV.HANDLE              = V.TIPOVIAGEM                                                                                             
               JOIN GLGL_ENUMERACAOITEMS                                  STATUSVIAGEM    ON STATUSVIAGEM.HANDLE = V.STATUS   
               JOIN GN_PESSOAS                                            VMOT                ON VMOT.HANDLE                = V.MOTORISTA                                                                                        
               LEFT JOIN GLOP_CONTRATOFRETEVIAGENS          VFRETE                                                                                                                                                                         
               INNER JOIN GLOP_CONTRATOFRETES               FRETE               ON FRETE.HANDLE                  = VFRETE.CONTRATOFRETE                                                                               
                                                                                                                AND FRETE.Status              Not In (262, 433, 731)                                                                               
                                                                                                                On VFRETE.VIAGEM       = V.Handle                                                                                                 
			   JOIN GLOP_CONTRATOFRETCALCULOS							  CALC						 ON CALC.CONTRATOFRETE = FRETE.HANDLE
               LEFT JOIN GLGL_ENUMERACAOITEMS               STFRETE                    ON STFRETE.HANDLE             = FRETE.STATUS                                                                                              
               JOIN GLGL_FILIAIS                                          FO                         ON FO.HANDLE               = V.FILIALORIGEM                                                                                     
               JOIN GLGL_FILIAIS                                          FD                         ON FD.HANDLE               = V.FILIALDESTINO                                                                                    
               JOIN MA_RECURSOS                                           VEICULO01           ON VEICULO01.HANDLE           = V.VEICULO1                                                                                         
               LEFT JOIN MF_VEICULOTIPOS                                  VEICTIPO            ON VEICTIPO.HANDLE            = VEICULO01.TIPOVEICULO                                                                              
               LEFT JOIN K_MF_TIPOCLASSIFICACAOFROTA        CLASSFROTA          ON CLASSFROTA.HANDLE       = VEICULO01.K_TIPOCLASSIFICACAO                                                               
               LEFT JOIN MA_RECURSOS                                      VEICULO02           ON VEICULO02.HANDLE           = V.VEICULO2                                                                                         
               LEFT JOIN MA_RECURSOS                                      VEICULO03           ON VEICULO03.HANDLE           = V.VEICULO3                                                                                         
               JOIN GN_PESSOAS                                            BENEFICIARIO  ON BENEFICIARIO.HANDLE = FRETE.BENEFICIARIO                                                                    
               LEFT JOIN GLOP_LINHAVIAGENS                         LINHA               ON LINHA.HANDLE               = V.LINHAVIAGEM                                                                                             
               LEFT JOIN K_GLOP_LINHAVIAGEMLIMITES          LVL                        ON LVL.LINHAVIAGEM            = LINHA.HANDLE                                                                                              
                                                                                                               AND LVL.TIPOTERCEIRO           = VEICULO01.TIPOFROTAAGREGADA                                                                  
                                                                                                               AND LVL.TIPOVEICULO            = VEICULO01.TIPOVEICULO                                                                              
               LEFT JOIN K_GLOP_VIAGEMBLOQUEIOS                    VB                         ON VB.VIAGEM                  = V.HANDLE                                                                                                  
                                                                        And Not VB.STATUS            = 61                                                                                                       
               LEFT JOIN K_GLOP_VIAGEMCUSTOMOTIVOS          VCM                        ON VCM.HANDLE              = VB.MOTIVOLIBERACAO                                                                           
               LEFT JOIN Z_GRUPOUSUARIOS                                  USUARIO                    ON USUARIO.HANDLE          = VB.USUARIOAPROVACAO                                                                                                                                                                                                                                                                                      
               
			   INNER JOIN GLOP_VIAGEMDOCUMENTOS DV
					ON DV.VIAGEM = V.HANDLE
			   INNER JOIN GLGL_DOCUMENTOS D
					ON DV.DOCUMENTOLOGISTICA = D.HANDLE 
			   LEFT JOIN GLOP_LINHAVIAGEMFILIAIS KM
					ON KM.LINHAVIAGEM = ISNULL(LINHA.HANDLE, ISNULL(V.DISTANCIACONSIDERADA, V.DISTANCIATOTAL))
			  -- LEFT JOIN [DBRodo].[dbo].[GLGL_DOCUMENTOASSOCIADOS] DA WITH(NOLOCK)
					--ON D.HANDLE = DA.DOCUMENTOLOGISTICA
  			--   INNER JOIN [DBRodo].[dbo].[GLGL_DOCUMENTOCLIENTES] DC WITH(NOLOCK)
					--ON DA.DOCUMENTOCLIENTE = DC.HANDLE
			  -- INNER JOIN GLOP_COLETAPEDIDOS CP 
					--ON CP.HANDLE = DC.PEDIDOCOLETA                                                                                           
     --          INNER JOIN GLOP_VIAGEMDOCUMENTOS VD 
					--ON VD.DOCUMENTOCOLETA = CP.HANDLE


             WHERE 1 = 1                                                                                                                                                                                                                                       
             And Convert(Date, v.INICIOEFETIVO) Between '2019-07-01' And '2019-07-02'
			 AND V.NUMEROVIAGEM = '2019/178155-27'

			 GROUP BY  V.LINHAVIAGEM,
					   V.NUMEROVIAGEM ,                                                                        
                       V.INICIOEFETIVO ,                                                                
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
					   V.HANDLE,
					   CALC.CONTRATOFRETE,
					   CALC.HANDLE,
					   FRETE.HANDLE,
					   VEICULO01.PLACANUMERO,
                       VEICULO02.PLACANUMERO,
                       VEICULO03.PLACANUMERO,
                       CLASSFROTA.NOME,
					   LINHA.HANDLE,
					   V.DISTANCIACONSIDERADA, V.DISTANCIATOTAL,  KM.DISTANCIA