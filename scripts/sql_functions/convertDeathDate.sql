CREATE OR REPLACE FUNCTION convertDeathDate( death_date varchar )
    RETURNS date AS
$$
DECLARE
    death_date_str varchar;
BEGIN
    death_date_str := death_date::varchar;

    -- Pad with zeroes to length of 8. Truncate to 8 chars if longer.
    death_date_str := rpad(death_date_str, 8, '0');

    -- Four trailing zeroes: to middle of year
    death_date_str := replace(death_date_str, '0000', '0601');
    -- Two trailing zeroes: to middle of month
    death_date_str := replace(death_date_str, '00', '15');

    RETURN to_date(death_date_str, 'yyyymmdd');
END;
$$ LANGUAGE plpgsql;
