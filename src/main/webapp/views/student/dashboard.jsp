<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page session="true" %>
<%
    Object currentUser = session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
        return;
    }

    String studentName = String.valueOf(currentUser).trim();
    if (studentName.isEmpty()) {
        studentName = "Student";
    }

    String userEmail = String.valueOf(session.getAttribute("userEmail")).trim();
    if (userEmail.isEmpty() || "null".equalsIgnoreCase(userEmail)) {
        userEmail = studentName.toLowerCase().replace(" ", ".");
    }

    String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard | LU Librisync</title>
    <style>
        :root {
            --bg: #eef6f0;
            --surface: rgba(255, 255, 255, 0.94);
            --surface-strong: #ffffff;
            --line: rgba(32, 112, 58, 0.14);
            --text: #1f2f24;
            --muted: #5f7667;
            --accent: #0f7f34;
            --accent-strong: #0a6428;
            --accent-soft: #dff3e5;
            --success-soft: #dcebd7;
            --warning-soft: #f8e4bf;
            --shadow: 0 22px 45px rgba(18, 95, 44, 0.12);
            --radius-xl: 28px;
            --radius-lg: 20px;
            --radius-md: 14px;
        }

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            min-height: 100vh;
            font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
            color: var(--text);
            background:
                radial-gradient(circle at top left, rgba(32, 182, 77, 0.18), transparent 32%),
                radial-gradient(circle at top right, rgba(11, 123, 47, 0.14), transparent 28%),
                linear-gradient(180deg, #f8fcf8 0%, #e8f2ea 100%);
        }

        a {
            color: inherit;
            text-decoration: none;
        }

        .layout {
            display: grid;
            grid-template-columns: 280px minmax(0, 1fr);
            min-height: 100vh;
        }

        .sidebar {
            padding: 32px 24px;
            background: rgba(10, 109, 40, 0.94);
            color: #f3fff6;
            position: relative;
            overflow: hidden;
        }

        .sidebar::after {
            content: "";
            position: absolute;
            inset: auto -80px -60px auto;
            width: 220px;
            height: 220px;
            border-radius: 50%;
            background: rgba(220, 255, 232, 0.1);
        }

        .brand {
            position: relative;
            z-index: 1;
            margin-bottom: 28px;
        }

        .brand-mark {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 52px;
            height: 52px;
            border-radius: 16px;
            background: rgba(255, 255, 255, 0.18);
            font-size: 24px;
            margin-bottom: 14px;
        }

        .brand h1 {
            margin: 0;
            font-size: 1.5rem;
            letter-spacing: 0.04em;
        }

        .brand p,
        .sidebar-note p,
        .hero-copy p,
        .section-heading p,
        .mini-card p,
        .timeline-item p,
        .policy-card p,
        .activity-card p,
        .empty-state p,
        .profile-card p,
        .footer-note {
            color: rgba(243, 255, 246, 0.82);
        }

        .brand p,
        .hero-copy p,
        .section-heading p,
        .mini-card p,
        .timeline-item p,
        .policy-card p,
        .activity-card p,
        .empty-state p,
        .profile-card p,
        .footer-note {
            margin: 0;
        }

        .nav {
            position: relative;
            z-index: 1;
            display: grid;
            gap: 10px;
        }

        .nav a {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 14px 16px;
            border-radius: 16px;
            color: #f3fff6;
            background: rgba(255, 255, 255, 0.08);
            transition: transform 0.2s ease, background 0.2s ease;
        }

        .nav a.active,
        .nav a:hover {
            background: rgba(255, 255, 255, 0.18);
            transform: translateX(4px);
        }

        .sidebar-note {
            position: relative;
            z-index: 1;
            margin-top: 28px;
            padding: 18px;
            border-radius: 18px;
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(220, 255, 232, 0.18);
        }

        .sidebar-note h3 {
            margin: 0 0 8px;
            font-size: 1rem;
        }

        .content {
            padding: 28px;
        }

        .hero {
            display: grid;
            grid-template-columns: minmax(0, 1.4fr) minmax(320px, 0.8fr);
            gap: 22px;
            margin-bottom: 22px;
        }

        .hero-card,
        .profile-card,
        .stats-grid .stat-card,
        .section-card,
        .activity-card,
        .policy-card {
            background: var(--surface);
            border: 1px solid var(--line);
            border-radius: var(--radius-xl);
            box-shadow: var(--shadow);
            backdrop-filter: blur(10px);
        }

        .hero-card {
            padding: 30px;
            background:
                linear-gradient(135deg, rgba(244, 255, 247, 0.95), rgba(228, 247, 232, 0.92)),
                var(--surface);
        }

        .eyebrow {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 8px 12px;
            border-radius: 999px;
            background: rgba(15, 127, 52, 0.12);
            color: var(--accent-strong);
            font-size: 0.88rem;
            font-weight: 600;
            margin-bottom: 14px;
        }

        .hero-copy h2 {
            margin: 0 0 10px;
            font-size: clamp(2rem, 3vw, 3rem);
            line-height: 1.08;
        }

        .hero-copy p {
            color: var(--muted);
            max-width: 640px;
            line-height: 1.6;
        }

        .hero-actions {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            margin-top: 22px;
        }

        .button,
        .button-secondary {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            min-height: 46px;
            padding: 0 18px;
            border-radius: 14px;
            font-weight: 600;
            transition: transform 0.2s ease, box-shadow 0.2s ease, background 0.2s ease;
        }

        .button {
            background: var(--accent);
            color: #fff;
            box-shadow: 0 14px 28px rgba(10, 100, 40, 0.24);
        }

        .button:hover {
            background: var(--accent-strong);
            transform: translateY(-2px);
        }

        .button-secondary {
            background: rgba(255, 255, 255, 0.7);
            color: var(--text);
            border: 1px solid var(--line);
        }

        .button-secondary:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 24px rgba(11, 123, 47, 0.12);
        }

        .profile-card {
            padding: 24px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            gap: 18px;
        }

        .profile-header {
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .avatar {
            width: 58px;
            height: 58px;
            border-radius: 18px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #0f7f34, #20b64d);
            color: #fff;
            font-size: 1.35rem;
            font-weight: 700;
        }

        .profile-card h3,
        .section-heading h3,
        .activity-card h3,
        .policy-card h3 {
            margin: 0;
        }

        .profile-card p {
            color: var(--muted);
            line-height: 1.55;
        }

        .mini-grid,
        .stats-grid,
        .policies-grid,
        .actions-grid {
            display: grid;
            gap: 18px;
        }

        .mini-grid {
            grid-template-columns: repeat(2, minmax(0, 1fr));
        }

        .mini-card {
            padding: 16px;
            border-radius: 18px;
            background: var(--surface-strong);
            border: 1px solid var(--line);
        }

        .mini-card strong {
            display: block;
            margin-bottom: 4px;
            font-size: 1.05rem;
        }

        .stats-grid {
            grid-template-columns: repeat(4, minmax(0, 1fr));
            margin-bottom: 22px;
        }

        .continue-reading-card {
            margin-bottom: 22px;
            padding: 24px;
            background:
                linear-gradient(180deg, rgba(255, 255, 255, 0.96), rgba(244, 251, 246, 0.94)),
                var(--surface);
            border: 1px solid var(--line);
            border-radius: var(--radius-xl);
            box-shadow: var(--shadow);
            overflow: hidden;
        }

        .continue-heading {
            display: flex;
            align-items: flex-end;
            justify-content: space-between;
            gap: 12px;
            margin-bottom: 16px;
        }

        .continue-heading h3,
        .continue-heading p {
            margin: 0;
        }

        .continue-heading p {
            color: var(--muted);
            line-height: 1.55;
        }

        .continue-row {
            display: flex;
            gap: 16px;
            overflow-x: auto;
            padding-bottom: 8px;
            scroll-snap-type: x proximity;
        }

        .continue-row::-webkit-scrollbar {
            height: 8px;
        }

        .continue-row::-webkit-scrollbar-thumb {
            background: rgba(15, 127, 52, 0.18);
            border-radius: 999px;
        }

        .continue-item {
            min-width: 290px;
            max-width: 290px;
            padding: 16px;
            border-radius: 24px;
            background: linear-gradient(180deg, rgba(255, 255, 255, 0.96), rgba(238, 249, 241, 0.96));
            border: 1px solid rgba(32, 112, 58, 0.12);
            display: grid;
            gap: 14px;
            scroll-snap-align: start;
        }

        .continue-cover {
            min-height: 166px;
            padding: 16px;
            border-radius: 20px;
            color: #f3fff6;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.12);
        }

        .continue-cover.emerald {
            background: linear-gradient(160deg, #0d5f2d 0%, #149341 52%, #6bd28a 100%);
        }

        .continue-cover.olive {
            background: linear-gradient(160deg, #4f5b1d 0%, #84993c 50%, #d0e78b 100%);
        }

        .continue-cover.teal {
            background: linear-gradient(160deg, #104a52 0%, #177f87 52%, #79d3dd 100%);
        }

        .continue-tag {
            display: inline-flex;
            align-items: center;
            align-self: flex-start;
            padding: 6px 10px;
            border-radius: 999px;
            font-size: 0.76rem;
            font-weight: 700;
            letter-spacing: 0.04em;
            text-transform: uppercase;
            background: rgba(255, 255, 255, 0.16);
        }

        .continue-cover h4,
        .continue-body h4 {
            margin: 0;
        }

        .continue-cover p {
            margin: 8px 0 0;
            color: rgba(243, 255, 246, 0.82);
            line-height: 1.45;
        }

        .continue-body {
            display: grid;
            gap: 10px;
        }

        .continue-body p {
            margin: 0;
            color: var(--muted);
            line-height: 1.5;
        }

        .continue-progress {
            height: 8px;
            border-radius: 999px;
            background: rgba(15, 127, 52, 0.1);
            overflow: hidden;
        }

        .continue-progress span {
            display: block;
            height: 100%;
            border-radius: inherit;
            background: linear-gradient(90deg, #0f7f34 0%, #42c863 100%);
        }

        .continue-meta {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 10px;
            font-size: 0.86rem;
            color: var(--muted);
        }

        .continue-actions {
            display: flex;
            gap: 10px;
        }

        .continue-actions a,
        .continue-actions button {
            flex: 1;
            min-height: 42px;
            border-radius: 14px;
            border: 0;
            cursor: pointer;
            font: inherit;
            font-weight: 700;
            transition: transform 0.2s ease, background 0.2s ease, box-shadow 0.2s ease;
        }

        .continue-actions a {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            background: var(--accent);
            color: #fff;
            box-shadow: 0 12px 22px rgba(10, 100, 40, 0.18);
        }

        .continue-actions button {
            background: rgba(15, 127, 52, 0.08);
            color: var(--accent-strong);
        }

        .continue-actions a:hover,
        .continue-actions button:hover {
            transform: translateY(-2px);
        }

        .continue-empty {
            margin-top: 10px;
            padding: 18px;
            border-radius: 20px;
            background: rgba(244, 255, 247, 0.92);
            border: 1px dashed rgba(32, 112, 58, 0.24);
            color: var(--muted);
        }

        .stat-card {
            padding: 22px;
        }

        .stat-card .label {
            display: block;
            color: var(--muted);
            font-size: 0.95rem;
            margin-bottom: 10px;
        }

        .stat-card .value {
            display: block;
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 6px;
        }

        .stat-card .hint {
            color: var(--muted);
            line-height: 1.5;
        }

        .section-grid {
            display: grid;
            grid-template-columns: minmax(0, 1.15fr) minmax(320px, 0.85fr);
            gap: 22px;
            margin-bottom: 22px;
        }

        .section-card {
            padding: 24px;
        }

        .section-heading {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 12px;
            margin-bottom: 18px;
        }

        .section-heading p {
            color: var(--muted);
            line-height: 1.55;
        }

        .actions-grid {
            grid-template-columns: repeat(2, minmax(0, 1fr));
        }

        .action-link {
            display: block;
            padding: 18px;
            border-radius: var(--radius-lg);
            background: var(--surface-strong);
            border: 1px solid var(--line);
            transition: transform 0.2s ease, border-color 0.2s ease, box-shadow 0.2s ease;
        }

        .action-link:hover {
            transform: translateY(-3px);
            border-color: rgba(15, 127, 52, 0.3);
            box-shadow: 0 16px 28px rgba(11, 123, 47, 0.1);
        }

        .action-link strong {
            display: block;
            margin-bottom: 8px;
            font-size: 1.02rem;
        }

        .action-link span {
            color: var(--muted);
            line-height: 1.55;
        }

        .timeline {
            display: grid;
            gap: 14px;
        }

        .timeline-item {
            position: relative;
            padding: 18px 18px 18px 54px;
            border-radius: var(--radius-lg);
            background: var(--surface-strong);
            border: 1px solid var(--line);
        }

        .timeline-item::before {
            content: "";
            position: absolute;
            top: 22px;
            left: 22px;
            width: 14px;
            height: 14px;
            border-radius: 50%;
            background: var(--accent);
            box-shadow: 0 0 0 5px rgba(15, 127, 52, 0.14);
        }

        .timeline-item strong {
            display: block;
            margin-bottom: 6px;
        }

        .timeline-item p {
            color: var(--muted);
            line-height: 1.55;
        }

        .policy-stack {
            display: grid;
            gap: 18px;
        }

        .policy-card {
            padding: 22px;
        }

        .policy-pill {
            display: inline-flex;
            align-items: center;
            padding: 7px 11px;
            border-radius: 999px;
            font-size: 0.82rem;
            font-weight: 700;
            margin-bottom: 12px;
        }

        .policy-pill.success {
            background: var(--success-soft);
            color: #31572c;
        }

        .policy-pill.warning {
            background: var(--warning-soft);
            color: #8b5b08;
        }

        .policy-card p {
            color: var(--muted);
            line-height: 1.55;
        }

        .policy-list,
        .bullet-list {
            margin: 14px 0 0;
            padding-left: 18px;
            color: var(--muted);
        }

        .policy-list li,
        .bullet-list li {
            margin-bottom: 8px;
            line-height: 1.5;
        }

        .activity-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 18px;
        }

        .activity-card {
            padding: 22px;
        }

        .activity-card p {
            color: var(--muted);
            line-height: 1.55;
        }

        .empty-state {
            margin-top: 14px;
            padding: 16px;
            border-radius: 16px;
            background: rgba(244, 255, 247, 0.85);
            border: 1px dashed rgba(32, 112, 58, 0.24);
        }

        .empty-state strong {
            display: block;
            margin-bottom: 6px;
        }

        .footer-note {
            margin-top: 22px;
            color: var(--muted);
            text-align: center;
            font-size: 0.95rem;
        }

        @media (max-width: 1180px) {
            .layout,
            .hero,
            .section-grid,
            .activity-grid,
            .stats-grid {
                grid-template-columns: 1fr;
            }

            .sidebar {
                height: auto;
            }
        }

        @media (max-width: 760px) {
            .content,
            .sidebar {
                padding: 20px;
            }

            .actions-grid,
            .mini-grid {
                grid-template-columns: 1fr;
            }

            .continue-item {
                min-width: 100%;
                max-width: 100%;
            }

            .hero-card,
            .profile-card,
            .section-card,
            .activity-card,
            .policy-card,
            .stat-card {
                padding: 20px;
            }

            .hero-copy h2 {
                font-size: 2rem;
            }
        }
    </style>
</head>
<body>
    <div class="layout">
        <aside class="sidebar">
            <div class="brand">
                <div class="brand-mark">LU</div>
                <h1>Librisync</h1>
                <p>Your student library portal for borrowing, tracking, and planning your next reads.</p>
            </div>

            <nav class="nav">
                <a class="active" href="<%= contextPath %>/views/student/dashboard.jsp">Dashboard</a>
                <a href="<%= contextPath %>/views/student/books.jsp">Browse Books</a>
                <a href="<%= contextPath %>/views/student/borrowed.jsp">Borrowed Books</a>
                <a href="<%= contextPath %>/views/student/reservations.jsp">Reservations</a>
                <a href="<%= contextPath %>/views/student/profile.jsp">My Profile</a>
                <a href="<%= contextPath %>/logout" data-swal-confirm="true" data-swal-title="Log out?" data-swal-text="You will need to sign in again to continue using LU Librisync." data-swal-confirm-text="Yes, log out" data-swal-cancel-text="Stay here" data-swal-icon="?">Logout</a>
            </nav>

            <div class="sidebar-note">
                <h3>Student Essentials</h3>
                <p>Keep track of your borrowed books, reserve unavailable titles, and update your account details from one place.</p>
            </div>
        </aside>

        <main class="content">
            <section class="hero">
                <div class="hero-card">
                    <div class="eyebrow">Student Portal</div>
                    <div class="hero-copy">
                        <h2>Welcome back, <%= studentName %>.</h2>
                        <p>
                            This dashboard is your library home base. From here you can browse available titles,
                            review your borrowed books, monitor reservations, and keep your student profile updated.
                        </p>
                    </div>

                    <div class="hero-actions">
                        <a class="button" href="<%= contextPath %>/views/student/books.jsp">Browse Collection</a>
                        <a class="button-secondary" href="<%= contextPath %>/views/student/borrowed.jsp">View Borrowed Books</a>
                    </div>
                </div>

                <div class="profile-card">
                    <div class="profile-header">
                        <div class="avatar"><%= studentName.substring(0, 1).toUpperCase() %></div>
                        <div>
                            <h3><%= studentName %></h3>
                            <p>Logged in student account</p>
                        </div>
                    </div>

                    <div class="mini-grid">
                        <div class="mini-card">
                            <strong>Books</strong>
                            <p>Browse the full collection and look for available titles.</p>
                        </div>
                        <div class="mini-card">
                            <strong>Reservations</strong>
                            <p>Queue for in-demand books and track your requests.</p>
                        </div>
                        <div class="mini-card">
                            <strong>Borrowing</strong>
                            <p>Review active loans and stay on top of return dates.</p>
                        </div>
                        <div class="mini-card">
                            <strong>Profile</strong>
                            <p>Maintain your student details and account information.</p>
                        </div>
                    </div>

                    <a class="button-secondary" href="<%= contextPath %>/views/student/profile.jsp">Manage My Profile</a>
                </div>
            </section>

            <section class="continue-reading-card">
                <div class="continue-heading">
                    <div>
                        <h3>Continue Reading</h3>
                        <p>Pick up your digital books right where you left them, with quick resume cards inspired by modern reading apps.</p>
                    </div>
                    <a class="button-secondary" href="<%= contextPath %>/views/student/books.jsp">Open Digital Books</a>
                </div>

                <div class="continue-row" id="continueReadingRow"></div>
                <div class="continue-empty" id="continueReadingEmpty">
                    Start reading any digital title and it will appear here with saved progress, current section, and a resume button.
                </div>
            </section>

            <section class="stats-grid">
                <article class="stat-card">
                    <span class="label">Available Student Features</span>
                    <span class="value">4</span>
                    <span class="hint">Books, borrowed list, reservations, and profile tools are ready from this dashboard.</span>
                </article>
                <article class="stat-card">
                    <span class="label">Quick Access</span>
                    <span class="value">24/7</span>
                    <span class="hint">Use the portal anytime to review your library activity and account details.</span>
                </article>
                <article class="stat-card">
                    <span class="label">Borrowing Support</span>
                    <span class="value">Easy</span>
                    <span class="hint">Follow the guided steps below when you want to borrow or reserve a title.</span>
                </article>
                <article class="stat-card">
                    <span class="label">Student View</span>
                    <span class="value">Focused</span>
                    <span class="hint">This page is designed around student tasks instead of admin-only management actions.</span>
                </article>
            </section>

            <section class="section-grid">
                <div class="section-card">
                    <div class="section-heading">
                        <div>
                            <h3>Student Actions</h3>
                            <p>Jump straight into the tasks students use most often inside LU Librisync.</p>
                        </div>
                    </div>

                    <div class="actions-grid">
                        <a class="action-link" href="<%= contextPath %>/views/student/books.jsp">
                            <strong>Browse Books</strong>
                            <span>Explore available titles, search your next read, and review collection options.</span>
                        </a>
                        <a class="action-link" href="<%= contextPath %>/views/student/borrowed.jsp">
                            <strong>My Borrowed Books</strong>
                            <span>Check what you currently have on loan and stay updated on your reading list.</span>
                        </a>
                        <a class="action-link" href="<%= contextPath %>/views/student/reservations.jsp">
                            <strong>My Reservations</strong>
                            <span>Track book reservations and monitor requests for titles that are not yet available.</span>
                        </a>
                        <a class="action-link" href="<%= contextPath %>/views/student/profile.jsp">
                            <strong>Update Profile</strong>
                            <span>Review your account details so the library can keep your student record current.</span>
                        </a>
                    </div>
                </div>

                <div class="section-card">
                    <div class="section-heading">
                        <div>
                            <h3>How Borrowing Works</h3>
                            <p>A simple student flow to help you move from searching to returning with fewer surprises.</p>
                        </div>
                    </div>

                    <div class="timeline">
                        <div class="timeline-item">
                            <strong>1. Search the collection</strong>
                            <p>Open the books page to browse the library catalog and identify titles you need.</p>
                        </div>
                        <div class="timeline-item">
                            <strong>2. Reserve when unavailable</strong>
                            <p>If a book is not immediately available, use the reservations section to keep track of your request.</p>
                        </div>
                        <div class="timeline-item">
                            <strong>3. Monitor active loans</strong>
                            <p>Visit the borrowed books page regularly so you do not miss important loan or return updates.</p>
                        </div>
                        <div class="timeline-item">
                            <strong>4. Keep your profile updated</strong>
                            <p>Make sure your account details remain correct so library communication stays accurate.</p>
                        </div>
                    </div>
                </div>
            </section>

            <section class="section-grid">
                <div class="policy-stack">
                    <article class="policy-card">
                        <span class="policy-pill success">Student-ready</span>
                        <h3>Features Covered on This Dashboard</h3>
                        <p>The student dashboard now reflects the core student experience instead of admin management functions.</p>
                        <ul class="policy-list">
                            <li>Browse and discover books from the catalog</li>
                            <li>View currently borrowed titles</li>
                            <li>Track reservations and requests</li>
                            <li>Access and update profile information</li>
                        </ul>
                    </article>

                    <article class="policy-card">
                        <span class="policy-pill warning">Helpful reminders</span>
                        <h3>Library Best Practices</h3>
                        <p>Use these habits to make the most of your student account and avoid unnecessary delays.</p>
                        <ul class="bullet-list">
                            <li>Check your borrowed books page regularly for status updates.</li>
                            <li>Reserve high-demand books as early as possible.</li>
                            <li>Keep your personal information current in your profile.</li>
                            <li>Coordinate with the library staff for any special borrowing concerns.</li>
                        </ul>
                    </article>
                </div>

                <div class="section-card">
                    <div class="section-heading">
                        <div>
                            <h3>Activity Snapshot</h3>
                            <p>This space summarizes the kinds of student activity this portal supports right now.</p>
                        </div>
                    </div>

                    <div class="activity-grid">
                        <article class="activity-card">
                            <h3>Catalog Access</h3>
                            <p>Find books needed for coursework, research, and personal reading in one student area.</p>
                        </article>
                        <article class="activity-card">
                            <h3>Loan Tracking</h3>
                            <p>Keep a single destination for reviewing books already borrowed under your account.</p>
                        </article>
                        <article class="activity-card">
                            <h3>Reservation Queue</h3>
                            <p>Stay organized when popular titles are busy by monitoring requests and pending holds.</p>
                        </article>
                    </div>

                    <div class="empty-state">
                        <strong>Ready for backend data</strong>
                        <p>
                            This page is prepared as a student-facing dashboard and can later display live counts,
                            due dates, and reservation status once the student servlets are connected.
                        </p>
                    </div>
                </div>
            </section>

            <p class="footer-note">LU Librisync Student Dashboard</p>
        </main>
    </div>

    <script src="<%= contextPath %>/assets/js/lu-swal.js"></script>
    <script src="<%= contextPath %>/assets/js/reading-progress.js"></script>
    <script>
        (function () {
            var userKey = "<%= userEmail %>";
            var contextPath = "<%= contextPath %>";
            var row = document.getElementById("continueReadingRow");
            var emptyState = document.getElementById("continueReadingEmpty");

            if (!row || !emptyState || !window.LuReadingProgress) {
                return;
            }

            function renderCards() {
                var entries = window.LuReadingProgress.getContinueReading(userKey).slice(0, 6);
                row.innerHTML = "";

                if (!entries.length) {
                    emptyState.style.display = "block";
                    return;
                }

                emptyState.style.display = "none";

                entries.forEach(function (entry) {
                    var item = document.createElement("article");
                    item.className = "continue-item";
                    item.innerHTML =
                        "<div class=\"continue-cover " + entry.coverTone + "\">" +
                            "<span class=\"continue-tag\">Resume</span>" +
                            "<div>" +
                                "<h4>" + entry.title + "</h4>" +
                                "<p>" + entry.author + "</p>" +
                            "</div>" +
                        "</div>" +
                        "<div class=\"continue-body\">" +
                            "<div>" +
                                "<h4>" + entry.chapterLabel + "</h4>" +
                                "<p>" + entry.minutesLeft + " min left to reach the next milestone.</p>" +
                            "</div>" +
                            "<div class=\"continue-progress\"><span style=\"width:" + entry.progress + "%\"></span></div>" +
                            "<div class=\"continue-meta\">" +
                                "<span>" + entry.progress + "% complete</span>" +
                                "<span>" + window.LuReadingProgress.timeAgo(entry.updatedAt) + "</span>" +
                            "</div>" +
                            "<div class=\"continue-actions\">" +
                                "<a href=\"" + window.LuReadingProgress.buildReaderUrl(contextPath, entry) + "\">Resume</a>" +
                                "<button type=\"button\" data-book-id=\"" + entry.bookId + "\">Remove</button>" +
                            "</div>" +
                        "</div>";
                    row.appendChild(item);
                });

                Array.prototype.slice.call(row.querySelectorAll("button[data-book-id]")).forEach(function (button) {
                    button.addEventListener("click", function () {
                        var bookId = button.getAttribute("data-book-id");
                        window.LuReadingProgress.removeEntry(userKey, bookId);
                        renderCards();
                    });
                });
            }

            renderCards();
            window.addEventListener("storage", renderCards);
            window.addEventListener("pageshow", renderCards);
        })();
    </script>
</body>
</html>
