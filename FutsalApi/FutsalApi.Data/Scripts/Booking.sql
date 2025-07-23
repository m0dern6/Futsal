CREATE OR REPLACE FUNCTION create_booking(
    p_user_id TEXT,
    p_ground_id INT,
    p_booking_date DATE,
    p_start_time TIME,
    p_end_time TIME,
    p_total_amount NUMERIC
)
RETURNS TABLE (booking_id INT) AS $$
BEGIN
    -- Check for overlapping bookings
    IF EXISTS (
        SELECT 1
        FROM "Bookings"
        WHERE "GroundId" = p_ground_id
          AND "BookingDate" = p_booking_date
          AND "StartTime" < p_end_time
          AND "EndTime" > p_start_time
    ) THEN
        RAISE EXCEPTION 'The selected time slot is already booked.';
    END IF;

    -- Insert the new booking
    INSERT INTO "Bookings" ("UserId", "GroundId", "BookingDate", "StartTime", "EndTime", "TotalAmount", "Status", "CreatedAt")
    VALUES (p_user_id, p_ground_id, p_booking_date, p_start_time, p_end_time, p_total_amount, 0, NOW())
    RETURNING "Id" INTO booking_id;

    RETURN QUERY SELECT booking_id;
END;
$$ LANGUAGE plpgsql;