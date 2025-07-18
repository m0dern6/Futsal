
# API Endpoints

This document outlines the available API endpoints for the Futsal API.

## Futsal Ground Management

*   **GET /api/futsal-grounds**: Retrieves a list of all futsal grounds.
*   **GET /api/futsal-grounds/{id}**: Retrieves a specific futsal ground by its ID.
*   **POST /api/futsal-grounds**: Creates a new futsal ground.
*   **PUT /api/futsal-grounds/{id}**: Updates an existing futsal ground.
*   **DELETE /api/futsal-grounds/{id}**: Deletes a futsal ground.

## Booking Management

*   **GET /api/bookings**: Retrieves a list of all bookings.
*   **GET /api/bookings/{id}**: Retrieves a specific booking by its ID.
*   **POST /api/bookings**: Creates a new booking.
*   **PUT /api/bookings/{id}**: Updates an existing booking.
*   **DELETE /api/bookings/{id}**: Deletes a booking.

## User Management

*   **POST /api/auth/register**: Registers a new user.
*   **POST /api/auth/login**: Authenticates a user and returns a JWT token.
*   **GET /api/users/me**: Retrieves the profile of the currently authenticated user.

## Payment Management

*   **GET /api/payments**: Retrieves a list of all payments.
*   **GET /api/payments/{id}**: Retrieves a specific payment by its ID.
*   **POST /api/payments**: Creates a new payment.

## Review Management

*   **GET /api/reviews**: Retrieves a list of all reviews for a futsal ground.
*   **POST /api/reviews**: Creates a new review for a futsal ground.

## Notification Management

*   **GET /api/notifications**: Retrieves a list of all notifications for the authenticated user.
*   **POST /api/notifications/mark-as-read**: Marks all notifications as read.
