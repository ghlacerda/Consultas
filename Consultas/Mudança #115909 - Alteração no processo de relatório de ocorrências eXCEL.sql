--==============================================================================================================================================================
--seleciona os clientes que podem ocorrencias.
--==============================================================================================================================================================
--DROP TABLE IF EXISTS #TempOcor

INSERT INTO [SQLAZGERAL].[BI_PATRUS].[dbo].[TEMP_TempOcorrencias]
Select Stuff((Select Concat(';', CONTATO.EMAIL)
		From GN_PESSOACONTATOS CONTATO
	       Where CONTATO.PESSOA				= GN_PESSOAS.HANDLE
		 And CONTATO.K_TIPOENVIORELATOCORRENCIAS	= GN_PESSOACONTATOS.K_TIPOENVIORELATOCORRENCIAS
		 For XML PATH ('')), 1, 1, '')						[EMAIL],
       Stuff((Select Top 1 Concat(';', CONTATO.EMAIL)
		From GN_PESSOACONTATOS CONTATO
	       Where CONTATO.PESSOA				= GN_PESSOAS.HANDLE
		 And CONTATO.K_TIPOENVIORELATOCORRENCIAS	= GN_PESSOACONTATOS.K_TIPOENVIORELATOCORRENCIAS
		 And CONTATO.EMAIL							Like '%@Patrus.%'
		 For XML PATH ('')), 1, 1, '')						[EMAILRESPOSTA],					 	   
	   GN_PESSOAS.CGCCPF											[CNPJ],
	   '<center><h2><b><u>Comunicado de Ocorrências</u></b></h2></center></br>
		Prezado cliente, </br></br>
		Informamos que as mercadorias constantes na(s) nota(s) Fiscal(s) em referência, encontram-se pendentes em nosso depósito, aguardamos instruções de como proceder. </br></br>
		Vale lembrar que: </br>
		<font color="Red">“Conforme resolução 123 de 2005, cap. V / art. 8º, o prazo de cobertura no seguro de RCTR-C (Responsabilidade Civil do Transportador Rodoviário de Carga) para os riscos de incêndio ou explosão, nos depósitos, armazéns ou pátios usados pelo transportador nas localidades de início, pernoite, baldeação e destino da viagem, é de 10 dias improrrogáveis, contados da data de entrada naqueles depósitos, armazéns ou pátios."</font></br></br>
		Cobranças adicionais de <b>TPC (Taxa de Permanecia de Carga) e TFD (Taxa de Fiel Depositário)</b>, quando aplicáveis serão feitas conforme acordo comercial. </br></br>
		Atenciosamente,</br>
		<b>SIC</b> - Setor de Informação ao Cliente
		<b>Patrus Transportes Urgentes</b>'							[CORPOEMAIL],
	   Case GN_PESSOACONTATOS.K_TIPOENVIORELATOCORRENCIAS	
			When 1 Then 'MHTML'
			When 2 Then 'EXCELOPENXML'
			When 3 Then 'PDF'
			Else 'EXCELOPENXML'
	   End															[TIPOENVIO],
	   Concat('Comunicado de ocorrencias |',
				' NF: ', IsNull(GLGLORI.NUMEROSDOCUMENTOS, GLGL_DOCUMENTOS.NUMEROSDOCUMENTOS),
				' | CT-e: ', IsNull(GLGLORI.NUMERO, GLGL_DOCUMENTOS.NUMERO))		[ASSUNTO],
	   Min(GLOP_OCORRENCIAS.HANDLE)										[HDLOCORREN]

  From GN_PESSOAS
 Inner Join GN_PESSOACONTATOS		On GN_PESSOACONTATOS.PESSOA									= GN_PESSOAS.HANDLE 
 Inner Join GLGL_DOCUMENTOS			On GLGL_DOCUMENTOS.TOMADORSERVICOPESSOA						= GN_PESSOAS.HANDLE

 Inner Join GLOP_OCORRENCIAS			On GLOP_OCORRENCIAS.DOCUMENTO							= GLGL_DOCUMENTOS.HANDLE
 Inner Join GLOP_OCORRENCIALOGS			On GLOP_OCORRENCIALOGS.OCORRENCIA						= GLOP_OCORRENCIAS.HANDLE 
 Inner Join GLOP_MOTIVOOCORRENCIAS		On GLOP_MOTIVOOCORRENCIAS.HANDLE						= GLOP_OCORRENCIAS.OCORRENCIA
  Left Join GLOP_SERVICOREALIZADORPS	On GLOP_SERVICOREALIZADORPS.DOCUMENTOLOGISTICARPS		= GLGL_DOCUMENTOS.HANDLE
  Left Join GLGL_DOCUMENTOS	GLGLORI		On GLGLORI.HANDLE										= GLOP_SERVICOREALIZADORPS.DOCUMENTOLOGISTICA
 
 Where GN_PESSOACONTATOS.K_ENVIARELATORIOOCORRENCIAS											= 'S'
   And Exists (Select 1
				 From GN_PESSOACONTATOS CONTATO
				Where CONTATO.K_ENVIARELATORIOOCORRENCIAS										= 'S'
				  And CONTATO.PESSOA															= GN_PESSOAS.HANDLE)

   And ((IsNull(GLGLORI.TIPODOCUMENTO, GLGL_DOCUMENTOS.TIPODOCUMENTO)							In (2)
   And   IsNull(GLGLORI.TIPODOCUMENTOFRETE, GLGL_DOCUMENTOS.TIPODOCUMENTOFRETE)					= 153)
    Or  (IsNull(GLGLORI.TIPODOCUMENTO, GLGL_DOCUMENTOS.TIPODOCUMENTO)							In (6)
   And   IsNull(GLGLORI.TIPODOCUMENTOFRETE, GLGL_DOCUMENTOS.TIPODOCUMENTOFRETE)					In (322, 324)))
   And (GLOP_OCORRENCIAS.PENDENCIA																= 'S'  
   And  GLOP_OCORRENCIAS.ESTORNADO																= 'N'
   And  GLOP_OCORRENCIAS.CONCLUIDOEM															Is Null)
   And GLOP_MOTIVOOCORRENCIAS.LISTARRELATORIO													= 'S'
 --  And (GLOP_MOTIVOOCORRENCIAS.HANDLE															In (2,3,4,5,6,9,16,21,25,28,29,30,34,38,39,41,49,55,56,64,66,74,80,83,90,96,98,314,315,316,318,319,321,322,325,872,1196,1199,1280,1532,2197,2283,11770,11773,12026,19233,20328,22014,22018,25058,25059,25062,25153,25553,26779,27048,27915,28391,28396,28397,28894,29435,29439,31037,32367)
	--Or  GLOP_MOTIVOOCORRENCIAS.OCORRENCIAPADRAO													In (2,3,4,5,6,9,16,21,25,28,29,30,34,38,39,41,49,55,56,64,66,74,80,83,90,96,98,314,315,316,318,319,321,322,325,872,1196,1199,1280,1532,2197,2283,11770,11773,12026,19233,20328,22014,22018,25058,25059,25062,25153,25553,26779,27048,27915,28391,28396,28397,28894,29435,29439,31037,32367))
   And (GLOP_OCORRENCIALOGS.DATA																Between    
																											--Case 
																											-- When DatePart(Hour, GetDate()) <= 11 Then Cast(Cast(Cast(DateAdd(Day, -1, GetDate()) As Date) As DateTime) + '23:00:00' As DateTime)
																											-- When DatePart(Hour, GetDate()) <= 17 Then Cast(Cast(Cast(DateAdd(Day,  0, GetDate()) As Date) As DateTime) + '11:00:00' As DateTime)
																											-- When DatePart(Hour, GetDate()) <= 23 Then Cast(Cast(Cast(DateAdd(Day,  0, GetDate()) As Date) As DateTime) + '17:00:00' As DateTime)
																											-- When DatePart(Hour, GetDate()) >  23 Then Cast(Cast(Cast(DateAdd(Day,  0, GetDate()) As Date) As DateTime) + '17:00:00' As DateTime)
																										    --End
																											Cast(Cast(Cast(DateAdd(Day, -1, GetDate()) As Date) As DateTime) + '11:00:00' As DateTime)
																									And Case 
																											 When DatePart(Hour, GetDate()) <= 11 Then Cast(Cast(Cast(DateAdd(Day,  0, GetDate()) As Date) As DateTime) + '11:00:00' As DateTime)
																											 When DatePart(Hour, GetDate()) <= 17 Then Cast(Cast(Cast(DateAdd(Day,  0, GetDate()) As Date) As DateTime) + '17:00:00' As DateTime)
																											 When DatePart(Hour, GetDate()) <= 23 Then Cast(Cast(Cast(DateAdd(Day,  0, GetDate()) As Date) As DateTime) + '23:00:00' As DateTime)
																											 When DatePart(Hour, GetDate()) >  23 Then Cast(Cast(Cast(DateAdd(Day,  0, GetDate()) As Date) As DateTime) + '23:00:00' As DateTime)
																										End)
   And GN_PESSOAS.CGCCPF																		In ('87.235.172/0001-22', '10.158.356/0001-01')
   And GLOP_OCORRENCIALOGS.DESCRICAO															= 'Inclusão'    
 Group By GN_PESSOAS.HANDLE,
		  GN_PESSOACONTATOS.K_TIPOENVIORELATOCORRENCIAS,
		  GN_PESSOAS.CGCCPF,	  
		  IsNull(GLGLORI.NUMERO, GLGL_DOCUMENTOS.NUMERO),
		  IsNull(GLGLORI.NUMEROSDOCUMENTOS, GLGL_DOCUMENTOS.NUMEROSDOCUMENTOS)
 Union All 
Select Stuff((Select Concat(';', CONTATO.EMAIL)
			    From GN_PESSOACONTATOS CONTATO
			   Where CONTATO.PESSOA							= GN_PESSOAS.HANDLE
			     And CONTATO.K_TIPOENVIORELATOCORRENCIAS	= GN_PESSOACONTATOS.K_TIPOENVIORELATOCORRENCIAS
			     For XML PATH ('')), 1, 1, '')				[EMAIL],
	   Stuff((Select Top 1 Concat(';', CONTATO.EMAIL)
			    From GN_PESSOACONTATOS CONTATO
			   Where CONTATO.PESSOA							= GN_PESSOAS.HANDLE
			     And CONTATO.K_TIPOENVIORELATOCORRENCIAS	= GN_PESSOACONTATOS.K_TIPOENVIORELATOCORRENCIAS
				 And CONTATO.EMAIL							Like '%@Patrus.%'
			     For XML PATH ('')), 1, 1, '')				[EMAILRESPOSTA],					 	   
	   GN_PESSOAS.CGCCPF									[CNPJ],
	   '<center><h2><b><u>Comunicado de Ocorrências</u></b></h2></center></br>
		Prezado cliente, </br></br>
		Informamos que as mercadorias constantes na(s) nota(s) Fiscal(s) em referência, encontram-se pendentes em nosso depósito, aguardamos instruções de como proceder. </br></br>
		Vale lembrar que: </br>
		<font color="Red">“Conforme resolução 123 de 2005, cap. V / art. 8º, o prazo de cobertura no seguro de RCTR-C (Responsabilidade Civil do Transportador Rodoviário de Carga) para os riscos de incêndio ou explosão, nos depósitos, armazéns ou pátios usados pelo transportador nas localidades de início, pernoite, baldeação e destino da viagem, é de 10 dias improrrogáveis, contados da data de entrada naqueles depósitos, armazéns ou pátios."</font></br></br>
		Cobranças adicionais de <b>TPC (Taxa de Permanecia de Carga) e TFD (Taxa de Fiel Depositário)</b>, quando aplicáveis serão feitas conforme acordo comercial. </br></br>
		Atenciosamente,</br>r
		<b>SIC</b> - Setor de Informação ao Cliente
		<b>Patrus Transportes Urgentes</b>'					[CORPOEMAIL],
	   Case GN_PESSOACONTATOS.K_TIPOENVIORELATOCORRENCIAS	
			When 1 Then 'MHTML'
			When 2 Then 'EXCELOPENXML'
			When 3 Then 'PDF'
			Else 'EXCELOPENXML'
	   End													[TIPOENVIO],
	   Concat('Comunicado de ocorrencias | ',
				Format(GetDate(), 'dd/MM/yyyy HH:mm'))		[ASSUNTO],
	   0													[HDLOCORREN]
  From GN_PESSOAS
 Inner Join GN_PESSOACONTATOS		On GN_PESSOACONTATOS.PESSOA		= GN_PESSOAS.HANDLE
 Where GN_PESSOACONTATOS.K_ENVIARELATORIOOCORRENCIAS				= 'S'
   And Exists (Select 1
				 From GN_PESSOACONTATOS CONTATO
				Where CONTATO.K_ENVIARELATORIOOCORRENCIAS			= 'S'
				  And CONTATO.PESSOA								= GN_PESSOAS.HANDLE)
   And Not GN_PESSOAS.CGCCPF										In ('87.235.172/0001-22', '10.158.356/0001-01')
 Group By GN_PESSOAS.HANDLE,
		  GN_PESSOACONTATOS.K_TIPOENVIORELATOCORRENCIAS,
		  GN_PESSOAS.CGCCPF


--==============================================================================================================================================================
--==============================================================================================================================================================
--Consulta Principal Email
--==============================================================================================================================================================
--==============================================================================================================================================================

DECLARE @UPDT VARCHAR(1) = 'N'
DECLARE @BeginDate DATE = DATEADD(DD,-1,GETDATE())
DECLARE @EndDate DATE = GETDATE()
--DECLARE @HDLOCORREN INT = 0


--DROP TABLE IF EXISTS #OCORRENCIAS

Select GLOP_OCORRENCIAS.HANDLE,
	   IsNull(GLGLORI.NUMERO, GLGL_DOCUMENTOS.NUMERO)											[DOCUMENTO],
	   GNREM.NOME																				[REMETENTE],
	   GNDES.NOME																				[DESTINATARIO],
	   MUNICIPIOS.NOME																			[MUNICIPIO],
	   ESTADOS.SIGLA																			[ESTADO],
	   FILIAIS.NOME																				[FILIAL],
	   Cast(Cast(GLGL_DOCUMENTOS.DATAEMISSAO As Date) As DateTime) + 
			Format(GLGL_DOCUMENTOS.HORAEMISSAO, 'HH:mm:ss')										[EMISSAO],
	   IsNull(GLGLORI.NUMEROSDOCUMENTOS, GLGL_DOCUMENTOS.NUMEROSDOCUMENTOS)						[NF],
	   IsNull(GLGLORI.DOCCLIVALORTOTAL, GLGL_DOCUMENTOS.DOCCLIVALORTOTAL)						[VLRNF],
	   IsNull(GLGLORI.DOCCLIVOLUME, GLGL_DOCUMENTOS.DOCCLIVOLUME)								[VOLUME],
	   GLOP_OCORRENCIAS.INCLUIDOEM,
	   GLOP_MOTIVOOCORRENCIAS.DESCRICAO															[OCORRENCIA],  
	   --IIF(GLOP_MOTIVOOCORRENCIAS.DESCRICAO	Like '%Agen%' Or GLOP_MOTIVOOCORRENCIAS.DESCRICAO	Like 'Entrega Prog%',
		  -- IIF(Replace(Cast(SubString(OBSERVACAO, 1, CharIndex(Char(13), OBSERVACAO)) As VarChar(Max)), Char(10), '') Like '%Agend%', Replace(Cast(SubString(OBSERVACAO, 1, CharIndex(Char(13), OBSERVACAO)) As VarChar(Max)), Char(10), '') , ''),
		  -- '')	
	   IIF(GLOP_MOTIVOOCORRENCIAS.DESCRICAO	Like '%Agen%' Or GLOP_MOTIVOOCORRENCIAS.DESCRICAO	Like 'Entrega Prog%',																				
			IIF(GLOP_AGENDAMENTOS.HANDLE Is Null, 
				'', 
				Concat('Agendado para entrega no dia ', Format(GLOP_AGENDAMENTOS.DATAENTREGAINICIAL, 'dd/MM/yyyy'))), '') 	[OBSERVACAO],
	   A.*

  Into #OCORRENCIAS
  From GLGL_DOCUMENTOS  
 Inner Join GLOP_OCORRENCIAS			On GLOP_OCORRENCIAS.DOCUMENTO							= GLGL_DOCUMENTOS.HANDLE
 Inner Join GLOP_OCORRENCIALOGS			On GLOP_OCORRENCIALOGS.OCORRENCIA						= GLOP_OCORRENCIAS.HANDLE
 Inner Join GLOP_MOTIVOOCORRENCIAS		On GLOP_MOTIVOOCORRENCIAS.HANDLE						= GLOP_OCORRENCIAS.OCORRENCIA
  Left Join GLOP_SERVICOREALIZADORPS	On GLOP_SERVICOREALIZADORPS.DOCUMENTOLOGISTICARPS		= GLGL_DOCUMENTOS.HANDLE
  Left Join GLGL_DOCUMENTOS	GLGLORI		On GLGLORI.HANDLE										= GLOP_SERVICOREALIZADORPS.DOCUMENTOLOGISTICA

  Left Join GLGL_DOCUMENTOASSOCIADOS	On GLGL_DOCUMENTOASSOCIADOS.DOCUMENTOLOGISTICA			= IsNull(GLGLORI.HANDLE, GLGL_DOCUMENTOS.HANDLE)	
  Left Join GLOP_AGENDAMENTODOCCLIS		On GLOP_AGENDAMENTODOCCLIS.DOCUMENTOCLIENTE				= GLGL_DOCUMENTOASSOCIADOS.DOCUMENTOCLIENTE
  left Join GLOP_AGENDAMENTOS			On GLOP_AGENDAMENTOS.HANDLE								= GLOP_AGENDAMENTODOCCLIS.AGENDAMENTO

 Inner Join GN_PESSOAS	GNREM			On GNREM.HANDLE											= GLGL_DOCUMENTOS.REMETENTE
 Inner Join GN_PESSOAS	GNTOM			On GNTOM.HANDLE											= GLGL_DOCUMENTOS.TOMADORSERVICOPESSOA
 Inner Join GN_PESSOAS	GNDES			On GNDES.HANDLE											= GLGL_DOCUMENTOS.DESTINATARIO
 Inner Join GLGL_PESSOAENDERECOS		On GLGL_PESSOAENDERECOS.HANDLE							= GLGL_DOCUMENTOS.DESTINOENDERECO 
 Inner Join MUNICIPIOS					On MUNICIPIOS.HANDLE									= GLGL_PESSOAENDERECOS.MUNICIPIO
 Inner Join ESTADOS						On ESTADOS.HANDLE										= MUNICIPIOS.ESTADO
 Inner Join FILIAIS						On FILIAIS.HANDLE										= IsNull(GLGLORI.FILIALENTREGA, GLGL_DOCUMENTOS.FILIALENTREGA)
  Left Join GLOP_VIAGENS				On GLOP_VIAGENS.HANDLE									= GLOP_OCORRENCIAS.VIAGEM
  LEFT JOIN [SQLAZGERAL].[BI_PATRUS].[dbo].[TEMP_TempOcorrencias] A					ON A.CNPJ COLLATE SQL_Latin1_General_CP850_CI_AS = GNTOM.CGCCPF 
																					AND (A.HDLOCORREN = GLOP_OCORRENCIAS.HANDLE OR A.HDLOCORREN = 0)
 Where ((IsNull(GLGLORI.TIPODOCUMENTO, GLGL_DOCUMENTOS.TIPODOCUMENTO)							In (2)
   And   IsNull(GLGLORI.TIPODOCUMENTOFRETE, GLGL_DOCUMENTOS.TIPODOCUMENTOFRETE)					= 153)
    Or  (IsNull(GLGLORI.TIPODOCUMENTO, GLGL_DOCUMENTOS.TIPODOCUMENTO)							In (6)
   And   IsNull(GLGLORI.TIPODOCUMENTOFRETE, GLGL_DOCUMENTOS.TIPODOCUMENTOFRETE)					In (322, 324)))
   And (GLOP_OCORRENCIAS.PENDENCIA																= 'S'  
   And  GLOP_OCORRENCIAS.ESTORNADO																= 'N'
   And  GLOP_OCORRENCIAS.CONCLUIDOEM															Is Null)
   And GLOP_MOTIVOOCORRENCIAS.LISTARRELATORIO													= 'S'
 --  And (GLOP_MOTIVOOCORRENCIAS.HANDLE															In (2,3,4,5,6,9,16,21,25,28,29,30,34,38,39,41,49,55,56,64,66,74,80,83,90,96,98,314,315,316,318,319,321,322,325,872,1196,1199,1280,1532,2197,2283,11770,11773,12026,19233,20328,22014,22018,25058,25059,25062,25153,25553,26779,27048,27915,28391,28396,28397,28894,29435,29439,31037,32367)
	--Or  GLOP_MOTIVOOCORRENCIAS.OCORRENCIAPADRAO													In (2,3,4,5,6,9,16,21,25,28,29,30,34,38,39,41,49,55,56,64,66,74,80,83,90,96,98,314,315,316,318,319,321,322,325,872,1196,1199,1280,1532,2197,2283,11770,11773,12026,19233,20328,22014,22018,25058,25059,25062,25153,25553,26779,27048,27915,28391,28396,28397,28894,29435,29439,31037,32367))
   And (GLOP_OCORRENCIALOGS.DATA																Between CONVERT(DATETIME, CONCAT(@BeginDate,' ','23:00:00'))
																									And CONVERT(DATETIME, CONCAT(@EndDate,' ', '11:00:00')))
 --  And GNTOM.CGCCPF																				In (SELECT DISTINCT CNPJ FROM #TempOcor)
 --  And (GLOP_OCORRENCIAS.HANDLE																	= @HDLOCORREN SELECT DISTINCT  HDLOCORREN FROM #TempOcor
	--Or  @HDLOCORREN																				= 0)
   And GLOP_OCORRENCIALOGS.DESCRICAO															= 'Inclusão'

If @UPDT = 'S'
BEGIN
       Update GLOP_OCORRENCIAS
          Set GLOP_OCORRENCIAS.OBSERVACAO      =      Concat('Ocorrência comunicada.',																																				 Char(13)+Char(10),
                                                                                    '',                                                                                                                                              Char(13)+Char(10),
                                                                                    Format(GetDate(), 'dd/MM/yyyy HH:mm:ss'),    ' - ', Case DatePart(DW, GetDate())      
                                                                                                                                                                               When 1 Then 'Dom'
                                                                                                                                                                               When 2 Then 'Seg'
                                                                                                                                                                               When 3 Then 'Ter'
                                                                                                                                                                               When 4 Then 'Qua'
                                                                                                                                                                               When 5 Then 'Qui'
                                                                                                                                                                               When 6 Then 'Sex'
                                                                                                                                                                               When 7 Then 'Sab'
                                                                                                                                                                       End, ' - Comunicado de Ocorrencias', Char(13)+Char(10),
                                                                                    '____________________________________________________________________',                              Char(13)+Char(10),
                                                                                    '',                                                                                                                                              Char(13)+Char(10),
                                                                                    GLOP_OCORRENCIAS.OBSERVACAO)
From GLOP_OCORRENCIAS
Inner Join #OCORRENCIAS TOCORRENCIAS   On TOCORRENCIAS.HANDLE     = GLOP_OCORRENCIAS.HANDLE

Update GLOP_OCORRENCIAS
          Set 
               K_SITUACAOPENDENCIA = 3
              ,K_DTINCLUSAOSITUACAOPENDENCIA = GETDATE()
From GLOP_OCORRENCIAS
Inner Join #OCORRENCIAS TOCORRENCIAS   On TOCORRENCIAS.HANDLE     = GLOP_OCORRENCIAS.HANDLE
Where GLOP_OCORRENCIAS.HANDLE = (Select Min(O.HANDLE) FROM GLOP_OCORRENCIAS O WHERE O.AGRUPADOR = GLOP_OCORRENCIAS.AGRUPADOR)
AND GLOP_OCORRENCIAS.K_RESPONSAVELPENDENCIA = 'P'
AND GLOP_OCORRENCIAS.K_SITUACAOPENDENCIA = 4;
END;

INSERT INTO [SQLAZGERAL].[BI_PATRUS].[dbo].[BI_NotificationOcorrencia]
Select DOCUMENTO, 
	   REMETENTE,
	   DESTINATARIO,
	   MUNICIPIO,
	   ESTADO,
	   FILIAL,
	   EMISSAO,
	   NF,
	   VLRNF,
	   VOLUME,
	   INCLUIDOEM,
	   OCORRENCIA,
	   OBSERVACAO,
	   EMAIL,
	   EMAILRESPOSTA,
	   CNPJ,
	   CORPOEMAIL,
	   TIPOENVIO,
	   ASSUNTO,
	   HDLOCORREN AS TEMPCORREN,
	   CONCAT(CONCAT(CONVERT(varchar, @BeginDate, 101),' ','23:00:00'),' à ', CONCAT(CONVERT(varchar, @EndDate, 101),' ','11:00:00')) AS [DATAHORAENVIOEMAIL],
	   'NÃO' AS [STATUSENVIO]
  From #OCORRENCIAS TOCORRENCIAS
  WHERE EMAIL IS NOT NULL
 Group By DOCUMENTO, 
	      REMETENTE,
	      DESTINATARIO,
	      MUNICIPIO,
	      ESTADO,
	      FILIAL,
	      EMISSAO,
	      NF,
	      VLRNF,
	      VOLUME,
	      INCLUIDOEM,
	      OCORRENCIA,
	      OBSERVACAO,
		  EMAIL,
		  EMAILRESPOSTA,
		  CNPJ,
		  CORPOEMAIL,
		  TIPOENVIO,
		  ASSUNTO,
		  HDLOCORREN


----==============================================================================================================================================================
----Envia emails enquanto contador for menor que x
----==============================================================================================================================================================
DECLARE @counter INT = 1;
DECLARE @countx INT
SET @countx = (SELECT COUNT(EMAIL) FROM [dbo].[BI_NotificationOcorrencia] WHERE [STATUSENVIO] = 'NÃO' AND TIPOENVIO = 'EXCELOPENXML')

WHILE @counter <= @countx
BEGIN

--==============================================================================================================================================================
--Deleta o arquivo e cria um novo em branco para inserior os dados
--==============================================================================================================================================================
--delete existing file
exec master..xp_cmdshell 'del \\fileserverazure\relatorios_ocorrencias$\Ocorrencias11.xls' 

--create new file from blank template
exec master..xp_cmdshell 'copy \\fileserverazure\relatorios_ocorrencias$\BackupArquivoVazio\Ocorrencias11.xls \\fileserverazure\relatorios_ocorrencias$\Ocorrencias11.xls' 

----==============================================================================================================================================================
----Retorna os destinatarios dos emails
----==============================================================================================================================================================

DROP TABLE #EmailsHaEnviar
SELECT TOP (1) EMAIL into #EmailsHaEnviar FROM [dbo].[BI_NotificationOcorrencia] 
WHERE [STATUSENVIO] = 'NÃO' AND TIPOENVIO = 'EXCELOPENXML'

--==============================================================================================================================================================
--POPULA O ARQUIVO EXCEL (SO FUNCIONA NO SQLAZGERAL)
--==============================================================================================================================================================
insert into OPENROWSET('Microsoft.ACE.OLEDB.12.0','Excel 12.0;
Database=\\fileserverazure\relatorios_ocorrencias$\Ocorrencias11.xls;HDR=NO;','SELECT * FROM [plan1$]') 
SELECT 
	   [DOCUMENTO]
	   ,[REMETENTE]
	   ,[DESTINATARIO]
	   ,[MUNICIPIO]
	   ,[ESTADO]
	   ,[FILIAL]
	   ,[EMISSAO]
	   ,[NF]
	   ,[VLRNF]
       ,[VOLUME]
       ,[INCLUIDOEM]
	   ,[OCORRENCIA]
       ,[OBSERVACAO]
  
FROM [dbo].[BI_NotificationOcorrencia]
WHERE STATUSENVIO = 'NÃO'
AND TIPOENVIO = 'EXCELOPENXML'
AND EMAIL = (SELECT EMAIL FROM #EmailsHaEnviar) 

DECLARE @QYERY VARCHAR(MAX) 
SET @QYERY = (SELECT * FROM #EmailsHaEnviar)


EXEC msdb.dbo.sp_send_dbmail  
			@profile_name = 'MonitoramentoSQL',  
			@recipients = @QYERY,  
			@file_attachments ='\\fileserverazure\relatorios_ocorrencias$\Ocorrencias11.xls',  
			@subject = 'Automated Success Message',
			@body_format='HTML';

--==============================================================================================================================================================
--Update nos destinatarios que já foram enviados.
--==============================================================================================================================================================

UPDATE [dbo].[BI_NotificationOcorrencia]
SET [STATUSENVIO] = 'SIM'
WHERE EMAIL COLLATE SQL_Latin1_General_CP850_CI_AS = (SELECT EMAIL FROM #EmailsHaEnviar) AND TIPOENVIO = 'EXCELOPENXML'


    SET @counter = @counter + 1;
END
