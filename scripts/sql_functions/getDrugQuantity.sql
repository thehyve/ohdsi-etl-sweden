/*  Calculates quantity of drugs dispensed
    from forpstl (package size) and antal (number of packages dispensed)
    Returns an integer or None. */
CREATE OR REPLACE FUNCTION getDrugQuantity( packsize_str varchar, amount decimal)
    RETURNS integer AS
$$
DECLARE
    packsize_num integer;
    regex_packsize varchar :='(\d+( ?x ?\d+)?)';
BEGIN
    -- Skip if packsize refers to volume/weigth instead of quantity
    IF strpos(packsize_str,'mi') > 0 OR strpos(packsize_str,',') > 0  OR strpos(packsize_str,'gr') > 0 THEN
        -- Anything like mi/mill/milliter or decimal or gram/milligr is not quantity related.
        -- Do not assign a quantity
        RETURN NULL;
    END IF;

    -- Get numbers/expression form packsize
    packsize_str := substring(packsize_str, regex_packsize); -- Null if no match
    -- No match, then packsize is invalid
    IF packsize_str IS NULL THEN
        RETURN NULL;
    END IF;

    -- Evaluate expression, if present. e.g. '3 x 28' becomes 84
    packsize_str := replace(packsize_str, 'x', '*');
    EXECUTE 'SELECT '||packsize_str INTO packsize_num;
    IF packsize_num = 0 THEN
        RETURN NULL;
    END IF;

    RETURN round(packsize_num * amount);
END;
$$ LANGUAGE plpgsql;
