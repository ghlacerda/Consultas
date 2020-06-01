--Select [Filial]				[FILIAL],
--	   [Ano]				[ANO],
--	   [Mês]				[MES],
--	   [Peso Considerado]	[PESO],
--	   [Volumes]			[VOLUME],
--	   [Receita]			[RECEITA]
--  Into #TPLAN
--  From OPENROWSET('Microsoft.ACE.OLEDB.12.0', 'Excel 12.0; Database=\\fileserverazure\tarifas$\BASE_POWER_BI_NÃOMEXER\Orcamento_Receita_Unidades.xlsx', [Orcamento_Matriz$]) TB

DROP TABLE IF EXISTS #TPLAN
SELECT [Filial]				[FILIAL],
	   [Ano]				[ANO],
	   [Mês]				[MES],
	   [Peso Considerado]	[PESO],
	   [Volumes]			[VOLUME],
	   [Receita]			[RECEITA]
  Into #TPLAN


FROM [BI_PATRUS].[dbo].[Orcamento_Matriz]


DECLARE @DATAINICIAL	DATE
DECLARE @DATAFINAL		DATE
Declare @TBDIAS			Table (HANDLE				Int	,
							   NOME					VarChar(200),
							   DATA					Date,
							   [Frete Total]		Float,
							   [Volume Total]		Float,
							   [Peso Total]			Float,
							   [Qntde Docs]			Float,
							   METARECEITA			Float,
							   METAPESO				Float,
							   METAVOLUME			Float)

SET @DATAINICIAL    = Cast(DateAdd(Day, ((Day(GetDate())-1)*(-1)), DateAdd(Month, ((Month(GetDate())-1)*(-1)), DateAdd(Year, 0, GetDate()))) As Date)
SET @DATAFINAL      = Cast(EoMonth(DateAdd(Month, ((Month(GetDate())-12)*(-1)), DateAdd(Year, 0, GetDate()))) As Date);

With DATA (Dia) 
	AS (Select @DATAINICIAL
		 Union All
		Select DateAdd(Day, 1, C.Dia)
		  From DATA C
		 Where C.Dia < @DATAFINAL)

Insert Into @TBDIAS
Select GLGL_FILIAIS.HANDLE, 
	   FILIAIS.NOME,  
	   Data.dia [Dia],
	   0 [Frete Total], 
	   0 [Volume Total], 
	   0 [Peso Total], 
	   0 [Qntde Docs],
	   IsNull(
	   IIF(DatePart(DW, DATA.DIA) In (1, 7), 0,
			(Select TPLAN.RECEITA
			   From #TPLAN TPLAN
			  Where TPLAN.FILIAL	= FILIAIS.NOME				Collate SQL_Latin1_General_CP1_CI_AS
			    And TPLAN.ANO		= Year(DATA.DIA)			
			    And TPLAN.MES		= Case Month(DATA.DIA)
										   When 01 Then 'Janeiro'
										   When 02 Then 'Fevereiro'
										   When 03 Then 'Março'
										   When 04 Then 'Abril'
										   When 05 Then 'Maio'
										   When 06 Then 'Junho'
										   When 07 Then 'Julho'
										   When 08 Then 'Agosto'
										   When 09 Then 'Setembro'
										   When 10 Then 'Outubro'
										   When 11 Then 'Novembro'
										   When 12 Then 'Dezembro'
									  End						Collate SQL_Latin1_General_CP1_CI_AS)/	   
			(Day(EoMonth(DATA.DIA))-
			((DateDiff(WK, DateAdd(Day, ((Day(DATA.DIA)-1)*(-1)), DATA.DIA), EoMonth(DATA.DIA)) * 2)	+ 
			IIF(DatePart(DW, DateAdd(Day, ((Day(DATA.DIA)-1)*(-1)), DATA.DIA)) In (1, 7), 1, 0)			+ 
			IIF(DatePart(DW, EoMonth(DATA.DIA)) In (1, 7), 1, 0)))), 0)							[METARECEITA],
	   IsNull(
	   IIF(DatePart(DW, DATA.DIA) In (1, 7), 0,
			(Select TPLAN.PESO
			   From #TPLAN TPLAN
			  Where TPLAN.FILIAL	= FILIAIS.NOME				Collate SQL_Latin1_General_CP1_CI_AS
			    And TPLAN.ANO		= Year(DATA.DIA)			
			    And TPLAN.MES		= Case Month(DATA.DIA)
										   When 01 Then 'Janeiro'
										   When 02 Then 'Fevereiro'
										   When 03 Then 'Março'
										   When 04 Then 'Abril'
										   When 05 Then 'Maio'
										   When 06 Then 'Junho'
										   When 07 Then 'Julho'
										   When 08 Then 'Agosto'
										   When 09 Then 'Setembro'
										   When 10 Then 'Outubro'
										   When 11 Then 'Novembro'
										   When 12 Then 'Dezembro'
									  End						Collate SQL_Latin1_General_CP1_CI_AS)/	   
			(Day(EoMonth(DATA.DIA))-
			((DateDiff(WK, DateAdd(Day, ((Day(DATA.DIA)-1)*(-1)), DATA.DIA), EoMonth(DATA.DIA)) * 2)	+ 
			IIF(DatePart(DW, DateAdd(Day, ((Day(DATA.DIA)-1)*(-1)), DATA.DIA)) In (1, 7), 1, 0)			+ 
			IIF(DatePart(DW, EoMonth(DATA.DIA)) In (1, 7), 1, 0)))), 0)							[METAPESO],
	   IsNull(
	   IIF(DatePart(DW, DATA.DIA) In (1, 7), 0,
			(Select TPLAN.VOLUME
			   From #TPLAN TPLAN
			  Where TPLAN.FILIAL	= FILIAIS.NOME				Collate SQL_Latin1_General_CP1_CI_AS
			    And TPLAN.ANO		= Year(DATA.DIA)			
			    And TPLAN.MES		= Case Month(DATA.DIA)
										   When 01 Then 'Janeiro'
										   When 02 Then 'Fevereiro'
										   When 03 Then 'Março'
										   When 04 Then 'Abril'
										   When 05 Then 'Maio'
										   When 06 Then 'Junho'
										   When 07 Then 'Julho'
										   When 08 Then 'Agosto'
										   When 09 Then 'Setembro'
										   When 10 Then 'Outubro'
										   When 11 Then 'Novembro'
										   When 12 Then 'Dezembro'
									  End						Collate SQL_Latin1_General_CP1_CI_AS)/	   
			(Day(EoMonth(DATA.DIA))-
			((DateDiff(WK, DateAdd(Day, ((Day(DATA.DIA)-1)*(-1)), DATA.DIA), EoMonth(DATA.DIA)) * 2)	+ 
			IIF(DatePart(DW, DateAdd(Day, ((Day(DATA.DIA)-1)*(-1)), DATA.DIA)) In (1, 7), 1, 0)			+ 
			IIF(DatePart(DW, EoMonth(DATA.DIA)) In (1, 7), 1, 0)))), 0)							[METAVOLUME]
  From DATA 
 Cross Join FILIAIS
 Inner Join GLGL_FILIAIS	On GLGL_FILIAIS.FILIAL	= FILIAIS.HANDLE
 Where FILIAIS.EMPRESA								= 1
   And (GLGL_FILIAIS.CLASSIFICACAO					= 2
    Or  GLGL_FILIAIS.CLASSIFICACAO					Is Null)
Option (maxrecursion 10000);

Select TB1.HANDLE,
	   TB1.NOME,
	   TB1.Data,
	   Sum(TB1.[Frete Total])			[Frete Total],
	   Sum(TB1.[Volume Total])			[Volume Total],
	   Sum(TB1.[Peso Total])			[Peso Total],
	   Sum(IsNull(TB1.[Qntde Docs], 0))	[Qntde Docs]
  Into #TBCPRINC
  From (Select FILIAIS.HANDLE,
			   FILIAIS.NOME,
			   IIF((Month(GLGL_DOCUMENTOS.DATAEMISSAO) = 2 And Day(GLGL_DOCUMENTOS.DATAEMISSAO) > 28), DateAdd(Day, 28-Day(GLGL_DOCUMENTOS.DATAEMISSAO), Cast(GLGL_DOCUMENTOS.DATAEMISSAO As Date)), 
																									   Cast(GLGL_DOCUMENTOS.DATAEMISSAO As Date)) [Data],
			   IsNull(GLGL_DOCUMENTOS.VALORCONTABIL, 0)																													[Frete Total],
			   IsNull(GLGL_DOCUMENTOS.DOCCLIVOLUME, 0)																													[Volume Total],
			   IsNull(GLGL_DOCUMENTOS.DOCCLIPESOTOTAL, 0)																												[Peso Total],
			   Cast(IIF(GLGL_DOCUMENTOS.TIPODOCUMENTO In (22, 13), (Select Count(*) [Qtde]
																	  From GLGL_DOCLOGASSOCIADOS
																	 Where GLGL_DOCLOGASSOCIADOS.DOCUMENTOLOGISTICAPAI = GLGL_DOCUMENTOS.HANDLE), 1) As float)			[Qntde Docs]
		  --Into #TBCPRINC
		  From GLGL_DOCUMENTOS
		 Inner Join GLGL_FILIAIS
			On GLGL_FILIAIS.HANDLE									= GLGL_DOCUMENTOS.FILIAL
		 Inner Join FILIAIS
			On FILIAIS.HANDLE										= GLGL_FILIAIS.FILIAL
		  Left Join GLGL_PESSOACONFIGURACOES
			On GLGL_PESSOACONFIGURACOES.PESSOALOGISTICA				= GLGL_DOCUMENTOS.REMETENTE
		 Where GLGL_DOCUMENTOS.STATUS								Not In (224, 404)
		   And GLGL_DOCUMENTOS.STATUS								Not In (220, 223, 236, 237, 417)
		   And GLGL_DOCUMENTOS.FRETECORTESIA						= 'N'
		   And (GLGL_FILIAIS.CLASSIFICACAO							= 2
		    Or  GLGL_FILIAIS.CLASSIFICACAO							Is Null)
		   And ((GLGL_DOCUMENTOS.TIPODOCUMENTO						In (1, 2, 17, 22))
			Or (GLGL_DOCUMENTOS.TIPODOCUMENTO						In (6)
		   And GLGL_DOCUMENTOS.TIPORPS								<> 323
		   And Not Exists (Select 1
							 From GLGL_DOCLOGASSOCIADOS DLA
							Inner Join GLGL_DOCUMENTOS NFS 
							   On (DLA.DOCUMENTOLOGISTICAPAI		= NFS.HANDLE)
								Where DLA.DOCUMENTOLOGISTICAFILHO		= GLGL_DOCUMENTOS.HANDLE
							  And NFS.TIPODOCUMENTO					In (1, 2, 17, 22)
							  And NFS.FRETECORTESIA					= 'N'
							  And NFS.STATUS						Not In (224, 404)
							  And NFS.STATUS						Not In (220, 223, 236, 237, 417))))   
		   And Cast(GLGL_DOCUMENTOS.DATAEMISSAO As Date)			>= @DATAINICIAL
		   And Cast(GLGL_DOCUMENTOS.DATAEMISSAO As Date)			<= @DATAFINAL
		   And GLGL_DOCUMENTOS.SISTEMAORIGEM						= 3) TB1
 Group By TB1.HANDLE,
		  TB1.NOME,
		  TB1.Data

Select HANDLE,
	   NOME,
	   REGIONAL,
	   DATA,
	   CATEGORIA,
	   VALOR,
	   Case CATEGORIA 
			When 'Frete Total'	Then METARECEITA
			When 'Volume Total'	Then METAVOLUME
			When 'Peso Total'	Then METAPESO
			When 'TKM Peso'		Then METATKMPESO
			When 'TKM Volume'	Then METATKMVOLUME
	   End [META]
  From (Select TBDIAS.HANDLE,
			   TBDIAS.NOME,
			   Case ESTADOS.SIGLA
					When 'CE' Then 'Regional Nordeste'
					When 'RN' Then 'Regional Nordeste'
					When 'PB' Then 'Regional Nordeste'
					When 'PE' Then 'Regional Nordeste'
					When 'AL' Then 'Regional Nordeste'
					When 'SE' Then 'Regional Nordeste'
					When 'BA' Then 'Regional Nordeste'
					When 'MG' Then 'Regional MG'
					When 'ES' Then 'Regional ES'
					When 'RJ' Then 'Regional RJ'
					When 'SP' Then 'Regional SP'
					When 'PR' Then 'Regional Sul'
					When 'SC' Then 'Regional Sul'
					When 'RS' Then 'Regional Sul'
			   End																			[REGIONAL],
			   TBDIAS.DATA,
			   IsNull(TBPRINC.[Frete Total], TBDIAS.[Frete Total])							[Frete Total],
			   IsNull(TBPRINC.[Volume Total], TBDIAS.[Volume Total])						[Volume Total],
			   IsNull(TBPRINC.[Peso Total], TBDIAS.[Peso Total])							[Peso Total],	   
			   IsNull(IsNull(TBPRINC.[Frete Total], TBDIAS.[Frete Total])/
					  NULLIF(IsNull(TBPRINC.[Peso Total], TBDIAS.[Peso Total]), 0), 0)		[TKM Peso],
			   IsNull(IsNull(TBPRINC.[Frete Total], TBDIAS.[Frete Total])/
					  NULLIF(IsNull(TBPRINC.[Volume Total], TBDIAS.[Volume Total]), 0), 0)	[TKM Volume],
			   METARECEITA,
			   METAPESO,
			   METAVOLUME,
			   IsNull(METARECEITA/NULLIF(METAPESO, 0), 0)									[METATKMPESO],
			   IsNull(METARECEITA/NULLIF(METAVOLUME, 0), 0)									[METATKMVOLUME]
		  From @TBDIAS TBDIAS
		  Inner Join FILIAIS			On FILIAIS.HANDLE				= TBDIAS.HANDLE
		  Inner Join ESTADOS			On ESTADOS.HANDLE				= FILIAIS.ESTADO
		  Left Join #TBCPRINC TBPRINC	On TBPRINC.HANDLE				= TBDIAS.HANDLE
									   And Cast(TBPRINC.DATA As Date)	= Cast(TBDIAS.DATA As Date)) TAB
 Unpivot (VALOR For CATEGORIA In ([Frete Total], [Volume Total], [Peso Total], [TKM Peso], [TKM Volume])) UnPVT
 Where DATA	<= Cast(EoMonth(GetDate()) As Date)
 Order By NOME,
		  DATA, 
		  CATEGORIA

 Drop table #TBCPRINC
 Drop table #TPLAN