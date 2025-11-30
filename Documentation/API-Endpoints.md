## Images Management

- **POST /images/upload/single**: Uploads a single image file.
- **POST /images/upload/multiple**: Uploads multiple image files.
- **DELETE /images/delete/single/{imageUrl}**: Deletes a single image by its URL (URL-encoded).
- **DELETE /images/delete/multiple**: Deletes multiple images by their URLs (in request body).
- **GET /images/user**: Retrieves all images uploaded by the current user.

# API Endpoints

This document outlines the available API endpoints for the Futsal API.

## Futsal Ground Management

- **GET /FutsalGround**: Retrieves a list of all futsal grounds.
- **GET /FutsalGround/search**: Searches for futsal grounds.
- **GET /FutsalGround/{id}**: Retrieves a specific futsal ground by its ID.
- **POST /FutsalGround**: Creates a new futsal ground.
- **PUT /FutsalGround/{id}**: Updates an existing futsal ground.
- **DELETE /FutsalGround/{id}**: Deletes a futsal ground.

## Booking Management

- **GET /Booking**: Retrieves a list of all bookings.
- **POST /Booking**: Creates a new booking.
- **PUT /Booking/{id}**: Updates an existing booking.
- **PATCH /Booking/cancel/{id}**: Cancels a booking.

## User Management

- **POST /User/register**: Registers a new user.
- **POST /User/login**: Authenticates a user and returns a JWT token.
- **GET /User/manage/info**: Retrieves the profile of the currently authenticated user.

## Payment Management

- **GET /Payment**: Retrieves a list of all payments.
- **GET /Payment/{bookingId}**: Retrieves a specific payment by its booking ID.
- **POST /Payment**: Creates a new payment.

## Payment Gateway Management

- **POST /PaymentGateway/khalti/initiate**: Initiates a Khalti payment.
- **POST /PaymentGateway/khalti/callback**: Handles the Khalti payment callback.
- **POST /PaymentGateway/khalti/webhook**: Handles the Khalti payment webhook.

## Review Management

- **GET /Reviews**: Retrieves a list of all reviews for a futsal ground.
- **GET /Reviews/Ground/{groundId}**: Retrieves a list of all reviews for a specific futsal ground.
- **GET /Reviews/{id}**: Retrieves a specific review by its ID.
- **POST /Reviews**: Creates a new review for a futsal ground.
- **PUT /Reviews/{id}**: Updates an existing review.
- **DELETE /Reviews/{id}**: Deletes a review.

## Notification Management

- **GET /Notifications**: Retrieves a list of all notifications for the authenticated user.
- **POST /Notifications/Send**: Sends a notification to multiple users.
- **PUT /Notifications/{notificationId}**: Marks a notification as read.
