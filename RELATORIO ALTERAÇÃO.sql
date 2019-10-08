Select DISTINCT
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
	   End																						[Regional],
	   FILIAISEMI.NOME																			[Filial],
	   IsNull(GLDOC.NUMERO, GLGL_DOCUMENTOS.NUMERO)												[Documento],
	   GLGL_TIPODOCUMENTOS.NOME																	[TIPODOC],
	   IsNull(Cast(GLDOC.DATAEMISSAO As Date), Cast(GLGL_DOCUMENTOS.DATAEMISSAO As Date))		[Emissao],
	   PARADAENTREGA.CHEGADA,
	   ENTREGA.NOME,
	   --V.NUMEROVIAGEM,
	  -- CASE
			--WHEN GLGL_DOCUMENTOS.STATUS In (228, 231) THEN V.CHEGADAEFETIVA
	  -- ELSE ''
	  -- END AS																					[DATACHEGADAREGIONAL],
	   

	   FILIAIS.NOME																				[FilialAtual],
	   GLGL_ENUMERACAOITEMS.NOME																[Status],	
	   GN_PESSOASREM.CGCCPF																		[CNPJREM],
	   GN_PESSOASREM.NOME																		[Remetente],
	   GN_PESSOASDEST.CGCCPF																	[CNPJDEST],
	   GN_PESSOASDEST.NOME																		[Destinatario],
	   IsNull(GLDOC.NUMEROSDOCUMENTOS, GLGL_DOCUMENTOS.NUMEROSDOCUMENTOS)						[NF],
	   IsNull(ISNULL(GLDOC.DTPREVISAOENTREGAEDI, GLDOC.DTPREVISAOENTREGAEMISSAO),			  
	   ISNULL(GLGL_DOCUMENTOS.DTPREVISAOENTREGAEDI, GLGL_DOCUMENTOS.DTPREVISAOENTREGAEMISSAO))	[PREVENTREGA],
	   Case 
			When GLGL_DOCUMENTOS.STATUS In (225, 226, 227, 230, 603)		Then 'Entrega'
			When GLGL_DOCUMENTOS.STATUS In (228, 231)						Then 'Transferência'
			When GLGL_DOCUMENTOS.STATUS In (239)							Then Case (Select GLOP_VIAGENS.TIPOVIAGEM
																						 From GLOP_VIAGENS
																						Inner Join GLOP_VIAGEMDOCUMENTOS
																						   On GLOP_VIAGEMDOCUMENTOS.VIAGEM				= GLOP_VIAGENS.HANDLE
																						Where GLOP_VIAGEMDOCUMENTOS.DOCUMENTOLOGISTICA	= GLGL_DOCUMENTOS.HANDLE)
																					  When 172 Then 'Transferência'
																					  Else 'Entrega'
																				 End
		   When GLGL_DOCUMENTOS.FILIALATUAL = GLGL_DOCUMENTOS.FILIALENTREGA	Then 'Entrega'
		   Else 'Transferência'
	   End																						[Tipo],
	   IsNull(GLDOC.VALORCONTABIL, GLGL_DOCUMENTOS.VALORCONTABIL)								[VALORCONTABIL],
	   IsNull(GLDOC.DOCCLIVOLUME, GLGL_DOCUMENTOS.DOCCLIVOLUME)									[DOCCLIVOLUME],
	   IsNull(GLDOC.DOCCLIVALORTOTAL, GLGL_DOCUMENTOS.DOCCLIVALORTOTAL)							[DOCCLIVALORTOTAL],
	   DateDiff(Day,
	   IsNull((Select Max(GLOP_VIAGEMPARADAS.CHEGADA)
				 From GLOP_VIAGEMDOCUMENTOS 
				Inner Join GLOP_VIAGEMPARADAS
				   On GLOP_VIAGEMPARADAS.HANDLE							= GLOP_VIAGEMDOCUMENTOS.PARADA
				  And GLOP_VIAGEMPARADAS.VIAGEM							= GLOP_VIAGEMDOCUMENTOS.VIAGEM
				Where GLOP_VIAGEMDOCUMENTOS.DOCUMENTOLOGISTICA			= GLGL_DOCUMENTOS.HANDLE
				  And GLOP_VIAGEMPARADAS.FILIAL							= GLGL_DOCUMENTOS.FILIALATUAL
				  And Not GLOP_VIAGEMPARADAS.CHEGADA					Is Null), GLGL_DOCUMENTOS.DATAEMISSAO),
	   GetDate())																				[Tempo],
	   GLOP_MOTIVOOCORRENCIAS.DESCRICAO															[Ocorrencia],
	   MUNICIPIOS.NOME																			[CIDENTREGA]
  From GLGL_DOCUMENTOS
  Left Join GLOP_SERVICOREALIZADORPS						
 Inner Join GLGL_DOCUMENTOS	GLDOC							On GLDOC.HANDLE										= GLOP_SERVICOREALIZADORPS.DOCUMENTOLOGISTICA
															On GLOP_SERVICOREALIZADORPS.DOCUMENTOLOGISTICARPS	= GLGL_DOCUMENTOS.HANDLE
 Inner Join GLGL_FILIAIS									On GLGL_FILIAIS.HANDLE								= GLGL_DOCUMENTOS.FILIALATUAL
 Inner Join FILIAIS											On FILIAIS.HANDLE									= GLGL_FILIAIS.FILIAL
 Inner Join ESTADOS											On ESTADOS.HANDLE									= FILIAIS.ESTADO
 Inner Join GLGL_FILIAIS FILIALENTRAGA						On FILIALENTRAGA.HANDLE								= GLGL_DOCUMENTOS.FILIALENTREGA
 Inner Join FILIAIS ENTREGA									On ENTREGA.HANDLE									= FILIALENTRAGA.FILIAL
 Inner Join GLGL_ENUMERACAOITEMS							On GLGL_ENUMERACAOITEMS.HANDLE						= GLGL_DOCUMENTOS.STATUS
 Inner Join GLGL_FILIAIS GLGL_FILIAISEMI					On GLGL_FILIAISEMI.HANDLE							= GLGL_DOCUMENTOS.FILIAL
 Inner Join FILIAIS FILIAISEMI								On FILIAISEMI.HANDLE								= GLGL_FILIAISEMI.FILIAL
 Inner Join GLGL_TIPODOCUMENTOS								On GLGL_TIPODOCUMENTOS.HANDLE						= IsNull(GLDOC.TIPODOCUMENTO, GLGL_DOCUMENTOS.TIPODOCUMENTO)
  Left Join GLGL_ENUMERACAOITEMS GLGL_ENUMERACAOITEMSTPRPS	On GLGL_ENUMERACAOITEMSTPRPS.HANDLE					= IsNull(GLDOC.TIPORPS		, GLGL_DOCUMENTOS.TIPORPS)
 Inner Join GN_PESSOAS GN_PESSOASREM						On GN_PESSOASREM.HANDLE								= GLGL_DOCUMENTOS.REMETENTE
 Inner Join GN_PESSOAS GN_PESSOASDEST						On GN_PESSOASDEST.HANDLE							= GLGL_DOCUMENTOS.DESTINATARIO
  Left Join GLOP_OCORRENCIAS								On GLOP_OCORRENCIAS.DOCUMENTO						= GLGL_DOCUMENTOS.HANDLE
														   And GLOP_OCORRENCIAS.HANDLE							= (Select Max(X.HANDLE)
																													 From GLOP_OCORRENCIAS X
																													Where X.DOCUMENTO			= GLOP_OCORRENCIAS.DOCUMENTO
																													  And X.ESTORNADO			= 'N'
																													  And X.CONCLUIDOEM			Is Null
																													  And x.PENDENCIA			= 'S')
  Left Join GLOP_MOTIVOOCORRENCIAS							On GLOP_MOTIVOOCORRENCIAS.HANDLE					= GLOP_OCORRENCIAS.OCORRENCIA
  Left Join GLGL_PESSOAENDERECOS							On GLGL_PESSOAENDERECOS.HANDLE						= GLGL_DOCUMENTOS.DESTINOENDERECO
  Left Join MUNICIPIOS										On MUNICIPIOS.HANDLE								= GLGL_PESSOAENDERECOS.MUNICIPIO
  LEFT JOIN GLOP_VIAGEMDOCUMENTOS DV
	ON DV.DOCUMENTOLOGISTICA = GLGL_DOCUMENTOS.HANDLE

  LEFT JOIN GLOP_VIAGENS V
	ON DV.VIAGEM = V.HANDLE

  LEFT JOIN GLOP_VIAGEMDOCUMENTOS VIAGEMDOCENTREGA ON VIAGEMDOCENTREGA.HANDLE = 
	(SELECT MAX(TB.HANDLE)
	FROM (
       SELECT XVD.HANDLE
       FROM GLOP_VIAGEMDOCUMENTOS XVD
       INNER JOIN GLOP_VIAGEMPARADAS XP ON XP.HANDLE = XVD.PARADA
       WHERE XP.FILIAL = GLGL_DOCUMENTOS.FILIALATUAL
       AND XVD.TIPOSERVICO = 198
       AND XVD.DOCUMENTOLOGISTICA = GLGL_DOCUMENTOS.HANDLE
       AND XVD.SITUACAO <> 211
        UNION ALL 
       SELECT XVD.HANDLE 
       FROM GLOP_VIAGEMDOCUMENTOS XVD
       INNER JOIN GLOP_VIAGEMPARADAS XP ON XP.HANDLE = XVD.PARADA
       WHERE XP.FILIAL = GLGL_DOCUMENTOS.FILIALATUAL
       AND XVD.TIPOSERVICO = 198
      AND XVD.SITUACAO <> 211
      AND XVD.DOCUMENTOLOGISTICA = (SELECT MAX(RPS.HANDLE)                                
										FROM GLGL_DOCUMENTOS RPS                              
										WHERE RPS.DOCUMENTOLOGISTICA = GLGL_DOCUMENTOS.HANDLE               
										               AND RPS.STATUS NOT IN (236, 237)                    
										               AND RPS.TIPODOCUMENTO = 6                           
										               AND RPS.TIPORPSSERVICO = 324                        
										               AND EXISTS (                                        
										                              SELECT 1                                          
										                              FROM GLOP_VIAGEMDOCUMENTOS X                      
										                              WHERE X.DOCUMENTOLOGISTICA = RPS.HANDLE           
										                                            AND X.TIPOSERVICO = 198                         
										                                            AND X.SITUACAO <> 211                           
										                              )                                                 
										)                                                     
                              ) AS TB )                                                                                
                                         
  LEFT JOIN GLOP_VIAGEMPARADAS PARADAENTREGA ON PARADAENTREGA.HANDLE = VIAGEMDOCENTREGA.PARADA  

 Where Not GLGL_DOCUMENTOS.STATUS										In (236, 237, 417, 219, 220, 221, 222, 223, 224, 229, 230, 231,  399, 
																			404, 416, 418, 419, 420, 439, 609, 743, 890, 625)  
   And Cast(GLGL_DOCUMENTOS.DATAEMISSAO As Date)						>= '2015-01-12'
   And Not (FILIAIS.HANDLE												In (1, 182, 296, 297)
    Or		FILIAIS.NOME												Like 'Inativ%')
   And (GLGL_DOCUMENTOS.DATAENTREGA										Is Null
   And  Not GLGL_DOCUMENTOS.STATUS										In (234, 235, 313, 314, 418, 419, 420, 421))
   And GLGL_DOCUMENTOS.SISTEMAORIGEM									= 3
   And ((GLGL_DOCUMENTOS.TIPODOCUMENTO									In (1, 2)
   And   GLGL_DOCUMENTOS.TIPODOCUMENTOFRETE								In (153)
   And GLGL_DOCUMENTOS.RECUSADO											= 'N'
   And Not Exists (Select 1
					 From GLOP_SERVICOREALIZADORPS
					Inner Join GLOP_SERVICOSREALIZADOS
					   On GLOP_SERVICOSREALIZADOS.HANDLE				= GLOP_SERVICOREALIZADORPS.SERVICOREALIZADO
					Inner Join GLGL_SERVICOLOGISTICA
					   On GLGL_SERVICOLOGISTICA.HANDLE					= GLOP_SERVICOSREALIZADOS.SERVICO
					Where GLOP_SERVICOREALIZADORPS.DOCUMENTOLOGISTICA	= GLGL_DOCUMENTOS.HANDLE
					  And GLGL_SERVICOLOGISTICA.FUNCAO					= 39))

	Or (GLGL_DOCUMENTOS.TIPODOCUMENTO									In (6)
   And ((Not GLGL_DOCUMENTOS.TIPORPS									In (323, 324))
	Or  (GLGL_DOCUMENTOS.TIPORPS										= 324
   And Exists (Select 1
				 From GLOP_SERVICOREALIZADORPS
				Inner Join GLOP_SERVICOSREALIZADOS
				   On GLOP_SERVICOSREALIZADOS.HANDLE					= GLOP_SERVICOREALIZADORPS.SERVICOREALIZADO
				Inner Join GLGL_SERVICOLOGISTICA
				   On GLGL_SERVICOLOGISTICA.HANDLE						= GLOP_SERVICOSREALIZADOS.SERVICO
				Where GLOP_SERVICOREALIZADORPS.DOCUMENTOLOGISTICARPS	= GLGL_DOCUMENTOS.HANDLE
				  And GLGL_SERVICOLOGISTICA.FUNCAO						= 39)))))
  And (FILIAIS.HANDLE													In (6)
   Or 6															= 0)
  And (Case ESTADOS.SIGLA
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
    End																= 'Regional RJ'
   Or  'Regional RJ'													= '0')
  And (Exists (Select 1
			 	 From GLOP_SERVICOREALIZADORPS X 
			    Inner Join GLGL_DOCUMENTOS Y		On Y.HANDLE		= X.DOCUMENTOLOGISTICA
			    Where X.DOCUMENTOLOGISTICARPS						= GLDOC.HANDLE
			      And (Y.DATAENTREGA								Is Null
			 	  And  Not Y.STATUS									In (234, 235, 313, 314, 418, 419, 420, 421)))
   Or GLDOC.HANDLE													Is Null)