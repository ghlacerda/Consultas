SELECT OCO.NOME, DOC.DOCUMENTODIGITADO, MOV.DATAINCLUSAO, USU.NOME, MOV.ABATIMENTO, MOV.HISTORICO, PES.NOME, PES.CGCCPF, CAT.nome PoloAtendimento,P.nome GerenteContas,
 CASE MOV.K_MOTIVODESCONTO
 WHEN 1 THEN 'Não agrupamento de NF via EDI'
 WHEN 2 THEN 'Cad. não clientes incompleto'
 WHEN 3 THEN 'Informação divergente da NF'
 WHEN 4 THEN 'Cotação de Frete não acatada'
 WHEN 5 THEN 'Frete comb. antec. não inform.'
 WHEN 6 THEN 'Cubagem divergente'
 WHEN 7 THEN 'Falta inf.med. carga vol.'
 WHEN 8 THEN 'Ñ agrup. de NF´s Terminal'
 WHEN 9 THEN 'Atraso na entrega'
 WHEN 10 THEN 'Manut. tabelas'
 WHEN 11 THEN 'Diverg. Entend. "General.'
 WHEN 12 THEN 'Cadastro incompleto'
 WHEN 13 THEN 'Div. cadastrais Sintegra.'
 WHEN 14 THEN 'Diretoria'
 WHEN 15 THEN 'Indenizações e avarias'
 WHEN 16 THEN 'Renegociação de Frete'
 WHEN 17 THEN 'Reversão de Frete'
 WHEN 18 THEN 'Descontos Aurora'
 WHEN 19 THEN 'Acerto Pré-Fatura'
 WHEN 20 THEN 'Acordo Comercial'
 WHEN 21 THEN 'Acordo Diretoria'
 WHEN 22 THEN 'Agendamento Indevido'
 WHEN 23 THEN 'Agrupamento de NF Indevido'
 WHEN 24 THEN 'Aliquota de ICMS Indevida'
 WHEN 25 THEN 'Atraso na Entrega'
 WHEN 26 THEN 'Cadastro Incompleto'
 WHEN 27 THEN 'Cotação Divergente'
 WHEN 28 THEN 'Cotação não acatada'
 WHEN 29 THEN 'Cubagem Divergente'
 WHEN 30 THEN 'Cubagem Indevida'
 WHEN 31 THEN 'Depósito Antecipado'
 WHEN 32 THEN 'Fatura cancelada'
 WHEN 33 THEN 'Frete Combinado/Cortesia'
 WHEN 34 THEN 'Frete pago à vista'
 WHEN 35 THEN 'Generalidades Indevidas'
 WHEN 36 THEN 'Indenização e avarias'
 WHEN 37 THEN 'Informação divergente da NF'
 WHEN 38 THEN 'log reversa não autorizada'
 WHEN 39 THEN 'Não agrupamento de NF'
 WHEN 40 THEN 'Outro-Seção Detalhamento'
 WHEN 41 THEN 'Renegociação do Frete'
 WHEN 42 THEN 'Reversão de Frete CIF/FOB'
 WHEN 43 THEN 'Tabela Divergente'
 WHEN 44 THEN 'Taxa de boleto indevida'
 WHEN 45 THEN 'TDE Indevido'
 WHEN 46 THEN 'TDE não autorizado cliente'
 WHEN 47 THEN 'Problemas com Notfis / EDI'
 WHEN 48 THEN 'Erros Operacionais'
 WHEN 49 THEN 'Acordo Comercial Autorizado Sup. / Diretoria'
 WHEN 50 THEN 'Tabela Divergente Sistema x Cliente'
 WHEN 51 THEN 'Cadastro Errado DAC'
 WHEN 52 THEN 'Tratativas TPC / TFD'
 WHEN 53 THEN 'Problemas relacionados ao serviço de reentrega'
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

