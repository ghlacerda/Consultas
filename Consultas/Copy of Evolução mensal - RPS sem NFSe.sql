Select Case Month(DateAdd(Day, (Day(GLGL_DOCUMENTOS.DATAEMISSAO)*(-1))+1, GLGL_DOCUMENTOS.DATAEMISSAO))
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
	   End														[MES],
	   Sum(GLGL_DOCUMENTOS.VALORCONTABIL)						[TOTAL]
  From GLGL_DOCUMENTOS
 Inner Join GLGL_FILIAIS	On GLGL_FILIAIS.HANDLE				= GLGL_DOCUMENTOS.FILIAL
 Inner Join FILIAIS			On FILIAIS.HANDLE					= GLGL_FILIAIS.FILIAL
 Where Not GLGL_DOCUMENTOS.STATUS								In (223, 224, 236, 237, 399, 404, 416, 417, 418, 419, 420, 421, 609, 743, 890)                             
   And GLGL_DOCUMENTOS.FRETECORTESIA							= 'N'
   And GLGL_DOCUMENTOS.STATUSFATURA								In (388, 391)
   And (GLGL_DOCUMENTOS.TIPODOCUMENTO							= 6
   And  GLGL_DOCUMENTOS.TIPORPS									<> 323)
   And GLGL_DOCUMENTOS.VALORCONTABIL							> 0   
   And GLGL_DOCUMENTOS.DATAEMISSAO						>= CAST(DateAdd(yyyy, DateDiff(yyyy,0,GetDate()), 0) AS DATE)
   and GLGL_DOCUMENTOS.DATAEMISSAO						< CAST(getdate() AS DATE)
   and DATEPART(DW, GLGL_DOCUMENTOS.DATAEMISSAO) NOT IN (1,7)
   And FILIAIS.HANDLE											In (Select FILIAIS.HANDLE
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
																								   AND Year(DATAHORA)		= Year(GetDate())
																								   AND SERVICO				In ('I', 'A') ) TBXML
																						 Cross Apply DADOS.nodes('/CAMPOS[1]') as T(C)	    
																						 Where DADOS.exist('/CAMPOS[1]/NOME[1]')	= 1   
																						   And FILIAL								= FILIAIS.HANDLE))))
   And Not Exists (Select 1
					 From GLGL_DOCLOGASSOCIADOS
					Inner Join GLGL_DOCUMENTOS X	On X.HANDLE					= GLGL_DOCLOGASSOCIADOS.DOCUMENTOLOGISTICAPAI
					Where GLGL_DOCLOGASSOCIADOS.DOCUMENTOLOGISTICAFILHO			= GLGL_DOCUMENTOS.HANDLE
					  And X.FRETECORTESIA										= 'N'
					  And X.TIPODOCUMENTO										IN (1, 2, 17, 22)                   
				      And Not X.STATUS											IN (417, 236, 237, 416, 418, 421))
 Group By DateAdd(Day, (Day(GLGL_DOCUMENTOS.DATAEMISSAO)*(-1))+1, GLGL_DOCUMENTOS.DATAEMISSAO)