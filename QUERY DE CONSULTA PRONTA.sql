--declare @dtinicio datetime = dateadd(dd,-1, getdate())
--declare @dtfim datetime = getdate()


SELECT  DISTINCT  
     F.NOME
	,D.NUMERO AS CTRC
	--,D.HANDLE
	,CP.DATACONCLUSAO AS DATACOLETA
	,DC.NUMERO AS NOTAFISCALSERVIÇO
	,DC.VALORTOTAL
	,DC.VOLUME
	--,DC.PESOTOTAL
	,DC.PESOCONSIDERADO
	--,DC.PESOTOTALKG
	,GNP.NOME AS NOMEDESTINATARIO
	,GNP.CGCCPF AS CGCCPFDESTINATARIO
	,E.SIGLA
	--,DATEDIFF(second,DC.DATACOLETA, D.DATAENTREGA) AS [TRANSIT TIME]
	--,CONVERT(varchar, (DATEDIFF(second,CP.DATACONCLUSAO, D.DTPREVISAOENTREGAEMISSAO) % 31536000 / 86400)) AS [TRANSIT TIME]
	--,DTPREVISAOENTREGAEMISSAO
	,PES.DIA AS [TRANSIT TIME]
	,EI.NOME AS [STATUS]
	,D.DATAENTREGA
  

FROM [DBRodo].[dbo].[GLGL_DOCUMENTOS] D WITH(NOLOCK)

INNER JOIN [DBRodo].[dbo].[GLGL_DOCUMENTOASSOCIADOS] DA WITH(NOLOCK)
 ON D.HANDLE = DA.DOCUMENTOLOGISTICA

INNER JOIN [DBRodo].[dbo].[GLGL_DOCUMENTOCLIENTES] DC WITH(NOLOCK)
 ON DC.HANDLE = DA.DOCUMENTOCLIENTE 

INNER JOIN [DBRodo].[dbo].[GN_PESSOAS] GNP WITH(NOLOCK)
 ON D.DESTINOPESSOA = GNP.HANDLE 

INNER JOIN [DBRodo].[dbo].[GN_PESSOAS] GNPR WITH(NOLOCK)
 ON D.REMETENTE = GNPR.HANDLE 

INNER JOIN [DBRodo].[dbo].[FILIAIS] F WITH(NOLOCK)
 ON F.HANDLE = D.FILIAL

LEFT JOIN [DBRodo].[dbo].[FILIAIS] FET WITH(NOLOCK)
 ON D.FILIALENTREGA = FET.HANDLE

INNER JOIN [DBRodo].[dbo].[GLGL_DOCUMENTOTRIBUTOS] DT WITH(NOLOCK)
 ON D.HANDLE = DT.DOCUMENTO

INNER JOIN [DBRodo].[dbo].[ESTADOS] E WITH(NOLOCK)
 ON GNP.ESTADO = E.HANDLE

INNER JOIN [DBRodo].[dbo].[GLOP_COLETAPEDIDOS] CP WITH(NOLOCK)
 ON CP.HANDLE = DC.PEDIDOCOLETA

INNER JOIN [DBRodo].[dbo].[GLOP_PRAZOENTREGAS] PE WITH(NOLOCK)
 ON D.PRAZOENTREGA = PE.HANDLE

INNER JOIN [DBRodo].[dbo].[GLOP_PRAZOENTREGASERVICOS] PES WITH(NOLOCK)
 ON PE.HANDLE = PES.PRAZOENTREGA
 AND PES.SERVICO = 6 --ENTREGA PRAZO NORMAL (BUSCAR OS TIPOS DE SERVIÇO DENTRO DA GLGL_SERVICOLOGISTICA)

INNER JOIN [DBRodo].[dbo].[GLGL_ENUMERACAOITEMS] EI WITH(NOLOCK) --BUSCA OS STATUS DO DOCUMENTO
 ON EI.HANDLE = D.[STATUS]

WHERE D.DATAENTREGA >= @dtinicio 
AND D.DATAENTREGA < @dtfim
AND GNPR.CGCCPF ='02.162.259/0003-26'
AND (D.TIPODOCUMENTO = 2 OR (D.TIPODOCUMENTO = 6 AND D.TIPORPS = 322))

ORDER BY 1,3,2