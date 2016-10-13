\ir 'getDrugQuantity.sql'
\ir 'getDrugEndDate.sql'

/* Tests drug end date*/
-- drug_start, packsize, number of packs, prescription
select CASE WHEN getDrugEndDate( '01/01/2000','100 styck', 1, 1 ) = to_date('20000410','yyyymmdd') THEN 'passed 1' ELSE '#!#FAILED 1#!#' END;
select CASE WHEN getDrugEndDate( '01/01/2000','100 styck', 1, 3 ) = to_date('20000203','yyyymmdd') THEN 'passed 2' ELSE '#!#FAILED 2#!#' END;
select CASE WHEN getDrugEndDate( '01/01/2000','1000 styck', 0.5599, 1 ) = to_date('20010714','yyyymmdd') THEN 'passed 3' ELSE '#!#FAILED 3#!#' END;
select CASE WHEN getDrugEndDate( '01/01/2000','5 x 3 mill', 0.02799, 1 ) IS NULL THEN 'passed 4' ELSE '#!#FAILED 4#!#' END;
select CASE WHEN getDrugEndDate( '01/01/2012','200 dos(er', 2, 1 ) = to_date('20130204','yyyymmdd') THEN 'passed 5' ELSE '#!#FAILED 5#!#' END;
