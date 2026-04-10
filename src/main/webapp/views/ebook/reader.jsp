<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
        return;
    }

    String contextPath = request.getContextPath();
    String userName = String.valueOf(session.getAttribute("user"));
    String userEmail = String.valueOf(session.getAttribute("userEmail"));
    if (userEmail == null || userEmail.trim().isEmpty() || "null".equalsIgnoreCase(userEmail.trim())) {
        userEmail = userName.toLowerCase().replace(" ", ".");
    }

    String bookId = request.getParameter("bookId");
    String title = request.getParameter("title");
    String author = request.getParameter("author");
    String isbn = request.getParameter("isbn");
    String chapter = request.getParameter("chapter");
    String cover = request.getParameter("cover");
    String progress = request.getParameter("progress");

    if (bookId == null || bookId.trim().isEmpty()) {
        bookId = "clean-code";
    }
    if (title == null || title.trim().isEmpty()) {
        title = "Clean Code";
    }
    if (author == null || author.trim().isEmpty()) {
        author = "Robert C. Martin";
    }
    if (isbn == null || isbn.trim().isEmpty()) {
        isbn = "9780132350884";
    }
    if (chapter == null || chapter.trim().isEmpty()) {
        chapter = "Chapter 3 - Meaningful Names";
    }
    if (cover == null || cover.trim().isEmpty()) {
        cover = "emerald";
    }
    if (!"emerald".equals(cover) && !"olive".equals(cover) && !"teal".equals(cover)) {
        cover = "emerald";
    }
    if (progress == null || progress.trim().isEmpty()) {
        progress = "24";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Digital Reader | LU Librisync</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/librisync.css">
    <style>
        :root {
            --reader-bg: linear-gradient(180deg, #f4fbf5 0%, #e4f1e7 100%);
            --reader-surface: rgba(255, 255, 255, 0.94);
            --reader-line: rgba(32, 112, 58, 0.12);
            --reader-muted: #5f7667;
            --reader-text: #193025;
            --reader-accent: #0f7f34;
            --reader-accent-strong: #0a6428;
            --reader-shadow: 0 22px 44px rgba(18, 95, 44, 0.12);
        }

        body {
            margin: 0;
            min-height: 100vh;
            background:
                radial-gradient(circle at top left, rgba(32, 182, 77, 0.16), transparent 28%),
                radial-gradient(circle at bottom right, rgba(11, 123, 47, 0.12), transparent 30%),
                var(--reader-bg);
            color: var(--reader-text);
            font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
        }

        .reader-shell {
            width: min(1360px, calc(100% - 32px));
            margin: 20px auto;
            display: grid;
            gap: 18px;
        }

        .reader-topbar,
        .reader-stage,
        .reader-sidebar {
            background: var(--reader-surface);
            border: 1px solid var(--reader-line);
            border-radius: 26px;
            box-shadow: var(--reader-shadow);
            backdrop-filter: blur(12px);
        }

        .reader-topbar {
            padding: 18px 22px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 14px;
            flex-wrap: wrap;
        }

        .reader-topbar small,
        .reader-meta p,
        .reader-sidebar p,
        .reader-note,
        .status-chip,
        .reader-copy,
        .section-card p {
            color: var(--reader-muted);
        }

        .reader-links {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }

        .reader-links a,
        .reader-links button,
        .reader-actions button {
            border: 0;
            cursor: pointer;
            font: inherit;
        }

        .reader-grid {
            display: grid;
            grid-template-columns: minmax(0, 1.45fr) minmax(320px, 0.7fr);
            gap: 18px;
        }

        .reader-stage {
            padding: 24px;
        }

        .reader-hero {
            display: grid;
            grid-template-columns: 220px minmax(0, 1fr);
            gap: 22px;
            margin-bottom: 22px;
        }

        .cover-card {
            min-height: 300px;
            border-radius: 24px;
            padding: 22px;
            color: #f5fff7;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            box-shadow: 0 18px 36px rgba(18, 95, 44, 0.18);
        }

        .cover-card.emerald {
            background: linear-gradient(160deg, #0d5f2d 0%, #14a33f 55%, #65d68c 100%);
        }

        .cover-card.olive {
            background: linear-gradient(160deg, #445b1e 0%, #78993b 55%, #c3df74 100%);
        }

        .cover-card.teal {
            background: linear-gradient(160deg, #0d4953 0%, #13828b 55%, #72d6dc 100%);
        }

        .cover-kicker {
            display: inline-flex;
            align-items: center;
            align-self: flex-start;
            padding: 8px 12px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.14);
            font-size: 0.82rem;
            font-weight: 700;
            letter-spacing: 0.04em;
            text-transform: uppercase;
        }

        .cover-card h1 {
            margin: 0;
            font-size: 2rem;
            line-height: 1.04;
        }

        .cover-card p {
            margin: 10px 0 0;
            color: rgba(245, 255, 247, 0.82);
            line-height: 1.55;
        }

        .reader-meta h2 {
            margin: 0 0 8px;
            font-size: clamp(2rem, 3vw, 2.8rem);
            line-height: 1.06;
        }

        .meta-line {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
            margin-bottom: 14px;
        }

        .status-chip {
            display: inline-flex;
            align-items: center;
            padding: 7px 12px;
            border-radius: 999px;
            background: rgba(15, 127, 52, 0.1);
            color: var(--reader-accent-strong);
            font-size: 0.84rem;
            font-weight: 700;
        }

        .progress-panel {
            padding: 18px;
            border-radius: 20px;
            background: linear-gradient(180deg, rgba(243, 252, 245, 0.94), rgba(232, 246, 236, 0.94));
            border: 1px solid rgba(32, 112, 58, 0.12);
            margin-top: 18px;
        }

        .progress-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            flex-wrap: wrap;
            margin-bottom: 14px;
        }

        .progress-header strong {
            font-size: 1rem;
        }

        .progress-track {
            width: 100%;
            height: 10px;
            border-radius: 999px;
            background: rgba(15, 127, 52, 0.1);
            overflow: hidden;
            margin-bottom: 14px;
        }

        .progress-fill {
            height: 100%;
            width: 0;
            border-radius: inherit;
            background: linear-gradient(90deg, #0f7f34 0%, #39c65f 100%);
            transition: width 0.2s ease;
        }

        .progress-range {
            width: 100%;
            accent-color: var(--reader-accent);
        }

        .reader-actions {
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
            margin-top: 16px;
        }

        .reader-actions button,
        .reader-links a,
        .reader-links button {
            min-height: 44px;
            padding: 0 16px;
            border-radius: 14px;
            font-weight: 700;
            text-decoration: none;
            transition: transform 0.2s ease, box-shadow 0.2s ease, background 0.2s ease;
        }

        .button-solid {
            background: var(--reader-accent);
            color: #fff;
            box-shadow: 0 14px 26px rgba(10, 100, 40, 0.2);
        }

        .button-solid:hover {
            background: var(--reader-accent-strong);
            transform: translateY(-2px);
        }

        .button-soft {
            background: rgba(15, 127, 52, 0.1);
            color: var(--reader-accent-strong);
        }

        .button-soft:hover {
            transform: translateY(-2px);
        }

        .button-outline {
            background: #fff;
            color: var(--reader-text);
            border: 1px solid rgba(32, 112, 58, 0.16);
        }

        .reader-columns {
            display: grid;
            grid-template-columns: minmax(0, 1fr) 260px;
            gap: 18px;
            margin-top: 22px;
        }

        .reader-copy {
            padding: 22px;
            border-radius: 22px;
            background: #fff;
            border: 1px solid rgba(32, 112, 58, 0.12);
            line-height: 1.75;
            font-size: 1rem;
        }

        .reader-copy h3 {
            margin: 0 0 12px;
            color: var(--reader-text);
            font-size: 1.1rem;
        }

        .reader-copy p {
            margin: 0 0 14px;
        }

        .section-stack {
            display: grid;
            gap: 14px;
        }

        .section-card {
            padding: 16px;
            border-radius: 18px;
            background: #fff;
            border: 1px solid rgba(32, 112, 58, 0.12);
            transition: border-color 0.2s ease, transform 0.2s ease, box-shadow 0.2s ease;
        }

        .section-card.active {
            border-color: rgba(15, 127, 52, 0.34);
            box-shadow: 0 14px 26px rgba(11, 123, 47, 0.08);
            transform: translateY(-1px);
        }

        .section-card strong {
            display: block;
            margin-bottom: 6px;
        }

        .reader-sidebar {
            padding: 24px;
            display: grid;
            gap: 18px;
            align-content: start;
        }

        .sidebar-block {
            padding: 18px;
            border-radius: 20px;
            background: rgba(255, 255, 255, 0.92);
            border: 1px solid rgba(32, 112, 58, 0.12);
        }

        .sidebar-block h3 {
            margin: 0 0 10px;
        }

        .sidebar-block p {
            margin: 0;
            line-height: 1.55;
        }

        .details-list {
            display: grid;
            gap: 12px;
        }

        .details-list div {
            display: grid;
            gap: 4px;
        }

        .details-list span {
            color: var(--reader-muted);
            font-size: 0.84rem;
            text-transform: uppercase;
            letter-spacing: 0.04em;
        }

        .save-status {
            font-size: 0.9rem;
            color: var(--reader-accent-strong);
            min-height: 20px;
        }

        @media (max-width: 1120px) {
            .reader-grid,
            .reader-hero,
            .reader-columns {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 760px) {
            .reader-shell {
                width: min(100%, calc(100% - 16px));
                margin: 8px auto 18px;
            }

            .reader-topbar,
            .reader-stage,
            .reader-sidebar {
                padding-left: 18px;
                padding-right: 18px;
            }

            .reader-stage,
            .reader-sidebar {
                padding-top: 20px;
                padding-bottom: 20px;
            }
        }
    </style>
</head>
<body data-user-key="<%= userEmail %>" data-context-path="<%= contextPath %>">
    <div class="reader-shell">
        <header class="reader-topbar">
            <div>
                <strong>Digital Reader</strong><br>
                <small>Welcome, <%= userName %>. Your reading progress is saved automatically for this account.</small>
            </div>
            <div class="reader-links">
                <a class="button-outline" href="<%= contextPath %>/student/books">Back to Books</a>
                <a class="button-outline" href="<%= contextPath %>/student/dashboard">Dashboard</a>
            </div>
        </header>

        <section class="reader-grid">
            <div class="reader-stage">
                <div class="reader-hero">
                    <article class="cover-card <%= cover %>" id="coverCard">
                        <span class="cover-kicker">Digital Access</span>
                        <div>
                            <h1 id="coverTitle"><%= title %></h1>
                            <p id="coverAuthor"><%= author %></p>
                        </div>
                    </article>

                    <div class="reader-meta">
                        <div class="meta-line">
                            <span class="status-chip" id="chapterBadge"><%= chapter %></span>
                            <span class="status-chip" id="minutesBadge">Estimated 24 min left</span>
                        </div>
                        <h2 id="metaTitle"><%= title %></h2>
                        <p id="metaAuthor"><strong>Author:</strong> <%= author %></p>
                        <p><strong>ISBN:</strong> <span id="metaIsbn"><%= isbn %></span></p>
                        <p class="reader-note">
                            This reader is ready for your digital library flow. Move the progress slider as you read,
                            and your dashboard will remember where to continue next time.
                        </p>

                        <div class="progress-panel">
                            <div class="progress-header">
                                <strong id="progressLabel">Reading progress</strong>
                                <span class="status-chip" id="progressPercent">0% done</span>
                            </div>
                            <div class="progress-track">
                                <div class="progress-fill" id="progressFill"></div>
                            </div>
                            <input class="progress-range" id="progressRange" type="range" min="0" max="100" value="<%= progress %>">

                            <div class="reader-actions">
                                <button class="button-solid" id="saveProgressButton" type="button">Save Progress</button>
                                <button class="button-soft" id="nextSectionButton" type="button">Next Section</button>
                                <button class="button-outline" id="markFinishedButton" type="button">Mark as Finished</button>
                            </div>
                            <div class="save-status" id="saveStatus">Ready to save your current progress.</div>
                        </div>
                    </div>
                </div>

                <div class="reader-columns">
                    <article class="reader-copy">
                        <h3 id="readerSectionHeading">Current section</h3>
                        <p>
                            Clean interfaces and student-friendly flow matter here too. This digital reader is built to
                            feel simple, focused, and easy to return to after a break, much like the continue-reading
                            experience students are used to in modern reading apps.
                        </p>
                        <p>
                            As you move through a title, the dashboard will highlight your most recent digital reads,
                            show your saved percentage, and give you a quick resume action. That means fewer clicks
                            every time you return to LU Librisync.
                        </p>
                        <p>
                            Once your PDF or e-book engine is integrated later, the same resume logic can be connected
                            to real page numbers, chapter positions, and recent reading sessions.
                        </p>
                    </article>

                    <div class="section-stack" id="sectionStack"></div>
                </div>
            </div>

            <aside class="reader-sidebar">
                <section class="sidebar-block">
                    <h3>Book Details</h3>
                    <div class="details-list">
                        <div>
                            <span>Title</span>
                            <strong id="detailTitle"><%= title %></strong>
                        </div>
                        <div>
                            <span>Author</span>
                            <strong id="detailAuthor"><%= author %></strong>
                        </div>
                        <div>
                            <span>ISBN</span>
                            <strong id="detailIsbn"><%= isbn %></strong>
                        </div>
                        <div>
                            <span>Access Type</span>
                            <strong>Digital Reader</strong>
                        </div>
                    </div>
                </section>

                <section class="sidebar-block">
                    <h3>Resume-friendly Flow</h3>
                    <p>
                        Every save updates your dashboard's Continue Reading row, so students can jump straight back
                        into the same title without searching again.
                    </p>
                </section>

                <section class="sidebar-block">
                    <h3>What happens when you finish?</h3>
                    <p>
                        Marking a book as finished removes it from Continue Reading so the dashboard stays focused on
                        books you are still actively reading.
                    </p>
                </section>
            </aside>
        </section>
    </div>

    <script src="<%= contextPath %>/assets/js/reading-progress.js"></script>
    <script>
        (function () {
            var userKey = document.body.getAttribute("data-user-key");
            var contextPath = document.body.getAttribute("data-context-path");
            var progressRange = document.getElementById("progressRange");
            var progressFill = document.getElementById("progressFill");
            var progressPercent = document.getElementById("progressPercent");
            var progressLabel = document.getElementById("progressLabel");
            var chapterBadge = document.getElementById("chapterBadge");
            var minutesBadge = document.getElementById("minutesBadge");
            var saveStatus = document.getElementById("saveStatus");
            var sectionStack = document.getElementById("sectionStack");
            var saveProgressButton = document.getElementById("saveProgressButton");
            var nextSectionButton = document.getElementById("nextSectionButton");
            var markFinishedButton = document.getElementById("markFinishedButton");
            var book = {
                bookId: "<%= bookId %>",
                title: "<%= title %>",
                author: "<%= author %>",
                isbn: "<%= isbn %>",
                chapterLabel: "<%= chapter %>",
                coverTone: "<%= cover %>",
                progress: Number("<%= progress %>") || 0
            };

            if (!window.LuReadingProgress) {
                return;
            }

            var chapterMap = {
                "clean-code": [
                    "Chapter 1 - Clean Code",
                    "Chapter 2 - Meaningful Names",
                    "Chapter 3 - Functions",
                    "Chapter 4 - Comments",
                    "Chapter 5 - Formatting"
                ],
                "the-alchemist": [
                    "Part 1 - The Shepherd's Dream",
                    "Part 2 - Tangier",
                    "Part 3 - The Crystal Merchant",
                    "Part 4 - The Englishman",
                    "Part 5 - The Desert Journey"
                ]
            };

            var defaultSections = [
                "Section 1 - Introduction",
                "Section 2 - Core Ideas",
                "Section 3 - Applied Reading",
                "Section 4 - Reflection",
                "Section 5 - Wrap-up"
            ];

            var sectionList = chapterMap[book.bookId] || defaultSections;
            var savedEntry = window.LuReadingProgress
                .getContinueReading(userKey)
                .find(function (entry) {
                    return entry.bookId === book.bookId;
                });

            if (savedEntry) {
                book.progress = savedEntry.progress;
                book.chapterLabel = savedEntry.chapterLabel;
                if (savedEntry.coverTone) {
                    book.coverTone = savedEntry.coverTone;
                }
            }

            function clamp(value) {
                return Math.max(0, Math.min(100, Math.round(Number(value) || 0)));
            }

            function getSectionIndex(progress) {
                if (!sectionList.length) {
                    return 0;
                }

                return Math.min(sectionList.length - 1, Math.floor((clamp(progress) / 100) * sectionList.length));
            }

            function getChapterLabel(progress) {
                if (book.progress >= 100) {
                    return "Finished";
                }

                return sectionList[getSectionIndex(progress)] || sectionList[0];
            }

            function renderSectionCards(activeIndex) {
                sectionStack.innerHTML = "";

                sectionList.forEach(function (sectionName, index) {
                    var card = document.createElement("article");
                    card.className = "section-card" + (index === activeIndex ? " active" : "");
                    card.innerHTML =
                        "<strong>" + sectionName + "</strong>" +
                        "<p>" + (index < activeIndex
                            ? "Already covered in your recent reading sessions."
                            : index === activeIndex
                                ? "This is your current resume point."
                                : "Up next as you keep reading.") + "</p>";
                    sectionStack.appendChild(card);
                });
            }

            function updateUi() {
                var progress = clamp(progressRange.value);
                book.progress = progress;
                book.chapterLabel = getChapterLabel(progress);

                progressFill.style.width = progress + "%";
                progressPercent.textContent = progress + "% done";
                progressLabel.textContent = progress >= 100 ? "Reading completed" : "Reading progress";
                chapterBadge.textContent = book.chapterLabel;
                minutesBadge.textContent = progress >= 100
                    ? "Completed"
                    : "Estimated " + Math.max(4, Math.round((100 - progress) / 10) * 4) + " min left";
                document.getElementById("readerSectionHeading").textContent = book.chapterLabel;

                renderSectionCards(getSectionIndex(progress));
            }

            function saveProgress(message) {
                if (book.progress >= 100) {
                    window.LuReadingProgress.removeEntry(userKey, book.bookId);
                    saveStatus.textContent = message || "Marked as finished and removed from Continue Reading.";
                    return;
                }

                window.LuReadingProgress.upsertEntry(userKey, book);
                saveStatus.textContent = message || "Progress saved. You can continue this from the dashboard.";
            }

            progressRange.addEventListener("input", function () {
                updateUi();
                saveStatus.textContent = "Adjusting your reading progress...";
            });

            saveProgressButton.addEventListener("click", function () {
                saveProgress("Progress saved to your Continue Reading row.");
            });

            nextSectionButton.addEventListener("click", function () {
                progressRange.value = String(Math.min(100, clamp(progressRange.value) + 18));
                updateUi();
                saveProgress("Moved forward and updated your Continue Reading card.");
            });

            markFinishedButton.addEventListener("click", function () {
                progressRange.value = "100";
                updateUi();
                saveProgress("Book marked as finished.");
            });

            window.addEventListener("beforeunload", function () {
                if (book.progress >= 100) {
                    window.LuReadingProgress.removeEntry(userKey, book.bookId);
                } else {
                    window.LuReadingProgress.upsertEntry(userKey, book);
                }
            });

            updateUi();
            saveProgress("Reading session loaded. Your resume point is ready.");
        })();
    </script>
</body>
</html>
