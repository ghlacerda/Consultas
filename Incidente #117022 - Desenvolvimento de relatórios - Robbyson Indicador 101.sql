DECLARE @BeginDate DATE = '2019-12-01'
DECLARE @EndDate DATE = '2020-01-01'


SELECT 
	   colaborador_NAME,
	   colaborador_identification,
	   [Indicador que ele ser� avalidado(ID)],
	   SUM(resultado) AS resultado,
	   SUM(fator_0) AS fator_0,
	   SUM(fator_1) AS fator_1,
	   SUM(fator_2) AS fator_2,
	   SUM(fator_3) AS fator_3,
	   SUM(fator_4) AS fator_4,
	   SUM(fator_5) AS fator_5,
	   SUM(fator_6) AS fator_6,
	   SUM(fator_7) AS fator_7,
	   SUM(fator_8) AS fator_8,
	   SUM(fator_9) AS fator_9,
	   SUM(fator_10) AS fator_10,
	   [DATA]
FROM (
	SELECT DISTINCT 
		   P5.NOME AS colaborador_NAME,
		   CPF.CGCCPF AS colaborador_identification,
		   101 AS [Indicador que ele ser� avalidado(ID)],
		   CFS.VALORFRETE AS resultado,
		   0 AS fator_0,
		   0 AS fator_1,
		   0 AS fator_2,
		   0 AS fator_3,
		   0 AS fator_4,
		   0 AS fator_5,
		   0 AS fator_6,
		   0 AS fator_7,
		   0 AS fator_8,
		   0 AS fator_9,
		   0 AS fator_10,
		   CAST(CF.DATAINCLUSAO AS DATE) AS [DATA]

	FROM GLCM_COTACOES CF
	LEFT JOIN GLCM_COTACAOSERVICOS CFS ON CFS.COTACAO = CF.HANDLE
	LEFT JOIN GLCR_CLIENTEPOTENCIAL CP ON CP.HANDLE = CF.CLIENTEPOTENCIAL
	LEFT JOIN GN_PESSOAS C ON C.HANDLE = CF.PESSOA
	LEFT JOIN GLGL_ENUMERACAOITEMS TOMADORSERVICO ON TOMADORSERVICO.HANDLE = CF.TOMADORSERVICO
	LEFT JOIN GN_PESSOAS P1 ON P1.HANDLE = CF.PARTICIPANTECLIENTE1
	LEFT JOIN GLGL_ENUMERACAOITEMS PARTICIPANTE1 ON PARTICIPANTE1.HANDLE = CF.PARTICIPANTETIPO1
	LEFT JOIN GN_PESSOAS P2 ON P2.HANDLE = CF.PARTICIPANTECLIENTE2
	LEFT JOIN GLGL_ENUMERACAOITEMS PARTICIPANTE2 ON PARTICIPANTE2.HANDLE = CF.PARTICIPANTETIPO2
	LEFT JOIN GN_PESSOAS P3 ON P3.HANDLE = CF.PARTICIPANTECLIENTE3
	LEFT JOIN GLGL_ENUMERACAOITEMS PARTICIPANTE3 ON PARTICIPANTE3.HANDLE = CF.PARTICIPANTETIPO3
	LEFT JOIN GLGL_LOCALIDADES LO ON LO.HANDLE = CF.ORIGEM
	LEFT JOIN MUNICIPIOS MUNO ON MUNO.HANDLE = LO.MUNICIPIO
	LEFT JOIN GLGL_ENUMERACAOITEMS TIPOLO ON TIPOLO.HANDLE = LO.TIPO
	LEFT JOIN GLGL_LOCALIDADES LD ON LD.HANDLE = CF.DESTINO
	LEFT JOIN MUNICIPIOS MUND ON MUND.HANDLE = LD.MUNICIPIO
	LEFT JOIN GLGL_ENUMERACAOITEMS TIPOLD ON TIPOLD.HANDLE = LD.TIPO
	LEFT JOIN Z_GRUPOUSUARIOS U ON U.HANDLE = CF.USUARIOINCLUIU
	LEFT JOIN FILIAIS FINCLUSAO ON FINCLUSAO.HANDLE = CF.FILIAL
	LEFT JOIN FILIAIS FCOTACAO ON FCOTACAO.HANDLE = CF.FILIALCOTACAO
	LEFT JOIN FILIAIS FENTREGA ON FENTREGA.HANDLE = CF.FILIALENTREGA
	LEFT JOIN GLGL_DOCUMENTOS ON GLGL_DOCUMENTOS.COTACAO = CF.HANDLE
	LEFT JOIN GN_PESSOAS P4 ON P4.HANDLE = C.AGENTEVENDAS AND P4.EHAGENTEVENDAS = 'S'
	LEFT JOIN Z_GRUPOUSUARIOS P5 ON CF.USUARIOINCLUIU = P5.HANDLE
	LEFT JOIN GN_PESSOAS CPF ON P5.PESSOA = CPF.HANDLE
	WHERE CF.DATAINCLUSAO >= DATEADD(DD, -1,GETDATE())
	AND CF.DATAINCLUSAO < GETDATE()
	AND CF.STATUS in (6,7)

	UNION ALL

	SELECT DISTINCT 
		   P5.NOME AS colaborador_NAME,
		   CPF.CGCCPF AS colaborador_identification,
		   101 AS [Indicador que ele ser� avalidado(ID)],
		   0 AS resultado,
		   CFS.VALORFRETE AS fator_0,
		   0 AS fator_1,
		   0 AS fator_2,
		   0 AS fator_3,
		   0 AS fator_4,
		   0 AS fator_5,
		   0 AS fator_6,
		   0 AS fator_7,
		   0 AS fator_8,
		   0 AS fator_9,
		   0 AS fator_10,
		   CAST(CF.DATAINCLUSAO AS DATE) AS [DATA]

	FROM GLCM_COTACOES CF
	LEFT JOIN GLCM_COTACAOSERVICOS CFS ON CFS.COTACAO = CF.HANDLE
	LEFT JOIN GLCR_CLIENTEPOTENCIAL CP ON CP.HANDLE = CF.CLIENTEPOTENCIAL
	LEFT JOIN GN_PESSOAS C ON C.HANDLE = CF.PESSOA
	LEFT JOIN GLGL_ENUMERACAOITEMS TOMADORSERVICO ON TOMADORSERVICO.HANDLE = CF.TOMADORSERVICO
	LEFT JOIN GN_PESSOAS P1 ON P1.HANDLE = CF.PARTICIPANTECLIENTE1
	LEFT JOIN GLGL_ENUMERACAOITEMS PARTICIPANTE1 ON PARTICIPANTE1.HANDLE = CF.PARTICIPANTETIPO1
	LEFT JOIN GN_PESSOAS P2 ON P2.HANDLE = CF.PARTICIPANTECLIENTE2
	LEFT JOIN GLGL_ENUMERACAOITEMS PARTICIPANTE2 ON PARTICIPANTE2.HANDLE = CF.PARTICIPANTETIPO2
	LEFT JOIN GN_PESSOAS P3 ON P3.HANDLE = CF.PARTICIPANTECLIENTE3
	LEFT JOIN GLGL_ENUMERACAOITEMS PARTICIPANTE3 ON PARTICIPANTE3.HANDLE = CF.PARTICIPANTETIPO3
	LEFT JOIN GLGL_LOCALIDADES LO ON LO.HANDLE = CF.ORIGEM
	LEFT JOIN MUNICIPIOS MUNO ON MUNO.HANDLE = LO.MUNICIPIO
	LEFT JOIN GLGL_ENUMERACAOITEMS TIPOLO ON TIPOLO.HANDLE = LO.TIPO
	LEFT JOIN GLGL_LOCALIDADES LD ON LD.HANDLE = CF.DESTINO
	LEFT JOIN MUNICIPIOS MUND ON MUND.HANDLE = LD.MUNICIPIO
	LEFT JOIN GLGL_ENUMERACAOITEMS TIPOLD ON TIPOLD.HANDLE = LD.TIPO
	LEFT JOIN Z_GRUPOUSUARIOS U ON U.HANDLE = CF.USUARIOINCLUIU
	LEFT JOIN FILIAIS FINCLUSAO ON FINCLUSAO.HANDLE = CF.FILIAL
	LEFT JOIN FILIAIS FCOTACAO ON FCOTACAO.HANDLE = CF.FILIALCOTACAO
	LEFT JOIN FILIAIS FENTREGA ON FENTREGA.HANDLE = CF.FILIALENTREGA
	LEFT JOIN GLGL_DOCUMENTOS ON GLGL_DOCUMENTOS.COTACAO = CF.HANDLE
	LEFT JOIN GN_PESSOAS P4 ON P4.HANDLE = C.AGENTEVENDAS AND P4.EHAGENTEVENDAS = 'S'
	LEFT JOIN Z_GRUPOUSUARIOS P5 ON CF.USUARIOINCLUIU = P5.HANDLE
	LEFT JOIN GN_PESSOAS CPF ON P5.PESSOA = CPF.HANDLE
	WHERE CF.DATAINCLUSAO >= DATEADD(DD, -1,GETDATE())
	AND CF.DATAINCLUSAO < GETDATE()

) AS TEMP


WHERE REPLACE(REPLACE(colaborador_identification,'.',''),'-','') IN (
'90941420582'
,'31978702809'
,'10393367606'
,'05189394646'
,'10885833694'
,'01625270208'
,'03346435547'
,'38388819828'
,'07680142980'
,'16033860764'
,'05942288674'
,'13642347851'
,'14024970755'
,'01997107678'
,'09937947936'
,'11012152677'
,'04179896524'
,'10548782695'
,'08514862901'
,'12872134646'
,'11329465652'
,'43259828842'
,'04319181638'
,'13121760670'
,'08969107681'
,'02962035051'
,'03119563781'
,'15178961773'
,'33738337873'
,'01468024701'
,'41696008867'
,'47773997888'
,'33635494828'
,'04419709588'
,'31109001819'
,'05853762710'
,'12158808713'
,'03294646631'
,'98010271691'
)

GROUP BY colaborador_NAME,
	   colaborador_identification,
	   [Indicador que ele ser� avalidado(ID)],
	   [DATA]