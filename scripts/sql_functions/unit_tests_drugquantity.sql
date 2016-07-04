\ir 'getDrugQuantity.sql'

/* Tests Start Date*/
-- data_start, yob, immi, emi
select CASE WHEN getDrugQuantity( '100 styck', 1 ) = 100 THEN 'passed 1' ELSE '#!#FAILED 1#!#' END;
select CASE WHEN getDrugQuantity( '100 tablet', 0.1399 ) = 14 THEN 'passed 2' ELSE '#!#FAILED 2#!#' END;
select CASE WHEN getDrugQuantity( '1000 styck', 0.5599 ) = 560 THEN 'passed 3' ELSE '#!#FAILED 3#!#' END;
select CASE WHEN getDrugQuantity( '5 x 3 mill', 0.02799 ) IS NULL THEN 'passed 4' ELSE '#!#FAILED 4#!#' END;
select CASE WHEN getDrugQuantity( '2 x 52 kap', 2 ) = 208 THEN 'passed 5' ELSE '#!#FAILED 5#!#' END;
select CASE WHEN getDrugQuantity( '200 dos(er', 2 ) = 400 THEN 'passed 6' ELSE '#!#FAILED 6#!#' END;
select CASE WHEN getDrugQuantity( '15 gram', 2 ) IS NULL THEN 'passed 7' ELSE '#!#FAILED 7#!#' END;
select CASE WHEN getDrugQuantity( '6 x 5 x 0,', 2 ) IS NULL THEN 'passed 8' ELSE '#!#FAILED 8#!#' END;
select CASE WHEN getDrugQuantity( '2 x 0,2 mi', 0.25 ) IS NULL THEN 'passed 9' ELSE '#!#FAILED 9#!#' END;
select CASE WHEN getDrugQuantity( '3 x 30 tab', 0.25 ) = 23 THEN 'passed 10' ELSE '#!#FAILED 10#!#' END;
