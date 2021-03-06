Select [Previs�o Chegada],
	   Format([Previs�o Chegada], 'dd/MM/yyyy HH:mm')	[DataFormatada],
	   Upper(Tb.CODIGO)									[CODIGO],
	   [Observacao],
       Concat('biportaria', [Filial], '@patrus.com.br')									[UserAcess],
	   Cast((Row_Number() Over (Partition By [Filial]									    
								Order By [Previs�o Chegada]) / 7) As BigInt)  +1		[PAGINA]
  From (	Select GLGL_FILIAIS.SIGLA													[Filial],
				   Cast(GLOP_VIAGENS.INICIOEFETIVO As Date)								[Data],
				   DateAdd(Hour, ((Select Count(1) 
								     From GLOP_VIAGEMPARADAS X
								    Where X.VIAGEM					= GLOP_VIAGENS.HANDLE
								      And Not X.FILIAL				= GLOP_VIAGENS.FILIALORIGEM
								      And Not X.FILIAL				= GLOP_VIAGENS.FILIALDESTINO
								      And X.PARADAEFETUADA			= 'N') * 2),
				   IsNull(DateAdd(Second, ((Cast(((((Round((DBO.FN_CALCULADISTANCIA(K_GLOP_VEICULOPOSICOES.LATITUDE,	K_GLOP_VEICULOPOSICOES.LONGITUDE, FILIAIS.K_LATITUDE, FILIAIS.K_LONGITUDE) / 55),4) - Cast(Round((DBO.FN_CALCULADISTANCIA(K_GLOP_VEICULOPOSICOES.LATITUDE,	K_GLOP_VEICULOPOSICOES.LONGITUDE, FILIAIS.K_LATITUDE, FILIAIS.K_LONGITUDE) / 55),4) As Int)) * 100) - Cast(((Round((DBO.FN_CALCULADISTANCIA(K_GLOP_VEICULOPOSICOES.LATITUDE,	K_GLOP_VEICULOPOSICOES.LONGITUDE, FILIAIS.K_LATITUDE, FILIAIS.K_LONGITUDE) / 55),4) - Cast(Round((DBO.FN_CALCULADISTANCIA(K_GLOP_VEICULOPOSICOES.LATITUDE,	K_GLOP_VEICULOPOSICOES.LONGITUDE, FILIAIS.K_LATITUDE, FILIAIS.K_LONGITUDE) / 55),4) As Int)) * 100) As Int)) * 100) As Int) * 0.6)), 
								  DateAdd(Minute, (Cast(((Round((DBO.FN_CALCULADISTANCIA(K_GLOP_VEICULOPOSICOES.LATITUDE,	K_GLOP_VEICULOPOSICOES.LONGITUDE, FILIAIS.K_LATITUDE, FILIAIS.K_LONGITUDE) / 55),4) - Cast(Round((DBO.FN_CALCULADISTANCIA(K_GLOP_VEICULOPOSICOES.LATITUDE,	K_GLOP_VEICULOPOSICOES.LONGITUDE, FILIAIS.K_LATITUDE, FILIAIS.K_LONGITUDE) / 55),4) As Int)) * 100) As Int) * 0.6), 
										  DateAdd(Hour, Cast(Round((DBO.FN_CALCULADISTANCIA(K_GLOP_VEICULOPOSICOES.LATITUDE,	K_GLOP_VEICULOPOSICOES.LONGITUDE, FILIAIS.K_LATITUDE, FILIAIS.K_LONGITUDE) / 55),4) As Int), GetDate()))),
						  GLOP_VIAGENS.PREVISAOCHEGADA))								[Previs�o Chegada],
			
				   MA_RECURSOS.CODIGO													
				   ,
				   GLOP_LINHAVIAGENS.NOME												[Linha],
				   K_GLOP_VEICULOPOSICOES.LOCALIZACAO									[Localizacao],
				   GLOP_VIAGENS.K_OBSERVACOESRADAR										[Observacao]
			  From GLOP_VIAGENS
			 Inner Join GLOP_VIAGEMPARADAS			On GLOP_VIAGEMPARADAS.VIAGEM		= GLOP_VIAGENS.HANDLE
			 Inner Join GLOP_LINHAVIAGENS			On GLOP_LINHAVIAGENS.HANDLE			= GLOP_VIAGENS.LINHAVIAGEM
			 Inner Join FILIAIS						On FILIAIS.HANDLE					= GLOP_VIAGEMPARADAS.FILIAL
			 Inner Join GLGL_FILIAIS				On GLGL_FILIAIS.HANDLE				= FILIAIS.HANDLE
			 Inner Join GLGL_ENUMERACAOITEMS		On GLGL_ENUMERACAOITEMS.HANDLE		= GLOP_VIAGENS.STATUS
			 Inner Join MA_RECURSOS					On MA_RECURSOS.HANDLE				= GLOP_VIAGENS.VEICULO1
			  Left Join K_GLOP_VEICULOPOSICOES		On K_GLOP_VEICULOPOSICOES.HANDLE	= (Select Max(X.HANDLE)
																							 From K_GLOP_VEICULOPOSICOES X
																							Where X.VEICULO		= GLOP_VIAGENS.VEICULO1
																							  And X.DATAHORA	= (Select Max(Y.DATAHORA) 
																													 From K_GLOP_VEICULOPOSICOES Y
																													Where Y.VEICULO		= X.VEICULO))
			 Where GLOP_VIAGENS.STATUS													In (177, 178)
			   And GLOP_VIAGEMPARADAS.PARADAEFETUADA									= 'N'
			   And GLOP_VIAGEMPARADAS.PARADACANCELADA									= 'N'
			   And GLOP_VIAGEMPARADAS.ORDEM												> 0
			   And Cast(DateAdd(Hour, ((Select Count(1) 
									    From GLOP_VIAGEMPARADAS X
									   Where X.VIAGEM					= GLOP_VIAGENS.HANDLE
									     And Not X.FILIAL				= GLOP_VIAGENS.FILIALORIGEM
									     And Not X.FILIAL				= GLOP_VIAGENS.FILIALDESTINO
									     And X.PARADAEFETUADA			= 'N') * 2),
					   IsNull(DateAdd(Second, ((Cast(((((Round((DBO.FN_CALCULADISTANCIA(K_GLOP_VEICULOPOSICOES.LATITUDE,	K_GLOP_VEICULOPOSICOES.LONGITUDE, FILIAIS.K_LATITUDE, FILIAIS.K_LONGITUDE) / 55),4) - Cast(Round((DBO.FN_CALCULADISTANCIA(K_GLOP_VEICULOPOSICOES.LATITUDE,	K_GLOP_VEICULOPOSICOES.LONGITUDE, FILIAIS.K_LATITUDE, FILIAIS.K_LONGITUDE) / 55),4) As Int)) * 100) - Cast(((Round((DBO.FN_CALCULADISTANCIA(K_GLOP_VEICULOPOSICOES.LATITUDE,	K_GLOP_VEICULOPOSICOES.LONGITUDE, FILIAIS.K_LATITUDE, FILIAIS.K_LONGITUDE) / 55),4) - Cast(Round((DBO.FN_CALCULADISTANCIA(K_GLOP_VEICULOPOSICOES.LATITUDE,	K_GLOP_VEICULOPOSICOES.LONGITUDE, FILIAIS.K_LATITUDE, FILIAIS.K_LONGITUDE) / 55),4) As Int)) * 100) As Int)) * 100) As Int) * 0.6)), 
									  DateAdd(Minute, (Cast(((Round((DBO.FN_CALCULADISTANCIA(K_GLOP_VEICULOPOSICOES.LATITUDE,	K_GLOP_VEICULOPOSICOES.LONGITUDE, FILIAIS.K_LATITUDE, FILIAIS.K_LONGITUDE) / 55),4) - Cast(Round((DBO.FN_CALCULADISTANCIA(K_GLOP_VEICULOPOSICOES.LATITUDE,	K_GLOP_VEICULOPOSICOES.LONGITUDE, FILIAIS.K_LATITUDE, FILIAIS.K_LONGITUDE) / 55),4) As Int)) * 100) As Int) * 0.6), 
											  DateAdd(Hour, Cast(Round((DBO.FN_CALCULADISTANCIA(K_GLOP_VEICULOPOSICOES.LATITUDE,	K_GLOP_VEICULOPOSICOES.LONGITUDE, FILIAIS.K_LATITUDE, FILIAIS.K_LONGITUDE) / 55),4) As Int), GetDate()))),
							  GLOP_VIAGENS.PREVISAOCHEGADA))	As Date)				>= DateAdd(Day, -15, Cast(GetDate() As Date))
			   And GLOP_VIAGENS.CHEGADAEFETIVA											Is Null
			   And GLOP_VIAGENS.TIPOVIAGEM												= 172) TB
			   
WHERE [Previs�o Chegada] < DATEADD(HH, +3, GETDATE())

ORDER BY PAGINA, CODIGO