--DECLARE @filial int = 2
--DECLARE @BeginDate date = '2020-02-01'
--DECLARE @EndDate date = '2020-02-20'

SELECT       
	DISTINCT       
		DOCCLI.NUMERO AS [Número da NF],                                                                                                      
		COALESCE(A.DOCUMENTO,A.COLETA,A.VIAGEM)                      AS HANDLEDOC,                                   
		FEMISSAO.NOME                                                AS FILIALEMISSAO,                               
		(CASE                                                                                                        
		           WHEN A.PENDENCIA = 'N' THEN 'CONCLUIDO'                                                       
		           ELSE 'PENDENTE'                                                                                 
		END)                                                         AS SITUACAO,                                    
		MOTIVO.DESCRICAO                                             AS PENDENCIA,                                   
		FCADASTRO.NOME                                               AS FILIALCADASTRO,                              
		A.INCLUIDOEM                                                 AS INCLUIDOEM,                                  
		USUARIOINCLUSAO.NOME                                         AS USUARIOINCLUSAO,                             
		USUARIOCONCLUIU.NOME                                         AS USUARIOCONCLUIU,                             
		CAST(A.HANDLE AS VARCHAR(200))                                                      AS HANDLEOCORRENCIA,     
		CAST(A.OBSERVACAO AS NVARCHAR(MAX))                                                                        AS OBSERVACAO,           
		A.PREVISAOCONCLUSAO                                                                 AS PREVISAOCONCLUSAO,    
		CASE WHEN A.PREVISAOCONCLUSAO < ISNULL(A.CONCLUIDOEM,GETDATE()) THEN                                         
		          DATEDIFF(DAY,A.INCLUIDOEM,ISNULL(A.CONCLUIDOEM,GETDATE())) ELSE 0 END     AS ATRASO,               
		CASE WHEN A.EDIDATAHORAENVIO IS NULL THEN 'N' ELSE 'S' END                      AS EDIENVIADO,           
		CAST(B.NUMERO AS VARCHAR(50))      AS  NUMERO,                                      
		CASE WHEN B.TIPODOCUMENTO IN(1,2) THEN 'CT' ELSE 'RPS' END  AS  TIPODOCUMENTO , 
		FDESTINO.NOME                      AS  FILIALDESTINO,                               
		ISNULL(PESR.NOME,PPESR.NOME)       AS  REMETENTE,                                   
		ISNULL(PESD.NOME,PPESD.NOME)       AS  DESTINATARIO,                                
		B.VALORCONTABIL                    AS  VALORFRETE,                                  
		BENDERECO.NOME                     AS DESTINOBAIRRO,                                
		B.DOCCLIVALORTOTAL                 AS  VALORMERCADORIA,                                                                       
		B.DOCCLIPESOCONSIDERADO            AS  PESOTOTAL,                                                                             
		CAST(B.DOCCLIVOLUME AS INT)        AS  VOLUMES,                                                                               
		B.NUMEROSDOCUMENTOS AS NUMERONF,                                                                                              
		CAST( STUFF((SELECT ' / ' + CAST(DC.PEDIDO AS VARCHAR(20)) FROM GLGL_DOCUMENTOCLIENTES DC                                   
		              INNER JOIN GLGL_DOCUMENTOASSOCIADOS DA ON (DA.DOCUMENTOCLIENTE=DC.HANDLE)                                       
		              WHERE DA.DOCUMENTOLOGISTICA=A.DOCUMENTO AND DC.PEDIDO IS NOT NULL FOR XML PATH('')),2,1,'') AS VARCHAR(200)) AS PEDIDONF,                                                                                                                  
        A.CONCLUIDOEM                                                AS SOLUCAO,                         
        MOTIVO.ABRIRPENDENCIA                                        AS GERAPENDENCIA,                   
        A.CONCLUIDOEM                                                AS DATACONCLUSAO,                   
        RESP.NOME                                                    AS RESPONSAVELDESCRICAO,            
        PES.NOME                                                     AS CLIENTE,                         
        PES.HANDLE                                                   AS HANDLECLIENTE,                   
        MENDERECO.NOME                                               AS DESTINOMUNICIPIO,                
        EENDERECO.SIGLA                                              AS DESTINOUF,                       
        A.K_SITUACAOPENDENCIA                                        AS SITUACAOPENDENCIA,               
        USUARIODEFINIUPENDENCIA.NOME                                 AS USUARIODEFINIUPENDENCIA,         
        A.K_DTDEFINICAOSITUACAOPENDENCIA                             AS DTDEFINICAOSITUACAOPENDENCIA,  
		COUNT(distinct E.CODIGOBARRAS)										 AS TOTALFALTANTE,
		DOCCLI.VOLUME												 AS QTDTOTAL,
		DOCCLI.VALORTOTAL											 AS [Valor total NF],
		B.NUMERO													 AS [Número do Conhecimento],
		B.DTPREVISAOENTREGAEMISSAO									 AS [DT PREVISAO ENTREGA],
		ROUND((DOCCLI.VALORTOTAL/NULLIF(DOCCLI.VOLUME,0)),2)		 AS [Valor médio por volume],
		ROUND(((DOCCLI.VALORTOTAL/NULLIF(DOCCLI.VOLUME,0))*COUNT(distinct E.CODIGOBARRAS)),2) AS [Valor faltante]   
FROM       GLOP_OCORRENCIAS A                                                                               
   LEFT JOIN  GLGL_DOCUMENTOCLIENTES DOCCLI							ON ( DOCCLI.HANDLE = A.NOTAFISCAL)                          
   LEFT JOIN  GLGL_DOCUMENTOASSOCIADOS DA							ON ( DA.DOCUMENTOCLIENTE = DOCCLI.HANDLE )                  
   LEFT JOIN  GLGL_DOCUMENTOS B										ON      ( B.HANDLE = DA.DOCUMENTOLOGISTICA )                     
   LEFT JOIN  FILIAIS FEMISSAO                                      ON      ( FEMISSAO.HANDLE = B.FILIAL )                           
   LEFT JOIN  ED_PESSOAS PESR                                       ON      ( PESR.HANDLE = B.REMETENTESPED)                         
   LEFT JOIN  ED_PESSOAS PESD                                       ON      ( PESD.HANDLE = B.DESTINATARIOSPED)                      
   LEFT JOIN  GN_PESSOAS PPESR                                      ON      ( PPESR.HANDLE = B.REMETENTE)                            
   LEFT JOIN  GN_PESSOAS PPESD                                      ON      ( PPESD.HANDLE = B.DESTINATARIO)                         
   LEFT JOIN  FILIAIS FDESTINO                                      ON    ( FDESTINO.HANDLE = B.FILIALENTREGA )                    
   LEFT JOIN  GLGL_PESSOAENDERECOS ENDERECO							ON ( ENDERECO.HANDLE = B.DESTINOCONSIDERADO )               
   LEFT JOIN  BAIRROS BENDERECO										ON ( BENDERECO.HANDLE = ENDERECO.BAIRRO )                   
   LEFT JOIN  MUNICIPIOS MENDERECO									ON ( MENDERECO.HANDLE = ENDERECO.MUNICIPIO )                
   LEFT JOIN  ESTADOS EENDERECO										ON ( EENDERECO.HANDLE = ENDERECO.ESTADO )                   
   LEFT JOIN  GN_PESSOAS PES                                        ON ( PES.HANDLE = A.CLIENTE )                                                       
   LEFT JOIN  GLOP_MOTIVOOCORRENCIAS MOTIVO							ON     ( MOTIVO.HANDLE = A.OCORRENCIA )                                                 
   LEFT JOIN  GLGL_ENUMERACAOITEMS RESP								ON      ( A.RESPONSABILIDADE=RESP.HANDLE)                                                
   LEFT JOIN  FILIAIS FCADASTRO										ON ( FCADASTRO.HANDLE = A.FILIAL)                                                   
   LEFT JOIN  Z_GRUPOUSUARIOS USUARIOINCLUSAO						ON     ( USUARIOINCLUSAO.HANDLE = A.INCLUIDOPOR)                                        
   LEFT JOIN  Z_GRUPOUSUARIOS USUARIOCONCLUIU						ON     ( USUARIOCONCLUIU.HANDLE = A.CONCLUIDOPOR )                                      
   LEFT JOIN  Z_GRUPOUSUARIOS USUARIODEFINIUPENDENCIA				ON     ( USUARIODEFINIUPENDENCIA.HANDLE = A.K_USUARIODEFSITUACAOPENDENCIA ) 
   LEFT JOIN  GLGV_ETIQUETAS F										ON F.DOCUMENTOCLIENTE = DOCCLI.HANDLE
   LEFT JOIN GLGV_ETIQUETAVOLUMES E									ON E.ETIQUETA = F.HANDLE
   LEFT JOIN GLGV_PROCESSOITENS C									ON C.VOLUME = E.HANDLE
   LEFT JOIN GLGV_PROCESSOS D										ON C.PROCESSO = D.HANDLE
   LEFT JOIN GLGV_OCORRENCIAITENS X									ON E.HANDLE = X.ITEM
   LEFT JOIN GLGV_OCORRENCIAS Y										ON X.OCORRENCIA = Y.HANDLE
   LEFT JOIN FILIAIS K												ON B.FILIALENTREGA = K.HANDLE
   LEFT JOIN GN_PESSOAS L											ON DOCCLI.REMETENTE = L.HANDLE 


WHERE 1=1
		AND A.ESTORNADO = 'N' 
		AND A.EMPRESA = 1                                   
		AND ((DA.HANDLE IS NULL) OR (NOT(B.TIPODOCUMENTO = 6 AND B.TIPORPS = 324 AND B.TIPORPSSERVICO = 2)))
		AND B.STATUS NOT IN(236,237,417)
		AND MOTIVO.ABRIRPENDENCIA = 'S'                                            
		AND B.FILIALENTREGA IN(@filial) 
		AND (MOTIVO.HANDLE IN(33)  OR MOTIVO.OCORRENCIAPADRAO IN (33)) 
		AND A.INCLUIDOEM >= @BeginDate
		AND A.INCLUIDOEM < DATEADD(DD,1, @EndDate)
		AND A.PENDENCIA = 'S' 
		AND A.TIPODOCUMENTOOCORRENCIA = 1 
		AND A.HANDLE = (                         
							SELECT MIN(AA.HANDLE)               
							FROM GLOP_OCORRENCIAS AA            
							WHERE AA.DOCUMENTO = A.DOCUMENTO    
							AND AA.AGRUPADOR = A.AGRUPADOR    
						)                                         


GROUP BY 
		DOCCLI.NUMERO,                                                                                                      
        COALESCE(A.DOCUMENTO,A.COLETA,A.VIAGEM),                                   
        FEMISSAO.NOME,                               
        (CASE                                                                                                        
                   WHEN A.PENDENCIA = 'N' THEN 'CONCLUIDO'                                                       
                   ELSE 'PENDENTE'                                                                                 
        END),
        MOTIVO.DESCRICAO,
        FCADASTRO.NOME,
        A.INCLUIDOEM,
        USUARIOINCLUSAO.NOME,
        USUARIOCONCLUIU.NOME,
        CAST(A.HANDLE AS VARCHAR(200)),     
        CAST(A.OBSERVACAO AS NVARCHAR(MAX)),           
        A.PREVISAOCONCLUSAO,    
        CASE WHEN A.PREVISAOCONCLUSAO < ISNULL(A.CONCLUIDOEM,GETDATE()) THEN                                         
                  DATEDIFF(DAY,A.INCLUIDOEM,ISNULL(A.CONCLUIDOEM,GETDATE())) ELSE 0 END,               
        CASE WHEN A.EDIDATAHORAENVIO IS NULL THEN 'N' ELSE 'S' END,           
        CAST(B.NUMERO AS VARCHAR(50)),                                      
        CASE WHEN B.TIPODOCUMENTO IN(1,2) THEN 'CT' ELSE 'RPS' END, 
        FDESTINO.NOME,                               
        ISNULL(PESR.NOME,PPESR.NOME),                                   
        ISNULL(PESD.NOME,PPESD.NOME),                                
        B.VALORCONTABIL,                                  
        BENDERECO.NOME,                                
		B.DOCCLIVALORTOTAL,                                                                       
		B.DOCCLIPESOCONSIDERADO,                                                                             
		CAST(B.DOCCLIVOLUME AS INT),                                                                               
		B.NUMEROSDOCUMENTOS,                                                                                              
		A.DOCUMENTO,                                                                                                                
        A.CONCLUIDOEM,
        MOTIVO.ABRIRPENDENCIA,
        A.CONCLUIDOEM,
        RESP.NOME,
        PES.NOME,
        PES.HANDLE,
        MENDERECO.NOME ,
        EENDERECO.SIGLA,
        A.K_SITUACAOPENDENCIA,
        USUARIODEFINIUPENDENCIA.NOME,
        A.K_DTDEFINICAOSITUACAOPENDENCIA,
		DOCCLI.VOLUME,
		DOCCLI.VALORTOTAL,
		B.NUMERO,
		B.DTPREVISAOENTREGAEMISSAO