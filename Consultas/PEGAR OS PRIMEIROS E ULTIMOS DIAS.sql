--DIAS DO ANO

SELECT DateAdd(yyyy, DateDiff(yyyy,0,GetDate()), 0) AS [PRIMEIRO DIA DO ANO]
SELECT DATEADD(yyyy, DATEDIFF(yyyy, 0, GETDATE()) + 1, -1) AS [ULTIMO DIA DO ANO]
Select DateAdd(mm, DateDiff(mm,0,GetDate()) - 1, 0) as [Primeiro dia do m�s Anterior]
Select DateAdd(mm, DateDiff(mm,0,GetDate()), -1) as [�ltimo dia no m�s Anterior]
SELECT DATEADD(dd,-(DAY(GETDATE())-1),GETDATE()) AS [Primeiro dia do m�s]
select DateAdd(Day,-1,Dateadd(Month,1, Convert(char(08),getdate(), 126)+'01')) AS [ULTIMO DIA DO MES]
Select DateAdd(yy, DateDiff(yy,0,GetDate()) - 1, 0) AS [Primeiro dia ano anterior]