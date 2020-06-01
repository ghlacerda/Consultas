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
	   End													[REGIONAL],
	   FILIAIS.NOME,  
	   IIF((Month(Data.dia) = 2 And Day(Data.dia) > 28), DateAdd(Day, 28-Day(Data.dia), Data.dia), 
														 Data.dia) [Dia],
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
	   Sum(TB1.[Frete Total])				[Frete Total],
	   Sum(TB1.[Volume Total])				[Volume Total],
	   Sum(TB1.[Peso Total])				[Peso Total],
	   Sum(IsNull(TB1.[Qntde Docs], 0))		[Qntde Docs]
  Into #TBCPRINC
  From (Select distinct FILIAIS.HANDLE,
			   FILIAIS.ESTADO,
			   ESTADOS.NOME		[ESTNOME],
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
			   End			[REGIONAL],
			   FILIAIS.NOME,
			   IIF((Month(GLGL_DOCUMENTOS.DATAEMISSAO) = 2 And Day(GLGL_DOCUMENTOS.DATAEMISSAO) > 28), DateAdd(Day, 28-Day(GLGL_DOCUMENTOS.DATAEMISSAO), Cast(GLGL_DOCUMENTOS.DATAEMISSAO As Date)), 
																											   Cast(GLGL_DOCUMENTOS.DATAEMISSAO As Date)) [Data],
			   IsNull(GLGL_DOCUMENTOS.VALORCONTABIL, 0)																													[Frete Total],
			   IsNull(GLGL_DOCUMENTOS.DOCCLIVOLUME, 0)																													[Volume Total],
			   IsNull(GLGL_DOCUMENTOS.DOCCLIPESOTOTAL, 0)																												[Peso Total],
			   Cast(IIF(GLGL_DOCUMENTOS.TIPODOCUMENTO In (22, 13), (Select Count(*) [Qtde]
																	  From GLGL_DOCLOGASSOCIADOS
																	 Where GLGL_DOCLOGASSOCIADOS.DOCUMENTOLOGISTICAPAI = GLGL_DOCUMENTOS.HANDLE), 1) As float)			[Qntde Docs]
		  From GLGL_DOCUMENTOS
		 Inner Join GLGL_FILIAIS	On GLGL_FILIAIS.HANDLE		= GLGL_DOCUMENTOS.FILIAL
		 Inner Join FILIAIS			On FILIAIS.HANDLE			= GLGL_FILIAIS.FILIAL
		 Inner Join ESTADOS			On ESTADOS.HANDLE			= FILIAIS.ESTADO
		 Where GLGL_DOCUMENTOS.STATUS							Not In (223, 224, 236, 237, 399, 404, 416, 417, 418, 419, 420, 421, 609, 743, 890) 
		   And GLGL_DOCUMENTOS.STATUS							Not In (220, 223, 417)
		   And Cast(GLGL_DOCUMENTOS.DATAEMISSAO As Date)		Between @DATAINICIAL
																	And @DATAFINAL	
		   And GLGL_DOCUMENTOS.TIPODOCUMENTO					In (1, 2, 17, 22)
		   And (Cast(GLGL_DOCUMENTOS.DATACANCELAMENTO As Date)	> Cast(EoMonth(GLGL_DOCUMENTOS.DATAEMISSAO) As Date)
			Or  Cast(GLGL_DOCUMENTOS.DATACANCELAMENTO As Date)	Is Null)
		   And (GLGL_DOCUMENTOS.TIPODOCUMENTOFRETE				<> 155
		    Or  GLGL_DOCUMENTOS.TIPODOCUMENTOFRETE				Is Null)
		   And FILIAIS.HANDLE									In (Select FILIAIS.HANDLE
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
		 Union All
		Select FILIAIS.HANDLE,
			   FILIAIS.ESTADO,
			   ESTADOS.NOME		[ESTNOME],
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
			   End			[REGIONAL],
			   FILIAIS.NOME,
			   Cast(CT_LANCAMENTOS.COMPETENCIA As Date)			[DATA],
			   Sum(CT_LANCAMENTOS.VALOR)*(-1)					[Frete Total],
			   0												[Volume Total],
			   0												[Peso Total],
			   0												[Qntde Docs]
		  From CT_LANCAMENTOS 
		 Inner Join CT_CONTAS		On CT_CONTAS.HANDLE			= CT_LANCAMENTOS.CONTA
		 Inner Join FILIAIS			On FILIAIS.HANDLE			= CT_LANCAMENTOS.FILIAL
		 Inner Join ESTADOS			On ESTADOS.HANDLE			= FILIAIS.ESTADO
		 Where CT_CONTAS.VERSAO									= 4
		   And CT_CONTAS.EMPRESA								= 1
		   And CT_CONTAS.HANDLE									In (20077, 33296, 33295, 20274, 31413)
		   And CT_LANCAMENTOS.LANCAMENTOGERADO					= 'N'
		   And CT_LANCAMENTOS.NATUREZA							= 'D'
		   And Cast(CT_LANCAMENTOS.COMPETENCIA As Date)			Between @DATAINICIAL
																	And @DATAFINAL
		 Group By FILIAIS.HANDLE,
				  FILIAIS.ESTADO,
				  ESTADOS.NOME,
				  ESTADOS.SIGLA,
				  FILIAIS.NOME,
				  Cast(CT_LANCAMENTOS.COMPETENCIA As Date)	
		 Union All
		Select FILIAIS.HANDLE,
			   FILIAIS.ESTADO,
			   ESTADOS.NOME		[ESTNOME],
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
			   End			[REGIONAL],
			   FILIAIS.NOME,
			   Cast(CT_LANCAMENTOS.COMPETENCIA As Date)			[DATA],
			   Sum(CT_LANCAMENTOS.valor)						[Frete Total],
			   0												[Volume Total],
			   0												[Peso Total],
			   0												[Qntde Docs]
		  From CT_LANCAMENTOS 
		 Inner Join CT_CONTAS		On CT_CONTAS.HANDLE			= CT_LANCAMENTOS.CONTA
		 Inner Join FILIAIS			On FILIAIS.HANDLE			= CT_LANCAMENTOS.FILIAL
		 Inner Join ESTADOS			On ESTADOS.HANDLE			= FILIAIS.ESTADO
		 Where CT_CONTAS.VERSAO									= 4
		   And CT_CONTAS.EMPRESA								= 1
		   And CT_CONTAS.HANDLE									In (20077, 33296, 33295, 20274, 31413)
		   And CT_LANCAMENTOS.NATUREZA							= 'C'
		   And CT_LANCAMENTOS.LANCAMENTOFINANCEIRO				Is Null
		   And CT_LANCAMENTOS.LANCAMENTOGERADO					= 'N'
		   And Cast(CT_LANCAMENTOS.COMPETENCIA As Date)			Between @DATAINICIAL
																	And @DATAFINAL
		 Group By FILIAIS.HANDLE,
				  FILIAIS.ESTADO,
				  ESTADOS.NOME,
				  ESTADOS.SIGLA,
				  FILIAIS.NOME,
				  Cast(CT_LANCAMENTOS.COMPETENCIA As Date)) TB1
 Group By TB1.HANDLE,
		  TB1.ESTADO,
		  TB1.ESTNOME,
		  TB1.REGIONAL,
		  TB1.NOME,
		  TB1.Data

Select HANDLE,
			   UFHANDLE,
			   ESTNOME,
			   REGIONAL,
			   [Filial], 
			   Data, 
			   Categoria, 
			   ROUND(Valor,2) AS Valor, ROUND([ValorTotalAnt],2) AS [ValorTotalAnt], ROUND([ValorAcumuladoAnt],2) AS [ValorAcumuladoAnt],
	   ROUND(IIF(TB2.CATEGORIA	= 'Frete Total',   IsNull( (Select Sum(DOCLOG.VALORCONTABIL)						[TOTAL]
														  From GLGL_DOCUMENTOS DOCLOG
															Inner Join GLGL_FILIAIS	On GLGL_FILIAIS.HANDLE				= DOCLOG.FILIAL
															Inner Join FILIAIS			On FILIAIS.HANDLE				= GLGL_FILIAIS.FILIAL
															WHERE 1=1 AND DOCLOG.VALORCONTABIL > 0                                                                                                    
																   AND DOCLOG.STATUS NOT IN ( 223, 224, 236, 237, 399, 404, 416, 417, 418, 419, 420, 421, 609, 743, 890)                             
  																		   AND DOCLOG.FRETECORTESIA = 'N'                                                                                             
  																		   AND ISNULL(DOCLOG.TIPODOCUMENTOFRETE, 0) <> 155                                                                                         
																 AND DOCLOG.EMPRESA = 1                 
															     AND DOCLOG.STATUSFATURA IN (327, 388, 391, 389,390,1034)
															     AND ((DOCLOG.TIPODOCUMENTO = 6 AND DOCLOG.TIPORPS in( 322,324 )) 
															     and not EXISTS  (  SELECT 1                                       
																	  FROM GLGL_DOCLOGASSOCIADOS DLA,                            
																		   GLGL_DOCUMENTOS CT                                    
																	  WHERE DLA.DOCUMENTOLOGISTICAPAI = CT.HANDLE                
       																		And CT.FRETECORTESIA	= 'N'                        
																			AND CT.TIPODOCUMENTO IN(1,2,17,22)                   
																			AND CT.STATUS not IN ( 417, 236, 237, 416, 418, 421) 
																	  AND DLA.DOCUMENTOLOGISTICAFILHO = DOCLOG.HANDLE)        
															   )   
  																AND DOCLOG.DATACANCELAMENTO IS NULL   
															--Where GLGL_DOCUMENTOS.STATUS								NOT IN (223, 224, 236, 237, 399, 404, 416, 417, 418, 419, 420, 421, 609, 743, 890)
															----And GLGL_DOCUMENTOS.STATUS									Not In (223, 224, 236, 237, 404, 416, 417, 418, 421) --São documentos para nao considerar na hora do calculo, como por exemplo documentos cancelados etc.
															--And GLGL_DOCUMENTOS.STATUSFATURA							IN (327, 388, 391)
															--And GLGL_DOCUMENTOS.FRETECORTESIA							= 'N'
															--And (GLGL_DOCUMENTOS.TIPODOCUMENTO							In (6)
															--And GLGL_DOCUMENTOS.TIPORPS								    in( 322,324 ))
															--AND ISNULL(GLGL_DOCUMENTOS.TIPODOCUMENTOFRETE, 0) <> 155    
															--And Not Exists (Select 1
															--				 From GLGL_DOCLOGASSOCIADOS DLA
															--				Inner Join GLGL_DOCUMENTOS NFS 
															--				   On (DLA.DOCUMENTOLOGISTICAPAI			= NFS.HANDLE)
														 --					Where DLA.DOCUMENTOLOGISTICAFILHO			= GLGL_DOCUMENTOS.HANDLE
															--				  And NFS.TIPODOCUMENTO						In (1, 2, 17, 22)
															--				  And NFS.FRETECORTESIA						= 'N'
															--				  And NFS.STATUS							Not In (224, 404)
															--				  And NFS.STATUS							Not In (223, 224, 236, 237, 399, 404, 416, 417, 418, 419, 420, 421, 609, 743, 890) )
														   And Cast(DOCLOG.DATAEMISSAO As Date)				= TB2.Data
														   And FILIAIS.HANDLE											= TB2.HANDLE ), 0), 0),2)	[TotalLiberadoeNaoLiberado],


		ROUND(IIF(TB2.CATEGORIA	= 'Frete Total',   IsNull( (Select Sum(DOCLOG.VALORCONTABIL)						[TOTAL]
														  From GLGL_DOCUMENTOS DOCLOG
															Inner Join GLGL_FILIAIS	On GLGL_FILIAIS.HANDLE				= DOCLOG.FILIAL
															Inner Join FILIAIS			On FILIAIS.HANDLE				= GLGL_FILIAIS.FILIAL
															WHERE 1=1 AND DOCLOG.VALORCONTABIL > 0                                                                                                    
																   AND DOCLOG.STATUS NOT IN ( 223, 224, 236, 237, 399, 404, 416, 417, 418, 419, 420, 421, 609, 743, 890)                             
  																		   AND DOCLOG.FRETECORTESIA = 'N'                                                                                             
  																		   AND ISNULL(DOCLOG.TIPODOCUMENTOFRETE, 0) <> 155                                                                                         
																 AND DOCLOG.EMPRESA = 1                 
															     AND DOCLOG.STATUSFATURA IN (327, 388, 391)
															     AND ((DOCLOG.TIPODOCUMENTO = 6 AND DOCLOG.TIPORPS in( 322,324 )) 
															     and not EXISTS  (  SELECT 1                                       
																	  FROM GLGL_DOCLOGASSOCIADOS DLA,                            
																		   GLGL_DOCUMENTOS CT                                    
																	  WHERE DLA.DOCUMENTOLOGISTICAPAI = CT.HANDLE                
       																		And CT.FRETECORTESIA	= 'N'                        
																			AND CT.TIPODOCUMENTO IN(1,2,17,22)                   
																			AND CT.STATUS not IN ( 417, 236, 237, 416, 418, 421) 
																	  AND DLA.DOCUMENTOLOGISTICAFILHO = DOCLOG.HANDLE)        
															   )   
  																AND DOCLOG.DATACANCELAMENTO IS NULL   
															--Where GLGL_DOCUMENTOS.STATUS								NOT IN (223, 224, 236, 237, 399, 404, 416, 417, 418, 419, 420, 421, 609, 743, 890)
															----And GLGL_DOCUMENTOS.STATUS									Not In (223, 224, 236, 237, 404, 416, 417, 418, 421) --São documentos para nao considerar na hora do calculo, como por exemplo documentos cancelados etc.
															--And GLGL_DOCUMENTOS.STATUSFATURA							IN (327, 388, 391)
															--And GLGL_DOCUMENTOS.FRETECORTESIA							= 'N'
															--And (GLGL_DOCUMENTOS.TIPODOCUMENTO							In (6)
															--And GLGL_DOCUMENTOS.TIPORPS								    in( 322,324 ))
															--AND ISNULL(GLGL_DOCUMENTOS.TIPODOCUMENTOFRETE, 0) <> 155    
															--And Not Exists (Select 1
															--				 From GLGL_DOCLOGASSOCIADOS DLA
															--				Inner Join GLGL_DOCUMENTOS NFS 
															--				   On (DLA.DOCUMENTOLOGISTICAPAI			= NFS.HANDLE)
														 --					Where DLA.DOCUMENTOLOGISTICAFILHO			= GLGL_DOCUMENTOS.HANDLE
															--				  And NFS.TIPODOCUMENTO						In (1, 2, 17, 22)
															--				  And NFS.FRETECORTESIA						= 'N'
															--				  And NFS.STATUS							Not In (224, 404)
															--				  And NFS.STATUS							Not In (223, 224, 236, 237, 399, 404, 416, 417, 418, 419, 420, 421, 609, 743, 890) )
														   And Cast(DOCLOG.DATAEMISSAO As Date)				= TB2.Data
														   And FILIAIS.HANDLE											= TB2.HANDLE ), 0), 0),2)	[Disponiveis Para faturar],

		ROUND(IIF(TB2.CATEGORIA	= 'Frete Total',   IsNull( (Select Sum(GLGL_DOCUMENTOS.VALORCONTABIL)						[TOTAL]
														  From GLGL_DOCUMENTOS
															Inner Join GLGL_FILIAIS	On GLGL_FILIAIS.HANDLE				= GLGL_DOCUMENTOS.FILIAL
															Inner Join FILIAIS			On FILIAIS.HANDLE					= GLGL_FILIAIS.FILIAL
															Where GLGL_DOCUMENTOS.STATUS									Not In (224, 404)
															And GLGL_DOCUMENTOS.STATUS									Not In (223, 224, 236, 237, 399, 404, 416, 417, 418, 419, 420, 421, 609, 743, 890) 
															And GLGL_DOCUMENTOS.STATUSFATURA							IN (389,390,1034)
															And GLGL_DOCUMENTOS.FRETECORTESIA							= 'N'
															And (GLGL_DOCUMENTOS.TIPODOCUMENTO							In (6)
															And GLGL_DOCUMENTOS.TIPORPS									<> 323)
															And Not Exists (Select 1
																			 From GLGL_DOCLOGASSOCIADOS DLA
																			Inner Join GLGL_DOCUMENTOS NFS 
																			   On (DLA.DOCUMENTOLOGISTICAPAI			= NFS.HANDLE)
														 					Where DLA.DOCUMENTOLOGISTICAFILHO			= GLGL_DOCUMENTOS.HANDLE
																			  And NFS.TIPODOCUMENTO						In (1, 2, 17, 22)
																			  And NFS.FRETECORTESIA						= 'N'
																			  And NFS.STATUS							Not In (224, 404)
																			  And NFS.STATUS							Not In (223, 224, 236, 237, 399, 404, 416, 417, 418, 419, 420, 421, 609, 743, 890) )
														   And Cast(GLGL_DOCUMENTOS.DATAEMISSAO As Date)				= TB2.Data
														   And FILIAIS.HANDLE											= TB2.HANDLE ), 0), 0),2)	[Não dispoivel para faturar]
  From (Select HANDLE,
			   UFHANDLE,
			   ESTNOME,
			   REGIONAL,
			   NOME			[Filial], 
			   Data, 
			   Categoria, 
			   Valor,
			   Lead(Valor, 1, 0) Over (Partition By HANDLE, NOME, Categoria, DatePart(Day, Data), DatePart(Month, Data)
										   Order By HANDLE, NOME, Categoria, DatePart(Day, Data), DatePart(Month, Data), DatePart(Year, Data) Desc)													[ValorTotalAnt],
			   IIF(Data < Cast(GetDate() As Date), Lead(Valor, 1, 0) Over (Partition By HANDLE, NOME, Categoria, DatePart(Day, Data), DatePart(Month, Data)
																				      Order By HANDLE, NOME, Categoria, DatePart(Day, Data), DatePart(Month, Data), DatePart(Year, Data) Desc), 0 )	[ValorAcumuladoAnt]
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
 Where Year(TB2.Data)												= Year(GetDate())
 Order By 5, 6, 7

 Drop table #TBCPRINC