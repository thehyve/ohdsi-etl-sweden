/*
Add the datasource to the webapi. https://github.com/OHDSI/WebAPI/wiki/Source-Configuration
Assumes the webapi schema exists in the same database.
Needs to be a function to easy pass parameters from the main bash script.
Input: Database name, Database schema
Daimon_type: 0=CDM, 1=Vocabulary, 2=Results, 3=LAERTES.
Possible Issue: point two databases to same results schema (webapi in this case). See also:
http://forums.ohdsi.org/t/issues-with-webapi-daimons-and-results-schema-using-different-schemas/1499
*/
CREATE OR REPLACE FUNCTION setSourceDaimon( cdm_schema_name VARCHAR,
                                            source_name VARCHAR,
                                            source_key VARCHAR,
                                            prio_daimon INTEGER DEFAULT 1)
    RETURNS INTEGER AS
$$
DECLARE
    max_source_id integer;
    new_source_id integer;
    max_source_daimon_id integer;
    new_source_daimon_id integer;
    source_key_unique varchar;
BEGIN
    EXECUTE 'SELECT MAX(source_id) FROM webapi.source' INTO max_source_id;
    IF max_source_id IS NULL THEN
        new_source_id := 1;
    ELSE
        new_source_id := max_source_id + 1;
    END IF;

    -- Concatenate source_id to make source_key unique
    source_key_unique := concat(source_key,new_source_id::varchar);

    INSERT INTO webapi.source (source_id, source_name, source_key, source_connection, source_dialect)
    VALUES
    (new_source_id, source_name, source_key_unique, 'jdbc:postgresql://localhost:5432/ohdsi?user=webapi&password=webapi', 'postgresql')
    ;

    EXECUTE 'SELECT MAX(source_daimon_id) FROM webapi.source_daimon' INTO max_source_daimon_id;
    IF max_source_daimon_id IS NULL THEN
        new_source_daimon_id := 1;
    ELSE
        new_source_daimon_id := max_source_daimon_id +1;
    END IF;

    INSERT INTO webapi.source_daimon (source_daimon_id, source_id, daimon_type, table_qualifier, priority)
    VALUES
    (new_source_daimon_id,   new_source_id, 0, cdm_schema_name, prio_daimon), -- CDM
    (new_source_daimon_id+1, new_source_id, 1, 'cdm5',          prio_daimon), -- Vocabulary
    (new_source_daimon_id+2, new_source_id, 2, 'webapi',        prio_daimon) -- Results (Achilles, Cohort, ...)
    ;

    RETURN new_source_id;
END
$$ LANGUAGE plpgsql;
