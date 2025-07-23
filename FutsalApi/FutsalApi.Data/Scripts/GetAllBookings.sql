CREATE OR REPLACE FUNCTION get_all_bookings(
    p_page INT,
    p_page_size INT
)
RETURNS TABLE (
    id INT,
    booking_date DATE,
    start_time TIME,
    end_time TIME,
    status INT,
    total_amount NUMERIC,
    created_at TIMESTAMP,
    ground_name TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        b."Id",
        b."BookingDate",
        b."StartTime",
        b."EndTime",
        b."Status",
        b."TotalAmount",
        b."CreatedAt",
        g."Name" AS ground_name
    FROM
        "Bookings" AS b
    INNER JOIN
        "FutsalGrounds" AS g ON b."GroundId" = g."Id"
    ORDER BY
        b."BookingDate" DESC
    OFFSET (p_page - 1) * p_page_size
    LIMIT p_page_size;
END;
$$ LANGUAGE plpgsql;