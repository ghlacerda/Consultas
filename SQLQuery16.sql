--Select BL				[VENDEDOR],
--	   [Período]		[PERIODO],
--	   [Meta Proposta]	[META]
--  Into #TMETA
--  From OPENROWSET('Microsoft.ACE.OLEDB.12.0', 'Excel 12.0; Database=\\fileserverazure\tarifas$\BASE_POWER_BI_NÃOMEXER\Metas_Vendedor.xlsx', [Planilha1$]) TB
-- Where Not TB.Vendedor		Is Null
--   And Not TB.[Período]		= 'Totais'

drop table if exists #TMETA
select 

	   BL	[VENDEDOR],
	   [Período]		[PERIODO],
	   [Meta Proposta 2019 ]	[META]
Into #TMETA

from [BI_PATRUS].[dbo].[Metas]
Where BL		Is Not Null
And Not [Período]		= 'Totais'


DECLARE @DATAINICIAL	DATE
DECLARE @DATAFINAL		DATE
Declare @TBDIAS			Table (AGV_HANDLE			Int,
							   DATA					Date,
							   VALOR				Float,
							   META					Float)

SET @DATAINICIAL    = Cast(DateAdd(Day, ((Day(GetDate())-1)*(-1)), DateAdd(Month, ((Month(GetDate())-1)*(-1)), DateAdd(Year, 0, GetDate()))) As Date)
SET @DATAFINAL      = Cast(EoMonth(GetDate()) As Date); 

With DATA (Dia) 
	AS (Select @DATAINICIAL
		 Union All
		Select DateAdd(Day, 1, C.Dia)
		  From DATA C
		 Where C.Dia < @DATAFINAL)

Insert Into @TBDIAS
Select GN_AGENTEVENDAS.HANDLE,
       DATA.DIA,
	   0						[VALOR],
	   IsNull(
	   IIF(DatePart(DW, DATA.DIA) In (1, 7), 0,
			(Select TMETA.META
			   From #TMETA TMETA
			  Where TMETA.VENDEDOR	= GN_AGENTEVENDAS.NOME Collate SQL_Latin1_General_CP1_CI_AS
			    And TMETA.PERIODO	= Case Month(DATA.DIA)
										   When 01 Then 'Jan'
										   When 02 Then 'Fev'
										   When 03 Then 'Mar'
										   When 04 Then 'Abr'
										   When 05 Then 'Mai'
										   When 06 Then 'Jun'
										   When 07 Then 'Jul'
										   When 08 Then 'Ago'
										   When 09 Then 'Set'
										   When 10 Then 'Out'
										   When 11 Then 'Nov'
										   When 12 Then 'Dez'
									  End Collate SQL_Latin1_General_CP1_CI_AS)/	   
			(Day(EoMonth(DATA.DIA))-
			((DateDiff(WK, DateAdd(Day, ((Day(DATA.DIA)-1)*(-1)), DATA.DIA), EoMonth(DATA.DIA)) * 2)	+ 
			IIF(DatePart(DW, DateAdd(Day, ((Day(DATA.DIA)-1)*(-1)), DATA.DIA)) In (1, 7), 1, 0)			+ 
			IIF(DatePart(DW, EoMonth(DATA.DIA)) In (1, 7), 1, 0)))), 0)							[META]
  From DATA 
 Cross Join GN_PESSOAS GN_AGENTEVENDAS
 Inner Join Z_GRUPOUSUARIOS			On Z_GRUPOUSUARIOS.PESSOA					= GN_AGENTEVENDAS.HANDLE
 Where GN_AGENTEVENDAS.EHAGENTEVENDAS											= 'S' 
   And GN_AGENTEVENDAS.INATIVO													= 'N' 
   And Exists (Select 1 
				 From GLGL_PESSOAS GL_ELABORACAO								
				Where GL_ELABORACAO.HANDLE										= GN_AGENTEVENDAS.HANDLE 
				  And GL_ELABORACAO.ELABORACAO									= 'N')
Option (maxrecursion 10000);

--Drop Table #TMETA

Select GN_AGENTEVENDAS.HANDLE,
	   GN_AGENTEVENDAS.CGCCPF						[AGVCGCCPF],
	   GN_AGENTEVENDAS.NOME							[AGVNOME],
	   GN_CLIENTE.CGCCPF							[CLICGCCPF],
	   GN_CLIENTE.NOME								[CLINOME],
	   Cast(GLGL_DOCUMENTOS.DATAEMISSAO As Date)	[DATA],
	   Sum(GLGL_DOCUMENTOS.VALORCONTABIL)			[VALOR]
  Into #AGVCLI
  From GN_PESSOAS GN_AGENTEVENDAS
 Inner Join GN_PESSOAS GN_CLIENTE	On GN_CLIENTE.AGENTEVENDAS					= GN_AGENTEVENDAS.HANDLE
 Inner Join GLGL_DOCUMENTOS			On GLGL_DOCUMENTOS.TOMADORSERVICOPESSOA		= GN_CLIENTE.HANDLE
 Where GN_AGENTEVENDAS.EHAGENTEVENDAS											= 'S' 
   And GN_AGENTEVENDAS.INATIVO													= 'N' 
   And Exists (Select 1 
				 From GLGL_PESSOAS GL_ELABORACAO								
				Where GL_ELABORACAO.HANDLE										= GN_AGENTEVENDAS.HANDLE 
				  And GL_ELABORACAO.ELABORACAO									= 'N')
   And GLGL_DOCUMENTOS.STATUS													Not In (224, 404)
   And GLGL_DOCUMENTOS.STATUS													Not In (220, 223, 236, 237, 417, 419)
   And GLGL_DOCUMENTOS.FRETECORTESIA											= 'N'
   And ((GLGL_DOCUMENTOS.TIPODOCUMENTO											In (1, 2, 17, 22))
	Or (GLGL_DOCUMENTOS.TIPODOCUMENTO											In (6)
   And GLGL_DOCUMENTOS.TIPORPS													<> 323   
   And Not Exists (Select 1
					 From GLGL_DOCLOGASSOCIADOS DLA
 				    Inner Join GLGL_DOCUMENTOS NFS 
					   On (DLA.DOCUMENTOLOGISTICAPAI							= NFS.HANDLE)
			 	    Where DLA.DOCUMENTOLOGISTICAFILHO							= GLGL_DOCUMENTOS.HANDLE
					  And NFS.TIPODOCUMENTO										In (1, 2, 17, 22)
					  And NFS.FRETECORTESIA										= 'N'
					  And NFS.STATUS											Not In (224, 404)
					  And NFS.STATUS											Not In (220, 223, 236, 237, 417, 419))))
   And Cast(GLGL_DOCUMENTOS.DATAEMISSAO As Date)								Between @DATAINICIAL
																					And @DATAFINAL
 Group By GN_AGENTEVENDAS.HANDLE,
		  GN_AGENTEVENDAS.CGCCPF,
		  GN_AGENTEVENDAS.NOME,
	      GN_CLIENTE.CGCCPF,
		  GN_CLIENTE.NOME,
	      Cast(GLGL_DOCUMENTOS.DATAEMISSAO As Date)
 Order By GN_AGENTEVENDAS.NOME,
	      GN_CLIENTE.NOME,
		  Cast(GLGL_DOCUMENTOS.DATAEMISSAO As Date)

Select TBDIAS.AGV_HANDLE																					[HANDLE], 
	   TBDIAS.DATA																							[DATA],
	   GN_PESSOAS.CGCCPF																					[CGCCPFAGV],
	   GN_PESSOAS.NOME																						[NOMEAGV], 
	   AGVCLI.CLICGCCPF																						[CGCCPFCLI], 
	   AGVCLI.CLINOME																						[NOMECLI], 
	   IsNull(AGVCLI.VALOR, TBDIAS.VALOR)																	[VALOR],
	   IsNull( TBDIAS.META/ 
			   NULLIF( (Select Count(*)
						  From #AGVCLI X
						 Where X.HANDLE						= TBDIAS.AGV_HANDLE
						   And Cast(X.DATA	As Date)		= Cast(TBDIAS.DATA	As Date)), 0), TBDIAS.META)	[META]
  From @TBDIAS TBDIAS
 Inner Join GN_PESSOAS		On GN_PESSOAS.HANDLE			= TBDIAS.AGV_HANDLE
  Left Join #AGVCLI AGVCLI	On AGVCLI.HANDLE				= TBDIAS.AGV_HANDLE
						   And Cast(AGVCLI.DATA	As Date)	= Cast(TBDIAS.DATA	As Date)
  Group By TBDIAS.AGV_HANDLE,
		   TBDIAS.DATA,
		   GN_PESSOAS.CGCCPF,
		   GN_PESSOAS.NOME,
		   AGVCLI.CLICGCCPF,
		   AGVCLI.CLINOME,
		   IsNull(AGVCLI.VALOR, TBDIAS.VALOR),
		   TBDIAS.META
  --Having TBDIAS.META										> 0
  Order By TBDIAS.AGV_HANDLE,  
		   TBDIAS.DATA   

Drop Table #AGVCLI