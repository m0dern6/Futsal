# Pages Overview

This document provides an overview of the different pages available in the Futsal Booking System, categorized by user roles (Admin and User).

## Admin Pages

These pages are designed for administrators to manage various aspects of the system, including futsal grounds, bookings, users, and roles.

*   **Admin Dashboard (`/admin/dashboard`)**
    *   **Purpose:** Provides a high-level overview of key system metrics and quick access to administrative functions.
    *   **Functionality:** Displays statistics (e.g., total users, total futsal grounds, total bookings) and navigation links to other admin sections.

*   **Futsal Grounds List (`/admin/futsal-grounds`)**
    *   **Purpose:** Allows administrators to view, edit, and delete futsal ground listings.
    *   **Functionality:** Displays a paginated list of all registered futsal grounds with options to manage each entry.

*   **Futsal Ground Form (No direct route, used for creation/editing)**
    *   **Purpose:** Used for creating new futsal ground entries or modifying existing ones.
    *   **Functionality:** Provides a form with fields for futsal ground details such as name, location, price per hour, opening/closing times, and description.

*   **Bookings List (`/admin/bookings`)**
    *   **Purpose:** Enables administrators to view all bookings made in the system.
    *   **Functionality:** Displays a comprehensive list of all bookings, including booking ID, user, futsal ground, date, time, and status.

*   **Users List (`/admin/users`)**
    *   **Purpose:** Allows administrators to view all registered users.
    *   **Functionality:** Displays a list of users with their ID, email, and email confirmation status.

*   **Roles List (`/admin/roles`)**
    *   **Purpose:** Enables administrators to manage user roles within the system.
    *   **Functionality:** Displays a list of all defined roles with options to edit or delete them.

*   **Role Form (No direct route, used for creation/editing)**
    *   **Purpose:** Used for creating new roles or modifying existing ones.
    *   **Functionality:** Provides a form to define or update role names.

*   **Role Claims (`/admin/roles/{RoleId}/claims`)**
    *   **Purpose:** Allows administrators to manage claims (permissions) associated with specific roles.
    *   **Functionality:** Displays existing claims for a role and provides functionality to add or remove claims.

## User Pages

These pages are designed for general users to browse futsal grounds, make bookings, and manage their personal information.

*   **Futsal Grounds List (`/futsal-grounds`)**
    *   **Purpose:** Allows users to browse available futsal grounds.
    *   **Functionality:** Displays a list of futsal grounds with basic information and an option to view detailed information for each.

*   **Futsal Ground Details (`/futsal-grounds/{Id:int}`)**
    *   **Purpose:** Provides detailed information about a specific futsal ground.
    *   **Functionality:** Shows name, location, price, description, operating hours, and includes a "Book Now" button. Also displays reviews for the ground.

*   **My Bookings (`/my-bookings`)**
    *   **Purpose:** Allows users to view and manage their personal bookings.
    *   **Functionality:** Displays a list of the user's past and upcoming bookings with options to cancel upcoming bookings.

*   **Booking Form (`/bookings/new/{GroundId:int}`)**
    *   **Purpose:** Enables users to create a new booking for a selected futsal ground.
    *   **Functionality:** Provides a form to select booking date, start time, and end time.

*   **Reviews List (Integrated into Futsal Ground Details)**
    *   **Purpose:** Displays reviews submitted for a specific futsal ground.
    *   **Functionality:** Shows user, rating, and comments for each review.

*   **Review Form (No direct route, used for creation/editing)**
    *   **Purpose:** Allows users to submit or update a review for a futsal ground.
    *   **Functionality:** Provides a form to enter a rating and comment.

*   **User Profile (`/profile`)**
    *   **Purpose:** Enables users to view and update their profile information.
    *   **Functionality:** Provides fields to update email and password.

*   **Login (`/login`)**
    *   **Purpose:** Allows users to authenticate and access the system.
    *   **Functionality:** Provides a form for email and password login.

*   **Register (`/register`)**
    *   **Purpose:** Allows new users to create an account.
    *   **Functionality:** Provides a form for new user registration with email and password.

*   **Forgot Password (`/forgot-password`)**
    *   **Purpose:** Enables users to reset their password if forgotten.
    *   **Functionality:** Provides a form to request a password reset link via email.
