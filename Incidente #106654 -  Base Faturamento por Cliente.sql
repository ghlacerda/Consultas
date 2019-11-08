--CONSULTA ANTIGA
--Select Convert(Date, GLGL_DOCUMENTOS.DATAEMISSAO)									[DATA],
--	   FILIAIS.NOME																	[FILIAL],
--	   GN_PESSOAS.CGCCPF															[CNPJ],
--	   GN_PESSOAS.NOME																[TOMADOR],
--	   Convert(Decimal(14,2), Sum(IsNull(GLGL_DOCUMENTOS.VALORCONTABIL, 0)))		[VALORFATURAMENTO],
--   	   Convert(Decimal(14,2), Sum(IsNull(GLGL_DOCUMENTOTRIBUTOS.VALORICMS, 0)))		[ICMS],
--	   Count(Distinct GLGL_DOCUMENTOS.HANDLE)										[QTDDOC],
--	   Sum(IsNull(GLGL_DOCUMENTOS.DOCCLIVOLUME, 0))									[VOLUME]
--  From GLGL_DOCUMENTOS
--  Left Join GLGL_DOCUMENTOTRIBUTOS		On GLGL_DOCUMENTOTRIBUTOS.DOCUMENTO			= GLGL_DOCUMENTOS.HANDLE
-- Inner Join GLGL_PESSOAS				On GLGL_PESSOAS.HANDLE						= GLGL_DOCUMENTOS.TOMADORSERVICOPESSOA
-- Inner Join GLGL_PESSOACONFIGURACOES	On GLGL_PESSOACONFIGURACOES.PESSOALOGISTICA	= GLGL_PESSOAS.HANDLE
-- Inner Join GN_PESSOAS					On GN_PESSOAS.HANDLE						= GLGL_PESSOAS.PESSOA
-- Inner Join FILIAIS						On FILIAIS.HANDLE							= GLGL_DOCUMENTOS.FILIAL
-- Where GLGL_DOCUMENTOS.STATUS														Not In (224, 404)
--   And GLGL_DOCUMENTOS.STATUS														Not In (220, 223, 236, 237, 417)
--   And GLGL_DOCUMENTOS.FRETECORTESIA												= 'N'
--   And Convert(Date, GLGL_DOCUMENTOS.DATAEMISSAO)									Between Convert(Date, Concat(Format(DateAdd(Year, -1, GetDate()), 'yyyy-'), '01-01'))
--																						And Convert(Date, DateAdd(Day, -1, GetDate()))
--   And ((GLGL_DOCUMENTOS.TIPODOCUMENTO												In (1, 2, 17, 22))
--	Or (GLGL_DOCUMENTOS.TIPODOCUMENTO												In (6)
--   And GLGL_DOCUMENTOS.TIPORPS														<> 323   
--   And Not Exists (Select 1
--					 From GLGL_DOCLOGASSOCIADOS DLA
-- 				    Inner Join GLGL_DOCUMENTOS NFS 
--					   On (DLA.DOCUMENTOLOGISTICAPAI								= NFS.HANDLE)
--			 	    Where DLA.DOCUMENTOLOGISTICAFILHO								= GLGL_DOCUMENTOS.HANDLE
--					  And NFS.TIPODOCUMENTO											In (1, 2, 17, 22)
--					  And NFS.FRETECORTESIA											= 'N'
--					  And NFS.STATUS												Not In (224, 404)
--					  And NFS.STATUS												Not In (220, 223, 236, 237, 417))))
--   And GLGL_PESSOACONFIGURACOES.CLIENTEEPP											= 'S'
-- Group By Convert(Date, GLGL_DOCUMENTOS.DATAEMISSAO),
--		  FILIAIS.NOME,
--		  GN_PESSOAS.CGCCPF,
--		  GN_PESSOAS.NOME											
-- Having Sum(IsNull(GLGL_DOCUMENTOS.VALORCONTABIL, 0)) > 0
-- Order By [FILIAL],
--		  [DATA],
--		  [VALORFATURAMENTO] Desc

Select Convert(Date, GLGL_DOCUMENTOS.DATAEMISSAO)									[DATA],
	   FILIAIS.NOME																	[FILIAL],
	   GN_PESSOAS.CGCCPF															[CNPJ],
	   GN_PESSOAS.NOME																[TOMADOR],
	   Convert(Decimal(14,2), Sum(IsNull(GLGL_DOCUMENTOS.VALORCONTABIL, 0)))		[VALORFATURAMENTO],
   	   Convert(Decimal(14,2), Sum(IsNull(GLGL_DOCUMENTOTRIBUTOS.VALORICMS, 0)))		[ICMS],
	   Count(Distinct GLGL_DOCUMENTOS.HANDLE)										[QTDDOC],
	   Sum(IsNull(GLGL_DOCUMENTOS.DOCCLIVOLUME, 0))									[VOLUME]
  From GLGL_DOCUMENTOS
  Left Join GLGL_DOCUMENTOTRIBUTOS		On GLGL_DOCUMENTOTRIBUTOS.DOCUMENTO			= GLGL_DOCUMENTOS.HANDLE
 Inner Join GLGL_PESSOAS				On GLGL_PESSOAS.HANDLE						= GLGL_DOCUMENTOS.TOMADORSERVICOPESSOA
 Inner Join GLGL_PESSOACONFIGURACOES	On GLGL_PESSOACONFIGURACOES.PESSOALOGISTICA	= GLGL_PESSOAS.HANDLE
 Inner Join GN_PESSOAS					On GN_PESSOAS.HANDLE						= GLGL_PESSOAS.PESSOA
 Inner Join FILIAIS						On FILIAIS.HANDLE							= GLGL_DOCUMENTOS.FILIAL
 Where 1=1 
 --GLGL_DOCUMENTOS.STATUS														Not In (224, 404)
   AND GLGL_DOCUMENTOS.STATUS NOT IN(236,237,417,220,221,222,223,224,399,404,416,418,419,420,609,743,890)     
  	AND (GLGL_DOCUMENTOS.TIPODOCUMENTO IN(1,2) OR (GLGL_DOCUMENTOS.TIPODOCUMENTO = 6 AND GLGL_DOCUMENTOS.TIPORPS <> 324) )  
   And GLGL_DOCUMENTOS.FRETECORTESIA												= 'N'
   AND GLGL_DOCUMENTOS.DATAEMISSAO	>= Convert(Date, Concat(Format(DateAdd(Year, -1, GetDate()), 'yyyy-'), '01-01'))
										AND GLGL_DOCUMENTOS.DATAEMISSAO < Convert(Date, GetDate())
   And ((GLGL_DOCUMENTOS.TIPODOCUMENTO												In (1, 2, 17, 22))
	Or (GLGL_DOCUMENTOS.TIPODOCUMENTO												In (6)
   And GLGL_DOCUMENTOS.TIPORPS														<> 323   
   And Not Exists (Select 1
					 From GLGL_DOCLOGASSOCIADOS DLA
 				    Inner Join GLGL_DOCUMENTOS NFS 
					   On (DLA.DOCUMENTOLOGISTICAPAI								= NFS.HANDLE)
			 	    Where DLA.DOCUMENTOLOGISTICAFILHO								= GLGL_DOCUMENTOS.HANDLE
					  And NFS.TIPODOCUMENTO											In (1, 2, 17, 22)
					  And NFS.FRETECORTESIA											= 'N'
					  --And NFS.STATUS												Not In (224, 404)
					  And NFS.STATUS												NOT IN(236,237,417,220,221,222,223,224,399,404,416,418,419,420,609,743,890))))
   And GLGL_PESSOACONFIGURACOES.CLIENTEEPP											= 'S'
   --and FILIAIS.NOME = 'Campinas - CPQ/Hortolandia'
   --and GN_PESSOAS.NOME LIKE '%MERCADO ENVIOS%'
 Group By Convert(Date, GLGL_DOCUMENTOS.DATAEMISSAO),
		  FILIAIS.NOME,
		  GN_PESSOAS.CGCCPF,
		  GN_PESSOAS.NOME											
 Having Sum(IsNull(GLGL_DOCUMENTOS.VALORCONTABIL, 0)) > 0
 Order By [FILIAL],
		  [DATA],
		  [VALORFATURAMENTO] Desc