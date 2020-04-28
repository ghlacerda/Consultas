DECLARE @cols AS NVARCHAR(MAX),
    @colsName AS NVARCHAR(MAX),
    @query  AS NVARCHAR(MAX)

select @cols = STUFF((SELECT distinct ',' + QUOTENAME(country +'_'+c.col) 
                      from mytransactions
                      cross apply 
                      (
                        select 'TotalCount' col
                        union all
                        select 'TotalAmount'
                      ) c
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,'')

select @colsName 
    = STUFF((SELECT distinct ', ' + QUOTENAME(country +'_'+c.col) 
               +' as ['
               + country + case when c.col = 'TotalCount' then ' # of Transactions]' else 'Total $ Amount]' end
             from mytransactions
             cross apply 
             (
                select 'TotalCount' col
                union all
                select 'TotalAmount'
             ) c
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,'')

set @query 
  = 'SELECT chardate, ' + @colsName + ' 
     from 
     (
      select 
        numericmonth, 
        chardate,
        country +''_''+col col, 
        value
      from
      (
        select numericmonth, 
          country, 
          chardate,
          cast(totalcount as numeric(10, 2)) totalcount,
          cast(totalamount as numeric(10, 2)) totalamount
        from mytransactions
      ) src
      unpivot
      (
        value
        for col in (totalcount, totalamount)
      ) unpiv
     ) s
     pivot 
     (
       sum(value)
       for col in (' + @cols + ')
     ) p 
     order by numericmonth'

execute(@query)