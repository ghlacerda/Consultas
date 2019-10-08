CREATE PROCEDURE SP_TC_COBRANCA_AGUARDANDO_EFETIVACAO
AS
BEGIN
	
----------------------------------------------------------------------------
--PEGA AS PRINCIPAIS INFORMA��ES DO PROCESSO
----------------------------------------------------------------------------

DROP TABLE IF EXISTS #TEMP_PROCESSOS

SELECT 

	EI.NOME AS [Status]						
	,F.NOME AS Filial						
	,P.NUMERO AS N�mero	
	,P.HANDLE
	,P.PLANOCARGADESCARGA					
	,CASE
		WHEN P.TIPO = 1 THEN 'Carregamento'
		WHEN P.TIPO = 2 THEN 'Descarregamento'
		WHEN P.TIPO = 3 THEN 'Auditoria'
		WHEN P.TIPO = 4 THEN 'Pre-Picking'
	ELSE 'N�o Informado'	
	END AS Tipo							
	,CASE
		WHEN P.SUBTIPO = 1 THEN 'Transferencia' 
		WHEN P.SUBTIPO = 2 THEN 'Entrega'
		WHEN P.SUBTIPO = 3 THEN 'Coleta'
		WHEN P.SUBTIPO = 4 THEN 'Unitizador'
	ELSE 'N�o Informado'
	END AS SubTipo							
	,P.DATAABERTURA AS [Data Abertura]
	,GUA.NOME AS [Usu�rio Abertura]					
	,P.DATAENCERRAMENTOLEITURAS AS [Data Encerramento Leituras]	
	,GU.NOME AS [Usu�rio Encerramento]
	--,T1.TOTALDOCUMENTOS AS [Tot. Documentos]				
	,V.NUMEROVIAGEM AS  [N�mero viagem]	
	,CONVERT(VARCHAR(MAX),FU.K_SIGLA) + '/' + CONVERT(VARCHAR(MAX),U.HANDLE) AS Unitizador									
	,TU.NOME AS [Tipo Unitizador]				

INTO #TEMP_PROCESSOS 
FROM GLGV_PROCESSOS P WITH(NOLOCK)

INNER JOIN GLGL_ENUMERACAOITEMS EI WITH(NOLOCK)
	ON P.STATUS = EI.CODIGO

INNER JOIN FILIAIS F WITH(NOLOCK)
	ON P.FILIAL = F.HANDLE

INNER JOIN Z_GRUPOUSUARIOS GU
	ON P.USUARIOENCERRAMENTOLEITURAS = GU.HANDLE

INNER JOIN Z_GRUPOUSUARIOS GUA
	ON P.USUARIOABERTURA = GUA.HANDLE

LEFT JOIN GLGV_UNITIZADORES U WITH(NOLOCK)
	ON P.UNITIZADOR = U.HANDLE

LEFT JOIN GLGV_TIPOUNITIZADORES TU WITH(NOLOCK)
	ON U.TIPO = TU.HANDLE

LEFT JOIN FILIAIS FU WITH(NOLOCK)
	ON U.FILIAL = FU.HANDLE

LEFT JOIN GLGV_PLANOCARGADESCARGAS PCD
	ON P.PLANOCARGADESCARGA = PCD.HANDLE

LEFT JOIN GLOP_VIAGENS V
	ON PCD.VIAGEM = V.HANDLE

WHERE DATAENCERRAMENTOLEITURAS <= DATEADD(HH, -3, GETDATE()) 
AND P.[STATUS] = 1337

----------------------------------------------------------------------------
--PEGA OS VOLUMES DO PROCESSO, UTILIZANDO A VIEW [VW_GESTAOVOLUMEVALORES]
----------------------------------------------------------------------------

DROP TABLE IF EXISTS #TEMP_VOLUMES

SELECT	 PROCESSO
		,TOTALDOCUMENTOS 

INTO #TEMP_VOLUMES
FROM  [dbo].[VW_GESTAOVOLUMEVALORES]
WHERE PROCESSO IN (SELECT DISTINCT HANDLE FROM #TEMP_PROCESSOS)

----------------------------------------------------------------------------
--RETORNA OS VALORES FINAIS
----------------------------------------------------------------------------

SELECT P.*, V.TOTALDOCUMENTOS 
FROM #TEMP_PROCESSOS P

INNER JOIN #TEMP_VOLUMES V
	ON P.HANDLE = V.PROCESSO

END
