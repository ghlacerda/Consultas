--glid_imppessoas -- tem municipio

SELECT TOP(10)

	A.EDINUMERO
	,A.HANDLE 
	,A.STATUS
	,E.NOME
	,CASE
		WHEN A.EDIVALORTOTAL IS NULL OR A.EDIVALORTOTAL = 0 THEN A.VALORTOTAL
	 ELSE A.EDIVALORTOTAL
	 END AS VALORTOTAL
	,CASE
		WHEN A.EDIVOLUME IS NULL OR A.EDIVOLUME = 0 THEN A.VOLUME
	 ELSE A.EDIVOLUME
	 END AS VOLUME
	,CASE
		WHEN A.EDIPESOTOTAL IS NULL OR A.EDIPESOTOTAL = 0 THEN A.PESOTOTAL
	 ELSE A.EDIPESOTOTAL
	 END AS PESOTOTAL 
	,A.EDICHAVENFE
	,B.EDIMUNICIPIO
	,C.NOME
	,D.EDIRAZAOSOCIAL AS TOMADORSERVICO
	,A.EDIDATAEMISSAO
	,D.CGCCPF
	,A.EDIREMETENTE

FROM GLID_IMPDOCCLIS A-- tem os valores mas nao tem filial de entrega ainda, pois n�o foi gerado o documento.
INNER JOIN GLID_IMPPESSOAS B ON ISNULL(A.EDIDESTINATARIO, A.EDIRECEBEDOR) = B.HANDLE
INNER JOIN MUNICIPIOS C ON B.MUNICIPIO = C.HANDLE 
INNER JOIN GLID_IMPPESSOAS D ON A.EDITOMADORSERVICOPESSOA = D.HANDLE
INNER JOIN GLGL_ENUMERACAOITEMS E ON A.STATUS = E.HANDLE
INNER JOIN GLID_IMPPESSOAS F ON A.EDIREMETENTE = F.HANDLE

WHERE 1=1
AND A.STATUS = 535
AND A.EDIDATAEMISSAO >= DATEADD(DD,-100, GETDATE())
AND A.EDIDATAEMISSAO < DATEADD(DD, 1, GETDATE())
AND F.EDICGCCPF IN ('61064838011682','58604190000306','61.064.838/0116-82','58.604.190/0003-06')