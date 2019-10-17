SELECT TOP(10) NUMEROVIAGEM, LINHA.NOME, DATAEMISSAO, DATAENTREGA, V.DATAINCLUSAO, V.FILIALORIGEM, V.FILIALDESTINO, D.DOCCLIPESOCUBADOTOTAL
FROM GLOP_VIAGENS V                                                                                                                                                                                     
LEFT JOIN GLGL_SUBTIPOVIAGENS SBV
	ON SBV.HANDLE = V.SUBTIPOVIAGEM  

INNER JOIN GLOP_VIAGEMDOCUMENTOS DV
	ON DV.VIAGEM = V.HANDLE

LEFT JOIN GLGL_DOCUMENTOS D
	ON DV.DOCUMENTOLOGISTICA = D.HANDLE

LEFT JOIN GLOP_LINHAVIAGENS LINHA               
	ON LINHA.HANDLE = V.LINHAVIAGEM   

JOIN MA_RECURSOS VEICULO01           
	ON VEICULO01.HANDLE = V.VEICULO1                                                                                         

	                                                                                          
LEFT JOIN K_GLOP_LINHAVIAGEMLIMITES LVL                        
	ON LVL.LINHAVIAGEM            = LINHA.HANDLE    
	AND LVL.TIPOTERCEIRO = VEICULO01.TIPOFROTAAGREGADA                                                                  
	AND LVL.TIPOVEICULO = VEICULO01.TIPOVEICULO

WHERE DOCCLIPESOCONSIDERADO = 0