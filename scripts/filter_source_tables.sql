/* Filter from the source tables */

-- Delete rows with dates that are not in the format yyyymmdd or empty
-- e.g. '.', 20030, '   1', '2011-02-' and '2012' are deleted
DELETE FROM bayer.patient_sluten
WHERE indatuma  !~ '\d{8}' OR utdatuma !~ '\d{8}'OR indatuma IS NULL OR utdatuma IS NULL
;

DELETE FROM bayer.patient_oppen
WHERE indatuma  !~ '\d{8}' OR indatuma IS NULL
;

DELETE FROM bayer.patient_dag_kiru
WHERE indatuma  !~ '\d{8}' OR indatuma IS NULL
;

DELETE FROM bayer.patient_sluten_long
WHERE indatuma  !~ '\d{8}' OR utdatuma !~ '\d{8}' OR indatuma IS NULL OR utdatuma IS NULL
;

DELETE FROM bayer.patient_oppen_long
WHERE indatuma  !~ '\d{8}' OR indatuma IS NULL
;

DELETE FROM bayer.patient_dag_kiru_long
WHERE indatuma  !~ '\d{8}' OR indatuma IS NULL
;

-- With drugs this problem not yet arises.
-- DELETE FROM bayer.drug
-- WHERE edatum  !~ '\d{1,2}/\d{1,2}/\d{4}'
-- ;
