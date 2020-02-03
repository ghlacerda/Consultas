--CAMPO								DESCRIÇÃO										OBSERVAÇÃO	EXEMPLO
--ok--					CNPJ do pagador do frete						O campo deve ser numérico sem caracteres como ".", "/" ou "-"	77388007000157
--OK--						Data de emisão do frete							Campo data, sem necessidade de hora.	24/01/2020
--ok--									Número do CTE									Campo numérico, sem ponto ou vírgula para separar milhar e decimal	2783
--ok--								Número da NF									Campo numérico, sem ponto ou vírgula para separar milhar e decimal	31500
--ok--					Filial de origem do frete						Campo caracter	São Paulo - SÃO
--ok--						UF de origem do frete							Campo caracter	SP
--ok--					Cidade de origem do frete						Campo caracter	COTIA
--OK--					CNPJ do emitente								O campo deve ser numérico sem caracteres como ".", "/" ou "-"	67957092000173
--OK--			Razão social do emitente						Campo caracter	VANTAGE SPECIALTY CHEMICALS INSUMOS COSMETICOS E FARMACEUTICOS LTDA.
--OK--				CNPJ do destinatário							O campo deve ser numérico sem caracteres como ".", "/" ou "-"	77388007000157
--OK--				Nome do destinatário							Campo caracter	BOTICA COMERCIAL FARMACEUTICA LTDA
--OK--						Valor da NF em reais							Campo numérico, com ponto para separar milhar e vírgula para separar decimal	3.891,76
--OK--				Volume transportado								Campo numérico, com ponto para separar milhar, sem necessidade de decimal	1.254
--OK--							Peso nota										Campo numérico, com ponto para separar milhar e vírgula para separar decimal	1.637,72
--OK--							Peso cubado										Campo numérico, com ponto para separar milhar e vírgula para separar decimal	2.000,00
--OK--						Peso cobrado									Campo numérico, com ponto para separar milhar e vírgula para separar decimal	2.000,00
--OK--							Valor do frete peso								Campo numérico, com ponto para separar milhar e vírgula para separar decimal	1.000,00
--ok--							Valor do frete									Campo numérico, com ponto para separar milhar e vírgula para separar decimal	110,99
--ok--								Valor do GRIS									Campo numérico, com ponto para separar milhar e vírgula para separar decimal	110,99
--OK--						Valor da taxa de coleta							Campo numérico, com ponto para separar milhar e vírgula para separar decimal	0,00
--OK--								Valor do pedágio								Campo numérico, com ponto para separar milhar e vírgula para separar decimal	10,00
--OK--						Alíquota de imposto								Campo numérico, com vírgula para separar decimal	7,00
--OK--						Valor do imposto								Campo numérico, com ponto para separar milhar e vírgula para separar decimal	92,73
--OK--				Valor do frete sem líquido de imposto			Campo numérico, com ponto para separar milhar e vírgula para separar decimal	1.231,98
--OK--FRETE TOTAL							Valor total do frete							Campo numérico, com ponto para separar milhar e vírgula para separar decimal	1.324,71


Select 
		REPLACE(REPLACE(REPLACE(GN_PESSOASTOM.CGCCPF,'.',''),'-',''),'/','') AS [PAGADOR DO FRETE],
		CAST(GLGL_DOCUMENTOS.DATAEMISSAO AS DATE) AS [DATA DE EMISSAO],
		GLGL_DOCUMENTOS.NUMERO AS [CTE],
		STUFF((Select ', ' + Cast(GLGL_DOCUMENTOCLIENTES.NUMERO		As VarChar(50))
                From GLGL_DOCUMENTOASSOCIADOS
			   Inner Join GLGL_DOCUMENTOCLIENTES
				  On GLGL_DOCUMENTOCLIENTES.HANDLE					= GLGL_DOCUMENTOASSOCIADOS.DOCUMENTOCLIENTE
               Where GLGL_DOCUMENTOASSOCIADOS.DOCUMENTOLOGISTICA	= GLGL_DOCUMENTOS.HANDLE
                For XML PATH ('')), 1, 1, '')					[NOTA],
	   FILIAIS.NOME												[FILIAL DE ORIGEM],
	   ESTADOSORI.SIGLA											[UF DE ORIGEM],
	   MUNICIPIOSORI.NOME										[CIDADE DE ORIGEM],
	   REPLACE(REPLACE(REPLACE(GN_PESSOASREM.CGCCPF,'.',''),'-',''),'/','')[CNPJ DO EMITENTE],
	   GN_PESSOASREM.NOME										[RAZAO SOCIAL DO REMETENTE],
	   REPLACE(REPLACE(REPLACE(GN_PESSOASDES.CGCCPF,'.',''),'-',''),'/','')	[CNPJ DO DESTINATARIO],
	   GN_PESSOASDES.NOME										[NOME DO DESTINATARIO],
	   IsNull(GLGL_DOCUMENTOS.DOCCLIVALORTOTAL, 0)				[VALOR DAS NOTAS],
	   IsNull(GLGL_DOCUMENTOS.DOCCLIATUALVOLUME, 0)				[VOLUMES TRANSPORTADOS],
	   IsNull(GLGL_DOCUMENTOS.DOCCLIPESOTOTAL, 0)				[PESO NOTA],
	   IsNull(GLGL_DOCUMENTOS.DOCCLIPESOCUBADOTOTAL, 0)			[PESO CUBADO],
	   IsNull(GLGL_DOCUMENTOS.DOCCLIATUALPESOCONSIDERADO, 0)	[PESO COBRADO],
	   --Round(IsNull(GLGL_DOCUMENTOS.VALORCONTABIL, 0)/
			 --IIF(IsNull(GLGL_DOCUMENTOS.DOCCLIPESOTOTAL, 0) = 0, 1, GLGL_DOCUMENTOS.DOCCLIPESOTOTAL), 2)	[FRETEPORPESO],
	   IsNull(GLGL_DOCUMENTOS.VALORFRETEPESO, 0)				[FRETE PESO],
	   IsNull(GLGL_DOCUMENTOS.VALORFRETEVALOR, 0)				[FRETE VALOR],
	   IsNull(GLGL_DOCUMENTOS.VALORGRIS, 0)						[GRIS],
	   0 AS [TAXA DE COLETA],
	   IsNull(GLGL_DOCUMENTOS.VALORPEDAGIO, 0)					[PEDAGIO],
	   IsNull(GLGL_DOCUMENTOTRIBUTOS.ALIQUOTAICMS, 0)			[ALIQ IMPOSTO],
	   (ISNULL(GLGL_DOCUMENTOTRIBUTOS.VALORICMS,0) + ISNULL(GLGL_DOCUMENTOTRIBUTOS.VALORICMSST,0) + ISNULL(GLGL_DOCUMENTOTRIBUTOS.VALORISS,0))				[VALOR IMPOSTO],
	   (GLGL_DOCUMENTOS.VALORCONTABIL - (ISNULL(GLGL_DOCUMENTOTRIBUTOS.VALORICMS,0) + ISNULL(GLGL_DOCUMENTOTRIBUTOS.VALORICMSST,0) + ISNULL(GLGL_DOCUMENTOTRIBUTOS.VALORISS,0))) AS [FRETE TOTAL SEM IMPOSTO],
	   GLGL_DOCUMENTOS.VALORCONTABIL							[VALOR FRETE]
	   


	   --MUNICIPIOSDES.NOME										[MUNICIPIODESTINO],
	   --ESTADOSDES.SIGLA											[UFDESTINO],
	   --GN_PESSOASTOM.NOME										[TOMADORSERVICO],
	   --(Select Count(1)
    --      From GLGL_DOCUMENTOASSOCIADOS
	   --  Inner Join GLGL_DOCUMENTOCLIENTES
		  --  On GLGL_DOCUMENTOCLIENTES.HANDLE					= GLGL_DOCUMENTOASSOCIADOS.DOCUMENTOCLIENTE
    --     Where GLGL_DOCUMENTOASSOCIADOS.DOCUMENTOLOGISTICA		= GLGL_DOCUMENTOS.HANDLE)					[QTDNOTAS],
	   --IsNull(GLGL_DOCUMENTOS.VALORTAXADESPACHO, 0)				[DESPACHO],
	   --IsNull(GLGL_DOCUMENTOS.VALOROUTROS, 0)					[OUTROS],
	   --GLGL_DOCUMENTOS.VALORTOTAL								[VALORSEMIMPOSTO],
	   --GLGL_ENUMERACAOITEMS.NOME								[STATUS],
    --   GLGL_DOCUMENTOTRIBUTOS.VALORICMSST                       [ICMSST]
  From GLGL_DOCUMENTOS
 Inner Join GLGL_PESSOAS GLGL_PESSOASREM					On GLGL_PESSOASREM.HANDLE				= GLGL_DOCUMENTOS.REMETENTE
 Inner Join GN_PESSOAS GN_PESSOASREM						On GN_PESSOASREM.HANDLE					= GLGL_PESSOASREM.PESSOA
 Inner Join GLGL_PESSOAS GLGL_PESSOASTOM					On GLGL_PESSOASTOM.HANDLE				= GLGL_DOCUMENTOS.TOMADORSERVICOPESSOA
 Inner Join GN_PESSOAS GN_PESSOASTOM						On GN_PESSOASTOM.HANDLE					= GLGL_PESSOASTOM.PESSOA
 Inner Join GLGL_PESSOAS GLGL_PESSOASDES					On GLGL_PESSOASDES.HANDLE				= GLGL_DOCUMENTOS.DESTINATARIO
 Inner Join GN_PESSOAS GN_PESSOASDES						On GN_PESSOASDES.HANDLE					= GLGL_PESSOASDES.PESSOA
 Inner Join GLGL_FILIAIS									On GLGL_FILIAIS.HANDLE					= GLGL_DOCUMENTOS.FILIAL
 Inner Join FILIAIS											On FILIAIS.HANDLE						= GLGL_FILIAIS.FILIAL
 Inner Join GLGL_PESSOAENDERECOS GLGL_PESSOAENDERECOSORI	On GLGL_PESSOAENDERECOSORI.HANDLE		= GLGL_DOCUMENTOS.REMETENTEENDERECO
 Inner Join MUNICIPIOS MUNICIPIOSORI						On MUNICIPIOSORI.HANDLE					= GLGL_PESSOAENDERECOSORI.MUNICIPIO
 Inner Join ESTADOS ESTADOSORI								On ESTADOSORI.HANDLE					= MUNICIPIOSORI.ESTADO
 Inner Join GLGL_PESSOAENDERECOS GLGL_PESSOAENDERECOSDES	On GLGL_PESSOAENDERECOSDES.HANDLE		= GLGL_DOCUMENTOS.DESTINOENDERECO
 Inner Join MUNICIPIOS MUNICIPIOSDES						On MUNICIPIOSDES.HANDLE					= GLGL_PESSOAENDERECOSDES.MUNICIPIO
 Inner Join ESTADOS ESTADOSDES								On ESTADOSDES.HANDLE					= MUNICIPIOSDES.ESTADO
  Left Join GLGL_DOCUMENTOTRIBUTOS							On GLGL_DOCUMENTOTRIBUTOS.DOCUMENTO		= GLGL_DOCUMENTOS.HANDLE
 Inner Join GLGL_ENUMERACAOITEMS							On GLGL_ENUMERACAOITEMS.HANDLE			= GLGL_DOCUMENTOS.STATUS
 Where (GLGL_DOCUMENTOS.TIPODOCUMENTO						In (1, 2)
    Or (GLGL_DOCUMENTOS.TIPODOCUMENTO						= 6
   And  GLGL_DOCUMENTOS.TIPORPS								<> 324))
AND GN_PESSOASTOM.HANDLE IN (228301,865381)
And Cast(GLGL_DOCUMENTOS.DATAEMISSAO As Date)			Between :DATAINICIAL
									And :DATAFINAL


--AND Cast(GLGL_DOCUMENTOS.DATAEMISSAO As Date) >= '2020-01-01'
--AND Cast(GLGL_DOCUMENTOS.DATAEMISSAO As Date) < '2020-02-01'
