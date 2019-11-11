--1º	Nº CT-E
--2º	Data Emissão CT-E
--3º	Cliente Remetente
--4º	Cidade destinatário
--5º	Região
--6º	CEP
--7º	UF
--8º	NF
--9º	Valor NF
--10º	Peso real
--11º	Peso cubado
--12º	Peso Considerado 
--13º	Frete peso
--14º	GRIS
--15º	Pedágio
--16º	ADV. (Frete Valor)
--17º	Aliquita de ICMS
--18º	ICMS
--19º	Frete Total
--20º	Vol.
--21º	Pedido
--22º	Chave CTe
--23º	Tipo Entrega

SELECT TOP(10) 
	D.NUMERO AS [Nº CT-E]
	,D.DATAEMISSAO AS [Data Emissão CT-E]
	,REM.NOME AS [Cliente Remetente]
	,MUN.NOME AS [Cidade destinatário]





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