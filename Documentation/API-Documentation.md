# Futsal API Documentation

This document provides comprehensive information about all the endpoints available in the Futsal API system, including both the main API service and the authentication service, along with the data models used throughout the application.

## Table of Contents

- [Authentication Service (FutsalApi.Auth)](#authentication-service-futsalapi-auth)
  - [User Management](#user-management)
  - [Role Management](#role-management)
  - [User Role Management](#user-role-management)
- [Main API Service (FutsalApi.ApiService)](#main-api-service-futsalapi-apiservice)
  - [Booking Management](#booking-management)
  - [Futsal Ground Management](#futsal-ground-management)
  - [Payment Management](#payment-management)
  - [Review Management](#review-management)
  - [Notification Management](#notification-management)
- [Data Models](#data-models)
  - [Request Models](#request-models)
  - [Response Models](#response-models)
  - [Database Entities (DTOs)](#database-entities-dtos)

---

## Authentication Service (FutsalApi.Auth)

### User Management

Base URL: `/User`

#### Endpoints

| Method | Endpoint                   | Description               | Request Body                     | Response              |
| ------ | -------------------------- | ------------------------- | -------------------------------- | --------------------- |
| POST   | `/register`                | Register a new user       | `RegisterRequest`                | `Ok`                  |
| POST   | `/login`                   | Authenticate user         | `LoginRequest`                   | `AccessTokenResponse` |
| GET    | `/login/google`            | Google OAuth login        | -                                | Redirect to Google    |
| GET    | `/auth/google/callback`    | Handle Google callback    | -                                | Redirect              |
| POST   | `/logout`                  | Logout user               | -                                | `Ok`                  |
| POST   | `/refresh`                 | Refresh access token      | `RefreshRequest`                 | `AccessTokenResponse` |
| GET    | `/confirmEmail`            | Confirm email address     | Query params                     | `Ok`                  |
| POST   | `/resendConfirmationEmail` | Resend confirmation email | `ResendConfirmationEmailRequest` | `Ok`                  |
| POST   | `/forgotPassword`          | Request password reset    | `ForgotPasswordRequest`          | `Ok`                  |
| POST   | `/resetPassword`           | Reset password            | `ResetPasswordRequest`           | `Ok`                  |
| POST   | `/verifyResetCode`         | Verify reset code         | `VerifyResetCodeRequest`         | `Ok`                  |

#### Account Management

Base URL: `/User/manage`

| Method | Endpoint               | Description              | Request Body       | Response                 |
| ------ | ---------------------- | ------------------------ | ------------------ | ------------------------ |
| POST   | `/deactivate`          | Deactivate user account  | -                  | `Ok`                     |
| POST   | `/sendRevalidateEmail` | Send revalidation email  | -                  | `Ok`                     |
| GET    | `/revalidate`          | Revalidate user via link | Query params       | `Ok`                     |
| GET    | `/setup2fa`            | Setup 2FA                | -                  | `TwoFactorSetupResponse` |
| POST   | `/2fa`                 | Enable/disable 2FA       | `TwoFactorRequest` | `Ok`                     |
| GET    | `/info`                | Get user information     | -                  | `UserInfo`               |
| POST   | `/info`                | Update user information  | `UserInfo`         | `Ok`                     |

---

### Role Management

Base URL: `/Roles`
**Authorization Required**

#### Endpoints

| Method | Endpoint           | Description          | Request Body  | Response             |
| ------ | ------------------ | -------------------- | ------------- | -------------------- |
| GET    | `/`                | Get all roles        | -             | `IEnumerable<Role>`  |
| GET    | `/{roleId}`        | Get role by ID       | -             | `Role`               |
| POST   | `/`                | Create new role      | `RoleRequest` | `Role`               |
| PUT    | `/{roleId}`        | Update existing role | `RoleRequest` | `Role`               |
| DELETE | `/{roleId}`        | Delete role          | -             | `Ok`                 |
| GET    | `/{roleId}/Claims` | Get role claims      | -             | `IEnumerable<Claim>` |
| POST   | `/{roleId}/Claims` | Add role claim       | `ClaimModel`  | `Ok`                 |
| PUT    | `/{roleId}/Claims` | Update role claim    | `ClaimModel`  | `Ok`                 |
| DELETE | `/{roleId}/Claims` | Remove role claim    | `ClaimModel`  | `Ok`                 |

---

### User Role Management

Base URL: `/UserRoles`
**Authorization Required**

#### Endpoints

| Method | Endpoint         | Description                 | Request Body      | Response         |
| ------ | ---------------- | --------------------------- | ----------------- | ---------------- |
| GET    | `/`              | Get all user roles          | -                 | `List<UserRole>` |
| GET    | `/{userId}`      | Get roles for specific user | -                 | `List<string>`   |
| GET    | `/Role/{roleId}` | Get users in specific role  | -                 | `List<string>`   |
| POST   | `/`              | Assign role to user         | `UserRoleRequest` | `Ok`             |
| DELETE | `/{userId}`      | Remove user role            | Query: roleId     | `Ok`             |

---

## Main API Service (FutsalApi.ApiService)

### Booking Management

Base URL: `/Booking`
**Authorization Required**

#### Endpoints

| Method | Endpoint       | Description             | Request Body     | Response                       | Permissions     |
| ------ | -------------- | ----------------------- | ---------------- | ------------------------------ | --------------- |
| GET    | `/`            | Get bookings by user ID | -                | `IEnumerable<BookingResponse>` | CanView:Booking |
| POST   | `/`            | Create new booking      | `BookingRequest` | `string`                       | -               |
| PUT    | `/{id}`        | Update existing booking | `BookingRequest` | `string`                       | -               |
| PATCH  | `/cancel/{id}` | Cancel booking          | -                | `string`                       | -               |

#### Query Parameters for GET /

- `page` (int, default: 1): Page number
- `pageSize` (int, default: 10): Items per page

---

### Futsal Ground Management

Base URL: `/FutsalGround`
**Authorization Required**

#### Endpoints

| Method | Endpoint    | Description                            | Request Body          | Response                            |
| ------ | ----------- | -------------------------------------- | --------------------- | ----------------------------------- |
| GET    | `/`         | Get all futsal grounds with pagination | -                     | `IEnumerable<FutsalGroundResponse>` |
| GET    | `/search`   | Search futsal grounds                  | -                     | `IEnumerable<FutsalGroundResponse>` |
| GET    | `/{id:int}` | Get futsal ground by ID                | -                     | `FutsalGroundResponse`              |
| POST   | `/`         | Create new futsal ground               | `FutsalGroundRequest` | `FutsalGroundResponse`              |
| PUT    | `/{id:int}` | Update existing futsal ground          | `FutsalGroundRequest` | `FutsalGroundResponse`              |
| DELETE | `/{id:int}` | Delete futsal ground                   | -                     | `Ok`                                |

#### Query Parameters for GET / and /search

- `page` (int): Page number
- `pageSize` (int): Items per page
- `name` (string): Search by name (for /search)
- `location` (string): Filter by location (for /search)
- `minRating` (double): Minimum average rating (for /search)

---

### Payment Management

Base URL: `/Payment`
**Authorization Required**

#### Endpoints

| Method | Endpoint           | Description               | Request Body     | Response                       |
| ------ | ------------------ | ------------------------- | ---------------- | ------------------------------ |
| GET    | `/`                | Get payments by user ID   | -                | `IEnumerable<PaymentResponse>` |
| GET    | `/{bookingId:int}` | Get payment by booking ID | -                | `PaymentResponse`              |
| POST   | `/`                | Create new payment        | `PaymentRequest` | `string`                       |

#### Query Parameters for GET /

- `page` (int): Page number
- `pageSize` (int): Items per page

---

### Review Management

Base URL: `/Reviews`
**Authorization Required**

#### Endpoints

| Method | Endpoint                 | Description                     | Request Body    | Response                      |
| ------ | ------------------------ | ------------------------------- | --------------- | ----------------------------- |
| GET    | `/`                      | Get all reviews with pagination | -               | `IEnumerable<ReviewResponse>` |
| GET    | `/Ground/{groundId:int}` | Get reviews for specific ground | -               | `IEnumerable<ReviewResponse>` |
| GET    | `/{id:int}`              | Get review by ID                | -               | `ReviewResponse`              |
| POST   | `/`                      | Create new review               | `ReviewRequest` | `ReviewResponse`              |
| PUT    | `/{id:int}`              | Update existing review          | `ReviewRequest` | `ReviewResponse`              |
| DELETE | `/{id:int}`              | Delete review                   | -               | `Ok`                          |

#### Query Parameters for GET endpoints

- `page` (int): Page number
- `pageSize` (int): Items per page

---

### Notification Management

Base URL: `/Notifications`
**Authorization Required**

#### Endpoints

| Method | Endpoint                | Description                         | Request Body            | Response                            |
| ------ | ----------------------- | ----------------------------------- | ----------------------- | ----------------------------------- |
| GET    | `/`                     | Get notifications by user ID        | -                       | `IEnumerable<NotificationResponse>` |
| POST   | `/Send`                 | Send notification to multiple users | `NotificationListModel` | `string`                            |
| PUT    | `/{notificationId:int}` | Update notification status          | -                       | `string`                            |

#### Query Parameters for GET /

- `page` (int): Page number
- `pageSize` (int): Items per page

---

## Data Models

### Request Models

#### BookingRequest

```csharp
public class BookingRequest
{
    public required string UserId { get; set; }
    public int GroundId { get; set; }
    public DateTime BookingDate { get; set; }
    public TimeSpan StartTime { get; set; }
    public TimeSpan EndTime { get; set; }
}
```

#### FutsalGroundRequest

```csharp
public class FutsalGroundRequest
{
    public string Name { get; set; } = string.Empty;
    public string Location { get; set; } = string.Empty;
    public string OwnerId { get; set; } = string.Empty;
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public string Description { get; set; } = string.Empty;
    public string ImageUrl { get; set; } = string.Empty;
    public decimal PricePerHour { get; set; }
    public TimeSpan OpenTime { get; set; }
    public TimeSpan CloseTime { get; set; }
}
```

#### PaymentRequest

```csharp
public class PaymentRequest
{
    public int BookingId { get; set; }
    public PaymentMethod Method { get; set; }
    public string? TransactionId { get; set; }
    public decimal AmountPaid { get; set; }
    public PaymentStatus Status { get; set; } = PaymentStatus.Pending;
}
```

#### ReviewRequest

```csharp
public class ReviewRequest
{
    public int Id { get; set; }
    public string UserId { get; set; } = string.Empty;
    public int GroundId { get; set; }
    public int Rating { get; set; }
    public string? Comment { get; set; }
}
```

#### NotificationListModel

```csharp
public class NotificationListModel
{
    public required List<string> UserId { get; set; }
    public string Message { get; set; } = string.Empty;
}
```

#### RoleRequest

```csharp
public class RoleRequest
{
    public string Name { get; set; } = string.Empty;
}
```

---

### Response Models

#### BookingResponse

```csharp
public class BookingResponse
{
    public int Id { get; set; }
    public string UserId { get; set; } = string.Empty;
    public int GroundId { get; set; }
    public DateTime BookingDate { get; set; }
    public TimeSpan StartTime { get; set; }
    public TimeSpan EndTime { get; set; }
    public BookingStatus Status { get; set; }
    public decimal TotalAmount { get; set; }
    public DateTime CreatedAt { get; set; }
    public string GroundName { get; set; } = string.Empty;
}
```

#### FutsalGroundResponse

```csharp
public class FutsalGroundResponse
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Location { get; set; } = string.Empty;
    public string OwnerId { get; set; } = string.Empty;
    public decimal PricePerHour { get; set; }
    public double AverageRating { get; set; }
    public int RatingCount { get; set; } = 0;
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public string Description { get; set; } = string.Empty;
    public string ImageUrl { get; set; } = string.Empty;
    public TimeSpan OpenTime { get; set; }
    public TimeSpan CloseTime { get; set; }
    public DateTime CreatedAt { get; set; }
    public string OwnerName { get; set; } = string.Empty;
}
```

#### PaymentResponse

```csharp
public class PaymentResponse
{
    public int Id { get; set; }
    public decimal? RemainingAmount { get; set; }
    public int BookingId { get; set; }
    public PaymentMethod Method { get; set; }
    public string? TransactionId { get; set; }
    public decimal AmountPaid { get; set; }
    public PaymentStatus Status { get; set; } = PaymentStatus.Pending;
    public DateTime PaymentDate { get; set; } = DateTime.UtcNow;
}
```

#### ReviewResponse

```csharp
public class ReviewResponse
{
    public int Id { get; set; }
    public string UserId { get; set; } = string.Empty;
    public string UserName { get; set; } = string.Empty;
    public string UserImageUrl { get; set; } = string.Empty;
    public string ReviewImageUrl { get; set; } = string.Empty;
    public int GroundId { get; set; }
    public int Rating { get; set; }
    public string? Comment { get; set; }
    public DateTime CreatedAt { get; set; }
}
```

#### NotificationResponse

```csharp
public class NotificationResponse
{
    public int Id { get; set; }
    public string UserId { get; set; } = string.Empty;
    public string UserName { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
    public bool IsRead { get; set; } = false;
    public DateTime? ReadAt { get; set; } = null;
    public DateTime CreatedAt { get; set; }
}
```

---

### Database Entities (DTOs)

#### User

```csharp
public class User : IdentityUser
{
    public string? ImageUrl { get; set; } = null;
}
```

#### Role

```csharp
public class Role : IdentityRole
{
    // Inherits from IdentityRole
}
```

#### UserRole

```csharp
public class UserRole : IdentityUserRole<string>
{
    // Inherits from IdentityUserRole
}
```

#### Booking

```csharp
public class Booking
{
    public int Id { get; set; }
    public required string UserId { get; set; }
    public int GroundId { get; set; }
    public DateTime BookingDate { get; set; }
    public TimeSpan StartTime { get; set; }
    public TimeSpan EndTime { get; set; }
    public BookingStatus Status { get; set; } = BookingStatus.Pending;
    public decimal TotalAmount { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; } = null;

    // Navigation Properties
    public User User { get; set; } = null!;
    public FutsalGround Ground { get; set; } = null!;
}
```

#### FutsalGround

```csharp
public class FutsalGround
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Location { get; set; } = string.Empty;
    public string OwnerId { get; set; } = string.Empty;
    public decimal PricePerHour { get; set; }
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public string Description { get; set; } = string.Empty;
    public string ImageUrl { get; set; } = string.Empty;
    public double AverageRating { get; set; } = 0.0;
    public int RatingCount { get; set; } = 0;
    public TimeSpan OpenTime { get; set; }
    public TimeSpan CloseTime { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; } = null;
    public bool IsActive { get; set; } = true;

    // Navigation Properties
    public User Owner { get; set; } = null!;
}
```

#### Payment

```csharp
public class Payment
{
    public int Id { get; set; }
    public int BookingId { get; set; }
    public PaymentMethod Method { get; set; }
    public string? TransactionId { get; set; }
    public decimal AmountPaid { get; set; }
    public PaymentStatus Status { get; set; } = PaymentStatus.Pending;
    public DateTime PaymentDate { get; set; } = DateTime.UtcNow;

    // Navigation Properties
    public Booking Booking { get; set; } = null!;
}
```

#### Review

```csharp
public class Review
{
    public int Id { get; set; }
    public string UserId { get; set; } = string.Empty;
    public int GroundId { get; set; }
    public int Rating { get; set; }
    public string? Comment { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; } = null;
    public string? ImageUrl { get; set; } = null;

    // Navigation Properties
    public User User { get; set; } = null!;
    public FutsalGround Ground { get; set; } = null!;
}
```

#### Notification

```csharp
public class Notification
{
    public int Id { get; set; }
    public required string UserId { get; set; }
    public string Message { get; set; } = string.Empty;
    public bool IsRead { get; set; } = false;
    public DateTime? ReadAt { get; set; } = null;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation Properties
    public User User { get; set; } = null!;
}
```

#### Image

```csharp
public class Image
{
    public int Id { get; set; }
    public string Url { get; set; } = default!;
    public ImageEntityType EntityType { get; set; }
    public string? EntityId { get; set; }
    public DateTime UploadedAt { get; set; } = DateTime.UtcNow;
}
```

#### GroundClosure

```csharp
public class GroundClosure
{
    public int Id { get; set; }
    public int GroundId { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public string? Reason { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation Properties
    public virtual FutsalGround? Ground { get; set; } = null!;
}
```

---

### Enums

#### BookingStatus

```csharp
public enum BookingStatus
{
    Pending,
    Confirmed,
    Cancelled,
    Completed
}
```

#### PaymentMethod

```csharp
public enum PaymentMethod
{
    Cash,
    Online
}
```

#### PaymentStatus

```csharp
public enum PaymentStatus
{
    Pending,
    PartiallyCompleted,
    Completed,
    Failed
}
```

#### ImageEntityType

```csharp
public enum ImageEntityType
{
    Review,
    Ground,
    User
}
```

---

## Authentication & Authorization

- **Bearer Token Authentication**: Most endpoints require authentication via Bearer token
- **Permission-based Authorization**: Some endpoints require specific permissions (e.g., `CanView:Booking`)
- **Role-based Access**: User roles determine access to different functionalities
- **Google OAuth**: Supported for user authentication

## Common Response Codes

- **200 OK**: Successful request
- **201 Created**: Resource created successfully
- **204 No Content**: Successful request with no content
- **400 Bad Request**: Invalid request data
- **401 Unauthorized**: Authentication required or failed
- **403 Forbidden**: Insufficient permissions
- **404 Not Found**: Resource not found
- **500 Internal Server Error**: Server error

## Pagination

Most list endpoints support pagination with the following query parameters:

- `page`: Page number (default: 1)
- `pageSize`: Number of items per page (default: 10)

## Notes

- All dates are in UTC format
- Decimal values are used for monetary amounts
- TimeSpan is used for time intervals (e.g., booking duration, opening hours)
- Foreign key relationships are maintained between entities
- Soft delete is implemented for some entities (IsActive flag)
