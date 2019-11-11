--1�	N� CT-E
--2�	Data Emiss�o CT-E
--3�	Cliente Remetente
--4�	Cidade destinat�rio
--5�	Regi�o
--6�	CEP
--7�	UF
--8�	NF
--9�	Valor NF
--10�	Peso real
--11�	Peso cubado
--12�	Peso Considerado 
--13�	Frete peso
--14�	GRIS
--15�	Ped�gio
--16�	ADV. (Frete Valor)
--17�	Aliquita de ICMS
--18�	ICMS
--19�	Frete Total
--20�	Vol.
--21�	Pedido
--22�	Chave CTe
--23�	Tipo Entrega

SELECT TOP(10) 
	D.NUMERO AS [N� CT-E]
	,D.DATAEMISSAO AS [Data Emiss�o CT-E]
	,REM.NOME AS [Cliente Remetente]
	,MUN.NOME AS [Cidade destinat�rio]





FROM GLGL_DOCUMENTOS D
INNER JOIN GN_PESSOAS REM 
	ON D.REMETENTE = REM.HANDLE
INNER JOIN GN_PESSOAS DEST
	ON D.DESTINATARIO = DEST.HANDLE
INNER JOIN MUNICIPIOS MUN
	ON DEST.MUNICIPIO = MUN.HANDLE

WHERE D.DATAEMISSAO >= '2019-11-10'
AND D.DATAEMISSAO < '2019-11-11'
AND D.TIPODOCUMENTO IN (2,6)