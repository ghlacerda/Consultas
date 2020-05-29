Select Case Month(CT_LANCAMENTOS.COMPETENCIA)
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
	   End												[MES],
	   Sum(IIF(CT_LANCAMENTOS.NATUREZA = 'D', CT_LANCAMENTOS.VALOR*(-1), CT_LANCAMENTOS.VALOR)) 	[TOTAL]
  From CT_LANCAMENTOS 
 Inner Join CT_CONTAS		On CT_CONTAS.HANDLE					= CT_LANCAMENTOS.CONTA
 Where Year(CT_LANCAMENTOS.COMPETENCIA)							= Year(GetDate())
   And CT_CONTAS.VERSAO									= 4
   And CT_CONTAS.EMPRESA								= 1
   And CT_CONTAS.HANDLE									In (20077, 33296, 33295, 20274, 31413)
   And CT_LANCAMENTOS.LANCAMENTOGERADO							= 'N'
 Group By CT_LANCAMENTOS.COMPETENCIA   
 Order By CT_LANCAMENTOS.COMPETENCIA