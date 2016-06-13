CREATE OR REPLACE FUNCTION convertDeathDate( death_date integer )
    RETURNS date AS
$$
DECLARE
    death_date_str varchar;
BEGIN
    death_date_str := death_date::varchar;

    -- Four trailing zeroes: to middle of year
    death_date_str := replace(death_date_str, '0000', '0601');
    -- Two trailing zeroes: to middle of month
    death_date_str := replace(death_date_str, '00', '15');

    RETURN to_date(death_date_str, 'yyyymmdd');
END;
$$ LANGUAGE plpgsql;

/* Tests */
