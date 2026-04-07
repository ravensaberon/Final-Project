(function (global) {
    "use strict";

    var STORAGE_PREFIX = "lu-librisync-reading-progress::";
    var MAX_ENTRIES = 8;

    function getStorageKey(userKey) {
        return STORAGE_PREFIX + String(userKey || "guest");
    }

    function clampProgress(value) {
        var numeric = Number(value);
        if (Number.isNaN(numeric)) {
            numeric = 0;
        }

        return Math.max(0, Math.min(100, Math.round(numeric)));
    }

    function estimateMinutesLeft(progress) {
        var remaining = Math.max(0, 100 - progress);
        return Math.max(3, Math.round(remaining / 10) * 4);
    }

    function normalizeEntry(entry) {
        if (!entry || !entry.bookId) {
            return null;
        }

        var progress = clampProgress(entry.progress);

        return {
            bookId: String(entry.bookId),
            title: String(entry.title || "Untitled Book"),
            author: String(entry.author || "Unknown Author"),
            isbn: String(entry.isbn || ""),
            progress: progress,
            chapterLabel: String(entry.chapterLabel || "Keep reading"),
            coverTone: String(entry.coverTone || "emerald"),
            updatedAt: String(entry.updatedAt || new Date().toISOString()),
            minutesLeft: Number(entry.minutesLeft || estimateMinutesLeft(progress))
        };
    }

    function readEntries(userKey) {
        try {
            var raw = global.localStorage.getItem(getStorageKey(userKey));
            if (!raw) {
                return [];
            }

            var parsed = JSON.parse(raw);
            if (!Array.isArray(parsed)) {
                return [];
            }

            return parsed
                .map(normalizeEntry)
                .filter(Boolean)
                .sort(function (left, right) {
                    return new Date(right.updatedAt).getTime() - new Date(left.updatedAt).getTime();
                });
        } catch (error) {
            return [];
        }
    }

    function writeEntries(userKey, entries) {
        try {
            global.localStorage.setItem(getStorageKey(userKey), JSON.stringify(entries.slice(0, MAX_ENTRIES)));
        } catch (error) {
            // Ignore storage quota and privacy mode failures.
        }
    }

    function upsertEntry(userKey, entry) {
        var normalized = normalizeEntry(entry);
        if (!normalized) {
            return [];
        }

        var entries = readEntries(userKey).filter(function (item) {
            return item.bookId !== normalized.bookId;
        });

        normalized.updatedAt = new Date().toISOString();
        normalized.minutesLeft = estimateMinutesLeft(normalized.progress);
        entries.unshift(normalized);
        writeEntries(userKey, entries);
        return readEntries(userKey);
    }

    function removeEntry(userKey, bookId) {
        var entries = readEntries(userKey).filter(function (item) {
            return item.bookId !== bookId;
        });

        writeEntries(userKey, entries);
        return entries;
    }

    function buildReaderUrl(contextPath, entry) {
        var params = [
            "bookId=" + encodeURIComponent(entry.bookId),
            "title=" + encodeURIComponent(entry.title),
            "author=" + encodeURIComponent(entry.author),
            "isbn=" + encodeURIComponent(entry.isbn),
            "chapter=" + encodeURIComponent(entry.chapterLabel),
            "cover=" + encodeURIComponent(entry.coverTone),
            "progress=" + encodeURIComponent(String(entry.progress))
        ];

        return String(contextPath || "") + "/ebook/read?" + params.join("&");
    }

    function timeAgo(isoValue) {
        var timestamp = new Date(isoValue).getTime();
        if (Number.isNaN(timestamp)) {
            return "Recently opened";
        }

        var elapsedSeconds = Math.max(1, Math.floor((Date.now() - timestamp) / 1000));
        if (elapsedSeconds < 60) {
            return "Just now";
        }

        var elapsedMinutes = Math.floor(elapsedSeconds / 60);
        if (elapsedMinutes < 60) {
            return elapsedMinutes + " min ago";
        }

        var elapsedHours = Math.floor(elapsedMinutes / 60);
        if (elapsedHours < 24) {
            return elapsedHours + " hr ago";
        }

        var elapsedDays = Math.floor(elapsedHours / 24);
        return elapsedDays + " day" + (elapsedDays === 1 ? "" : "s") + " ago";
    }

    global.LuReadingProgress = {
        getContinueReading: readEntries,
        upsertEntry: upsertEntry,
        removeEntry: removeEntry,
        buildReaderUrl: buildReaderUrl,
        timeAgo: timeAgo
    };
})(window);
