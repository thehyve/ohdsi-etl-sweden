\ir 'getObservationStartDate.sql'
\ir 'getObservationEndDate.sql'

/* Tests Start Date*/
-- data_start, yob, immi, emi
select CASE WHEN getObservationStartDate(   to_date('19970101','yyyymmdd'),
                                            to_date('19980205','yyyymmdd'),
                                            to_date(NULL,'yyyymmdd'),
                                            to_date(NULL,'yyyymmdd')
                                        ) = to_date('19980205','yyyymmdd') THEN 'passed 1' ELSE '#!#FAILED#!#' END;
select CASE WHEN getObservationStartDate(   to_date('19970101','yyyymmdd'),
                                            to_date('19600101','yyyymmdd'),
                                            to_date('19980205','yyyymmdd'),
                                            to_date(NULL,'yyyymmdd')
                                        ) = to_date('19980205','yyyymmdd') THEN 'passed 2' ELSE '#!#FAILED#!#' END;
select CASE WHEN getObservationStartDate(   to_date('19970101','yyyymmdd'),
                                            to_date('19600101','yyyymmdd'),
                                            to_date(NULL,'yyyymmdd'),
                                            to_date('19980205','yyyymmdd')
                                        ) = to_date('19970101','yyyymmdd') THEN 'passed 3' ELSE '#!#FAILED#!#' END;
select CASE WHEN getObservationStartDate(   to_date('19970101','yyyymmdd'),
                                            to_date('19600101','yyyymmdd'),
                                            to_date('19990101','yyyymmdd'),
                                            to_date('20020202','yyyymmdd')
                                        ) = to_date('19990101','yyyymmdd') THEN 'passed 4' ELSE '#!#FAILED#!#' END;
select CASE WHEN getObservationStartDate(   to_date('19970101','yyyymmdd'),
                                            to_date('19600101','yyyymmdd'),
                                            to_date('20020213','yyyymmdd'),
                                            to_date('19990101','yyyymmdd')
                                        ) = to_date('19970101','yyyymmdd') THEN 'passed 5' ELSE '#!#FAILED#!#' END;
select CASE WHEN getObservationStartDate(   to_date('19970101','yyyymmdd'),
                                            to_date('19961231','yyyymmdd'),
                                            to_date(NULL,'yyyymmdd'),
                                            to_date(NULL,'yyyymmdd')
                                        ) = to_date('19970101','yyyymmdd') THEN 'passed 6' ELSE '#!#FAILED#!#' END;
-- One odd example. Emigrated before study start date, then obs_start is study start.
-- This should never happen, as a person should be in the country during the study
select CASE WHEN getObservationStartDate(   to_date('19970101','yyyymmdd'),
                                            to_date('19661231','yyyymmdd'),
                                            to_date(NULL,'yyyymmdd'),
                                            to_date('19950101','yyyymmdd')
                                        ) = to_date('19970101','yyyymmdd') THEN 'passed 7' ELSE '#!#FAILED#!#' END;
-- Immi -> Emi
select CASE WHEN getObservationStartDate(   to_date('19970101','yyyymmdd'),
                                            to_date('19661231','yyyymmdd'),
                                            to_date('19991022','yyyymmdd'),
                                            to_date('20110911','yyyymmdd')
                                        ) = to_date('19991022','yyyymmdd') THEN 'passed 8' ELSE '#!#FAILED#!#' END;
-- Start -> Emi
select CASE WHEN getObservationStartDate(   to_date('19970101','yyyymmdd'),
                                            to_date('19661231','yyyymmdd'),
                                            to_date('19910320','yyyymmdd'),
                                            to_date('20110911','yyyymmdd')
                                        ) = to_date('19970101','yyyymmdd') THEN 'passed 9' ELSE '#!#FAILED#!#' END;

/* Tests End Date */
-- data_end, death, immi, emi
select CASE WHEN getObservationEndDate( to_date('20150801','yyyymmdd'),
                                        to_date(NULL,'yyyymmdd'),
                                        to_date(NULL,'yyyymmdd'),
                                        to_date(NULL,'yyyymmdd')
                                    ) = to_date('20150801','yyyymmdd') THEN 'passed 0' ELSE '#!#FAILED#!#' END;
select CASE WHEN getObservationEndDate( to_date('20150801','yyyymmdd'),
                                        to_date('19980205','yyyymmdd'),
                                        to_date(NULL,'yyyymmdd'),
                                        to_date(NULL,'yyyymmdd')
                                        ) = to_date('19980205','yyyymmdd') THEN 'passed 1' ELSE '#!#FAILED#!#' END;
select CASE WHEN getObservationEndDate( to_date('20150801','yyyymmdd'),
                                        to_date(NULL,'yyyymmdd'),
                                        to_date('19980205','yyyymmdd'),
                                        to_date(NULL,'yyyymmdd')
                                        ) = to_date('20150801','yyyymmdd') THEN 'passed 2' ELSE '#!#FAILED#!#' END;
select CASE WHEN getObservationEndDate( to_date('20150801','yyyymmdd'),
                                        to_date(NULL,'yyyymmdd'),
                                        to_date(NULL,'yyyymmdd'),
                                        to_date('19980205','yyyymmdd')
                                        ) = to_date('19980205','yyyymmdd') THEN 'passed 3' ELSE '#!#FAILED#!#' END;
select CASE WHEN getObservationEndDate( to_date('20150801','yyyymmdd'),
                                        to_date('20010101','yyyymmdd'),
                                        to_date('19990101','yyyymmdd'),
                                        to_date('20020202','yyyymmdd')
                                        ) = to_date('20010101','yyyymmdd') THEN 'passed 4' ELSE '#!#FAILED#!#' END;
select CASE WHEN getObservationEndDate( to_date('20150801','yyyymmdd'),
                                        to_date(null,'yyyymmdd'),
                                        to_date('20020213','yyyymmdd'),
                                        to_date('19990101','yyyymmdd')
                                        ) = to_date('19990101','yyyymmdd') THEN 'passed 5' ELSE '#!#FAILED#!#' END;
select CASE WHEN getObservationEndDate( to_date('20150801','yyyymmdd'),
                                        to_date('19961231','yyyymmdd'),
                                        to_date(NULL,'yyyymmdd'),
                                        to_date('19961230','yyyymmdd')
                                        ) = to_date('19961230','yyyymmdd') THEN 'passed 6' ELSE '#!#FAILED#!#' END;
-- One odd example. Emigrated before study start date, then data_end is study end date.
-- This should never happen, as a person should be in the country during the study
select CASE WHEN getObservationEndDate( to_date('20150801','yyyymmdd'),
                                        to_date(NULL,'yyyymmdd'),
                                        to_date(NULL,'yyyymmdd'),
                                        to_date('19950101','yyyymmdd')
                                        ) = to_date('19950101','yyyymmdd') THEN 'passed 7' ELSE '#!#FAILED#!#' END;
-- Another odd example. Death before study start date, then death is study end date.
-- This should never happen, as a person should be alive during the study
select CASE WHEN getObservationEndDate( to_date('20150801','yyyymmdd'),
                                        to_date('19600101','yyyymmdd'),
                                        to_date(NULL,'yyyymmdd'),
                                        to_date(NULL,'yyyymmdd')
                                    ) = to_date('19600101','yyyymmdd') THEN 'passed 7.5' ELSE '#!#FAILED#!#' END;
-- Immi -> Emi
select CASE WHEN getObservationEndDate( to_date('20150801','yyyymmdd'),
                                        to_date(NULL,'yyyymmdd'),
                                        to_date('19991022','yyyymmdd'),
                                        to_date('20110911','yyyymmdd')
                                        ) = to_date('20110911','yyyymmdd') THEN 'passed 8' ELSE '#!#FAILED#!#' END;
-- Start -> Emi
select CASE WHEN getObservationEndDate( to_date('20150801','yyyymmdd'),
                                        to_date(NULL,'yyyymmdd'),
                                        to_date('19910320','yyyymmdd'),
                                        to_date('20110911','yyyymmdd')
                                        ) = to_date('20110911','yyyymmdd') THEN 'passed 9' ELSE '#!#FAILED#!#' END;
