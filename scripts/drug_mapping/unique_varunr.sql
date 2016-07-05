WITH unique_varunr as
(
    SELECT DISTINCT ON (varunr) varunr, lnamn, atc, styrknum, styrka_enh, styrka_tf
    FROM bayer.drug
    ORDER BY varunr
), varunr_counts as
(
    SELECT varunr, COUNT(*) as frequency
    FROM bayer.drug
    GROUP BY varunr
)
SELECT unique_varunr.*, varunr_counts.frequency
INTO drugmap.unique_varunr
FROM unique_varunr
JOIN varunr_counts
    ON unique_varunr.varunr = varunr_counts.varunr
ORDER BY frequency DESC
;
