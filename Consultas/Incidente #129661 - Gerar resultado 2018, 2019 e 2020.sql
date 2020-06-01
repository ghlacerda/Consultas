 WITH ENTREGAS_EPP (                                                                                                                     
	MES,  
	ANO,                                                                                                                               
	TIPO,  
	TOTALVOLUMES,                                                                                                                              
	TOTAL                                                                                                                                
)                                                                                                                                        
AS (                                                                                                                                     
	SELECT                                                                                                                                     
		MONTH(DOC.DATAENTREGA) MES  
		,YEAR(DOC.DATAENTREGA) AS ANO                                                                                                           
		,'EPP' TIPO                                                                                                                            
		,COUNT(1) TOTAL  
		,SUM(DOC.DOCCLIVOLUME) AS    TOTALVOLUMES                                                                                                                   
	FROM GLGL_DOCUMENTOS DOC WITH(NOLOCK)                                                                                                               
	INNER JOIN GLGL_PESSOAENDERECOS DESTINO WITH(NOLOCK) ON (DESTINO.HANDLE = DOC.DESTINOCONSIDERADO)                                                       
	LEFT  JOIN GLGL_PESSOACONFIGURACOES CONFTOMA WITH(NOLOCK) ON (CONFTOMA.PESSOALOGISTICA = DOC.TOMADORSERVICOPESSOA)                                      
	WHERE (DOC.TIPODOCUMENTO = 1 OR (DOC.TIPODOCUMENTO = 2 AND DOC.TIPODOCUMENTOFRETE = 153 AND DOC.STATUSCTE = 7) OR (DOC.TIPODOCUMENTO = 6 AND DOC.TIPORPS <> 324)) 
	AND CONFTOMA.CLIENTEEPP = 'S'                                                                                                             
	AND DOC.DATAENTREGA IS NOT NULL                                                                                                           
	AND DOC.STATUS NOT IN (236,237,417)                                                                                                       

	--If ValorFiltro("ESTADO") <> "" Then
	--   qSql.Add(" AND DESTINO.ESTADO IN (" + ValorFiltro("ESTADO") + ") ")
	--End If

	--AND DESTINO.ESTADO = :ESTADO   
	AND DOC.FILIALENTREGA = 2                                                                                                         
	AND YEAR(DOC.DATAENTREGA) in (2018, 2019, 2020)                                                                                                         
	GROUP BY MONTH(DOC.DATAENTREGA) ,YEAR(DOC.DATAENTREGA)                                                                                                        
	UNION ALL                                                                                                                                
	SELECT                                                                                                                                   
		MONTH(DOC.DATAENTREGA) MES   
		,YEAR(DOC.DATAENTREGA) AS ANO                                                                                                         
		,'Fracionado' TIPO                                                                                                                   
		,COUNT(1) TOTAL    
		,SUM(DOC.DOCCLIVOLUME) AS    TOTALVOLUMES                                                                                                                    
	FROM GLGL_DOCUMENTOS DOC WITH(NOLOCK)                                                                                                                 
	INNER JOIN GLGL_PESSOAENDERECOS DESTINO WITH(NOLOCK) ON (DESTINO.HANDLE = DOC.DESTINOCONSIDERADO)                                                     
	LEFT  JOIN GLGL_PESSOACONFIGURACOES CONFTOMA WITH(NOLOCK) ON (CONFTOMA.PESSOALOGISTICA = DOC.TOMADORSERVICOPESSOA)                                    
	WHERE (DOC.TIPODOCUMENTO = 1 OR (DOC.TIPODOCUMENTO = 2 AND DOC.TIPODOCUMENTOFRETE = 153 AND DOC.STATUSCTE = 7) OR (DOC.TIPODOCUMENTO = 6 AND DOC.TIPORPS <> 324))
	AND (CONFTOMA.CLIENTEEPP = 'N'  OR CONFTOMA.CLIENTEEPP Is Null)                                                                                                         
	AND DOC.DATAENTREGA IS NOT NULL                                                                                                              
	AND DOC.STATUS NOT IN (236,237,417)                                                                                                              

	--If ValorFiltro("ESTADO") <> "" Then
	--   qSql.Add(" AND DESTINO.ESTADO IN (" + ValorFiltro("ESTADO") + ") ")
	--End If

	--AND DESTINO.ESTADO = :ESTADO  
	    AND DOC.FILIALENTREGA = 2                                                                                                              
		AND YEAR(DOC.DATAENTREGA) in (2018, 2019, 2020)                                                                                                           
		GROUP BY MONTH(DOC.DATAENTREGA)  ,YEAR(DOC.DATAENTREGA)                                                                                                        
	)   
	
	SELECT * FROM ENTREGAS_EPP A  
	order by MES, ANO
	
	                                                                                                                                        
	--SELECT                                                                                                                                      
	--	   TIPO			TIPO,                                                                                                                   
	--	   ISNULL(SUM([01]),0)	JANEIRO,                                                                                                        
	--	   ISNULL(SUM([02]),0)	FEVEREIRO,                                                                                                      
	--	   ISNULL(SUM([03]),0)	MARCO,                                                                                                          
	--	   ISNULL(SUM([04]),0)	ABRIL,                                                                                                          
	--	   ISNULL(SUM([05]),0)	MAIO,                                                                                                           
	--	   ISNULL(SUM([06]),0)	JUNHO,                                                                                                          
	--	   ISNULL(SUM([07]),0)	JULHO,                                                                                                          
	--	   ISNULL(SUM([08]),0)	AGOSTO,                                                                                                         
	--	   ISNULL(SUM([09]),0)	SETEMBRO,                                                                                                       
	--	   ISNULL(SUM([10]),0)	OUTUBRO,                                                                                                        
	--	   ISNULL(SUM([11]),0)	NOVEMBRO,                                                                                                       
	--	   ISNULL(SUM([12]),0)	DEZEMBRO,                                                                                                       
	--	   ISNULL(SUM([01]),0) + ISNULL(SUM([02]),0) + ISNULL(SUM([03]),0) + ISNULL(SUM([04]),0) + ISNULL(SUM([05]),0) + ISNULL(SUM([06]),0) +	
	--	   ISNULL(SUM([07]),0) + ISNULL(SUM([08]),0) + ISNULL(SUM([09]),0) + ISNULL(SUM([10]),0) + ISNULL(SUM([11]),0) + ISNULL(SUM([12]),0) TOTAL
	--FROM ENTREGAS_EPP A                                                                                                                         
	--PIVOT (SUM(TOTAL) FOR MES IN ([01],[02],[03],[04],[05],[06],[07],[08],[09],[10],[11],[12]))  AS PIVOT_ENTREGAS                              
	--GROUP BY TIPO 