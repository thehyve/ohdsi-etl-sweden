/*  Calculates the number of days a drug is supplied.
*/
CREATE OR REPLACE FUNCTION getDrugDaysSupply( packsize_str varchar, amount decimal, daily_prescription decimal)
    RETURNS integer AS
$$
DECLARE
    start_date date;
    quantity integer;
    days integer;
BEGIN
    -- Datum
    start_date := to_date(start_date_raw, 'mm/dd/yyyy');

    -- Quantity
    quantity := getDrugQuantity(packsize_str, amount);
    IF quantity IS NULL THEN
        RETURN NULL;
    END IF;

    -- Days, round down (this is the max number of days the prescription lasts)
    RETURN FLOOR( quantity/daily_prescription );
END;
$$ LANGUAGE plpgsql;
