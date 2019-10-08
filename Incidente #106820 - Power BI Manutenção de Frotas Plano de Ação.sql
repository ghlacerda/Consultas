Select MA_RECURSOS.CODIGO																	[PLACA],
	   DateDiff(Day, Cast(MF_ORDEMSERVICOS.DATAINCLUSAO As Date), Cast(GetDate() As Date))	[TEMPO]
  From MA_RECURSOS
 Inner Join MF_ORDEMSERVICOS 		On MF_ORDEMSERVICOS.HANDLE		= (Select Max(MF.HANDLE)
																		 From MF_ORDEMSERVICOS MF
																		Where MF.VEICULO					= MA_RECURSOS.HANDLE
																		  And MF.STATUS						<> 3
																		  And Not (MF.CODIGO				Like 'PD.%'
																		   Or	   MF.CODIGO				Like 'PM.%'))
 Where MF_ORDEMSERVICOS.STATUS										<> 3
   And Cast(MF_ORDEMSERVICOS.DATAINCLUSAO	As Date)				< DateAdd(Day, -7, Cast(GetDate() As Date))
   And (MA_RECURSOS.TIPO											= 1 
	Or  MA_RECURSOS.TIPO											= 4) 
   And MA_RECURSOS.TIPOREGISTRO										= 1
   And MA_RECURSOS.ATIVO											= 'S'
   And MA_RECURSOS.ORIGEM											= 1
   And Not (MF_ORDEMSERVICOS.CODIGO									Like 'PD.%'
	Or		MF_ORDEMSERVICOS.CODIGO									Like 'PM.%')
 Order By 2 Desc