# LU Librisync

LU Librisync is a Java Servlet and JSP based Library Management System for campus libraries. It includes separate admin and student experiences, digital library support, and core library workflows such as registration, borrowing, returns, reservations, analytics, and password recovery.

## Target Features

- Admin dashboard
- Category, author, and book management
- Issue and return book workflow
- Student search by student ID and student detail viewing
- Student registration with generated student ID
- Student dashboard, borrowed books, reservations, and profile maintenance
- Change password and recover password
- Advanced search with category, author, availability, ISBN, and barcode support
- Analytics dashboard for most borrowed books, overdue tracking, and reading history
- Reservation queue, fine calculation, due reminders, and QR-ready issue flow
- E-book upload, access, and digital library reader support

## Project Structure

- `src/main/java/com/lulibrisync/controller`
  Contains auth, admin, student, search, and ebook servlet flows.
- `src/main/webapp/views`
  Contains JSP views for each major area of the system.
- `database/schema.sql`
  Base database schema for LU Librisync.
- `database/sample-data.sql`
  Seed content for demo and development.

## Setup

1. Create the MySQL database using `database/schema.sql`.
2. Optional: load `database/sample-data.sql` after replacing the placeholder hashed passwords or registering fresh accounts through the app.
3. Update database credentials with environment variables if needed:
   - `LU_LIBRISYNC_DB_URL`
   - `LU_LIBRISYNC_DB_USER`
   - `LU_LIBRISYNC_DB_PASSWORD`
4. Build and deploy the WAR to Tomcat 9.

## Spring Boot REST API (JWT + BCrypt)

The project now includes a Spring Boot REST API layer secured with JWT and BCrypt:

- `POST /api/auth/register` (public)
- `POST /api/auth/login` (public)
- `GET /api/admin/users` (`ROLE_ADMIN`)
- `GET /api/student/profile` (`ROLE_STUDENT` or `ROLE_ADMIN`)

Security rules for API:

- All `/api/**` endpoints are protected by Spring Security JWT filter.
- Only `/api/auth/login` and `/api/auth/register` are public.
- `/api/admin/**` requires admin role.
- `/api/student/**` requires student/admin role.

Password hashing:

- New passwords are hashed using BCrypt.
- Legacy PBKDF2/plain hashes are still readable for migration compatibility.

Required environment variables:

- `LU_LIBRISYNC_DB_URL`
- `LU_LIBRISYNC_DB_USER`
- `LU_LIBRISYNC_DB_PASSWORD`
- `LU_LIBRISYNC_JWT_SECRET` (recommended to set a strong 32+ byte secret)

## Current Direction

This codebase is being upgraded into a full LU Librisync foundation. The system now includes stronger auth flow design, generated student IDs, password reset/change flow support, and a shared UI direction for the remaining admin, student, search, and digital library pages.
