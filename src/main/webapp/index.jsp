<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LU Librisync | Landing</title>
    <style>
        :root {
            --green-900: #0b7b2f;
            --green-800: #12913a;
            --green-700: #20b64d;
            --green-100: #e7f8eb;
            --green-050: #f4fcf6;
            --text-900: #1f2c22;
            --text-700: #5d7065;
            --line: #d8e6db;
            --bg: #edf5ef;
            --panel: #f4fbf6;
            --white: #ffffff;
            --shadow: 0 24px 60px rgba(11, 123, 47, 0.14);
            --radius-xl: 24px;
            --radius-lg: 16px;
            --hero-image: url('<%= contextPath %>/assets/images/library-hero-placeholder.svg');
        }

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            min-height: 100vh;
            font-family: "Poppins", "Segoe UI", Tahoma, sans-serif;
            color: var(--text-900);
            background:
                radial-gradient(circle at top left, rgba(32, 182, 77, 0.12), transparent 28%),
                linear-gradient(180deg, #f7fbf8 0%, var(--bg) 100%);
        }

        a {
            color: inherit;
            text-decoration: none;
        }

        .landing-shell {
            width: 100%;
            min-height: 100vh;
            background: var(--white);
        }

        .hero-stage {
            position: relative;
            min-height: 74vh;
            isolation: isolate;
            overflow: hidden;
            border-bottom: 1px solid var(--line);
        }

        .site-nav {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            z-index: 4;
            min-height: 72px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 14px;
            padding: 14px 26px;
            background: linear-gradient(135deg, rgba(11, 123, 47, 0.95), rgba(18, 145, 58, 0.92));
            border-bottom: 1px solid rgba(255, 255, 255, 0.18);
        }

        .nav-left {
            display: inline-flex;
            align-items: center;
            gap: 12px;
            color: var(--white);
            font-weight: 800;
            letter-spacing: 0.02em;
        }

        .nav-logo {
            width: 36px;
            height: 36px;
            border-radius: 11px;
            background: rgba(255, 255, 255, 0.16);
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 0.86rem;
            font-weight: 800;
        }

        .nav-right {
            display: inline-flex;
            align-items: center;
            gap: 10px;
        }

        .hero-image {
            position: absolute;
            inset: 0;
            background-image: var(--hero-image);
            background-size: cover;
            background-position: center;
            background-color: #080b11;
            transform: scale(1.015);
            z-index: 1;
        }

        .hero-image::after {
            content: "";
            position: absolute;
            inset: 0;
            background: linear-gradient(90deg, rgba(8, 11, 16, 0.08) 0%, rgba(8, 11, 16, 0.28) 100%);
        }

        .content-blob {
            position: relative;
            z-index: 2;
            width: min(58%, 690px);
            min-height: 74vh;
            padding: 108px 56px 42px 54px;
            background: var(--panel);
            border-radius: 0 62% 58% 0 / 0 68% 62% 0;
            border-right: 1px solid rgba(11, 123, 47, 0.12);
        }

        .brand {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 16px;
            color: var(--green-900);
            font-weight: 800;
            letter-spacing: 0.02em;
        }

        .brand-mark {
            width: 34px;
            height: 34px;
            border-radius: 11px;
            color: var(--white);
            background: linear-gradient(135deg, var(--green-900), var(--green-700));
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 0.86rem;
            font-weight: 800;
        }

        .content-blob h1 {
            margin: 0;
            font-size: clamp(2.25rem, 5vw, 3.5rem);
            line-height: 1.02;
            letter-spacing: -0.03em;
            color: var(--green-900);
        }

        .content-blob p {
            margin: 18px 0 0;
            max-width: 370px;
            color: var(--text-700);
            font-size: 1.01rem;
            line-height: 1.65;
        }

        .hero-actions {
            margin-top: 28px;
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }

        .btn,
        .btn-outline {
            min-height: 44px;
            border-radius: 999px;
            padding: 0 20px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 0.9rem;
            font-weight: 700;
            transition: 0.2s ease;
        }

        .btn {
            color: var(--white);
            background: linear-gradient(135deg, var(--green-900), var(--green-700));
            box-shadow: 0 12px 20px rgba(11, 123, 47, 0.24);
        }

        .btn:hover {
            transform: translateY(-1px);
        }

        .btn-outline {
            color: var(--green-900);
            border: 1px solid rgba(11, 123, 47, 0.26);
            background: rgba(255, 255, 255, 0.72);
        }

        .btn-outline:hover {
            background: var(--green-050);
        }

        .slider-dots {
            margin-top: 26px;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: rgba(11, 123, 47, 0.25);
        }

        .dot.active {
            background: var(--green-900);
        }

        .placeholder-note {
            margin-top: 18px;
            padding: 10px 12px;
            border-radius: 10px;
            background: rgba(11, 123, 47, 0.08);
            border: 1px dashed rgba(11, 123, 47, 0.24);
            color: #356047;
            font-size: 0.78rem;
            line-height: 1.45;
            max-width: 390px;
        }

        .placeholder-note code {
            font-family: Consolas, Monaco, monospace;
            background: rgba(255, 255, 255, 0.8);
            padding: 2px 6px;
            border-radius: 6px;
        }

        .feature-zone {
            padding: 28px 28px 34px;
            background: #f8fbf9;
        }

        .feature-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 14px;
            margin-bottom: 14px;
        }

        .feature-head h2 {
            margin: 0;
            font-size: 1.05rem;
            color: #234633;
            letter-spacing: 0.02em;
        }

        .feature-head p {
            margin: 0;
            color: var(--text-700);
            font-size: 0.92rem;
        }

        .feature-carousel {
            position: relative;
            border-radius: var(--radius-xl);
            min-height: 170px;
            border: 1px solid var(--line);
            background: var(--white);
            box-shadow: 0 12px 30px rgba(11, 123, 47, 0.08);
            overflow: hidden;
        }

        .feature-slide {
            position: absolute;
            inset: 0;
            padding: 24px 22px;
            opacity: 0;
            transform: translateX(18px);
            transition: opacity 0.38s ease, transform 0.38s ease;
            display: grid;
            grid-template-columns: auto 1fr auto;
            align-items: center;
            gap: 16px;
            pointer-events: none;
        }

        .feature-slide.is-active {
            opacity: 1;
            transform: translateX(0);
            pointer-events: auto;
        }

        .feature-icon {
            width: 52px;
            height: 52px;
            border-radius: 14px;
            background: linear-gradient(135deg, var(--green-900), var(--green-700));
            color: var(--white);
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2rem;
            font-weight: 700;
        }

        .feature-copy strong {
            display: block;
            margin-bottom: 4px;
            color: var(--green-900);
            font-size: 1rem;
        }

        .feature-copy span {
            color: var(--text-700);
            line-height: 1.5;
            font-size: 0.93rem;
        }

        .feature-link {
            min-height: 40px;
            padding: 0 16px;
            border-radius: 999px;
            color: var(--white);
            background: linear-gradient(135deg, var(--green-900), var(--green-700));
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 0.86rem;
            font-weight: 700;
            white-space: nowrap;
        }

        .carousel-dots {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            margin-top: 14px;
        }

        .carousel-dot {
            width: 9px;
            height: 9px;
            border: none;
            border-radius: 50%;
            background: rgba(11, 123, 47, 0.24);
            cursor: pointer;
            padding: 0;
        }

        .carousel-dot.is-active {
            background: var(--green-900);
        }

        @media (max-width: 1080px) {
            .content-blob {
                width: min(64%, 600px);
                padding: 94px 42px 32px 42px;
            }
        }

        @media (max-width: 900px) {
            .hero-stage {
                min-height: auto;
            }

            .hero-image {
                position: relative;
                min-height: 320px;
            }

            .content-blob {
                width: 100%;
                min-height: 0;
                border-radius: 0;
                padding: 88px 22px 24px;
                border-right: none;
                border-top: 1px solid var(--line);
            }

            .content-blob p {
                max-width: none;
            }

            .site-nav {
                min-height: 62px;
                padding: 10px 14px;
            }

            .feature-zone {
                padding: 18px 14px 22px;
            }

            .feature-slide {
                grid-template-columns: 1fr;
                align-content: center;
                justify-items: start;
                padding: 20px 16px;
            }

            .feature-link {
                margin-top: 4px;
            }
        }
    </style>
</head>
<body>
    <div class="landing-shell">
        <section class="hero-stage">
            <header class="site-nav">
                <a class="nav-left" href="<%= contextPath %>/index.jsp">
                    <span class="nav-logo">LU</span>
                    <span>Librisync</span>
                </a>
                <div class="nav-right">
                    <a class="btn-outline" href="<%= contextPath %>/views/auth/login.jsp">Login</a>
                    <a class="btn" href="<%= contextPath %>/views/auth/register.jsp">Create Account</a>
                </div>
            </header>

            <div class="hero-image" aria-hidden="true"></div>

            <div class="content-blob">
                <div class="brand">
                    <span class="brand-mark">LU</span>
                    <span>Librisync</span>
                </div>

                <h1>Comprehensive<br>Library Portal</h1>
                <p>Access books, manage borrowings, and handle reservations in one user-centered system for LU community.</p>

                <div class="hero-actions">
                    <a class="btn" href="<%= contextPath %>/views/auth/login.jsp">Login</a>
                    <a class="btn-outline" href="<%= contextPath %>/views/auth/register.jsp">Create Account</a>
                </div>

                <div class="slider-dots" aria-hidden="true">
                    <span class="dot active"></span>
                    <span class="dot"></span>
                    <span class="dot"></span>
                </div>

                <div class="placeholder-note">
                    Background image placeholder file:
                    <code>/assets/images/library-hero-placeholder.svg</code><br>
                    Replace this file anytime with your final custom image.
                </div>
            </div>
        </section>

        <section class="feature-zone" id="library">
            <div class="feature-head">
                <h2>Library Features</h2>
                <p>Auto slider view of key system functions</p>
            </div>

            <div class="feature-carousel" data-feature-carousel>
                <article class="feature-slide is-active">
                    <span class="feature-icon">&#128214;</span>
                    <div class="feature-copy">
                        <strong>Book Discovery</strong>
                        <span>Browse titles, check availability, and find your next read quickly.</span>
                    </div>
                    <a class="feature-link" href="<%= contextPath %>/views/auth/login.jsp">Open Login</a>
                </article>

                <article class="feature-slide">
                    <span class="feature-icon">&#128218;</span>
                    <div class="feature-copy">
                        <strong>Borrow & Track</strong>
                        <span>View borrowed books and keep your account activity organized.</span>
                    </div>
                    <a class="feature-link" href="<%= contextPath %>/views/auth/login.jsp">Go to Portal</a>
                </article>

                <article class="feature-slide">
                    <span class="feature-icon">&#128197;</span>
                    <div class="feature-copy">
                        <strong>Reservations</strong>
                        <span>Queue for unavailable titles and monitor request status updates.</span>
                    </div>
                    <a class="feature-link" href="<%= contextPath %>/views/auth/login.jsp">Check Access</a>
                </article>

                <article class="feature-slide">
                    <span class="feature-icon">&#128100;</span>
                    <div class="feature-copy">
                        <strong>Profile & Account</strong>
                        <span>Manage your account details and recover access anytime.</span>
                    </div>
                    <a class="feature-link" id="support" href="<%= contextPath %>/views/auth/login.jsp">Manage Account</a>
                </article>
            </div>

            <div class="carousel-dots" data-feature-dots>
                <button class="carousel-dot is-active" type="button" aria-label="Feature 1"></button>
                <button class="carousel-dot" type="button" aria-label="Feature 2"></button>
                <button class="carousel-dot" type="button" aria-label="Feature 3"></button>
                <button class="carousel-dot" type="button" aria-label="Feature 4"></button>
            </div>
        </section>
    </div>

    <script>
        (function () {
            var carousel = document.querySelector("[data-feature-carousel]");
            var slides = carousel ? carousel.querySelectorAll(".feature-slide") : [];
            var dotsWrap = document.querySelector("[data-feature-dots]");
            var dots = dotsWrap ? dotsWrap.querySelectorAll(".carousel-dot") : [];
            var index = 0;
            var timerId;
            var delay = 3500;

            if (!slides.length || slides.length !== dots.length) {
                return;
            }

            function showSlide(nextIndex) {
                index = (nextIndex + slides.length) % slides.length;
                for (var i = 0; i < slides.length; i++) {
                    slides[i].classList.toggle("is-active", i === index);
                    dots[i].classList.toggle("is-active", i === index);
                }
            }

            function play() {
                timerId = window.setInterval(function () {
                    showSlide(index + 1);
                }, delay);
            }

            function restart() {
                window.clearInterval(timerId);
                play();
            }

            for (var i = 0; i < dots.length; i++) {
                (function (dotIndex) {
                    dots[dotIndex].addEventListener("click", function () {
                        showSlide(dotIndex);
                        restart();
                    });
                })(i);
            }

            carousel.addEventListener("mouseenter", function () {
                window.clearInterval(timerId);
            });

            carousel.addEventListener("mouseleave", function () {
                restart();
            });

            play();
        })();
    </script>
</body>
</html>
