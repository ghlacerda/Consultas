SELECT OCO.NOME, DOC.DOCUMENTODIGITADO, MOV.DATAINCLUSAO, USU.NOME, MOV.ABATIMENTO, MOV.HISTORICO, PES.NOME, PES.CGCCPF, CAT.nome PoloAtendimento,P.nome GerenteContas,
 CASE MOV.K_MOTIVODESCONTO
 WHEN 1 THEN 'N�o agrupamento de NF via EDI'
 WHEN 2 THEN 'Cad. n�o clientes incompleto'
 WHEN 3 THEN 'Informa��o divergente da NF'
 WHEN 4 THEN 'Cota��o de Frete n�o acatada'
 WHEN 5 THEN 'Frete comb. antec. n�o inform.'
 WHEN 6 THEN 'Cubagem divergente'
 WHEN 7 THEN 'Falta inf.med. carga vol.'
 WHEN 8 THEN '� agrup. de NF�s Terminal'
 WHEN 9 THEN 'Atraso na entrega'
 WHEN 10 THEN 'Manut. tabelas'
 WHEN 11 THEN 'Diverg. Entend. "General.'
 WHEN 12 THEN 'Cadastro incompleto'
 WHEN 13 THEN 'Div. cadastrais Sintegra.'
 WHEN 14 THEN 'Diretoria'
 WHEN 15 THEN 'Indeniza��es e avarias'
 WHEN 16 THEN 'Renegocia��o de Frete'
 WHEN 17 THEN 'Revers�o de Frete'
 WHEN 18 THEN 'Descontos Aurora'
 WHEN 19 THEN 'Acerto Pr�-Fatura'
 WHEN 20 THEN 'Acordo Comercial'
 WHEN 21 THEN 'Acordo Diretoria'
 WHEN 22 THEN 'Agendamento Indevido'
 WHEN 23 THEN 'Agrupamento de NF Indevido'
 WHEN 24 THEN 'Aliquota de ICMS Indevida'
 WHEN 25 THEN 'Atraso na Entrega'
 WHEN 26 THEN 'Cadastro Incompleto'
 WHEN 27 THEN 'Cota��o Divergente'
 WHEN 28 THEN 'Cota��o n�o acatada'
 WHEN 29 THEN 'Cubagem Divergente'
 WHEN 30 THEN 'Cubagem Indevida'
 WHEN 31 THEN 'Dep�sito Antecipado'
 WHEN 32 THEN 'Fatura cancelada'
 WHEN 33 THEN 'Frete Combinado/Cortesia'
 WHEN 34 THEN 'Frete pago � vista'
 WHEN 35 THEN 'Generalidades Indevidas'
 WHEN 36 THEN 'Indeniza��o e avarias'
 WHEN 37 THEN 'Informa��o divergente da NF'
 WHEN 38 THEN 'log reversa n�o autorizada'
 WHEN 39 THEN 'N�o agrupamento de NF'
 WHEN 40 THEN 'Outro-Se��o Detalhamento'
 WHEN 41 THEN 'Renegocia��o do Frete'
 WHEN 42 THEN 'Revers�o de Frete CIF/FOB'
 WHEN 43 THEN 'Tabela Divergente'
 WHEN 44 THEN 'Taxa de boleto indevida'
 WHEN 45 THEN 'TDE Indevido'
 WHEN 46 THEN 'TDE n�o autorizado cliente'
 WHEN 47 THEN 'Problemas com Notfis / EDI'
 WHEN 48 THEN 'Erros Operacionais'
 WHEN 49 THEN 'Acordo Comercial Autorizado Sup. / Diretoria'
 WHEN 50 THEN 'Tabela Divergente Sistema x Cliente'
 WHEN 51 THEN 'Cadastro Errado DAC'
 WHEN 52 THEN 'Tratativas TPC / TFD'
 WHEN 53 THEN 'Problemas relacionados ao servi�o de reentrega'
 ELSE ''
 END MOTIVO
FROM FN_MOVIMENTACOES MOV INNER JOIN
     Z_GRUPOUSUARIOS USU ON USU.HANDLE = MOV.USUARIOINCLUIU INNER JOIN
     GN_PESSOAS PES ON PES.HANDLE = MOV.PESSOA INNER JOIN
	 gn_pessoas P on (P.handle = PES.AGENTEVENDAS) INNER JOIN
	 GN_CATEGORIASCLIENTE CAT on cat.handle = PES.CATEGORIACLIENTE inner join
     FN_OCORRENCIAS OCO ON MOV.OCORRENCIA = OCO.HANDLE INNER JOIN
     FN_DOCUMENTOS DOC ON DOC.HANDLE = MOV.DOCUMENTO
WHERE MOV.TIPOMOVIMENTO = 7
AND DOC.ENTRADASAIDA = 'S'
AND MOV.ABATIMENTO > 0
AND CAST(MOV.DATAINCLUSAO AS DATE) BETWEEN :DATAINCLUSAOINICIO AND :DATAINCLUSAOFIM
ORDER BY MOV.HANDLE DESC

