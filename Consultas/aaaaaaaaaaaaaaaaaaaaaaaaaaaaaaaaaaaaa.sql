--DECLARE @BeginDate Date = '2020-03-20 00:00:00.000'
--DECLARE @EndDate Date = '2020-03-21 00:00:00.000'



--use VETORRH

SELECT


R011LAN.NUMCAD R011LANNUMCAD,
R011LAN.DATLAN R011LANDATLAN,
R011LAN.ORILAN R011LANORILAN,
R011LAN.CODBHR R011LANCODBHR,
R011LAN.SINLAN R011LANSINLAN,
R011LAN.QTDHOR R011LANQTDHOR,
R011LAN.QTDPAG R011LANQTDPAG,
R011LAN.CODSIT R011LANCODSIT,
R016HIE.TABORG R016HIETABORG,
R038HFI.DATALT R038HFIDATALT,
R038HFI.CODFIL R038HFICODFIL,
R038HCA.CODCAR R038HCACODCAR,
R038HCA.ESTCAR R038HCAESTCAR,
R006ESC.CODESC R006ESCCODESC,
R006ESC.TURESC R006ESCTURESC,
R038HLO.NUMLOC R038HLONUMLOC,
R011LAN.DATCMP R011LANDATCMP,
R030EMP.NUMEMP R030EMPNUMEMP,
R030EMP.NOMEMP R030EMPNOMEMP,
R034FUN.NUMEMP R034FUNNUMEMP,
R034FUN.TIPCOL R034FUNTIPCOL,
R034FUN.NUMCAD R034FUNNUMCAD,
R034FUN.NOMFUN R034FUNNOMFUN,
R011BHR.CODBHR R011BHRCODBHR,
R011BHR.DESBHR R011BHRDESBHR

FROM R011LAN,
R016HIE,
R038HLO,
R038HES,
R038HFI,
R038HCA,
R006ESC,
R030EMP,
R034FUN,
R011BHR,
R016ORN
WHERE
( (R011LAN.NUMEMP = 1) ) AND
( (R011LAN.TIPCOL = 1) ) AND
( (R038HFI.CODFIL = 28) ) AND
((R011LAN.CODBHR = R011BHR.CODBHR) AND 
((R034FUN.NUMEMP = R011LAN.NUMEMP) AND 
(R034FUN.TIPCOL = R011LAN.TIPCOL) AND 
(R034FUN.NUMCAD = R011LAN.NUMCAD)) AND 
(R030EMP.NUMEMP = R011LAN.NUMEMP) AND 
(((R016HIE.TABORG = R038HLO.TABORG) AND 
(R016HIE.NUMLOC = R038HLO.NUMLOC) AND 
(R016HIE.DATINI <= @BeginDate) AND 
(R016HIE.DATFIM >= @EndDate)) AND 
((R038HLO.TABORG = R016ORN.TABORG) AND 
(R038HLO.NUMLOC = R016ORN.NUMLOC))) AND 
(R006ESC.CODESC = R034FUN.CODESC) AND 
((R038HCA.NUMEMP = R034FUN.NUMEMP) AND 
(R038HCA.TIPCOL = R034FUN.TIPCOL) AND 
(R038HCA.NUMCAD = R034FUN.NUMCAD)) AND 
((R038HES.NUMEMP = R034FUN.NUMEMP) AND 
(R038HES.TIPCOL = R034FUN.TIPCOL) AND 
(R038HES.NUMCAD = R034FUN.NUMCAD)) AND 
((R038HFI.NUMEMP = R034FUN.NUMEMP) AND 
(R038HFI.TIPCOL = R034FUN.TIPCOL) AND 
(R038HFI.NUMCAD = R034FUN.NUMCAD)) AND 
((R038HLO.NUMEMP = R034FUN.NUMEMP) AND 
(R038HLO.TIPCOL = R034FUN.TIPCOL) AND 
(R038HLO.NUMCAD = R034FUN.NUMCAD))) AND
(
 DATCMP >= DATEADD(MM, -1, @EndDate) AND DATLAN <= @BeginDate
 AND R038HFI.DATALT = (SELECT MAX (DATALT) FROM R038HFI TAB2 WHERE            (TAB2.NUMEMP = R038HFI.NUMEMP) AND            (TAB2.TIPCOL = R038HFI.TIPCOL) AND            (TAB2.NUMCAD = R038HFI.NUMCAD) AND            (TAB2.NUMEMP = TAB2.EMPATU) AND            (TAB2.NUMCAD = TAB2.CADATU) AND            (TAB2.DATALT <= @BeginDate)) 
 AND 
(R038HLO.DATALT = (SELECT MAX (DATALT) FROM R038HLO TABELA001 WHERE
(TABELA001.NUMEMP = R038HLO.NUMEMP) AND
(TABELA001.TIPCOL = R038HLO.TIPCOL) AND
(TABELA001.NUMCAD = R038HLO.NUMCAD) AND
(TABELA001.DATALT <= @BeginDate)))
 AND 
(R038HCA.DATALT = (SELECT MAX (DATALT) FROM R038HCA TABELA002 WHERE
(TABELA002.NUMEMP = R038HCA.NUMEMP) AND
(TABELA002.TIPCOL = R038HCA.TIPCOL) AND
(TABELA002.NUMCAD = R038HCA.NUMCAD) AND
(TABELA002.DATALT <= @BeginDate)))
 AND 
(R038HES.DATALT = (SELECT MAX (DATALT) FROM R038HES TABELA003 WHERE
(TABELA003.NUMEMP = R038HES.NUMEMP) AND
(TABELA003.TIPCOL = R038HES.TIPCOL) AND
(TABELA003.NUMCAD = R038HES.NUMCAD) AND
(TABELA003.DATALT <= @BeginDate)))
 AND NOT EXISTS (SELECT 1 FROM R038AFA WHERE R038AFA.NUMEMP = R034FUN.NUMEMP AND R038AFA.TIPCOL = R034FUN.TIPCOL AND R038AFA.NUMCAD = R034FUN.NUMCAD AND R038AFA.DATAFA = (SELECT MAX(R038AFA.DATAFA) FROM R038AFA, R010SIT WHERE R038AFA.NUMEMP = R034FUN.NUMEMP AND R038AFA.TIPCOL = R034FUN.TIPCOL AND R038AFA.NUMCAD = R034FUN.NUMCAD AND R038AFA.DATAFA <= @BeginDate AND R038AFA.SITAFA = R010SIT.CODSIT AND R010SIT.TIPSIT = 7))
)
ORDER BY
R011LAN.NUMEMP,
R011LAN.TIPCOL,
R011LAN.NUMCAD,
R011LAN.CODBHR,
R011LAN.DATLAN,
R011LAN.ORILAN