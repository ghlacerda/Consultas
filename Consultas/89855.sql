--================================================================================================================================================
--Acompanhamento de viagens
--================================================================================================================================================

DROP TABLE IF EXISTS #TempReceita
DROP TABLE IF EXISTS #TempDespesas
DROP TABLE IF EXISTS #TempResultado

DECLARE @BeginDate DATE = '2020-03-16'
DECLARE @EndDate DATE = '2020-03-21'
DECLARE @CGCCPF VARCHAR(15) = '01.661.025/0001-07' --tESTEI COM UM CNPJ QUALQUER

SELECT 
		'RECEITA' AS TIPO
		--,'' AS TIPOMOTORISTA
		,v.NUMEROVIAGEM  AS Manifesto
		,PLACA.PLACANUMERO AS Cavalo
		,PLACA2.PLACANUMERO Carreta
		,PLACA3.PLACANUMERO Carreta2
		,ISNULL(ISNULL(LINHAVIAGENS2.NOME, LINHA.NOME), FORIGEM.SIGLA)     AS LINHAVIAGEM
		--,VPARADA.PARADAEFETUADA
		,BENEFICIARIO.CGCCPF AS CGCCPFBENEFICIARIO
		,BENEFICIARIO.NOME BENEFICIARIO
		,MOTORISTA.NOME MOTORISTA
		,CF.DATAEMISSAO AS [DATA]
		,ROUND(CF.VALORQUILOMETRAGEM,2) AS VALORKMCF
		,ROUND(SUM(VDOC.PESO),2) AS PESOREAL
		,ROUND(ISNULL(CF.VALORTOTAL,0),2) AS VALORTOTAL
		,ROUND(ISNULL(NULLIF(CF.VALORTOTAL,0)/NULLIF(VPARADA.DISTANCIAPREVISTA,0),0),2) AS VALORPORKMLV
		,CASE 
			WHEN TRANSBORDADO = 'S' THEN ROUND(NULLIF(V.DISTANCIACONSIDERADA,0),2)
		ELSE ROUND(ISNULL((SELECT SUM(AA.DISTANCIA) FROM GLOP_LINHAVIAGEMFILIAIS AA WHERE AA.LINHAVIAGEM = LINHA.HANDLE),0),2) 
		END	AS KMTOTAL
		--,ROUND(NULLIF(V.DISTANCIACONSIDERADA,0),2) AS KMCONSIDERADO
		,ROUND(SUM(VDOC.VALORTOTAL),2) AS VALORTOTALMERCADORIA
		,ROUND(ISNULL((SELECT SUM(CALC.VALORFINAL) FROM GLOP_CONTRATOFRETCALCULOS CALC WHERE CALC.CONTRATOFRETE = CF.HANDLE AND CALC.CLASSIFICACAO = 13),0),2) TARIFAADD  
		,ISNULL(CFC.OBSERVACAO,'') AS [Observação Frete Combinado CF]
		,'' AS TIPODESPESAS
		,'' AS TIPOOS 
		                                                                                                                                
into #TempReceita
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

LEFT  JOIN GLOP_VIAGEMPARADAS VPARADA ON(VPARADA.VIAGEM = V.HANDLE AND VPARADA.FILIAL = V.FILIALDESTINO)                       
LEFT  JOIN GLOP_LINHAVIAGENS LINHA ON(LINHA.HANDLE = V.LINHAVIAGEM)                                                            
INNER JOIN GLGL_ENUMERACAOITEMS STATUS ON(STATUS.HANDLE = V.STATUS)                                                            
LEFT  JOIN K_GLOP_JUSTIFICATRASOVIAGEM JT ON (JT.HANDLE = V.K_JUSTIFICATIVAATRASO)                                                                            
LEFT  JOIN GLOP_CONTRATOFRETEVIAGENS CFV ON (CFV.VIAGEM = V.HANDLE)                                                                                                   --iNCLUSÃO DE PARCELAS DE PGTO A PEDIDO DO GUSTAVO GER REG MG: ANDRE 27/04/2016
LEFT  JOIN GLOP_CONTRATOFRETES CF ON (CFV.CONTRATOFRETE = CF.HANDLE)                                                                                                          
LEFT JOIN GLOP_FRETECOMBINADOLOGS CFC ON CF.HANDLE = CFC.CONTRATOFRETE AND CFC.HANDLE = (SELECT MAX(A.HANDLE) FROM GLOP_FRETECOMBINADOLOGS A WHERE A.CONTRATOFRETE = CF.HANDLE)
LEFT JOIN GLOP_LINHAVIAGENS LINHAVIAGENS2 WITH(NOLOCK) ON LINHAVIAGENS2.HANDLE = V.LINHAVIAGEMBASECALCULO

WHERE 1=1
--AND V.PREVISAOSAIDA >= '2020-03-16'
--AND V.PREVISAOSAIDA < '2020-03-21'
--AND V.INICIOEFETIVO >= @BeginDate
--AND V.INICIOEFETIVO < @EndDate

AND CF.DATAEMISSAO >= @BeginDate
AND CF.DATAEMISSAO < @EndDate


AND v.DATACANCELAMENTO is null 
AND V.STATUS NOT IN(176,179,747) 
AND (CF.HANDLE IS NULL OR (CF.HANDLE IS NOT NULL AND CF.STATUS NOT IN(731,433)))      

--and v.NUMEROVIAGEM in ('2020/103966-58')

--'2020/090738-9',
--'2020/100623-9',
--'2020/101091-9',
--'2020/105884-11',
--'2020/106483-11',
--'2020/107526-44',
--'2020/108024-11',
--'2020/108231-59'
--)

--AND PLACA.PLACANUMERO = 'DBL4255'


GROUP BY 
		V.NUMEROVIAGEM
		,PLACA.PLACANUMERO 
		,PLACA2.PLACANUMERO
		,PLACA3.PLACANUMERO
		,LINHA.HANDLE
		,ROUND(ISNULL(CF.VALORTOTAL,0),2)
		,ISNULL(ISNULL(LINHAVIAGENS2.NOME, LINHA.NOME), FORIGEM.SIGLA)
		,TRANSBORDADO
		--,VPARADA.PARADAEFETUADA
		,ROUND(CF.VALORQUILOMETRAGEM,2)
		,ROUND(NULLIF(V.DISTANCIACONSIDERADA,0),2)
		,BENEFICIARIO.CGCCPF
		,BENEFICIARIO.NOME
		,MOTORISTA.NOME
		,CF.DATAEMISSAO
		,ISNULL(NULLIF(CF.VALORTOTAL,0)/NULLIF(VPARADA.DISTANCIAPREVISTA,0),0)
		,ISNULL(VPARADA.DISTANCIAPREVISTA,0)
		,CF.HANDLE
		,ISNULL(CFC.OBSERVACAO,'') 


--================================================================================================================================================
--Despesas
--================================================================================================================================================

--DECLARE @BeginDate DATE = '2020-03-16'
--DECLARE @EndDate DATE = '2020-03-21'

SELECT 

	TIPO,
	 --TIPOMOTORISTA,
     Manifesto,
	 Cavalo,
	 Carreta,
     Carreta2,
	 LINHAVIAGEM,
	 CGCCPFBENEFICIARIO,
	 BENEFICIARIO,
	 MOTORISTA,
	 [DATA],
	 0 as VALORKMCF,
	 PESOREAL,
     ([Total NF]*(-1)) as [VALORTOTAL],
	 (VALORPORKMLV*(-1)) as VALORPORKMLV,
	 (KMTOTAL*(-1)) as KMTOTAL,
	--([Valor Bruto]*(-1)) as [Valor Bruto],
	 0 AS VALORTOTALMERCADORIA,
	 [Tarifas adicionais] as TARIFAADD,
	 '' AS [Observação Frete Combinado CF],
     --OBSERVACOES 
	 TIPODESPESAS,
	 TIPOOS

INTO #TempDespesas
FROM

(

SELECT 

	  'Despesas' AS TIPO,
	  'AGREGADO'                    AS TIPOMOTORISTA,
      CAST(A.NUMERO AS VARCHAR(20)) AS Manifesto,
	  V.PLACANUMERO                 AS Cavalo,
	  '' AS Carreta,
      '' AS Carreta2,
	  '' AS LINHAVIAGEM,
	  C.CGCCPF AS CGCCPFBENEFICIARIO,
	  C.NOME                        AS BENEFICIARIO,
	  E.NOME                        AS MOTORISTA,
	  VENCIMENTOS.DATAVENCIMENTO                 AS [DATA],
	  '' AS PESOREAL,
	  '' AS PESOCUBADO,
	  '' AS PESOCONSIDERADO,
      A.VALORTOTAL                  AS [Total NF],
	  '' AS VALORPORKMLV,
	  '' AS KMTOTAL,
	  '' AS [Valor Bruto],
	  '' AS [Tarifas adicionais],
      --A.OBSERVACOES 
	  TIPOLANC.DESCRICAO AS TIPODESPESAS,
	  TIPOORDEM.NOME AS TIPOOS
 

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



UNION ALL --Alterado por marcusoliveira conforme chamado 50652 passado pelo GiovanniCampos

SELECT  

	'Despesas' AS TIPO,
	  'TERCEIRO'                    AS TIPOMOTORISTA,
      CF.NUMERO AS Manifesto,
	  V.PLACANUMERO                 AS Cavalo,
	  '' AS Carreta,
      '' AS Carreta2,
	  '' AS LINHAVIAGEM,
	  C.CGCCPF AS CGCCPFBENEFICIARIO,
	  C.NOME                        AS BENEFICIARIO,
	  E.NOME                        AS MOTORISTA,
	  CF.DATAVENCIMENTO                 AS [DATA],
	  '' AS PESOREAL,
	  '' AS PESOCUBADO,
	  '' AS PESOCONSIDERADO,
      ADT.VALOR                  AS [Total NF],
	  '' AS VALORPORKMLV,
	  '' AS KMTOTAL,
	  '' AS [Valor Bruto],
	  '' AS [Tarifas adicionais],
      --GLOP_CONTRATODESPESAS.OBSERVACOES
	  TPLANC.DESCRICAO AS TIPODESPESAS,
	  TPOS.NOME AS TIPOOS
 

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

AND [DATA] >= @BeginDate
AND [DATA] < @EndDate
--AND Cavalo = 'HSI1073'

 

ORDER BY [DATA]

--==============================================================================================================================
--Cria tabela de resultado
--==============================================================================================================================

SELECT 
		*
into #TempResultado
FROM #TempReceita A

union all

SELECT  
		* 
FROM  #TempDespesas 


--==============================================================================================================================
--Mostra resultado
--==============================================================================================================================

--Não está puxando a distancia considerada quando há transbordo na viagem (segue no primeiro anexo campo que deve ser considerado neste caso); ok
--Quando é viagem que seguiu transbordo, não está fazendo o cálculo de Valor/Km; ok
--A coluna “VALORPORKMLV" deve ser a divisão entre as colunas “VALORKMCF" por “KMTOTAL" o que não está acontecendo, está sendo feita a divisão do “VALORTOTAL” por “KMTOTAL"; ok
--Verificar possibilidade de ordenar para primeiro ser as receitas e depois as despesas, mesmo formato que temos hoje;
--Retirar a coluna “TIPOOS", apresentaremos apenas a “TIPODESPESAS"; ok
--Alterar nome das colunas conforme segundo anexo;
--Na coluna “DATA” no caso das viagens puxar a data do contrato de frete;
--Para as despesas, deve se considerar a data de vencimento para entrar no relatório, parece estar pegando a data de emissão.


--Rank	TIPO	Manifesto/Despesa	Cavalo	Carreta	Carreta2	Linha de Viagem	Beneficiário	Motorista	Data	Peso	Vr Carga	Tarifas Ad.	Vr Viagem	Vr/Km	Km	Vr Total	Obs	Tipo Despesa

select 
	RANK() OVER  (PARTITION BY cavalo ORDER BY CASE
			WHEN TR.TIPO = 'Despesas' THEN 1
		ELSE 2
		END DESC, [DATA]) AS Rank,
	TR.TIPO,
    Manifesto as [Manifesto/Despesa],
	Cavalo,
	Carreta,
    Carreta2,
	LINHAVIAGEM as [Linha de Viagem],
	CGCCPFBENEFICIARIO,
	BENEFICIARIO as [Beneficiário],
	GNP.LOGRADOURO,
	GNP.BAIRRO,
	GNP.CEP,
	GNP.COMPLEMENTO,
	TR.MOTORISTA as [Motorista],
	CAST([DATA] AS DATE) AS [Data],
	ROUND(PESOREAL,2) AS Peso,
	ROUND(VALORTOTALMERCADORIA,2) AS [Vr Carga],
	ROUND(TARIFAADD,2) AS [Tarifas ad.],
	ROUND(VALORKMCF,2) AS [Vr Viagem],
	--ROUND(VALORPORKMLV,2) AS VALORPORKMLV,
	
	ISNULL(ROUND(VALORKMCF
	/
	NULLIF(ROUND(KMTOTAL,2),0),2),0) AS [Vr/Km],
	--ROUND(KMTOTAL,2) AS KMTOTAL,
	ROUND(KMTOTAL,2) AS Km,
	--ROUND(KMCONSIDERADO,2) AS KMCONSIDERADO,
    ROUND([VALORTOTAL],2) AS [Vr Total],
	[Observação Frete Combinado CF] as Obs,
	TIPODESPESAS as [Tipo Despesa]
	--TIPOOS
    
from #TempResultado TR
LEFT  JOIN GN_PESSOAS GNP ON TR.CGCCPFBENEFICIARIO = GNP.CGCCPF
WHERE CGCCPFBENEFICIARIO = @CGCCPF

--where Manifesto = '2020/102076-11'