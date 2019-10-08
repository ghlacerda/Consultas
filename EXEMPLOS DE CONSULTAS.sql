SELECT V.HANDLE,V.INICIOEFETIVO,V.PREVISAOCHEGADA,V.CHEGADAEFETIVA,V.NUMEROVIAGEM,TIPO.NOME TIPO                                     
                ,FORIGEM.SIGLA ORIGEM,FDESTINO.SIGLA DESTINO, STATUS.NOME STATUS                                                                 
                ,PLACA.PLACANUMERO, PLACA2.PLACANUMERO PLACA2,PLACA3.PLACANUMERO PLACA3,SUBTIPO.NOME SUBTIPO                                     
                ,MOTORISTA.NOME MOTORISTA,COUNT(VDOC.HANDLE) QTDDOC                                                                              
                ,sum(CASE WHEN VDOC.SITUACAO = 209 THEN 1 ELSE 0 END)QTREALIZADAS                                                                
                ,(CONVERT(NUMERIC(10,4),sum(CASE WHEN VDOC.SITUACAO = 209 THEN 1 ELSE 0 END))/COUNT(*)) *100 EFETIVIDADE                         
                ,sum(CASE WHEN VDOC.SITUACAO = 209 AND DOC.TIPO IN (186,188) THEN  1 ELSE 0 END) QTREALIZADASENTREGA                             
                ,sum(CASE WHEN DOC.TIPO IN (186,188) THEN  1 ELSE 0 END) QTENTREGA                                                               
                ,sum(CASE WHEN VDOC.SITUACAO = 209 AND DOC.TIPO IN (189) THEN  1 ELSE 0 END) QTREALIZADASCOLETA                                  
                ,sum(CASE WHEN DOC.TIPO IN (189) THEN  1 ELSE 0 END) QTCOLETA                                                                    
                ,SUM(VDOC.VOLUMES) VOLUMES,SUM(VDOC.PESO) PESO,SUM(VDOC.PESOCUBADO) PESOCUBADO,SUM(DOC.PESOCONSIDERADO) PESOCONSIDERADO          
                ,SUM(VDOC.VALORTOTAL) VALORMERCADORIA,SUM(VDOC.VALORFRETE) FRETE                                                                 
                ,VPARADA.INICIODESCARREGAMENTO INICIO_DESCARGA,VPARADA.FIMDESCARREGAMENTO FIM_DESCARGA                                           
                ,LINHA.NOME LINHAVIAGEM,V.DATAHORATRANSBORDO                                                                                     
                ,(SELECT SUM(AA.DISTANCIA) FROM GLOP_LINHAVIAGEMFILIAIS AA WHERE AA.LINHAVIAGEM = LINHA.HANDLE)  KMTOTAL                         
                ,CASE WHEN PLACA.ORIGEM = 1 THEN 'Próprio'                                                                                       
                 ELSE (SELECT NOME FROM MF_TIPOFROTAAGREGADA AA WHERE AA.HANDLE = PLACA.TIPOFROTAAGREGADA) END TIPOAGREG,                        
                                BENEFICIARIO.NOME BENEFICIARIO, BENEFICIARIO.CGCCPF CPFCNPJBENEFICIARIO, BENEFICIARIO.INSSPISPASEP, BENEFICIARIO.NASCIMENTO           
                               ,ISNULL((SELECT SUM(CALC.VALORFINAL) FROM GLOP_CONTRATOFRETCALCULOS CALC WHERE CALC.CONTRATOFRETE = CF.HANDLE AND CALC.CLASSIFICACAO = 5),0) PEDAGIO
                ,ISNULL((SELECT SUM(CALC.VALORFINAL) FROM GLOP_CONTRATOFRETCALCULOS CALC WHERE CALC.CONTRATOFRETE = CF.HANDLE AND CALC.CLASSIFICACAO = 7),0) GENERALIDADES  
                ,ISNULL((SELECT SUM(CALC.VALORFINAL) FROM GLOP_CONTRATOFRETCALCULOS CALC WHERE CALC.CONTRATOFRETE = CF.HANDLE AND CALC.CLASSIFICACAO = 8),0) DIARIA         
                ,ISNULL((SELECT SUM(CALC.VALORFINAL) FROM GLOP_CONTRATOFRETCALCULOS CALC WHERE CALC.CONTRATOFRETE = CF.HANDLE AND CALC.CLASSIFICACAO = 9),0) PRODUTIVIDADE  
                ,ISNULL((SELECT SUM(CALC.VALORFINAL) FROM GLOP_CONTRATOFRETCALCULOS CALC WHERE CALC.CONTRATOFRETE = CF.HANDLE AND CALC.CLASSIFICACAO = 10),0) QUILOMETRAGEM 
                ,ISNULL((SELECT SUM(CALC.VALORFINAL) FROM GLOP_CONTRATOFRETCALCULOS CALC WHERE CALC.CONTRATOFRETE = CF.HANDLE AND CALC.CLASSIFICACAO = 13),0) TARIFAADD     
                ,ISNULL((SELECT SUM(CALC.VALORFINAL) FROM GLOP_CONTRATOFRETCALCULOS CALC WHERE CALC.CONTRATOFRETE = CF.HANDLE AND CALC.CLASSIFICACAO = 14),0) FRETEVEICULO  
                ,ISNULL((SELECT SUM(CALC.VALORFINAL) FROM GLOP_CONTRATOFRETCALCULOS CALC WHERE CALC.CONTRATOFRETE = CF.HANDLE AND CALC.CLASSIFICACAO = 15),0) DESCONTOS     
                ,CF.FRETECOMBINADO, CFC.OBSERVACAO                                                                                                                                                                                                                                                                                                                                    
                ,ISNULL(CF.VALORTOTAL, 0) VALORTOTALCF                                                                                                                                                                                                                                                                                                                                
                ,V.K_DISTANCIATOTALREAL QUILOMETRAGEMREAL,V.DISTANCIATOTAL QUILOMETRAGEMINFO,V.DISTANCIACONSIDERADA                                                                                                                                                                                                                                                                      
                               , CF.NUMERO CFNUMERO, CF.DATAEMISSAO CFDATAEMISSAO                                                                                                                                                                                                                                                                            
                               FROM GLOP_VIAGENS V                                                                                                             
                               INNER JOIN GLGL_FILIAIS FORIGEM ON (FORIGEM.FILIAL = V.FILIALORIGEM)                                                            
                               INNER JOIN GLGL_FILIAIS FDESTINO ON (FDESTINO.FILIAL = V.FILIALDESTINO)                                                         
                               INNER JOIN GLGL_ENUMERACAOITEMS TIPO ON (TIPO.CODIGO = V.TIPOVIAGEM)                                                            
                               INNER JOIN MA_RECURSOS PLACA ON (PLACA.HANDLE = V.VEICULO1)                                                                     
                               LEFT  JOIN MA_RECURSOS PLACA2 ON (PLACA2.HANDLE = V.VEICULO2)                                                                   
                               LEFT  JOIN MA_RECURSOS PLACA3 ON (PLACA3.HANDLE = V.VEICULO3)                                                                   
                               INNER JOIN GN_PESSOAS MOTORISTA ON (MOTORISTA.HANDLE = V.MOTORISTA)                                                             
                               INNER JOIN GN_PESSOAS BENEFICIARIO ON (BENEFICIARIO.HANDLE = PLACA.PROPRIETARIO)                                                
                               INNER JOIN GLOP_VIAGEMDOCUMENTOS VDOC ON (VDOC.VIAGEM = V.HANDLE)                                                               
                               LEFT JOIN GLGL_SUBTIPOVIAGENS SUBTIPO ON (V.SUBTIPOVIAGEM = SUBTIPO.HANDLE)                                                     
                               INNER Join  (                                                                                                                      
                                               Select 186 AS TIPO,HANDLE, DOCCLIATUALPESOCONSIDERADO PESOCONSIDERADO FROM GLGL_DOCUMENTOS                                 
                                               WHERE TIPODOCUMENTO = 6                                                                                                        
                                               UNION ALL                                                                                                                            
                                               Select 188 AS TIPO,HANDLE, DOCCLIATUALPESOCONSIDERADO PESOCONSIDERADO FROM GLGL_DOCUMENTOS                                                   
                                               WHERE TIPODOCUMENTO = 2                                                                                                        
                                               UNION ALL                                                                                                                            
                                               Select 189 AS TIPO,HANDLE, PESOCONSIDERADO FROM GLOP_COLETAPEDIDOS ) DOC                                                                                
                                                               On (IsNull(VDOC.DOCUMENTOLOGISTICA,VDOC.DOCUMENTOCOLETA) = DOC.Handle And DOC.TIPO = VDOC.TIPODOCUMENTO)         
                               LEFT  JOIN GLOP_VIAGEMPARADAS VPARADA ON(VPARADA.VIAGEM = V.HANDLE AND VPARADA.FILIAL = V.FILIALDESTINO)                           
                               LEFT  JOIN GLOP_LINHAVIAGENS LINHA ON(LINHA.HANDLE = V.LINHAVIAGEM)                                                                
                               INNER JOIN GLGL_ENUMERACAOITEMS STATUS ON(STATUS.HANDLE = V.STATUS)                                                                
                  LEFT  JOIN K_GLOP_JUSTIFICATRASOVIAGEM JT ON (JT.HANDLE = V.K_JUSTIFICATIVAATRASO)                                                                                                                                                                                            
                  LEFT  JOIN GLOP_CONTRATOFRETEVIAGENS CFV ON (CFV.VIAGEM = V.HANDLE)                                                                                                                                                                                                                        
                  LEFT  JOIN GLOP_CONTRATOFRETES CF ON (CFV.CONTRATOFRETE = CF.HANDLE)                                                                                                                                                                                                                      
                  LEFT JOIN GLOP_FRETECOMBINADOLOGS CFC ON CF.HANDLE = CFC.CONTRATOFRETE AND CFC.HANDLE = (SELECT MAX(A.HANDLE) FROM GLOP_FRETECOMBINADOLOGS A WHERE A.CONTRATOFRETE = CF.HANDLE) 
                WHERE v.DATACANCELAMENTO is null AND V.STATUS NOT IN(176,179,747) AND (CF.HANDLE IS NULL OR (CF.HANDLE IS NOT NULL AND CF.STATUS NOT IN(731,433))) 
