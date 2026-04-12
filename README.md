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

## Verified Local Setup

This project is currently verified on the following local stack:

- Java 17
- Apache Tomcat 9
- MySQL 8
- Database name: `lu_librisync`
- App URL: `http://localhost:8080/lu-librisync/`

The current source is configured for local development through `src/main/resources/application.properties` and points to:

- `jdbc:mysql://127.0.0.1:3306/lu_librisync`
- username: `root`
- password: blank

If your local MySQL credentials are different, update `src/main/resources/application.properties` before rebuilding.

## Setup

1. Make sure MySQL is running on `127.0.0.1:3306`.
2. Create the database and schema:
   - run `database/schema.sql`
3. Load demo data:
   - run `database/sample-data.sql`
   - or restore `database/backups/lu_librisync_2026-04-12.sql`
4. Build the WAR:
   - `mvn -DskipTests package`
5. Deploy `target/lu-librisync.war` to Tomcat 9.
6. Open `http://localhost:8080/lu-librisync/`

## Demo Accounts

- Admin: `admin@lulibrisync.edu` / `Admin1234`
- Student: `maria.santos@student.edu` / `Student1234`
- Student: `john.cruz@student.edu` / `Student1234`

## Backup Restore

To restore the current known-good local database state:

1. Open MySQL client or Workbench on the `lu_librisync` database.
2. Run `database/backups/lu_librisync_2026-04-12.sql`
3. Restart Tomcat if the app is already running.

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

Optional environment variables:

- `LU_LIBRISYNC_JWT_SECRET` (recommended to set a strong 32+ byte secret)

## Current Direction

This codebase is being upgraded into a full LU Librisync foundation. The system now includes stronger auth flow design, generated student IDs, password reset/change flow support, and a shared UI direction for the remaining admin, student, search, and digital library pages.
