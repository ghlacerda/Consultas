select
	MES,
	sum([TOTAL]) as [TOTAL]
from(
Select 
Case Month(CT_LANCAMENTOS.COMPETENCIA)
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
	   Month(CT_LANCAMENTOS.COMPETENCIA) as numeromes,
	   DATEPART(DW, FN_DOCUMENTOS.DATAEMISSAO) dia,
	   Sum(IIF(CT_LANCAMENTOS.NATUREZA = 'D', CT_LANCAMENTOS.VALOR*(-1), CT_LANCAMENTOS.VALOR)) 	[TOTAL]
  From CT_LANCAMENTOS WITH(NOLOCK)
 Inner Join CT_CONTAS WITH(NOLOCK)		On CT_CONTAS.HANDLE					= CT_LANCAMENTOS.CONTA
 left join FN_DOCUMENTOS WITH(NOLOCK) ON (CT_LANCAMENTOS.LANCAMENTOFINANCEIRO =  FN_DOCUMENTOS.HANDLE)
 Where 1=1 
	--Year(CT_LANCAMENTOS.COMPETENCIA)							= Year(GetDate())
   and CAST(FN_DOCUMENTOS.DATAEMISSAO AS DATE) >= CAST(DateAdd(yy, DateDiff(yy,0,GetDate()) - 1, 0)  AS DATE)
   and CAST(FN_DOCUMENTOS.DATAEMISSAO AS DATE) < CAST(dateadd(yy, -1,getdate()) AS DATE)
   And CT_CONTAS.VERSAO									= 4
   And CT_CONTAS.EMPRESA								= 1
   And CT_CONTAS.HANDLE									In (20077, 33296, 33295, 20274, 31413)
   And CT_LANCAMENTOS.LANCAMENTOGERADO							= 'N'
   AND DATEPART(DW, FN_DOCUMENTOS.DATAEMISSAO) NOT IN (1,7)
 Group By CT_LANCAMENTOS.COMPETENCIA, DATEPART(DW, FN_DOCUMENTOS.DATAEMISSAO), Month(CT_LANCAMENTOS.COMPETENCIA)  
 --Order By CT_LANCAMENTOS.COMPETENCIA
 ) as t

 group by MES,numeromes
 order by numeromes