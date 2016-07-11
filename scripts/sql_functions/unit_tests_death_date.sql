\ir 'convertDeathDate.sql'

/* Tests Start Date*/
-- data_start, yob, immi, emi
select CASE WHEN convertDeathDate( '19970606' ) = to_date('19970606','yyyymmdd') THEN 'passed 1' ELSE '#!#FAILED 1#!#' END;
select CASE WHEN convertDeathDate( '19970600' ) = to_date('19970615','yyyymmdd') THEN 'passed 2' ELSE '#!#FAILED 2#!#' END;
select CASE WHEN convertDeathDate( '19970000' ) = to_date('19970601','yyyymmdd') THEN 'passed 3' ELSE '#!#FAILED 3#!#' END;
select CASE WHEN convertDeathDate( '1998' ) = to_date('19980601','yyyymmdd') THEN 'passed 4' ELSE '#!#FAILED 4#!#' END;
select CASE WHEN convertDeathDate( '20160230' ) = to_date('20160301','yyyymmdd') THEN 'passed 5' ELSE '#!#FAILED 5#!#' END;
select CASE WHEN convertDeathDate( '20080726' ) = to_date('20080726','yyyymmdd') THEN 'passed 6' ELSE '#!#FAILED 6#!#' END;
