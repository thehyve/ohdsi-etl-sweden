SELECT concept_class_id,
    COUNT(DISTINCT source_concept_id) as "Unique drugs",
    SUM(frequency) as "Prescribed drugs"
    -- Frequency is met dubbele tellingen voor drug component en drug form.
FROM mappings.vnr_mapping
GROUP BY concept_class_id
-- ORDER BY concept_class_id
;
