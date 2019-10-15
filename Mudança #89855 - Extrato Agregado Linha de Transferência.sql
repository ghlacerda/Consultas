  DECLARE @DTINICIO DATETIME = '2019-10-07'
  DECLARE @DTFIM DATETIME = '2019-10-08'

  DROP TABLE IF EXISTS #TempAcompanhamentoViagens
  DROP TABLE IF EXISTS #TempDespesas
  DROP TABLE IF EXISTS #TempViagensMistas
   
    SELECT VIAGENS.NUMEROVIAGEM  AS NUMEROVIAGEM,
           VIAGENS.HANDLE        AS HANDLEVIAGEM,
           FILIALORIGEM.NOME     AS FILIAL,
           FILIALDESTINO.NOME    AS FILIALDESTINO,
           MOTORISTA.NOME        AS MOTORISTA,
           BENEFICIARIO.NOME     AS BENEFICIARIO,
           VIAGENS.INICIOEFETIVO AS DATAINICIOVIAGEM,
           VIAGENS.PREVISAOSAIDA AS DATAPREVISAOSAIDA,
           ISNULL(LINHAVIAGENS2.NOME, LINHAVIAGENS.NOME)     AS LINHAVIAGEM,
           VEICULOTIPO.NOME      AS TIPOVEICULO,
           (SELECT SUM(CASE WHEN VIAGEMPARADAS.DISTANCIAPREVISTA IS NULL
                            THEN 0
                            ELSE VIAGEMPARADAS.DISTANCIAPREVISTA END)
              FROM GLOP_VIAGEMPARADAS VIAGEMPARADAS
             WHERE VIAGEMPARADAS.VIAGEM = VIAGENS.HANDLE) AS KMTOTAL,
           ((SELECT SUM(CASE WHEN CONTRATOFRETES.VALORTOTAL IS NULL THEN 0 ELSE CONTRATOFRETES.VALORTOTAL END)
               FROM GLOP_CONTRATOFRETEVIAGENS CONTRATOFRETEVIAGENS INNER
                    JOIN GLOP_CONTRATOFRETES CONTRATOFRETES ON (CONTRATOFRETEVIAGENS.CONTRATOFRETE = CONTRATOFRETES.HANDLE)
              WHERE CONTRATOFRETEVIAGENS.VIAGEM = VIAGENS.HANDLE
                    AND CONTRATOFRETES.STATUS NOT IN(433,262)) / NULLIF((SELECT SUM(CASE WHEN P.DISTANCIAPREVISTA IS NULL THEN 0 ELSE P.DISTANCIAPREVISTA END)
                                                                    FROM GLOP_VIAGEMPARADAS P
                                                                   WHERE P.VIAGEM = VIAGENS.HANDLE), 0)) AS VALORPORKMLV,
           VEICULO1.CODIGO AS PLACA,
           VEICULO2.CODIGO AS REBOQUE,
           VEICULO3.CODIGO AS TERCEIRAPLACA,
           (SELECT SUM(CASE WHEN CONTRATOFRETES.VALORTOTAL IS NULL THEN 0 ELSE CONTRATOFRETES.VALORTOTAL END)
              FROM GLOP_CONTRATOFRETEVIAGENS CONTRATOFRETEVIAGENS INNER
                   JOIN GLOP_CONTRATOFRETES CONTRATOFRETES ON (CONTRATOFRETEVIAGENS.CONTRATOFRETE = CONTRATOFRETES.HANDLE)
             WHERE CONTRATOFRETEVIAGENS.VIAGEM = VIAGENS.HANDLE
                   AND CONTRATOFRETES.STATUS NOT IN(433,262))  AS VALORTOTALCONTRATOFRETE,
           (SELECT SUM(VIAGEMDOCUMENTOS.VOLUMES)
              FROM GLOP_VIAGEMDOCUMENTOS VIAGEMDOCUMENTOS
             WHERE VIAGEMDOCUMENTOS.VIAGEM = VIAGENS.HANDLE) AS QTDVOLUMES,
           (SELECT SUM(VIAGEMDOCUMENTOS.PESO)
              FROM GLOP_VIAGEMDOCUMENTOS VIAGEMDOCUMENTOS
             WHERE VIAGEMDOCUMENTOS.VIAGEM = VIAGENS.HANDLE) AS PESOREAL,
           (SELECT SUM(VIAGEMDOCUMENTOS.PESOCUBADO)
              FROM GLOP_VIAGEMDOCUMENTOS VIAGEMDOCUMENTOS
             WHERE VIAGEMDOCUMENTOS.VIAGEM = VIAGENS.HANDLE) AS PESOCUBADO,
           (SELECT SUM(VIAGEMDOCUMENTOS.VALORFRETE)
              FROM GLOP_VIAGEMDOCUMENTOS VIAGEMDOCUMENTOS
             WHERE VIAGEMDOCUMENTOS.VIAGEM = VIAGENS.HANDLE) AS VALORFRETE,
           (SELECT SUM(VIAGEMDOCUMENTOS.VALORTOTAL)
              FROM GLOP_VIAGEMDOCUMENTOS VIAGEMDOCUMENTOS
             WHERE VIAGEMDOCUMENTOS.VIAGEM = VIAGENS.HANDLE) AS VALORTOTALMERCADORIA,
           ((SELECT SUM(VIAGEMDOCUMENTOS.VALORFRETE)
               FROM GLOP_VIAGEMDOCUMENTOS VIAGEMDOCUMENTOS
              WHERE VIAGEMDOCUMENTOS.VIAGEM = VIAGENS.HANDLE) / NULLIF((SELECT SUM(VIAGEMDOCUMENTOS.PESO)
                                                                   FROM GLOP_VIAGEMDOCUMENTOS VIAGEMDOCUMENTOS
                                                                  WHERE VIAGEMDOCUMENTOS.VIAGEM = VIAGENS.HANDLE AND VIAGEMDOCUMENTOS.PESO > 0.0), 0)) AS RECEITAPESOTOTAL,
           ((SELECT SUM(VIAGEMDOCUMENTOS.VALORFRETE)
               FROM GLOP_VIAGEMDOCUMENTOS VIAGEMDOCUMENTOS
              WHERE VIAGEMDOCUMENTOS.VIAGEM = VIAGENS.HANDLE) / NULLIF((SELECT SUM(VIAGEMDOCUMENTOS.PESOCUBADO)
                                                                   FROM GLOP_VIAGEMDOCUMENTOS VIAGEMDOCUMENTOS
                                                                  WHERE VIAGEMDOCUMENTOS.VIAGEM = VIAGENS.HANDLE AND VIAGEMDOCUMENTOS.PESOCUBADO > 0.0), 0)) AS RECEITAPESOCUBADO,
                      ((SELECT SUM(CASE WHEN CF.VALORTOTAL IS NULL THEN 0 ELSE CF.VALORTOTAL END)
                FROM GLOP_CONTRATOFRETEVIAGENS CFVG INNER
               jOIN GLOP_CONTRATOFRETES CF ON (CFVG.CONTRATOFRETE = CF.HANDLE)
                WHERE CFVG.VIAGEM = VIAGENS.HANDLE
                AND CF.STATUS NOT IN(433,262)) / NULLIF((SELECT SUM(VIAGEMDOCUMENTOS.VALORFRETE)
               FROM GLOP_VIAGEMDOCUMENTOS VIAGEMDOCUMENTOS
              WHERE VIAGEMDOCUMENTOS.VIAGEM = VIAGENS.HANDLE AND VIAGEMDOCUMENTOS.VALORFRETE > 0.0), 0) * 100) AS DESPESARECEITA,
           SUM(DOC.PESOCONSIDERADO) PESOCONSIDERADO,
		   CALC.TARIFAADD
		   
	  INTO #TempAcompanhamentoViagens
      FROM GLOP_VIAGENS VIAGENS
           INNER JOIN FILIAIS FILIALORIGEM ON FILIALORIGEM.HANDLE = VIAGENS.FILIALORIGEM
           INNER JOIN FILIAIS FILIALDESTINO ON FILIALDESTINO.HANDLE = VIAGENS.FILIALDESTINO
           LEFT JOIN GN_PESSOAS MOTORISTA ON MOTORISTA.HANDLE = VIAGENS.MOTORISTA
           INNER JOIN MA_RECURSOS VEICULO1 ON VEICULO1.HANDLE = VIAGENS.VEICULO1
           INNER JOIN MF_VEICULOTIPOS VEICULOTIPO ON VEICULOTIPO.HANDLE = VEICULO1.TIPOVEICULO
           LEFT JOIN GN_PESSOAS BENEFICIARIO ON BENEFICIARIO.HANDLE = VEICULO1.PROPRIETARIO
           INNER JOIN GLOP_LINHAVIAGENS LINHAVIAGENS ON LINHAVIAGENS.HANDLE = VIAGENS.LINHAVIAGEM
           LEFT JOIN MA_RECURSOS VEICULO2 ON VEICULO2.HANDLE = VIAGENS.VEICULO2
           LEFT JOIN MA_RECURSOS VEICULO3 ON VEICULO3.HANDLE = VIAGENS.VEICULO3
           INNER JOIN GLGL_ENUMERACAOITEMS TIPOTRANSFERENCIA ON TIPOTRANSFERENCIA.HANDLE = VIAGENS.TIPOVIAGEM
           INNER JOIN GLOP_VIAGEMDOCUMENTOS VDOC ON (VDOC.VIAGEM = VIAGENS.HANDLE)
		INNER JOIN  (
						SELECT 186 AS TIPO,HANDLE, DOCCLIATUALPESOCONSIDERADO PESOCONSIDERADO FROM GLGL_DOCUMENTOS
						WHERE TIPODOCUMENTO = 6
						UNION ALL
						SELECT 188 AS TIPO,HANDLE, DOCCLIATUALPESOCONSIDERADO PESOCONSIDERADO FROM GLGL_DOCUMENTOS
						WHERE TIPODOCUMENTO = 2
					) DOC ON VDOC.DOCUMENTOLOGISTICA = DOC.HANDLE AND DOC.TIPO = VDOC.TIPODOCUMENTO
		LEFT JOIN GLOP_LINHAVIAGENS LINHAVIAGENS2 ON LINHAVIAGENS2.HANDLE = VIAGENS.LINHAVIAGEMBASECALCULO
		LEFT JOIN GLOP_CONTRATOFRETEVIAGENS VFRETE       
		ON VFRETE.VIAGEM = VIAGENS.Handle
                                                                                                                                                                    
		INNER JOIN GLOP_CONTRATOFRETES FRETE               
			ON FRETE.HANDLE = VFRETE.CONTRATOFRETE                                                                               
			AND FRETE.Status Not In (262, 433, 731)   
                                                                                                                                                                                                               
		LEFT JOIN 
			(
					SELECT 
							CONTRATOFRETE,
							SUM(GENERALIDADES) AS GENERALIDADES,
							SUM(DIARIA) AS DIARIA,
							SUM(PRODUTIVIDADE) AS PRODUTIVIDADE,
							SUM(QUILOMETRAGEM) AS QUILOMETRAGEM,
							SUM(TARIFAADD) AS TARIFAADD,
							SUM(FRETEVEICULO) AS FRETEVEICULO,
							SUM(DESCONTOS) AS DESCONTOS
					FROM (
					SELECT DISTINCT 
							CONTRATOFRETE,
							CASE
								WHEN CLASSIFICACAO = 7 THEN SUM(VALORFINAL)
							ELSE 0
							END AS GENERALIDADES,
							CASE
								WHEN CLASSIFICACAO = 8 THEN SUM(VALORFINAL)
							ELSE 0
							END AS DIARIA,
							CASE
								WHEN CLASSIFICACAO = 9 THEN SUM(VALORFINAL)
							ELSE 0
							END AS PRODUTIVIDADE,
							CASE
								WHEN CLASSIFICACAO = 10 THEN SUM(ISNULL(VALORFINAL,0))
							ELSE 0
							END AS QUILOMETRAGEM,
							CASE
								WHEN CLASSIFICACAO = 13 THEN SUM(VALORFINAL)
							ELSE 0
							END AS TARIFAADD,
							CASE
								WHEN CLASSIFICACAO = 14 THEN SUM(VALORFINAL)
							ELSE 0
							END AS FRETEVEICULO,
							CASE
								WHEN CLASSIFICACAO = 15 THEN SUM(VALORFINAL)
							ELSE 0
							END AS DESCONTOS


					FROM GLOP_CONTRATOFRETCALCULOS

					GROUP BY CONTRATOFRETE, CLASSIFICACAO
					) AS T1

					GROUP BY CONTRATOFRETE
			)AS CALC						 
			ON CALC.CONTRATOFRETE = FRETE.HANDLE

     WHERE TIPOTRANSFERENCIA.HANDLE = 172
       AND VIAGENS.STATUS           <> 179
	  --AND NUMEROVIAGEM = '2018/384006-6'
	  AND VIAGENS.PREVISAOSAIDA >= @DTINICIO
	  AND VIAGENS.PREVISAOSAIDA < @DTFIM

  GROUP BY VIAGENS.NUMEROVIAGEM,
           FILIALORIGEM.NOME,
           FILIALDESTINO.NOME,
           MOTORISTA.NOME,
           BENEFICIARIO.NOME,
           VIAGENS.INICIOEFETIVO,
           VIAGENS.PREVISAOSAIDA,
           ISNULL(LINHAVIAGENS2.NOME, LINHAVIAGENS.NOME),
           VIAGENS.HANDLE,
           VEICULO1.CODIGO,
           VEICULO2.CODIGO,
           VEICULO3.CODIGO,
           VEICULOTIPO.NOME,
           VIAGENS.HANDLE,
		   TARIFAADD
  ORDER BY VIAGENS.NUMEROVIAGEM

---------------------------------------------------------------------------------------------
--DESPESAS
---------------------------------------------------------------------------------------------

SELECT * 

INTO #TempDespesas
FROM
(
SELECT 'AGREGADO'                    AS TIPO,
       CAST(A.NUMERO AS VARCHAR(20)) AS NUMERO,
       A.DATAEMISSAO                 AS DATAEMISSAO,
       STATUS.NOME                   AS STATUS,
       STATUS.HANDLE                 AS HANDLESTATUS,
       A.VALORTOTAL                  AS VALOR,
       C.NOME                        AS BENEFICIARIO,
       C.HANDLE                      AS HANDLEBENEFICIARIO,
       RNTRC.NOME                    AS CLASSIFICACAO,
       RNTRC.HANDLE                  AS HANDLECLASSIFICACAO,
       E.NOME                        AS MOTORISTA,
       E.HANDLE                      AS HANDLEMOTORISTA,
       V.PLACANUMERO                 AS VEICULO,
       V.HANDLE                      AS HANDLEVEICULO,
       VENCIMENTOS.DATAVENCIMENTO    AS VENCIMENTO,
       FLGL.SIGLA                    AS FILIAL,
       FILIAL.HANDLE                 AS HANDLEFILIAL,
       ORDEMSERVICO.CODIGO           AS ORDEM,
       ORDEMSERVICO.DESCRICAO        AS TIPOOS,
       TIPOORDEM.NOME                AS OCORRENCIA,
       TIPOORDEM.HANDLE              AS HANDLEOCORRENCIA,
       TIPOLANC.DESCRICAO            AS TIPOLANCAMENTO,
       --Data de Solicita��o e Recebimento Fiscal adicionado ao relatorio conforme solicita��o do Marcelinho COT e autoriza��o do Sergio Antonio
       --SysAid n� 65992 / 66039 - Incluido o campo Data Inicial no lugar de Data Solicita��o a pedido de Marcelinho e Jandir. SMS 1504961 - 06/02/2018 Giovanni Campos
       --Causa: As AIEs possuem dt Solicita��o diferente da data efetiva do abastecimento, ou seja, a dt solicita��o estava gerando duvidas nos agregados e por isso a mudan�a.
       ORDEMSERVICO.DATAINICIAL      AS DATAINICIAL,     --OS.DATASOLICITACAO                     AS DATASOLICITACAO,
       ORDEMSERVICO.DATARECEBIMENTOFISCAL  AS DATARECEBIMENTOFISCAL,
       A.OBSERVACOES		[OBSERVACOES], --Adicionado por marcusoliveira conforme chamado 50652 passado pelo GiovanniCampos
	   VG.NUMEROVIAGEM

FROM   GLOP_CONTRATODESPESAS A
       INNER JOIN GLGL_ENUMERACAOITEMS STATUS ON A.STATUS = STATUS.HANDLE
       LEFT JOIN GLGL_TIPOLANCAMENTOS TIPOLANC ON TIPOLANC.HANDLE = A.TIPOLANCAMENTO
       LEFT JOIN GN_PESSOAS C ON A.BENEFICIARIO = C.HANDLE
       LEFT JOIN GLGL_PESSOAS C1 ON C1.PESSOA = C.HANDLE
       LEFT JOIN GLGL_ENUMERACAOITEMS RNTRC ON C1.CLASSIFICACAORNTRC = RNTRC.HANDLE
       LEFT JOIN FILIAIS FILIAL ON A.FILIAL = FILIAL.HANDLE
       LEFT JOIN GLGL_FILIAIS FLGL ON FLGL.FILIAL = FILIAL.HANDLE
       LEFT JOIN GN_PESSOAS E ON A.MOTORISTA = E.HANDLE
       LEFT JOIN MA_RECURSOS V ON A.VEICULO = V.HANDLE
       LEFT JOIN GLOP_VIAGENS VG ON A.VIAGEM = VG.HANDLE
       LEFT JOIN GLOP_CIOTTACAGREGADO CIOT ON A.CIOT = CIOT.HANDLE
       LEFT JOIN GLOP_CONTRATODESPVENCTOS VENCIMENTOS ON VENCIMENTOS.CONTRATODESPESA = A.HANDLE
       LEFT JOIN GLOP_CONTRATODESPORDENS DESPORD
       INNER JOIN MF_ORDEMSERVICOS ORDEMSERVICO ON ORDEMSERVICO.HANDLE = DESPORD.ORDEMSERVICO
       INNER JOIN MF_TIPOORDEMSERVICOS TIPOORDEM ON ORDEMSERVICO.TIPOORDEMSERVICO = TIPOORDEM.HANDLE ON DESPORD.CONTRATODESPESA = A.HANDLE
WHERE  A.HANDLE IS NOT NULL
--Filtro criado para utiliza��o da Equipe de Telefonia (Autorizado por Sergio) [Sarah 29/9]
--{IF (([TIPOLANCAMENTO] <> ''), "AND TIPOLANC.HANDLE IN(" + [TIPOLANCAMENTO] + ")", "")}
UNION ALL --Alterado por marcusoliveira conforme chamado 50652 passado pelo GiovanniCampos
SELECT  'TERCEIRO'                         AS TIPO,
        CF.NUMERO                          AS NUMERO,
        CF.DATAEMISSAO                     AS DATAEMISSAO,
        STATUS.NOME                        AS STATUS,
        STATUS.HANDLE                      AS HANDLESTATUS,
        ADT.VALOR                          AS VALOR,
        C.NOME                             AS BENEFICIARIO,
        C.HANDLE                           AS HANDLEBENEFICIARIO,
        RNTRC.NOME                         AS CLASSIFICACAO,
        RNTRC.HANDLE                       AS HANDLECLASSIFICACAO,
        E.NOME                             AS MOTORISTA,
        E.HANDLE                           AS HANDLEMOTORISTA,
        V.PLACANUMERO                      AS VEICULO,
        V.HANDLE                           AS HANDLEVEICULO,
        CONVERT(DATE, CF.DATAEMISSAO, 103) AS DATAVENCIMENTO,
        FLGL.SIGLA                         AS FILIAL,
        FILIAL.HANDLE                      AS HANDLEFILIAL,
        OS.CODIGO                          AS ORDEM,
        OS.DESCRICAO                       AS TIPOOS,
        TPOS.NOME                          AS OCORRENCIA,
        TPOS.HANDLE                        AS HANDLEOCORRENCIA,
        TPLANC.DESCRICAO                   AS TIPOLANCAMENTO,
        --Data de Solicita��o e Recebimento Fiscal adicionado ao relatorio conforme solicita��o do Marcelinho COT
        --e autoriza��o do Sergio Antonio
		OS.DATAINICIAL                     AS DATAINICIAL,   --OS.DATASOLICITACAO                     AS DATASOLICITACAO,
        --SysAid n� 65992 / 66039 - Incluido o campo Data Inicial no lugar de Data Solicita��o a pedido de Marcelinho e Jandir. SMS 1504961 - 06/02/2018 Giovanni Campos
        --Causa: As AIEs possuem dt Solicita��o diferente da data efetiva do abastecimento, ou seja, a dt solicita��o estava gerando duvidas nos agregados e por isso a mudan�a.
        OS.DATARECEBIMENTOFISCAL           AS DATARECEBIMENTOFISCAL,
        GLOP_CONTRATODESPESAS.OBSERVACOES  [OBSERVACOES], --Adicionado por marcusoliveira conforme chamado 50652 passado pelo GiovanniCampos
		'' AS NUMEROVIAGEM

FROM    GLMF_OSVIAGEMCF OSCF
INNER JOIN GLOP_CONTRATOFRETEADTDSPS ADT ON OSCF.ADIANTAMENTODESPESA = ADT.HANDLE
INNER JOIN GLGL_TIPOLANCAMENTOS TPLANC ON ADT.TIPOLANCAMENTO = TPLANC.HANDLE
INNER JOIN GLOP_CONTRATOFRETES CF ON OSCF.CONTRATOFRETE = CF.HANDLE
INNER JOIN GLGL_ENUMERACAOITEMS STATUS ON CF.STATUS = STATUS.HANDLE
INNER JOIN MF_ORDEMSERVICOS OS ON OS.HANDLE = OSCF.ORDEMSERVICO
INNER JOIN MF_TIPOORDEMSERVICOS TPOS ON OS.TIPOORDEMSERVICO = TPOS.HANDLE
INNER JOIN GN_PESSOAS C ON CF.BENEFICIARIO = C.HANDLE
INNER JOIN GLGL_PESSOAS C1 ON C1.PESSOA = C.HANDLE
INNER JOIN GLGL_ENUMERACAOITEMS RNTRC ON C1.CLASSIFICACAORNTRC = RNTRC.HANDLE
LEFT  JOIN GN_PESSOAS E ON CF.MOTORISTA = E.HANDLE
INNER JOIN MA_RECURSOS V ON CF.VEICULO = V.HANDLE
INNER JOIN FILIAIS FILIAL ON CF.FILIAL = FILIAL.HANDLE
INNER JOIN GLGL_FILIAIS FLGL ON FLGL.FILIAL = FILIAL.HANDLE
LEFT JOIN GLOP_CONTRATODESPESAS On GLOP_CONTRATODESPESAS.HANDLE = ADT.CONTRATODESPESA --Adicionado por marcusoliveira conforme chamado 50652 passado pelo GiovanniCampos


WHERE CF.STATUS <> 433
) AS DESPESAS
WHERE 0=0
AND DATAINICIAL >= '2016-01-01'
AND DATAINICIAL < @DTFIM
AND STATUS in ('Aguardando D�bito')

ORDER BY DATAEMISSAO

-------------------------------------------------------------------------------------------------------------------------
--Somente viagens mistas
-------------------------------------------------------------------------------------------------------------------------

SELECT DISTINCT  
	
	VIAGENS.NUMEROVIAGEM
	,VEICULO1.CODIGO AS PLACA
	,VEICULO2.CODIGO AS REBOQUE
	,VEICULO3.CODIGO AS TERCEIRAPLACA
	,VEICULOTIPO.NOME AS TIPOVEICULO
	,FILIALORIGEM.NOME     AS LINHAVIAGEM
	,MOTORISTA.NOME AS MOTORISTA
	,BENEFICIARIO.NOME AS BENEFICIARIO
	,'' AS DATAPREVISAOSAIDA
	,0 AS PESOREAL
	,0 AS VALORTOTALMERCADORIA
	,0 AS KMTOTAL
	,0 AS VALORPORKMLV
	,0 AS VALORTRANSFERENCIA
	,SUM(ISNULL(FRETE.VALORTOTAL,0)) AS [Valor Distribui��o]
	,0 AS FRETECOMBINADO
	,0 AS VALORBRUTO
	,0 AS [Valor Descontos]
	--,VENCIMENTO
	,'' AS TIPOLANCAMENTO

INTO #TempViagensMistas
FROM GLOP_VIAGENS VIAGENS
INNER JOIN FILIAIS FILIALORIGEM ON FILIALORIGEM.HANDLE = VIAGENS.FILIALORIGEM
INNER JOIN GLOP_VIAGEMDOCUMENTOS VIAGEMDOCUMENTOS
   ON VIAGEMDOCUMENTOS.VIAGEM = VIAGENS.HANDLE
INNER JOIN MA_RECURSOS VEICULO1 ON VEICULO1.HANDLE = VIAGENS.VEICULO1
INNER JOIN GLOP_CONTRATOFRETEVIAGENS VFRETE       
	ON VFRETE.VIAGEM = VIAGENS.Handle
INNER JOIN GLOP_CONTRATOFRETES FRETE               
	ON FRETE.HANDLE = VFRETE.CONTRATOFRETE  
LEFT JOIN MA_RECURSOS VEICULO2 ON VEICULO2.HANDLE = VIAGENS.VEICULO2
LEFT JOIN MA_RECURSOS VEICULO3 ON VEICULO3.HANDLE = VIAGENS.VEICULO3
INNER JOIN MF_VEICULOTIPOS VEICULOTIPO ON VEICULOTIPO.HANDLE = VEICULO1.TIPOVEICULO
LEFT JOIN GN_PESSOAS MOTORISTA ON MOTORISTA.HANDLE = VIAGENS.MOTORISTA
LEFT JOIN GN_PESSOAS BENEFICIARIO ON BENEFICIARIO.HANDLE = VEICULO1.PROPRIETARIO


WHERE 1=1
--AND NUMEROVIAGEM = '2019/331909-2'
AND TIPOVIAGEM = 173
AND VIAGENS.PREVISAOSAIDA >= @DTINICIO
AND VIAGENS.PREVISAOSAIDA < @DTFIM
--AND VEICULO1.CODIGO = 'AQV6040'
AND FRETE.STATUS <> 433

GROUP BY 
		VIAGENS.NUMEROVIAGEM
		,VEICULO1.CODIGO
		,VEICULO2.CODIGO
		,VEICULO3.CODIGO
		,VEICULOTIPO.NOME
		,MOTORISTA.NOME
		,BENEFICIARIO.NOME
		,FILIALORIGEM.NOME

-------------------------------------------------------------------------------------------------------------------------
--Resultado Final
-------------------------------------------------------------------------------------------------------------------------
SELECT  DISTINCT 
	TIPO
	,NUMEROVIAGEM
	,PLACA
	,REBOQUE
	,TERCEIRAPLACA
	,TIPOVEICULO
	,LINHAVIAGEM
	,MOTORISTA
	,BENEFICIARIO
	,DATAPREVISAOSAIDA
	,PESOREAL
	,VALORTOTALMERCADORIA
	,KMTOTAL
	,VALORPORKMLV
	,VALORTRANSFERENCIA
	,SUM([Valor Distribui��o]) AS [Valor Distribui��o]
	,FRETECOMBINADO
	,VALORBRUTO
	--,SUM([Valor Descontos]) AS [Valor Descontos]
	--,VENCIMENTO
	--,TIPOLANCAMENTO
	,SUM(ISNULL([''],0)) AS MISTA
	,SUM(ISNULL([Abastecimento],0)) AS [Abastecimento]
	,SUM(ISNULL([Multas],0)) AS [Multas]
	,SUM(ISNULL([Rastreamento],0)) AS [Rastreamento]
	,SUM(ISNULL([Trava e Cong�neres],0)) AS [Trava e Cong�neres]
	,(SUM(ISNULL([''],0))+SUM(ISNULL([Abastecimento],0))+SUM(ISNULL([Multas],0))+SUM(ISNULL([Rastreamento],0))+SUM(ISNULL([Trava e Cong�neres],0))-VALORBRUTO) AS VALORLIQUIDO
FROM (
SELECT  DISTINCT 
	'Transferencia' AS TIPO
	,A.NUMEROVIAGEM
	,A.PLACA
	,REBOQUE
	,TERCEIRAPLACA
	,TIPOVEICULO
	,LINHAVIAGEM
	,A.MOTORISTA
	,A.BENEFICIARIO
	,DATAPREVISAOSAIDA
	,PESOREAL
	,VALORTOTALMERCADORIA
	,KMTOTAL
	,VALORPORKMLV
	,VALORTOTALCONTRATOFRETE AS VALORTRANSFERENCIA
	,0 AS [Valor Distribui��o]
	,A.TARIFAADD AS FRETECOMBINADO
	,VALORTOTALCONTRATOFRETE AS VALORBRUTO
	,B.VALOR AS [Valor Descontos]
	,B.VENCIMENTO
	,TIPOLANCAMENTO

FROM #TempAcompanhamentoViagens A
INNER JOIN #TempDespesas B ON A.PLACA = B.VEICULO
--LEFT JOIN #TempViagensMistas C ON A.PLACA = C.PLACA

UNION ALL

SELECT  DISTINCT 
	'Mista' AS TIPO
	,NUMEROVIAGEM
	,PLACA
	,REBOQUE
	,TERCEIRAPLACA
	,TIPOVEICULO
	,LINHAVIAGEM
	,MOTORISTA
	,BENEFICIARIO
	,DATAPREVISAOSAIDA
	,PESOREAL
	,VALORTOTALMERCADORIA
	,KMTOTAL
	,VALORPORKMLV
	,VALORTRANSFERENCIA
	,[Valor Distribui��o]
	,FRETECOMBINADO
	,VALORBRUTO
	,0 AS [Valor Descontos]
	,'' AS VENCIMENTO
	,TIPOLANCAMENTO

FROM #TempViagensMistas 
) AS T1
PIVOT (
    MAX([Valor Descontos])
    FOR TIPOLANCAMENTO IN
    ([''], [Abastecimento], [Multas], [Rastreamento], [Trava e Cong�neres])


) AS pvt
--WHERE A.NUMEROVIAGEM = '2019/331054-2'

GROUP BY
	TIPO
	,NUMEROVIAGEM
	,PLACA
	,REBOQUE
	,TERCEIRAPLACA
	,TIPOVEICULO
	,LINHAVIAGEM
	,MOTORISTA
	,BENEFICIARIO
	,DATAPREVISAOSAIDA
	,PESOREAL
	,VALORTOTALMERCADORIA
	,KMTOTAL
	,VALORPORKMLV
	,VALORTRANSFERENCIA
	,FRETECOMBINADO
	,VALORBRUTO
	--,VENCIMENTO