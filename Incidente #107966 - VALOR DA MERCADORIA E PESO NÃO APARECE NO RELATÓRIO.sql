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

  ,CASE WHEN V.TIPOVIAGEM IN (172) THEN (SELECT SUM(AA.DISTANCIA) FROM GLOP_LINHAVIAGEMFILIAIS AA WHERE AA.LINHAVIAGEM = LINHA.HANDLE) 
	 WHEN V.TIPOVIAGEM IN (169,170,173) THEN ISNULL (V.DISTANCIACONSIDERADA,V.DISTANCIATOTAL) END KMTOTAL                              

	,CASE WHEN PLACA.ORIGEM = 1 THEN 'Próprio'                                                                                         
	 ELSE (SELECT NOME FROM MF_TIPOFROTAAGREGADA AA WHERE AA.HANDLE = PLACA.TIPOFROTAAGREGADA) END TIPOAGREG,                          
	 BENEFICIARIO.NOME BENEFICIARIO, BENEFICIARIO.CGCCPF CPFCNPJBENEFICIARIO                                                           
  ,JT.NOME JUSTIFICATIVATRAFEGO, /*V.K_STROBSPROG OBSERVACAOTRAFEGO,*/ USUI.NOME USUARIOINCLUIU,USUA.NOME USUARIOALTEROU		  	
	,VEICULOTIPOS.Nome As VEICULOTIPOS																								
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
	LEFT JOIN GLOP_VIAGEMPARADAS VPARADA ON VPARADA.VIAGEM = V.HANDLE 								       							
	AND VPARADA.HANDLE = (SELECT MAX(HANDLE) FROM GLOP_VIAGEMPARADAS A WHERE A.PARADACANCELADA = 'N' AND A.VIAGEM = V.HANDLE)          
	LEFT  JOIN GLOP_LINHAVIAGENS LINHA ON(LINHA.HANDLE = V.LINHAVIAGEM)                                                                
	INNER JOIN GLGL_ENUMERACAOITEMS STATUS ON(STATUS.HANDLE = V.STATUS)                                                                
  LEFT  JOIN K_GLOP_JUSTIFICATRASOVIAGEM JT ON (JT.HANDLE = V.K_JUSTIFICATIVAATRASO) 												
  LEFT  JOIN Z_GRUPOUSUARIOS USUI ON (USUI.HANDLE = V.USUARIOINCLUIU) 													   			   
  LEFT  JOIN Z_GRUPOUSUARIOS USUA ON (USUA.HANDLE = V.USUARIOALTEROU) 													   			   
  INNER JOIN MF_VEICULOTIPOS VEICULOTIPOS ON VEICULOTIPOS.HANDLE = PLACA.TIPOVEICULO												
WHERE v.DATACANCELAMENTO is null AND V.STATUS NOT IN(179)
And V.PREVIAGEM = 'N'
AND V.DATAINCLUSAO >= '2019-09-29'
AND V.DATAINCLUSAO < '2019-10-01'

GROUP BY V.HANDLE,V.INICIOEFETIVO,V.NUMEROVIAGEM,TIPO.NOME,FORIGEM.SIGLA,FDESTINO.SIGLA	
,PLACA.PLACANUMERO,MOTORISTA.NOME,VPARADA.INICIODESCARREGAMENTO,VPARADA.FIMDESCARREGAMENTO,
V.CHEGADAEFETIVA,PLACA2.PLACANUMERO,PLACA3.PLACANUMERO, LINHA.NOME, STATUS.NOME,V.DATAHORATRANSBORDO 
,PLACA.ORIGEM,PLACA.TIPOFROTAAGREGADA ,LINHA.HANDLE,BENEFICIARIO.NOME, BENEFICIARIO.CGCCPF,SUBTIPO.NOME,V.PREVISAOCHEGADA
,JT.NOME, /*V.K_STROBSPROG,*/ USUI.NOME,USUA.NOME, VEICULOTIPOS.NOME, V.TIPOVIAGEM , V.DISTANCIACONSIDERADA, V.DISTANCIATOTAL
ORDER BY V.NUMEROVIAGEM