----�	Carregamento de transfer�ncia
----	o	N�mero da viagem origem (descarga)
----	o	Placa da descarga
----	o	Filial de origem 
----		�	Filial de destino 
----		�	N�mero
----		�	Status
----		�	Previs�o de entrega
--		�	Peso real
--		�	Qtd. Volumes
--		�	Frete
--		�	Pegar como base o status da GLOP_VIAGEMDOCUMENTOS
--		�	Volume qtd
--		�	Peso real
--		�	Frete



DECLARE @BeginDate DATETIME = '2019-11-10'
DECLARE @EndDate DATETIME = '2019-11-13'
 
  
Select DISTINCT 
	GLOP_VIAGENS.NUMEROVIAGEM
	,MA_RECURSOS.PLACANUMERO
	,FILO.NOME AS FILIALORIGEM
	,FILD.NOME AS FILIALDESTINO
	,GLGL_DOCUMENTOS.NUMERO AS [N�mero Documento]
	,EI.NOME AS [Status]
	,GLGL_DOCUMENTOS.DTPREVISAOENTREGAEMISSAO AS [Previs�o Entrega]
	,GLGL_DOCUMENTOS.DOCCLIPESOTOTAL AS [Peso Real]
	,GLGL_DOCUMENTOS.DOCCLIVOLUME AS [Qtd. Volumes]
	,GLGL_DOCUMENTOS.VALORFRETEVALOR AS [Frete]
	,DateAdd(Hour, ((Select Count(1) 
					     From GLOP_VIAGEMPARADAS X
					    Where X.VIAGEM					= GLOP_VIAGENS.HANDLE
					      And Not X.FILIAL				= GLOP_VIAGENS.FILIALORIGEM
					      And Not X.FILIAL				= GLOP_VIAGENS.FILIALDESTINO
					      And X.PARADAEFETUADA			= 'N') * 2),
	   IsNull(DateAdd(Second, ((Cast(((((Round((DBO.FN_CALCULADISTANCIA(K_GLOP_VEICULOPOSICOES.LATITUDE,	K_GLOP_VEICULOPOSICOES.LONGITUDE, FILIAIS.K_LATITUDE, FILIAIS.K_LONGITUDE) / 55),4) - Cast(Round((DBO.FN_CALCULADISTANCIA(K_GLOP_VEICULOPOSICOES.LATITUDE,	K_GLOP_VEICULOPOSICOES.LONGITUDE, FILIAIS.K_LATITUDE, FILIAIS.K_LONGITUDE) / 55),4) As Int)) * 100) - Cast(((Round((DBO.FN_CALCULADISTANCIA(K_GLOP_VEICULOPOSICOES.LATITUDE,	K_GLOP_VEICULOPOSICOES.LONGITUDE, FILIAIS.K_LATITUDE, FILIAIS.K_LONGITUDE) / 55),4) - Cast(Round((DBO.FN_CALCULADISTANCIA(K_GLOP_VEICULOPOSICOES.LATITUDE,	K_GLOP_VEICULOPOSICOES.LONGITUDE, FILIAIS.K_LATITUDE, FILIAIS.K_LONGITUDE) / 55),4) As Int)) * 100) As Int)) * 100) As Int) * 0.6)), 
					  DateAdd(Minute, (Cast(((Round((DBO.FN_CALCULADISTANCIA(K_GLOP_VEICULOPOSICOES.LATITUDE,	K_GLOP_VEICULOPOSICOES.LONGITUDE, FILIAIS.K_LATITUDE, FILIAIS.K_LONGITUDE) / 55),4) - Cast(Round((DBO.FN_CALCULADISTANCIA(K_GLOP_VEICULOPOSICOES.LATITUDE,	K_GLOP_VEICULOPOSICOES.LONGITUDE, FILIAIS.K_LATITUDE, FILIAIS.K_LONGITUDE) / 55),4) As Int)) * 100) As Int) * 0.6), 
							  DateAdd(Hour, Cast(Round((DBO.FN_CALCULADISTANCIA(K_GLOP_VEICULOPOSICOES.LATITUDE,	K_GLOP_VEICULOPOSICOES.LONGITUDE, FILIAIS.K_LATITUDE, FILIAIS.K_LONGITUDE) / 55),4) As Int), GetDate()))),
			  GLOP_VIAGENS.PREVISAOCHEGADA))								[Previsao Chegada]
	



From GLOP_VIAGENS
Inner Join GLOP_LINHAVIAGENS					On GLOP_LINHAVIAGENS.HANDLE						= GLOP_VIAGENS.LINHAVIAGEM
Inner Join GLGV_PLANOCARGADESCARGAS			    On GLGV_PLANOCARGADESCARGAS.VIAGEM				= GLOP_VIAGENS.HANDLE
Inner Join MA_RECURSOS							On MA_RECURSOS.HANDLE							= GLGV_PLANOCARGADESCARGAS.VEICULO 
Inner Join GLOP_VIAGEMPARADAS					On GLOP_VIAGEMPARADAS.HANDLE					= GLGV_PLANOCARGADESCARGAS.PARADA
Inner Join GLGL_FILIAIS						    On GLGL_FILIAIS.HANDLE							= GLGV_PLANOCARGADESCARGAS.FILIAL
Inner Join FILIAIS								On FILIAIS.HANDLE								= GLGL_FILIAIS.FILIAL
Inner Join FILIAIS FILO							On FILO.HANDLE								    = GLOP_VIAGENS.FILIALORIGEM
Inner Join GLGV_PROCESSOS						On GLGV_PROCESSOS.PLANOCARGADESCARGA			= GLGV_PLANOCARGADESCARGAS.HANDLE
LEFT JOIN GLOP_VIAGEMDOCUMENTOS                 On GLOP_VIAGEMDOCUMENTOS.VIAGEM		= GLOP_VIAGEMPARADAS.VIAGEM
												   And GLOP_VIAGEMDOCUMENTOS.PARADA		= GLOP_VIAGEMPARADAS.HANDLE
Left Join GLGL_DOCUMENTOS						On GLGL_DOCUMENTOS.HANDLE						= GLOP_VIAGEMDOCUMENTOS.DOCUMENTOLOGISTICA
Inner Join FILIAIS FILD							On FILD.HANDLE								    = GLGL_DOCUMENTOS.FILIALENTREGA
Left Join GLGV_PROCESSOPARTICIPANTES			
Inner Join GN_PESSOAS							On GN_PESSOAS.HANDLE							= GLGV_PROCESSOPARTICIPANTES.PESSOA
												On GLGV_PROCESSOPARTICIPANTES.PROCESSO			= GLGV_PROCESSOS.HANDLE
												   And GLGV_PROCESSOPARTICIPANTES.TIPOPARTICIPANTE	= 511
Left Join K_GLOP_VEICULOPOSICOES				On K_GLOP_VEICULOPOSICOES.HANDLE	= (Select Max(X.HANDLE)
																				 From K_GLOP_VEICULOPOSICOES X
																				Where X.VEICULO		= GLOP_VIAGENS.VEICULO1
																				  And X.DATAHORA	= (Select Max(Y.DATAHORA) 
																										 From K_GLOP_VEICULOPOSICOES Y
																										Where Y.VEICULO		= X.VEICULO))
LEFT JOIN GLGL_ENUMERACAOITEMS EI ON EI.CODIGO = GLOP_VIAGEMDOCUMENTOS.SITUACAO

Where GLOP_VIAGENS.TIPOVIAGEM = 172
  And GLGV_PLANOCARGADESCARGAS.TIPO = 'C'
  And GLGV_PROCESSOS.STATUS	<> 1336
  And GLGV_PROCESSOS.TIPO In (1)
  And GLGV_PROCESSOS.SUBTIPO In (1)
  And GLGV_PLANOCARGADESCARGAS.DATAABERTURA	Between @BeginDate
											And @EndDate
ORDER BY 1