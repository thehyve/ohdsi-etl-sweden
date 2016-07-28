CREATE OR REPLACE FUNCTION getObservationEndDate( study_end_date date, death_date date, immigration_date date, emigration_date date)
    RETURNS date AS
$$
DECLARE
    -- Observation end date can never be later than the study_end_date
    -- Immigration and emigration date are the most recent immigration and emigration respectively
BEGIN

    IF emigration_date IS NULL THEN
        -- If no emigration date,
        -- return the most past date from study_end_date and death_date
        -- independent whether there is an immigration date.
        -- Note, no knowledge about study_start_date
        RETURN LEAST(study_end_date, death_date);
    ELSE
        RETURN LEAST(study_end_date, death_date, emigration_date);
    END IF;

    -- Should not happen, but study_end_date is a safe option
    RETURN study_end_date;
END;
$$ LANGUAGE plpgsql;
