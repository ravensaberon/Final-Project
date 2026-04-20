(function () {
    function clampWidth(rawValue) {
        var parsed = Number(rawValue);
        if (!isFinite(parsed)) {
            return 0;
        }
        return Math.max(0, Math.min(100, parsed));
    }

    function applyProgressWidths() {
        var items = document.querySelectorAll("[data-progress-width]");
        items.forEach(function (item) {
            item.style.width = clampWidth(item.getAttribute("data-progress-width")) + "%";
        });
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", applyProgressWidths);
        return;
    }

    applyProgressWidths();
})();
