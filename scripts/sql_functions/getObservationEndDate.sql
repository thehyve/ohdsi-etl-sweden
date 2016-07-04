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
        -- If only immigration date, return first date of the following.
        IF immigration_date IS NULL THEN
            RETURN LEAST(study_end_date, death_date, emigration_date);
        ELSE
            -- Both immigration and emigration date.
            -- if immi after emi, then ignore immigration. (start and end will be between study_start and emi)
            -- if earlier than emigration, then take immigration into account. (start and end will be between immi and emi)
            IF immigration_date > emigration_date THEN
                RETURN LEAST(study_end_date, death_date, emigration_date);
            ELSE
                RETURN LEAST(study_end_date, death_date, emigration_date);
            END IF;
        END IF;
    END IF;
    
    -- Should not happen, but study_end_date is a safe option
    RETURN study_end_date;
END;
$$ LANGUAGE plpgsql;
