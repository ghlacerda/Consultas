SELECT		        PROCESSO.HANDLE
			,FILIAIS.NOME AS FILIAL
			,USUARIO.NOME  AS CONFERENTE
			,processo.NUMERO
			,CASE
				WHEN PROCESSO.TIPO = 1 THEN 'CARREGAMENTO'
				WHEN PROCESSO.TIPO = 2 THEN 'DESCARREGAMENTO'
				WHEN PROCESSO.TIPO = 3 THEN 'AUDITORIA'
				WHEN PROCESSO.TIPO = 4 THEN 'PRE-PICKING'
				END AS TIPO_PROCESSO
			,CASE
				WHEN PROCESSO.SUBTIPO = 1 THEN 'TRANSFERENCIA'
				WHEN PROCESSO.SUBTIPO = 2 THEN 'ENTREGA'
				WHEN PROCESSO.SUBTIPO = 3 THEN 'COLETA'
				WHEN PROCESSO.SUBTIPO = 4 THEN 'UNITIZADOR'
				END AS SUBTIPO_PROCESSO
				,DATEDIFF(MINUTE, processo.DATAABERTURA, ISNULL(PROCESSO.DATAENCERRAMENTOLEITURAS, GETDATE())) - ISNULL((
					SELECT SUM(DATEDIFF(MINUTE, PAUSA.DATAHORAPAUSA, ISNULL(PAUSA.DATAHORAREINICIO, GETDATE())))
					FROM GLGV_PROCESSOPAUSAS PAUSA
					WHERE PAUSA.PROCESSO = PROCESSO.HANDLE
					),0) TEMPO_MINUTOS
				,(SELECT COUNT(1) FROM GLGV_PROCESSOPARTICIPANTES WHERE GLGV_PROCESSOPARTICIPANTES.PROCESSO = PROCESSO.HANDLE) + isnull(K_QTDTERCEIROS,0)  PARTICIPANTES
				,LINHA.NOME LINHA_TRANSFERENCIA
				,(
        SELECT COUNT(1)
        FROM GLGV_OCORRENCIAS
        INNER JOIN GLGV_MOTIVOOCORRENCIAS ON GLGV_OCORRENCIAS.MOTIVOOCORRENCIA = GLGV_MOTIVOOCORRENCIAS.HANDLE
        WHERE GLGV_OCORRENCIAS.PROCESSO = PROCESSO.HANDLE
            AND GLGV_MOTIVOOCORRENCIAS.TIPO = 1
        ) TOTAL_AVARIA
    ,(
        SELECT COUNT(1)
        FROM GLGV_OCORRENCIAS
        INNER JOIN GLGV_MOTIVOOCORRENCIAS ON GLGV_OCORRENCIAS.MOTIVOOCORRENCIA = GLGV_MOTIVOOCORRENCIAS.HANDLE
        WHERE GLGV_OCORRENCIAS.PROCESSO = PROCESSO.HANDLE
            AND GLGV_MOTIVOOCORRENCIAS.TIPO = 2
        ) TOTAL_FALTA
    ,(
        SELECT COUNT(1)
        FROM GLGV_OCORRENCIAS
        INNER JOIN GLGV_MOTIVOOCORRENCIAS ON GLGV_OCORRENCIAS.MOTIVOOCORRENCIA = GLGV_MOTIVOOCORRENCIAS.HANDLE
        WHERE GLGV_OCORRENCIAS.PROCESSO = PROCESSO.HANDLE
            AND GLGV_MOTIVOOCORRENCIAS.TIPO = 3
        ) TOTAL_SOBRA
		,FILIALORIGEM.NOME       AS FILIAL_ORIGEM
		,VALORES.FRETETOTAL
		,VALORES.PESOTOTAL
		,VALORES.TOTALDOCUMENTOS
		,VALORES.TOTALLIDO
		,VALORES.TOTALVOLUME
		,VALORES.VALORTOTAL
		,PROCESSO.DATAABERTURA
		,PROCESSO.DATAENCERRAMENTOLEITURAS
FROM		GLGV_PROCESSOS PROCESSO
INNER JOIN	GLGV_PLANOCARGADESCARGAS	PLANO			ON PROCESSO.PLANOCARGADESCARGA   = PLANO.HANDLE
INNER JOIN	GLOP_VIAGENS				VIA				ON PLANO.VIAGEM                  = VIA.HANDLE
LEFT  JOIN	GLOP_LINHAVIAGENS			LINHA			ON VIA.LINHAVIAGEM               = LINHA.HANDLE
INNER JOIN	Z_GRUPOUSUARIOS				USUARIO			ON PROCESSO.USUARIOABERTURA      = USUARIO.HANDLE
INNER JOIN	FILIAIS										ON PROCESSO.FILIAL               = FILIAIS.HANDLE
INNER JOIN  FILIAIS						FILIALORIGEM	ON FILIALORIGEM.HANDLE			 = VIA.FILIALORIGEM
inner join	VW_GESTAOVOLUMEVALORES		VALORES			ON VALORES.PROCESSO				 = PROCESSO.HANDLE
WHERE		PROCESSO.DATAABERTURA
			BETWEEN '2019-10-14'
			AND     '2019-10-15'
 --{IF([FILIAL] <> '', "And FILIAIS.HANDLE In ([FILIAL])", "")}
AND			PROCESSO.STATUS		= 1335
--and PROCESSO.HANDLE in (745119, 745126, 745628, 748437)

--AND USUARIO.NOME LIKE '%Leandro Nunes%'