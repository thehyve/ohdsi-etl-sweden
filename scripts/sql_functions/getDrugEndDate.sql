/*  Calculates the end date of a drug.
    Derives how many units have been prescribed from packsize and amount.
    Then multiplies by the daily_prescription to get the number of days the prescription is for.
    Finally, add this number of days to the start_date.
*/
CREATE OR REPLACE FUNCTION getDrugEndDate( start_date_raw varchar, packsize_str varchar, amount decimal, daily_prescription decimal)
    RETURNS date AS
$$
DECLARE
    start_date date;
    quantity integer;
    days integer;
    days_str varchar;
    result date;
BEGIN
    -- Datum
    start_date := to_date(start_date_raw, 'mm/dd/yyyy');

    -- Quantity
    quantity := getDrugQuantity(packsize_str, amount);
    IF quantity IS NULL THEN
        RETURN NULL;
    END IF;

    -- Days, round down (this is the max number of days the prescription lasts)
    days := FLOOR( quantity/daily_prescription );
    days_str := to_char(days,'9')||' days';
    -- result := start_date + interval days_str;
    EXECUTE 'SELECT to_date('''||start_date_raw||''', ''mm/dd/yyyy'') + interval '''||to_char(days,'999999')||' days''' INTO result;
    -- Round to nearest even integer
    RETURN result;
END;
$$ LANGUAGE plpgsql;
