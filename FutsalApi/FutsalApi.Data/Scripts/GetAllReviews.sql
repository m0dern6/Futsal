CREATE OR REPLACE FUNCTION get_all_reviews(
    p_page INT,
    p_page_size INT
)
RETURNS TABLE (
    id INT,
    user_id TEXT,
    ground_id INT,
    rating INT,
    user_name TEXT,
    user_image_url TEXT,
    review_image_url TEXT,
    comment TEXT,
    created_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        r."Id",
        r."UserId",
        r."GroundId",
        r."Rating",
        u."UserName",
        u."ImageUrl",
        r."ImageUrl",
        r."Comment",
        r."CreatedAt"
    FROM
        "Reviews" AS r
    INNER JOIN
        "AspNetUsers" AS u ON r."UserId" = u."Id"
    ORDER BY
        r."CreatedAt" DESC
    OFFSET (p_page - 1) * p_page_size
    LIMIT p_page_size;
END;
$$ LANGUAGE plpgsql;