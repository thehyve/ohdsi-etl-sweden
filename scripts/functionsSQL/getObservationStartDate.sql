CREATE OR REPLACE FUNCTION getObservationStartDate( study_start_date date, year_of_birth date, immigration_date date, emigration_date date)
    RETURNS date AS
$$
DECLARE
    -- Observation start date can never be earlier than the study_start_date
    -- Immigration and emigration date are the most recent immigration and emigration respectively
BEGIN

    IF immigration_date IS NULL THEN
        -- If no immigration date,
        -- return the most recent date from study_start_date and yob
        -- independent whether there is a emigration date or not.
        RETURN GREATEST(study_start_date, year_of_birth);
    ELSE
        -- If only immigration date, return most recent date.
        IF emigration_date IS NULL THEN
            RETURN GREATEST(study_start_date, year_of_birth, immigration_date);
        ELSE
            -- Both immigration and emigration date.
            -- if immi after emi, then ignore immigration. (start and end will be between study_start and emi)
            -- if earlier than emigration, then take immigration into account. (start and end will be between immi and emi)
            IF immigration_date > emigration_date THEN
                RETURN GREATEST(study_start_date, year_of_birth);
            ELSE
                RETURN GREATEST(study_start_date, year_of_birth, immigration_date);
            END IF;
        END IF;
    END IF;

    -- Should not happen, but study_start_date is a safe option
    RETURN study_start_date;
END;
$$ LANGUAGE plpgsql;
