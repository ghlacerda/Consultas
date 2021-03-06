SELECT 
	TIPOCLIENTE,
	[TRANSIT TIME],
	SUM(QUANTIDADECOLETA) AS QTDPEDIDO,
	SUM(VOLUME) AS QTDVOLUME

FROM(

SELECT 

	DL.NUMERO,
	DL.FILIAL,                                                                                                                                                 
	DL.VALORTOTALRECEBER AS VALORFRETE,
	DOCCLIPESOTOTAL AS PESO,
	DOCCLIPESOCUBADOTOTAL AS PESOCUBADO, 
	DOCCLIPESOCONSIDERADO AS PESOCONSIDERADO,
	COUNT(DISTINCT CP.HANDLE) AS QUANTIDADECOLETA,
	DOCCLIPESOCONSIDERADO AS PESOCOLETAREALIZADO,
	DOCCLIVOLUME AS [VOLUME],
	DOCCLIVALORTOTAL AS [VALORMERCADORIA],
	CASE
		WHEN 
			(CASE
				WHEN PC.CLIENTEEPP = 'N' THEN 'FRACIONADO'
				--WHEN DST2.NOME = 'NATURA COSMETICOS S/A' THEN 'NATURA'
			ELSE 'EPP'
			END) = 'FRACIONADO' AND DST2.NOME = 'NATURA COSMETICOS S/A' THEN 'NATURA'
		ELSE (CASE
				WHEN PC.CLIENTEEPP = 'N' THEN 'FRACIONADO'
				--WHEN DST2.NOME = 'NATURA COSMETICOS S/A' THEN 'NATURA'
			ELSE 'EPP'
			END)
	END AS TIPOCLIENTE,
	DST2.NOME,
	PES.DIA AS [TRANSIT TIME]

FROM GLGL_DOCUMENTOASSOCIADOS DA   
                                                                                                                                                                   
INNER JOIN GLGL_DOCUMENTOCLIENTES DC 
	ON DC.HANDLE = DA.DOCUMENTOCLIENTE
	                                                                                       
INNER JOIN GLGL_DOCUMENTOS DL 
	ON DA.DOCUMENTOLOGISTICA = DL.HANDLE 
	                                                                                                     
INNER JOIN GLOP_COLETAPEDIDOS CP 
	ON CP.HANDLE = DC.PEDIDOCOLETA

LEFT JOIN GN_PESSOAS DST2 
	ON (DST2.HANDLE = DL.DESTINATARIO) 

INNER JOIN GLGL_PESSOACONFIGURACOES PC 
	ON DST2.CODIGO = PC.HANDLE

INNER JOIN [DBRodo].[dbo].[GLOP_PRAZOENTREGAS] PE WITH(NOLOCK)
 ON DL.PRAZOENTREGA = PE.HANDLE

INNER JOIN [DBRodo].[dbo].[GLOP_PRAZOENTREGASERVICOS] PES WITH(NOLOCK)
 ON PE.HANDLE = PES.PRAZOENTREGA
 AND PES.SERVICO = 6 --ENTREGA PRAZO NORMAL (BUSCAR OS TIPOS DE SERVI�O DENTRO DA GLGL_SERVICOLOGISTICA)

WHERE DL.DATAEMISSAO >= '2019-10-16'
AND DL.DATAEMISSAO < '2019-10-17'
And ((DL.TIPODOCUMENTO In (1, 2)                                                                                                         
And   TIPODOCUMENTOFRETE = 153)                                                                                                            
Or  (DL.TIPODOCUMENTO In (6)                                                                                                            
And  DL.TIPORPS <> 324))   
AND DL.STATUS <> 236
--AND PC.CLIENTEEPP <> 'N'


GROUP BY 
	DL.NUMERO,
	DL.FILIAL,                                                                                                                                                 
	DL.VALORTOTALRECEBER,
	DOCCLIPESOTOTAL,
	DOCCLIPESOCUBADOTOTAL, 
	DOCCLIPESOCONSIDERADO,
	DOCCLIPESOCONSIDERADO,
	DOCCLIVOLUME,
	DOCCLIVALORTOTAL,
	CASE
		WHEN 
			(CASE
				WHEN PC.CLIENTEEPP = 'N' THEN 'FRACIONADO'
				--WHEN DST2.NOME = 'NATURA COSMETICOS S/A' THEN 'NATURA'
			ELSE 'EPP'
			END) = 'FRACIONADO' AND DST2.NOME = 'NATURA COSMETICOS S/A' THEN 'NATURA'
		ELSE (CASE
				WHEN PC.CLIENTEEPP = 'N' THEN 'FRACIONADO'
				--WHEN DST2.NOME = 'NATURA COSMETICOS S/A' THEN 'NATURA'
			ELSE 'EPP'
			END)
	END,
	DST2.NOME,
	PES.DIA

) AS T1

GROUP BY T1.TIPOCLIENTE,[TRANSIT TIME]