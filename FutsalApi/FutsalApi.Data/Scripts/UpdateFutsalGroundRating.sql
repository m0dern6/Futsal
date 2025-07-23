CREATE OR REPLACE PROCEDURE update_futsal_ground_rating(p_ground_id INT)
AS $$
BEGIN
    -- Update the rating count and average rating for the specified futsal ground
    UPDATE "FutsalGrounds"
    SET
        "RatingCount" = (
            SELECT COUNT(*)
            FROM "Reviews"
            WHERE "GroundId" = p_ground_id
        ),
        "AverageRating" = (
            SELECT COALESCE(AVG("Rating"), 0)
            FROM "Reviews"
            WHERE "GroundId" = p_ground_id
        )
    WHERE "Id" = p_ground_id;
END;
$$ LANGUAGE plpgsql;