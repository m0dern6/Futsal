CREATE OR REPLACE FUNCTION delete_review_by_user(p_review_id INT, p_user_id TEXT)
RETURNS BOOLEAN AS $$
DECLARE
    deleted_rows INT;
BEGIN
    -- Delete the review and check if the user owns it
    DELETE FROM "Reviews"
    WHERE "Id" = p_review_id AND "UserId" = p_user_id;

    -- Get the number of deleted rows
    GET DIAGNOSTICS deleted_rows = ROW_COUNT;

    -- Return true if a row was deleted, otherwise false
    RETURN deleted_rows > 0;
END;
$$ LANGUAGE plpgsql;