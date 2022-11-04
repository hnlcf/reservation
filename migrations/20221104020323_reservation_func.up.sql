-- if user_id is null, find all reservations within during for the resource
-- if resource_id is null, find all reservations within during for the user
-- if both are null, find all reservations within during
-- if both are set, find all reservations within during for the resource and user
CREATE OR REPLACE FUNCTION resv.query(uid TEXT, rid TEXT, during TSTZRANGE) RETURNS TABLE (LIKE resv.reservations)
AS $$
BEGIN
    IF uid IS NULL AND rid IS NULL THEN
        -- if both are null, find all reservations within during
        RETURN QUERY SELECT * FROM resv.reservations WHERE timespan && during;
    ELSEIF uid IS NULL THEN
        -- if user_id is null, find all reservations within during for the resource
        RETURN QUERY SELECT * FROM resv.reservations WHERE resource_id = rid AND during @> timespan;
    ELSEIF rid IS NULL THEN
        -- if resource_id is null, find all reservations within during for the user
        RETURN QUERY SELECT * FROM resv.reservations WHERE user_id = uid AND during @> timespan;
    ELSE
        -- if both are set, find all reservations within during for the resource and user
        RETURN QUERY SELECT * FROM resv.reservations WHERE resource_id =rid AND user_id = uid AND during @> timespan;
    END IF;
END;
$$ LANGUAGE plpgsql;
