/*  Calculates the number of days a drug is supplied.
    Input: size of the pack, number of tablets in a pack and the number of prescription instruction (as tablets per day)
*/
CREATE OR REPLACE FUNCTION getDrugDaysSupply( packsize_str varchar, pack_amount decimal, daily_prescription decimal)
    RETURNS integer AS
$$
DECLARE
    quantity integer;
BEGIN
    -- Quantity
    quantity := getDrugQuantity(packsize_str, pack_amount);
    IF quantity IS NULL THEN
        RETURN NULL;
    END IF;

    -- Days, round down (this is the max number of days the prescription lasts)
    RETURN FLOOR( quantity/daily_prescription );
END;
$$ LANGUAGE plpgsql;
