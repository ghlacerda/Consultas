--Faturamento Gerentes

DECLARE @DATAINICIAL	DATE
DECLARE @DATAFINAL		DATE
Declare @TBDIAS			Table (HANDLE				Int,
							   UFHANDLE				Int,
							   ESTNOME				VarChar(200),
							   REGIONAL				VarChar(200),
							   NOME					VarChar(200),
							   DATA					Date,
							   [Frete Total]		Float,
							   [Volume Total]		Float,
							   [Peso Total]			Float,
							   [Qntde Docs]			Float)


SET @DATAINICIAL    = Cast(Concat(Year(DateAdd(Year, -1, GetDate())), '-01-01') As Date)
SET @DATAFINAL      = Cast(Concat(Year(DateAdd(Year,  0, GetDate())), '-12-31') As Date);

With DATA (Dia) 
	AS (Select @DATAINICIAL
		 Union All
		Select DateAdd(Day, 1, C.Dia)
		  From DATA C
		 Where C.Dia < @DATAFINAL)

Insert Into @TBDIAS
Select GLGL_FILIAIS.HANDLE,
	   FILIAIS.ESTADO,
	   ESTADOS.NOME, 
	  -- Case ESTADOS.SIGLA
			--When 'CE' Then 'Regional Nordeste'
			--When 'RN' Then 'Regional Nordeste'
			--When 'PB' Then 'Regional Nordeste'
			--When 'PE' Then 'Regional Nordeste'
			--When 'AL' Then 'Regional Nordeste'
			--When 'SE' Then 'Regional Nordeste'
			--When 'BA' Then 'Regional Nordeste'
			--When 'MG' Then 'Regional MG'
			--When 'ES' Then 'Regional ES'
			--When 'RJ' Then 'Regional RJ'
			--When 'SP' Then 'Regional SP'
			--When 'PR' Then 'Regional Sul'
			--When 'SC' Then 'Regional Sul'
			--When 'RS' Then 'Regional Sul'
	  -- End													[REGIONAL],
	  dbo.REGIONALASSOCIADA(ESTADOS.SIGLA)  [REGIONAL],
	   FILIAIS.NOME,  
	   --IIF((Month(Data.dia) = 2 And Day(Data.dia) > 28), DateAdd(Day, 28-Day(Data.dia), Data.dia),  Data.dia) [Dia],

	   cast(Data.dia as date) [Dia],
	   0 [Frete Total], 0 [Volume Total], 0 [Peso Total], 0 [Qntde Docs]
  From DATA 
 Cross Join FILIAIS
 Inner Join ESTADOS			On ESTADOS.HANDLE		= FILIAIS.ESTADO
 Inner Join GLGL_FILIAIS	On GLGL_FILIAIS.FILIAL	= FILIAIS.HANDLE
 Where FILIAIS.EMPRESA								= 1
   And FILIAIS.HANDLE								In (Select FILIAIS.HANDLE
														  From FILIAIS
														 Inner Join GLGL_FILIAIS	On GLGL_FILIAIS.FILIAL	= FILIAIS.HANDLE
														 Where FILIAIS.EMPRESA								= 1
														   And Not IsNull(GLGL_FILIAIS.CLASSIFICACAO, 0)	= 1
														   And ((Not FILIAIS.NOME							Like 'Inat%')
														    Or  (FILIAIS.NOME								Like 'Inat%'
														   And   Exists (	Select FILIAL,
																				   SubString(C.value('./NOME[1]', 'VarChar(250)'),2, 250)	[NOME]
																			  From (SELECT Z_LOG.DATAHORA,
																						   Cast(Z_LOG.DADOS As XML)	[DADOS],
																						   REGISTRO					[FILIAL] 
																					  FROM Z_LOG 
																					 WHERE TABELA				= 720 
																					   AND Year(DATAHORA)		>= Year(DateAdd(Year, -1, GetDate()))
																					   AND SERVICO				In ('I', 'A') ) TBXML
																			 Cross Apply DADOS.nodes('/CAMPOS[1]') as T(C)	    
																			 Where DADOS.exist('/CAMPOS[1]/NOME[1]')	= 1   
																			   And FILIAL								= FILIAIS.HANDLE))))
Option (maxrecursion 10000);

Select TB1.HANDLE,
	   TB1.ESTADO							[UFHANDLE],
	   TB1.ESTNOME,
	   TB1.REGIONAL,
	   TB1.NOME,
	   TB1.Data,
	   Sum(TB1.[Frete Total])			     [Frete Total],
	   Sum(TB1.[Volume Total])			     [Volume Total],
	   Sum(TB1.[Peso Total])			     [Peso Total],
	   Sum(IsNull(TB1.[Qntde Docs], 0))	     [Qntde Docs]
  Into #TBCPRINC
  From (Select FILIAIS.HANDLE,
			   FILIAIS.ESTADO,
			   ESTADOS.NOME		[ESTNOME],
			  -- Case ESTADOS.SIGLA
					--When 'CE' Then 'Regional Nordeste'
					--When 'RN' Then 'Regional Nordeste'
					--When 'PB' Then 'Regional Nordeste'
					--When 'PE' Then 'Regional Nordeste'
					--When 'AL' Then 'Regional Nordeste'
					--When 'SE' Then 'Regional Nordeste'
					--When 'BA' Then 'Regional Nordeste'
					--When 'MG' Then 'Regional MG'
					--When 'ES' Then 'Regional ES'
					--When 'RJ' Then 'Regional RJ'
					--When 'SP' Then 'Regional SP'
					--When 'PR' Then 'Regional Sul'
					--When 'SC' Then 'Regional Sul'
					--When 'RS' Then 'Regional Sul'
			  -- End			[REGIONAL],
			  dbo.REGIONALASSOCIADA(ESTADOS.SIGLA)  [REGIONAL],
			   FILIAIS.NOME,
			   --IIF((Month(GLGL_DOCUMENTOS.DATAEMISSAO) = 2 And Day(GLGL_DOCUMENTOS.DATAEMISSAO) > 28), DateAdd(Day, 28-Day(GLGL_DOCUMENTOS.DATAEMISSAO), Cast(GLGL_DOCUMENTOS.DATAEMISSAO As Date)), Cast(GLGL_DOCUMENTOS.DATAEMISSAO As Date)) [Data],
			   Cast(GLGL_DOCUMENTOS.DATAEMISSAO As Date) [Data],
			   IsNull(GLGL_DOCUMENTOS.VALORCONTABIL, 0)																													[Frete Total],
			   IsNull(GLGL_DOCUMENTOS.DOCCLIVOLUME, 0)																													[Volume Total],
			   IsNull(GLGL_DOCUMENTOS.DOCCLIPESOTOTAL, 0)																												[Peso Total],
			   Cast(IIF(GLGL_DOCUMENTOS.TIPODOCUMENTO In (22, 13), (Select Count(*) [Qtde]
																	  From GLGL_DOCLOGASSOCIADOS
																	 Where GLGL_DOCLOGASSOCIADOS.DOCUMENTOLOGISTICAPAI = GLGL_DOCUMENTOS.HANDLE), 1) As float)			[Qntde Docs]
		  --Into #TBCPRINC
		  From GLGL_DOCUMENTOS
		 Inner Join GLGL_FILIAIS				On GLGL_FILIAIS.HANDLE							= GLGL_DOCUMENTOS.FILIAL
		 Inner Join FILIAIS						On FILIAIS.HANDLE								= GLGL_FILIAIS.FILIAL
		 Inner Join ESTADOS						On ESTADOS.HANDLE								= FILIAIS.ESTADO
--		  Left Join GLGL_PESSOACONFIGURACOES	On GLGL_PESSOACONFIGURACOES.PESSOALOGISTICA		= GLGL_DOCUMENTOS.REMETENTE
		 Where GLGL_DOCUMENTOS.STATUS								Not In (224, 404) --ok
		   And GLGL_DOCUMENTOS.STATUS								Not In (220, 223, 236, 237, 417,416,419,421) --ok
		   And (Cast(GLGL_DOCUMENTOS.DATACANCELAMENTO As Date)	> Cast(EoMonth(GLGL_DOCUMENTOS.DATAEMISSAO) As Date)--ok
			Or  Cast(GLGL_DOCUMENTOS.DATACANCELAMENTO As Date)	Is Null)--ok
			And (GLGL_DOCUMENTOS.TIPODOCUMENTOFRETE				<> 155--ok
		    Or  GLGL_DOCUMENTOS.TIPODOCUMENTOFRETE				Is Null)--ok
			And Cast(GLGL_DOCUMENTOS.DATAEMISSAO As Date)			>= @DATAINICIAL
		   And Cast(GLGL_DOCUMENTOS.DATAEMISSAO As Date)			< @DATAFINAL

		   --And GLGL_DOCUMENTOS.FRETECORTESIA						= 'N'
		   And (GLGL_DOCUMENTOS.TIPODOCUMENTO					In (1, 2, 17, 22)
		        or (GLGL_DOCUMENTOS.TIPODOCUMENTO						In (6)
		   And GLGL_DOCUMENTOS.TIPORPS								<> 323
		   And Not Exists (Select 1
							 From GLGL_DOCLOGASSOCIADOS DLA
							Inner Join GLGL_DOCUMENTOS NFS 
							   On (DLA.DOCUMENTOLOGISTICAPAI		= NFS.HANDLE)
								Where DLA.DOCUMENTOLOGISTICAFILHO		= GLGL_DOCUMENTOS.HANDLE
							  And NFS.TIPODOCUMENTO					In (1, 2, 17, 22)
							 -- And NFS.FRETECORTESIA					= 'N'
							  And NFS.STATUS						Not In (224, 404)
							  --And NFS.STATUS						Not In (220, 223, 236, 237, 417))))   
							  And NFS.STATUS						Not In (220, 223, 236, 237, 417,416,419,421)))) 
		
		 And FILIAIS.HANDLE								In (Select FILIAIS.HANDLE
														  From FILIAIS
														 Inner Join GLGL_FILIAIS	On GLGL_FILIAIS.FILIAL	= FILIAIS.HANDLE
														 Where FILIAIS.EMPRESA								= 1
														   And Not IsNull(GLGL_FILIAIS.CLASSIFICACAO, 0)	= 1
														   And ((Not FILIAIS.NOME							Like 'Inat%')
														    Or  (FILIAIS.NOME								Like 'Inat%'
														   And   Exists (	Select FILIAL,
																				   SubString(C.value('./NOME[1]', 'VarChar(250)'),2, 250)	[NOME]
																			  From (SELECT Z_LOG.DATAHORA,
																						   Cast(Z_LOG.DADOS As XML)	[DADOS],
																						   REGISTRO					[FILIAL] 
																					  FROM Z_LOG 
																					 WHERE TABELA				= 720 
																					   AND Year(DATAHORA)		>= Year(DateAdd(Year, -1, GetDate()))
																					   AND SERVICO				In ('I', 'A') ) TBXML
																			 Cross Apply DADOS.nodes('/CAMPOS[1]') as T(C)	    
																			 Where DADOS.exist('/CAMPOS[1]/NOME[1]')	= 1   
																			   And FILIAL								= FILIAIS.HANDLE)))) 

		   
		   ) TB1
 Group By TB1.HANDLE,
		  TB1.ESTADO,
		  TB1.ESTNOME,
		  TB1.REGIONAL,
		  TB1.NOME,
		  TB1.Data


Select *
  From (Select HANDLE,
			   UFHANDLE,
			   ESTNOME,
			   REGIONAL,
			   NOME			[Filial], 
			   Data, 
			   Categoria, 
			   ROUND(Valor,2) as Valor,
			   ROUND(Lead(Valor, 1, 0) Over (Partition By HANDLE, NOME, Categoria, DatePart(Day, Data), DatePart(Month, Data)
										   Order By HANDLE, NOME, Categoria, DatePart(Day, Data), DatePart(Month, Data), DatePart(Year, Data) Desc),2) AS [ValorTotalAnt],
			   ROUND(IIF(Data < Cast(GetDate() As Date), Lead(Valor, 1, 0) Over (Partition By HANDLE, NOME, Categoria, DatePart(Day, Data), DatePart(Month, Data)
																				Order By HANDLE, NOME, Categoria, DatePart(Day, Data), DatePart(Month, Data), DatePart(Year, Data) Desc), 0 ),2) [ValorAcumuladoAnt]
		  From (Select * 
				 From #TBCPRINC TBCPRINC
				Where TBCPRINC.DATA									< Cast(GetDate() As Date)
				Union All
				Select * 
				  From @TBDIAS TBDIAS
				 Where Not Exists (Select 1
									 From #TBCPRINC TBCPRINC
									Where TBCPRINC.DATA				< Cast(GetDate() As Date)
									  And TBCPRINC.HANDLE			= TBDIAS.HANDLE
									  And TBCPRINC.DATA				= TBDIAS.DATA
									  And TBCPRINC.UFHANDLE			= TBDIAS.UFHANDLE
									  And TBCPRINC.REGIONAL			= TBDIAS.REGIONAL
									  And TBCPRINC.ESTNOME			= TBDIAS.ESTNOME)) TB1
		 Unpivot (Valor For Categoria In ([Frete Total], [Volume Total], [Qntde Docs], [Peso Total])) UnpvtDoc) TB2
 Where Year(Data)													= Year(GetDate())
 Order By 5, 6, 7


 Drop table #TBCPRINC