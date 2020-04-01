SELECT 

		VEIC1.PLACANUMERO AS Placa, 
		VEIC2.PLACANUMERO AS Reboque,                                                                                  
		VEIC3.PLACANUMERO AS Reboque2,
		F3.NOME AS [Classificação],
		UPPER(MOTORISTA.NOME) AS [Motorista],
		GFORIGEM.SIGLA  AS  Origem,                                                                                      
		GFDESTINO.SIGLA AS  Destino,
		LINHA.NOME AS [Linha de Viagem],
        CAST(CAST(VIAGEM.PREVISAOSAIDA AS DATE) AS DATETIME) + CONVERT(VARCHAR,LINHA.K_HORARIOSAIDAREP,108) AS [Saída Prevista REP],
		--CAST(CAST(VIAGEM.PREVISAOCHEGADA AS DATE) AS DATETIME) + CONVERT(VARCHAR,LINHA.K_HORARIO,108) AS [Chegada Prevista REP],
		VIAGEM.K_DATASAIDADIGITADA AS [Data Saída Manual],                                                                                      
		VIAGEM.K_DATACHEGADADIGITADA AS [Data Chegada Manual],
		Q.NOME AS [Situação Viagem],
		VIAGEM.NUMEROVIAGEM AS [Número Viagem],
		VIAGEM.NUMEROSMP AS [N° SMP],
		(CASE VIAGEM.STATUSSMP                                                                                          
		      WHEN 1 THEN 'Aguardando Envio'                                                                             
			  WHEN 2 THEN 'Aguardando Retorno'                                                                           
			  WHEN 3 THEN 'Aprovada'                                                                                     
			  WHEN 4 THEN 'Aprovada em espera'                                                                           
			  WHEN 5 THEN 'Recusada'                                                                                     
			  WHEN 6 THEN 'Não exige SMP'                                                                                 
              WHEN 7 THEN 'Digitada manualmente'                                                                         
              WHEN 8 THEN 'Cancelada'                                                                                     
			  WHEN 9 THEN 'Finalizada'                                                                                   
			  WHEN 10 THEN 'Desatualizada'                                                                                
			  WHEN 11 THEN 'Aprovada Raster'                                                                             
         END ) AS [Situação SMP],
		 KJ.NOME JUSTIFICATIVANOME, 
		 KA.NOME AS [Acompanhamento],
		 VIAGEM.K_DATASAIDAOMNILINK AS [Data de Saída],
		 VIAGEM.K_DATACHEGADAOMINILINK AS [Data de Chegada],
		 VIAGEM.PREVISAOSAIDA AS [Saída Prevista],                                                                                            
		 VIAGEM.PREVISAOCHEGADA AS [Chegada Prevista],
		 (CASE ISNULL(N.DDD, 0) WHEN '0' THEN N.TELEFONE ELSE N.DDD + N.TELEFONE END ) AS [Tel. Motorista], 
		 GMOTORISTA.CNHDATAVALIDADE AS [Validade CNH],
		 M.DATAVENCIMENTO AS [Validade Consulta],
		 CASE
			WHEN SUM(VD.PESO) < 10 THEN 'VAZIO'
		 ELSE 'CARREGADO'
		 END AS [Ocupação],
		 SUM(VD.VALORFRETE) AS Frete,               
		 SUM(VD.VALORTOTAL) AS [Valor Total],
		 SUM(VD.VOLUMES) AS Volumes,                
		 SUM(VD.PESO) AS [Peso Total]            

  FROM   GLOP_VIAGENS VIAGEM                                                                                                  
  INNER JOIN GLOP_LINHAVIAGENS LINHA ON ( VIAGEM.LINHAVIAGEM = LINHA.HANDLE )                                                 
  LEFT  JOIN K_LINHAVIAGEMDESPESAS B1 ON (B1.LINHADEVIAGEM = LINHA.HANDLE)                                                    
  INNER JOIN FILIAIS FORIGEM ON ( FORIGEM.HANDLE = VIAGEM.FILIALORIGEM )                                                      
  INNER JOIN GLGL_FILIAIS GFORIGEM ON ( FORIGEM.HANDLE = GFORIGEM.HANDLE )                                                    
  INNER JOIN FILIAIS FDESTINO ON ( FDESTINO.HANDLE = VIAGEM.FILIALDESTINO )                                                   
  INNER JOIN GLGL_FILIAIS GFDESTINO ON ( FDESTINO.HANDLE = GFDESTINO.FILIAL )                                                 
  INNER JOIN GN_PESSOAS MOTORISTA ON ( MOTORISTA.HANDLE = VIAGEM.MOTORISTA )                                                  
  LEFT OUTER JOIN GN_PESSOATELEFONES TELMOTORISTA ON ( TELMOTORISTA.PESSOA = MOTORISTA.HANDLE AND TELMOTORISTA.HANDLE = (SELECT MAX(E3.HANDLE) FROM   GN_PESSOATELEFONES E3 WHERE  TELMOTORISTA.PESSOA = E3.PESSOA) )                                                
  INNER JOIN MA_RECURSOS VEIC1 ON ( VEIC1.HANDLE = VIAGEM.VEICULO1 )                                                          
  LEFT JOIN MA_RECURSOS VEIC2 ON ( VEIC2.HANDLE = VIAGEM.VEICULO2 )                                                           
  LEFT JOIN MA_RECURSOS VEIC3 ON ( VEIC3.HANDLE = VIAGEM.VEICULO3 )                                                           
  LEFT JOIN K_MF_TIPOCLASSIFICACAOFROTA F3 ON ( VEIC1.K_TIPOCLASSIFICACAO = F3.HANDLE )                                       
  LEFT JOIN K_CLASSIFICACAODETALHES F3A ON ( VEIC1.TIPOFROTAAGREGADA = F3A.CLASSIFICACAO )                                    
  INNER JOIN GLGL_FILIAIS FLOCALVEIC1 ON ( FLOCALVEIC1.HANDLE = VEIC1.LOCALFILIAL )                                           
  LEFT JOIN GLGL_PESSOAS GMOTORISTA ON ( GMOTORISTA.PESSOA = MOTORISTA.HANDLE )                                               
  LEFT JOIN FILIAIS FILIALVEIC1  ON ( FILIALVEIC1.HANDLE = VEIC1.FILIAL )                                                     
  LEFT JOIN K_GLOP_VEICULOPOSICOES RST ON (RST.HANDLE = (                                                                                                           
			                                              SELECT MAX(AUX.HANDLE) FROM K_GLOP_VEICULOPOSICOES AUX WHERE AUX.VEICULO = VEIC1.HANDLE 
                                                               AND AUX.DATAHORA = (SELECT MAX(AUX2.DATAHORA) FROM K_GLOP_VEICULOPOSICOES AUX2 WHERE AUX2.VEICULO = VEIC1.HANDLE)
														))                                                                                                                       
  LEFT JOIN GLOP_VIAGENS VIAGEM2 ON ( VIAGEM2.FILIALORIGEM = FDESTINO.HANDLE AND VIAGEM2.HANDLE = (SELECT TOP 1 RVAUX.HANDLE                                                                 
																								   FROM   GLOP_VIAGENS RVAUX                                                                       
																								   WHERE  RVAUX.VEICULO1 = VIAGEM.VEICULO1                                                         
															                                       AND RVAUX.FILIALORIGEM = FDESTINO.HANDLE                                                 
															                                       AND ( ISNULL(RVAUX.INICIOEFETIVO, VIAGEM.INICIOEFETIVO + 1) > VIAGEM.INICIOEFETIVO ) AND RVAUX.DATACANCELAMENTO IS NULL                                                       
																	                               ORDER  BY ISNULL(RVAUX.INICIOEFETIVO,VIAGEM.INICIOEFETIVO + 1)) )                               
  LEFT JOIN GLOP_LINHAVIAGENS LINHAV2 ON ( VIAGEM2.LINHAVIAGEM = LINHAV2.HANDLE )                                             
  LEFT JOIN FILIAIS FDESTINOV2 ON ( FDESTINOV2.HANDLE = VIAGEM2.FILIALDESTINO )                                               
  LEFT OUTER JOIN (SELECT DATAVENCIMENTO,
                          PESSOA                                                                                              
                   FROM   GLGL_PESSOACERTIFICADOS                                                                             
                   WHERE  STATUS = 2                                                                                          
				   AND HANDLE = (SELECT MAX(HANDLE)                                                                    
								 FROM   GLGL_PESSOACERTIFICADOS X                                                      
								 WHERE GLGL_PESSOACERTIFICADOS.PESSOA = X.PESSOA)) M ON ( M.PESSOA = GMOTORISTA.PESSOA )
  LEFT JOIN (SELECT TELEFONE,                                                                                                 
                    PESSOA,                                                                                                   
					DDD                                                                                                       
             FROM   GN_PESSOATELEFONES                                                                                        
             WHERE  HANDLE = (SELECT MAX(HANDLE)                                                                              
                              FROM   GN_PESSOATELEFONES X                                                                     
                              WHERE  GN_PESSOATELEFONES.PESSOA = X.PESSOA)) N ON ( N.PESSOA = MOTORISTA.HANDLE )              
  LEFT OUTER JOIN (SELECT MAX(X.DATAVENCIMENTO) DATACONSULTA,                                                                 
                          X.PESSOA                                                                                            
                   FROM   GLGL_PESSOACERTIFICADOS X                                                                           
                   WHERE  X.STATUS = 2                                                                                        
                   GROUP  BY X.PESSOA) O  ON ( O.PESSOA = MOTORISTA.HANDLE )                                                  
  INNER JOIN GLGL_FILIAIS P  ON ( P.HANDLE = VEIC1.LOCALFILIAL )                                                                    
  LEFT OUTER JOIN (SELECT TT1.ORDEM,                                                                                          
                          TT1.VIAGEM,                                                                                          
						  TT1.HANDLE,                                                                                         
						  ISNULL(CAST(DATEDIFF(HH, TT1.CHEGADA, TT1.INICIOVIAGEM) AS VARCHAR) + ':' + RIGHT(CONVERT(VARCHAR(8), DATEADD(S, DATEDIFF(S, TT1.CHEGADA, TT1.INICIOVIAGEM), '00:00:00'), 108), 5), '0:00:00') TEMPOPARADA1
				   FROM   GLOP_VIAGEMPARADAS TT1                                                                                                       
				   WHERE  ORDEM = 1) P1 ON ( P1.VIAGEM = VIAGEM.HANDLE )                                                                              
  LEFT OUTER JOIN (SELECT TT2.ORDEM,                                                                                                   
						  TT2.VIAGEM,                                                                                                 
						  TT2.HANDLE,                                                                                                  
						  ISNULL(CAST(DATEDIFF(HH, TT2.CHEGADA, TT2.INICIOVIAGEM) AS VARCHAR) + ':' + RIGHT(CONVERT(VARCHAR(8), DATEADD(S, DATEDIFF(S, TT2.CHEGADA, TT2.INICIOVIAGEM), '00:00:00'), 108), 5), '0:00:00') TEMPOPARADA2
				   FROM   GLOP_VIAGEMPARADAS TT2                                                                                                       
				   WHERE  ORDEM = 2) P2  ON ( P2.VIAGEM = VIAGEM.HANDLE )                                                                             
  INNER JOIN GLGL_ENUMERACAOITEMS Q ON ( Q.HANDLE = VIAGEM.STATUS )                                                                   
  LEFT JOIN GLGL_FILIAIS GLFILIALBASEVEICULO ON ( GLFILIALBASEVEICULO.HANDLE = VEIC1.FILIAL )                                         
  LEFT JOIN K_GLOP_JUSTIFICATRASOVIAGEM KJ ON ( KJ.HANDLE = VIAGEM.K_JUSTIFICATIVAATRASO )                                                                            
  LEFT JOIN K_GLOP_VSTATUSACOMPANHAMENTO KA ON ( KA.HANDLE = VIAGEM.K_STACOMPANHAMENTO )
  INNER JOIN GLOP_VIAGEMDOCUMENTOS VD ON (VD.VIAGEM = VIAGEM.HANDLE)

WHERE VIAGEM.DATACANCELAMENTO IS NULL                                                                                              
      --AND VEIC1.HANDLE IN (107401) -- fazer o teste
	  AND VIAGEM.PREVISAOSAIDA >= '2020-03-01'
	  AND VIAGEM.PREVISAOSAIDA < = '2020-04-01'
	  AND VIAGEM.FILIALORIGEM <> VIAGEM.FILIALDESTINO

GROUP BY VEIC1.PLACANUMERO, 
		VEIC2.PLACANUMERO,                                                                                  
		VEIC3.PLACANUMERO,
		F3.NOME,
		UPPER(MOTORISTA.NOME),
		GFORIGEM.SIGLA,                                                                                      
		GFDESTINO.SIGLA,
		LINHA.NOME,
        CAST(CAST(VIAGEM.PREVISAOSAIDA AS DATE) AS DATETIME) + CONVERT(VARCHAR,LINHA.K_HORARIOSAIDAREP,108),
		--CAST(CAST(VIAGEM.PREVISAOSAIDA AS DATE) AS DATETIME) + CONVERT(VARCHAR,LINHA.K_HORARIOSAIDAREP,108),
		VIAGEM.K_DATASAIDADIGITADA,                                                                                      
		VIAGEM.K_DATACHEGADADIGITADA,
		Q.NOME,
		VIAGEM.NUMEROVIAGEM,
		VIAGEM.NUMEROSMP,
		(CASE VIAGEM.STATUSSMP                                                                                          
		      WHEN 1 THEN 'Aguardando Envio'                                                                             
			  WHEN 2 THEN 'Aguardando Retorno'                                                                           
			  WHEN 3 THEN 'Aprovada'                                                                                     
			  WHEN 4 THEN 'Aprovada em espera'                                                                           
			  WHEN 5 THEN 'Recusada'                                                                                     
			  WHEN 6 THEN 'Não exige SMP'                                                                                 
              WHEN 7 THEN 'Digitada manualmente'                                                                         
              WHEN 8 THEN 'Cancelada'                                                                                     
			  WHEN 9 THEN 'Finalizada'                                                                                   
			  WHEN 10 THEN 'Desatualizada'                                                                                
			  WHEN 11 THEN 'Aprovada Raster'                                                                             
         END ),
		 KJ.NOME, 
		 KA.NOME ,
		 VIAGEM.K_DATASAIDAOMNILINK,
		 VIAGEM.K_DATACHEGADAOMINILINK,
		 VIAGEM.PREVISAOSAIDA,                                                                                            
		 VIAGEM.PREVISAOCHEGADA,
		 (CASE ISNULL(N.DDD, 0) WHEN '0' THEN N.TELEFONE ELSE N.DDD + N.TELEFONE END ), 
		 GMOTORISTA.CNHDATAVALIDADE,
		 M.DATAVENCIMENTO

--ORDER BY VEIC1.PLACANUMERO, VIAGEM.PREVISAOSAIDA DESC, VIAGEM.INICIOEFETIVO