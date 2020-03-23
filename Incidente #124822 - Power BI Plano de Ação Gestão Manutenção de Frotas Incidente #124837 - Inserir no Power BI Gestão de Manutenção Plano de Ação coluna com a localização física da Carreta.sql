--Localizacao fisica da carreta

Select 
	 MA_RECURSOS.CODIGO																	[PLACA],
	 MA_RECURSOS.HANDLE,
	Cast(MF_ORDEMSERVICOS.DATAINCLUSAO As Date) AS [DATA INCLUSAO],
		   DateDiff(Day, Cast(MF_ORDEMSERVICOS.DATAINCLUSAO As Date), Cast(GetDate() As Date))	[TEMPO],
		   F.NOME as FILIAL
From MA_RECURSOS
 Inner Join MF_ORDEMSERVICOS 		On MF_ORDEMSERVICOS.HANDLE		= (Select Max(MF.HANDLE)
																		 From MF_ORDEMSERVICOS MF
																		Where MF.VEICULO					= MA_RECURSOS.HANDLE
																		  And MF.STATUS						<> 3
																		  --And MF.FILIAL <> 2 --TIAGO SOLICITOU QUE FILTRASSE SOMENTE A FILIAL DE CONTAGEM
																		  And ((MF.CODIGO NOT LIKE '%PD.%')
																				OR MF.CODIGO NOT LIKE '%PM.%'))
 Inner join FILIAIS F ON MA_RECURSOS.LOCALFILIAL = F.HANDLE -- foi inserido esse join para o novo campo de FILIAL
 Where MF_ORDEMSERVICOS.STATUS										<> 3
   And Cast(MF_ORDEMSERVICOS.DATAINCLUSAO	As Date)				< DateAdd(Day, -7, Cast(GetDate() As Date))
   And (MA_RECURSOS.TIPO											= 1 
	Or  MA_RECURSOS.TIPO											= 4) 
   And MA_RECURSOS.TIPOREGISTRO										= 1
   And MA_RECURSOS.ATIVO											= 'S'
   And MA_RECURSOS.ORIGEM											= 1
   And MA_RECURSOS.ACOPLAGEM                                        in (2,4) --Adicionado para mostrar somente carretas que tem acoplagem.
   And Not (MF_ORDEMSERVICOS.CODIGO									Like 'PD.%'
	Or		MF_ORDEMSERVICOS.CODIGO									Like 'PM.%')
  AND MA_RECURSOS.CODIGO NOT LIKE '%VENDA%'
  and MA_RECURSOS.LOCALFILIAL <> 2 --TIAGO SOLICITOU QUE FILTRASSE SOMENTE A FILIAL diferente DE CONTAGEM
  --AND MA_RECURSOS.CODIGO = 'JNY4553'
   
 Order By 2 Desc
