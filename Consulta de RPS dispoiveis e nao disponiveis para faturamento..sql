-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--RPS não disponivel para faturar
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Select 
	Sum(GLGL_DOCUMENTOS.VALORCONTABIL)						[TOTALNAODISPONIVELPARAFATURAR]
From GLGL_DOCUMENTOS
Inner Join GLGL_FILIAIS	On GLGL_FILIAIS.HANDLE				= GLGL_DOCUMENTOS.FILIAL
Inner Join FILIAIS			On FILIAIS.HANDLE					= GLGL_FILIAIS.FILIAL
Where GLGL_DOCUMENTOS.STATUS									Not In (224, 404)
And GLGL_DOCUMENTOS.STATUS									Not In (220, 223, 236, 237, 417)
And GLGL_DOCUMENTOS.STATUSFATURA								 IN (389,390,391,1034)
And GLGL_DOCUMENTOS.FRETECORTESIA							= 'N'
And (GLGL_DOCUMENTOS.TIPODOCUMENTO							In (6)
And GLGL_DOCUMENTOS.TIPORPS									<> 323)
--And Not Exists (Select 1
--																			 From GLGL_DOCLOGASSOCIADOS DLA
--																			Inner Join GLGL_DOCUMENTOS NFS 
--																			   On (DLA.DOCUMENTOLOGISTICAPAI			= NFS.HANDLE)
--														 				    Where DLA.DOCUMENTOLOGISTICAFILHO			= GLGL_DOCUMENTOS.HANDLE
--																			  And NFS.TIPODOCUMENTO						In (1, 2, 17, 22)
--																			  And NFS.FRETECORTESIA						= 'N'
--																			  And NFS.STATUS							Not In (224, 404)
--																			  And NFS.STATUS							Not In (220, 223, 236, 237, 417))
And Cast(GLGL_DOCUMENTOS.DATAEMISSAO As Date) >= '2019-01-01'

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--RPS Disponivel para faturar
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Select 
	Sum(GLGL_DOCUMENTOS.VALORCONTABIL)						[TOTALDISPONIVELPARAFATURAR]
From GLGL_DOCUMENTOS
Inner Join GLGL_FILIAIS	On GLGL_FILIAIS.HANDLE				= GLGL_DOCUMENTOS.FILIAL
Inner Join FILIAIS			On FILIAIS.HANDLE					= GLGL_FILIAIS.FILIAL
Where GLGL_DOCUMENTOS.STATUS									Not In (224, 404)
And GLGL_DOCUMENTOS.STATUS									Not In (220, 223, 236, 237, 417)
And GLGL_DOCUMENTOS.STATUSFATURA								 IN (388)
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
																			  And NFS.STATUS							Not In (220, 223, 236, 237, 417))
And Cast(GLGL_DOCUMENTOS.DATAEMISSAO As Date) >= '2019-01-01'





select 457462.210000001 + 709485.669999999