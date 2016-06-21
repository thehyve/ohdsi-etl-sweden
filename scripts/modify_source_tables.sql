-- 21-06-2016. Fix datum issue
DELETE FROM bayer.patient_oppen WHERE indatuma = '.';
DELETE FROM bayer.patient_oppen_long WHERE indatuma = '.';
