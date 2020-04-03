DECLARE @BeginDate DATE = '2020-01-01'
DECLARE @EndDate DATE = '2020-04-27'

DROP TABLE IF EXISTS #TempTeste

DECLARE @CLIENTE VARCHAR(MAX) = 'BOTICA COMERCIAL FARMACEUTICA LTDA'

SELECT 
	MARCAVEICULO
	,MODELOVEICULO
	,PLACA
	,ANOMODELO
	,FILIALORIGEM
	,ROUND(SUM(TOTALKGNATURA),2) AS TOTALKGNATURA
	,ROUND(SUM(TOTALKG),2) AS TOTALKG
	--,ROUND((SUM(TOTALKGNATURA)*100/(SUM(TOTALKG))),2) AS [%NATURA]
	,ROUND(
			CASE
				WHEN SUM(TOTALKG) = 0 THEN 0
			ELSE (SUM(TOTALKGNATURA)*100/(SUM(TOTALKG)))
			END,2
		   ) AS [%BOTICARIO]
	,COMBUSTIVEL
	,NUMEROVIAGEM
	,TIPOVIAGEM
	,KM_TOTAL
INTO #TempTeste
FROM (
SELECT  
	MARCA.NOME AS MARCAVEICULO
	,TIPO.NOME AS MODELOVEICULO
	,M.CODIGO AS PLACA
	,DATEPART(YYYY, M.ANODOMODELO) AS ANOMODELO
	,FILIAIS.NOME AS FILIALORIGEM
	,CASE
		WHEN GEP.GRUPO = 865381 THEN ROUND(ISNULL(ISNULL(ISNULL(DOC.DOCCLIPESOCONSIDERADO,DOC.DOCCLIPESOTOTAL),DOC.DOCCLIATUALPESOCUBADOTOTAL),0),2)
	ELSE 0 
	END AS TOTALKGNATURA
	
	,ROUND(ISNULL(ISNULL(ISNULL(DOC.DOCCLIPESOCONSIDERADO,DOC.DOCCLIPESOTOTAL),DOC.DOCCLIATUALPESOCUBADOTOTAL),0),2) AS TOTALKG
	,A.NUMEROVIAGEM
	,A.TIPOVIAGEM
	,ISNULL(MFC.NOME, 'N�O CADASTRADO') AS COMBUSTIVEL
	,CASE
		WHEN T1.HANDLE = 10 THEN CAST((ISNULL(A.DISTANCIACONSIDERADA, ISNULL(A.DISTANCIATOTAL, ISNULL(A.DISTANCIAPREVISTA, 0)))) AS FLOAT) 
	 ELSE 20
	 END AS KM_TOTAL


FROM GLOP_VIAGENS A                                                                                                                                         
LEFT JOIN FILIAIS ON FILIAIS.HANDLE = A.FILIALORIGEM                                                                                            
LEFT JOIN MA_RECURSOS M ON M.HANDLE = A.VEICULO1                                                                                        
LEFT JOIN MF_VEICULOTIPOS TIPO ON TIPO.HANDLE = M.TIPOVEICULO 
LEFT JOIN MF_PARTEMARCAS MARCA	On MARCA.HANDLE	= M.MARCAVEICULO
LEFT JOIN MF_MODELOCOMBUSTIVEIS MC ON MC.MODELO = M.MODELOVEICULO
LEFT JOIN MF_COMBUSTIVEIS MFC ON MC.COMBUSTIVEL = MFC.HANDLE
LEFT JOIN GLOP_VIAGEMDOCUMENTOS 	VDOCENTS 		ON	VDOCENTS.VIAGEM 	= A.HANDLE 		 AND VDOCENTS.DOCUMENTOLOGISTICA IS NOT NULL                 
LEFT JOIN GLOP_VIAGEMDOCUMENTOS 	VDOCCOLS		ON	VDOCCOLS.VIAGEM 	= A.HANDLE 		 AND VDOCCOLS.DOCUMENTOCOLETA IS NOT NULL                    
LEFT JOIN GLOP_COLETAPEDIDOS 		COLS			ON	COLS.HANDLE		 	= VDOCCOLS.DOCUMENTOCOLETA                                                   
LEFT JOIN GLGL_DOCUMENTOCLIENTES	DOCCLI			ON	DOCCLI.PEDIDOCOLETA = COLS.HANDLE                                                                
LEFT JOIN GLGL_DOCUMENTOS 			DOC				ON	DOC.HANDLE 			= VDOCENTS.DOCUMENTOLOGISTICA
LEFT JOIN GN_PESSOAS P ON DOC.REMETENTE = P.HANDLE
LEFT JOIN GLGN_GRUPOEMPRESARIALPESSOAS GEP ON P.HANDLE = GEP.PESSOA
LEFT JOIN 
		(
			select DISTINCT contratoviagem.VIAGEM, classificacao.HANDLE
				from GLOP_VIAGENS viagem
					left join GLOP_CONTRATOFRETEVIAGENS contratoviagem on viagem.HANDLE = contratoviagem.VIAGEM 
					left join GLOP_CONTRATOFRETCALCULOS contratocalculo on contratoviagem.CONTRATOFRETE = contratocalculo.CONTRATOFRETE
					left join GLCM_LEIAUTETACOMPONENTES componente on componente.HANDLE = contratocalculo.COMPONENTETARIFA
					left join GLCM_COMPONENTECALCULOS componentecalculo on componentecalculo.HANDLE = componente.COMPONENTECALCULO
					left join GLCM_COMCALCLASSIFICACOES classificacao on classificacao.HANDLE = componentecalculo.CLASSIFICACAO
				where 0=0
				and classificacao.HANDLE = 10
		) AS T1 ON A.HANDLE = T1.VIAGEM

WHERE 0=0
AND A.PREVISAOSAIDA >= @BeginDate
AND A.PREVISAOSAIDA < DATEADD(DD, 1, @EndDate)
--AND M.CODIGO = 'ENT6523'
--and A.NUMEROVIAGEM = '2020/034832-2'
AND P.NOME LIKE '%' + @CLIENTE + '%'


) AS T
--WHERE T.TOTALKGNATURA > 0

GROUP BY MARCAVEICULO
	,MODELOVEICULO
	,PLACA
	,ANOMODELO
	,FILIALORIGEM
	,NUMEROVIAGEM
	,TIPOVIAGEM
	,COMBUSTIVEL
	,KM_TOTAL


SELECT 
	MARCAVEICULO
	,MODELOVEICULO
	,PLACA
	,ANOMODELO
	,FILIALORIGEM
	,TOTALKGNATURA
	,TOTALKG
	,[%BOTICARIO]
	,COMBUSTIVEL
	,NUMEROVIAGEM
	,TIPOVIAGEM
	,KM_TOTAL
	,(KM_TOTAL/10) AS [ABASTECIMENTO/10]
	--,CASE
	--	WHEN KM_TOTAL = 20 THEN ((SELECT SUM(KM_TOTAL) FROM #TempTeste WHERE TOTALKGNATURA > 0 AND KM_TOTAL = 20) / (SELECT COUNT(*) FROM #TempTeste WHERE TOTALKGNATURA > 0 AND KM_TOTAL = 20))
	--ELSE ((SELECT SUM(KM_TOTAL) FROM #TempTeste WHERE TOTALKGNATURA > 0 AND KM_TOTAL <> 20) / (SELECT COUNT(*) FROM #TempTeste WHERE TOTALKGNATURA > 0 AND KM_TOTAL <> 20))
	--END AS ABASTECIMENTOMEDIO


FROM #TempTeste