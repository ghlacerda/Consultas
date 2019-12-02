--CNPJ
--razão social do cliente 
--nome 
--e-mail do agente de vendas


Select GN_PESSOAS.NOME Cliente,
          GN_PESSOAS.CGCCPF 'CNPJCPF',
          GN_PESSOASV.NOME  'AgenteVendas',
		  ISNULL(GN_PESSOASV.EMAIL, 'EMAIL NÃO CADASTRADO') AS 'Email',
          MUNICIPIOS.NOME MunicipioCliente,
          ESTADOS.NOME EstadoCliente,
          FILIALAG.NOME 'FilialResponsavel'
  From GN_PESSOAS
  Left Join GN_PESSOAS GN_PESSOASV
       On GN_PESSOASV.HANDLE                                              = GN_PESSOAS.AGENTEVENDAS
  Left Join MUNICIPIOS
       On MUNICIPIOS.HANDLE                                        = GN_PESSOAS.MUNICIPIO
  Left Join ESTADOS
       On ESTADOS.HANDLE                                                  = MUNICIPIOS.ESTADO
Inner Join GLGL_LOCALIDADES
       On GLGL_LOCALIDADES.MUNICIPIO                               = MUNICIPIOS.HANDLE
Inner Join GLGL_LOCALIDADEITEMS
       On GLGL_LOCALIDADEITEMS.LOCALIDADE                          = GLGL_LOCALIDADES.HANDLE
Inner Join GLGL_LOCALIDADES GLGL_LOCALIDADESAG
       On GLGL_LOCALIDADESAG.HANDLE                                = GLGL_LOCALIDADEITEMS.AGLUTINADOR
Inner Join GLOP_REGIAOATENDIMENTOS
       On GLOP_REGIAOATENDIMENTOS.LOCALIDADE                 = GLGL_LOCALIDADESAG.HANDLE
Inner Join FILIAIS FILIALAG
       On FILIALAG.HANDLE                                                 = GLOP_REGIAOATENDIMENTOS.FILIAL

Where GLOP_REGIAOATENDIMENTOS.STATUS                       = 566
and  GN_PESSOASV.INATIVO = 'N'
and  GN_PESSOASV.EHCLIENTE = 'N'
AND GN_PESSOAS.EHCLIENTE = 'S'
and GN_PESSOAS.INATIVO = 'N'
Group By GN_PESSOAS.NOME,
             GN_PESSOAS.CGCCPF,
             GN_PESSOASV.NOME,
             MUNICIPIOS.NOME,
             ESTADOS.NOME,
             FILIALAG.NOME,
			  GN_PESSOASV.EMAIL

ORDER BY Cliente