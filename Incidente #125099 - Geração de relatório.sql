Select FILIAIS.NOME										Filial_Origem,
	   MUNICIPIOS.NOME									Cidade,
	   MUNICIPIOSF.NOME									Cidade_Polo,
	   ESTADOS.SIGLA									UF,
	   FILIAISDEST.NOME									Filial_Destino,
	   Sum(GLGL_DOCUMENTOS.DOCCLIPESOTOTAL)				Total_Peso,
	   Sum(GLGL_DOCUMENTOS.DOCCLIPESOCONSIDERADO)		Total_Cubagem,
	   Sum(GLGL_DOCUMENTOS.VALORCONTABIL)				Total_Frete,
	   Sum(GLGL_DOCUMENTOS.DOCCLIVALORTOTALCONSIDERAR)	Total_NF,
	   Sum(GLGL_DOCUMENTOS.DOCCLIVOLUME)				Total_Volumes,
	   Count(*)											Ocorrências
  From GLGL_DOCUMENTOS
 Inner Join GLOP_VIAGEMDOCUMENTOS					On GLOP_VIAGEMDOCUMENTOS.DOCUMENTOLOGISTICA		= GLGL_DOCUMENTOS.HANDLE
 Inner Join GLOP_VIAGENS							On GLOP_VIAGENS.HANDLE							= GLOP_VIAGEMDOCUMENTOS.VIAGEM
 Inner Join FILIAIS									On FILIAIS.HANDLE								= GLGL_DOCUMENTOS.FILIAL
 Inner Join GLOP_VIAGEMPARADAS						On GLOP_VIAGEMPARADAS.VIAGEM					= GLOP_VIAGEMDOCUMENTOS.VIAGEM
												   And GLOP_VIAGEMPARADAS.HANDLE					= GLOP_VIAGEMDOCUMENTOS.PARADA
 Inner Join FILIAIS FILIAISDEST						On FILIAISDEST.HANDLE							= GLOP_VIAGEMPARADAS.FILIAL
 
 Inner Join GLGL_PESSOAENDERECOS					On GLGL_PESSOAENDERECOS.HANDLE					= GLGL_DOCUMENTOS.DESTINOENDERECO
 Inner Join MUNICIPIOS								On MUNICIPIOS.HANDLE							= GLGL_PESSOAENDERECOS.MUNICIPIO
 Inner Join ESTADOS									On ESTADOS.HANDLE								= MUNICIPIOS.ESTADO
 
 Inner Join GLGL_LOCALIDADES						On GLGL_LOCALIDADES.MUNICIPIO					= MUNICIPIOS.HANDLE
 Inner Join GLGL_LOCALIDADEITEMS					On GLGL_LOCALIDADEITEMS.LOCALIDADE				= GLGL_LOCALIDADES.HANDLE
 Inner Join GLGL_LOCALIDADES GLGL_LOCALIDADESAG		On GLGL_LOCALIDADESAG.HANDLE					= GLGL_LOCALIDADEITEMS.AGLUTINADOR
 Inner Join GLOP_REGIAOATENDIMENTOS					On GLOP_REGIAOATENDIMENTOS.LOCALIDADE			= GLGL_LOCALIDADESAG.HANDLE
 Inner Join FILIAIS FILIALAG						On FILIALAG.HANDLE								= GLOP_REGIAOATENDIMENTOS.FILIAL
 Inner Join MUNICIPIOS MUNICIPIOSF					On MUNICIPIOSF.HANDLE							= FILIALAG.MUNICIPIO
 Where GLOP_VIAGENS.TIPOVIAGEM																		In (172)
   And Not GLGL_DOCUMENTOS.STATUS																	In (236, 237, 417) 
   And GLGL_DOCUMENTOS.DATACANCELAMENTO																Is Null
   And GLOP_REGIAOATENDIMENTOS.STATUS																= 566
   And GLGL_DOCUMENTOS.TIPODOCUMENTO																In (1, 2) 
   And GLGL_DOCUMENTOS.TIPODOCUMENTO																= 2 
   And (Not GLGL_DOCUMENTOS.STATUS																	In (235) 
   And GLGL_DOCUMENTOS.RECUSADO																		= 'N')
   And GLOP_VIAGENS.TRANSBORDADO																	= 'N'
   And GLOP_VIAGENS.TRANSBORDO																		= 'N'
 --  And (ESTADOS.HANDLE																				In (@UFDESTINO)
	--Or  @UFDESTINO																					= -1)
 --  And (FILIAIS.HANDLE																				In (@FILIALORIGEM)
	--Or  @FILIALORIGEM																				= -1)
   And FILIAISDEST.HANDLE																			In (8)
   And Cast(GLOP_VIAGENS.INICIOEFETIVO As Date)														Between	'2020-03-01'
																										And '2020-03-16'
Group By FILIAIS.NOME,
		 MUNICIPIOS.NOME,
		 MUNICIPIOSF.NOME,
		 ESTADOS.SIGLA,
		 FILIAISDEST.NOME