/* Filter from the source tables */

-- Delete rows with dates that are not in the format yyyymmdd
-- e.g. '.', 20030, '   1', '2011-02-' and '2012' are deleted
DELETE FROM bayer.patient_sluten
WHERE indatuma  !~ '\d{8}' OR utdatuma !~ '\d{8}'
;

DELETE FROM bayer.patient_oppen
WHERE indatuma  !~ '\d{8}'
;

DELETE FROM bayer.patient_dag_kiru
WHERE indatuma  !~ '\d{8}'
;
