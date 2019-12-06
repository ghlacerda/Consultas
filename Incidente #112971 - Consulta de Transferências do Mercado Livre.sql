DECLARE @BeginDate DATETIME = DATEADD(DD, -3, GETDATE())
DECLARE @EndDate DATETIME = GETDATE()

SELECT DISTINCT 
	V.NUMEROVIAGEM 
	,TPV.NOME AS TIPOVIAGEM
	,GNPR.CGCCPF
	,CASE
		WHEN VP.ORDEM = 1 THEN 'HUB1'
		WHEN VP.ORDEM = 2 THEN 'HUB2'
		WHEN VP.ORDEM = 3 THEN 'HUB3'
		WHEN VP.ORDEM = 4 THEN 'HUB4'
		WHEN VP.ORDEM = 5 THEN 'HUB5'
		WHEN VP.ORDEM = 6 THEN 'HUB6'
		WHEN VP.ORDEM = 7 THEN 'HUB7'
		WHEN VP.ORDEM = 8 THEN 'HUB8'
		WHEN VP.ORDEM = 9 THEN 'HUB9'
	 ELSE ''
	 END AS HUB
    ,B.PLACANUMERO AS PLACA
	,C.NOME AS [TIPO VEICULO]
	,(SELECT FILIAL.SIGLA FROM GLOP_VIAGEMPARADAS INNER JOIN GLGL_FILIAIS FILIAL ON FILIAL.FILIAL = GLOP_VIAGEMPARADAS.FILIAL
		WHERE V.HANDLE = VIAGEM AND ORDEM = VP.ORDEM -1) ORIGEM
	,FD.SIGLA AS DESTINO
	,LINHAVIAGENS.NOME AS LINHAVIAGEM
	 ,(SELECT INICIOVIAGEM FROM GLOP_VIAGEMPARADAS 
	 WHERE VP.VIAGEM = GLOP_VIAGEMPARADAS.VIAGEM AND GLOP_VIAGEMPARADAS.ORDEM = VP.ORDEM -1 ) AS INICIOEFETIVO
	,VP.CHEGADA
	,SUM(D.DOCCLIVOLUME) AS TOTAL

FROM GLOP_VIAGENS V 
LEFT JOIN GLGL_FILIAIS FO                         
	ON FO.HANDLE = V.FILIALORIGEM
	
LEFT JOIN GLGL_SUBTIPOVIAGENS SBV
	ON SBV.HANDLE = V.SUBTIPOVIAGEM  

LEFT JOIN GLOP_VIAGEMDOCUMENTOS DV
	ON DV.VIAGEM = V.HANDLE --AND VP.HANDLE = DV.PARADA

LEFT JOIN GLOP_VIAGEMPARADAS VP
	ON V.HANDLE = VP.VIAGEM  AND VP.HANDLE = DV.PARADA   

LEFT JOIN GLGL_DOCUMENTOS D
	ON DV.DOCUMENTOLOGISTICA = D.HANDLE

INNER JOIN GLOP_LINHAVIAGENS LINHAVIAGENS 
	ON LINHAVIAGENS.HANDLE = V.LINHAVIAGEM

LEFT JOIN [DBRodo].[dbo].[GN_PESSOAS] GNPR WITH(NOLOCK)
	ON D.TOMADORSERVICOPESSOA = GNPR.HANDLE 

JOIN GLGL_ENUMERACAOITEMS TPV
	ON TPV.HANDLE = V.TIPOVIAGEM 

JOIN GLGL_FILIAIS FD                         
	ON FD.HANDLE = VP.FILIAL 

LEFT JOIN MA_RECURSOS B 
	ON V.VEICULO1 = B.HANDLE

LEFT JOIN MF_VEICULOTIPOS C 
	ON B.TIPOVEICULO = C.HANDLE

INNER JOIN GLGL_ENUMERACAOITEMS TIPOTRANSFERENCIA 
	ON TIPOTRANSFERENCIA.HANDLE = V.TIPOVIAGEM
	AND TIPOTRANSFERENCIA.HANDLE = 172

WHERE 0=0 
--AND NUMEROVIAGEM = '2019/331888-3'
AND GNPR.CGCCPF IN (@cnpj)
AND V.INICIOEFETIVO >= @BeginDate
AND V.INICIOEFETIVO < @EndDate
AND NOT EXISTS( SELECT 1                                                                         
						 FROM            glop_servicosrealizados SR                                                      
						 LEFT JOIN       glop_servicorealizadodocs SD                                                    
						 ON              sd.servicorealizado = sr.handle                                                 
						 LEFT JOIN       glop_servicorealizadorps SRPS                                                   
						 ON              srps.servicorealizado = sr.handle                                               
						 INNER JOIN      glgl_documentoassociados DA                                                     
						 ON              da.documentocliente = sd.documentocliente                                       
						 INNER JOIN      glgl_servicologistica SL                                                        
						 ON              sr.servico = sl.handle                                                          
						 
						 WHERE           da.documentologistica = D.HANDLE												 
						 AND SL.HANDLE IN (9,46)                                                                         
						 UNION ALL                                                                                       
						 SELECT  1                                                                                       
						 FROM GLOP_SERVICOSREALIZADOS SR                                                               
						 LEFT JOIN GLOP_SERVICOREALIZADORPS SD ON SD.SERVICOREALIZADO = SR.HANDLE                      
						 INNER JOIN GLGL_SERVICOLOGISTICA SL ON SR.SERVICO = SL.HANDLE                                 
						 LEFT JOIN GLGL_DOCLOGASSOCIADOS DLA ON DLA.DOCUMENTOLOGISTICAFILHO = SD.DOCUMENTOLOGISTICARPS 
						 
						 WHERE   DLA.DOCUMENTOLOGISTICAPAI = D.HANDLE													 
						 AND SL.HANDLE IN (9,46)
			  )


GROUP BY 
		V.NUMEROVIAGEM 
	,TPV.NOME
	,GNPR.CGCCPF
    ,VP.ORDEM
	,FO.SIGLA 
	,FD.SIGLA 
	,LINHAVIAGENS.NOME
	,V.INICIOEFETIVO
	--,V.CHEGADAEFETIVA
	,V.HANDLE
	,VP.CHEGADA
	,VP.INICIOVIAGEM
	,VP.FILIAL
	,VP.VIAGEM
	,B.PLACANUMERO
	,C.NOME
ORDER BY 1,2