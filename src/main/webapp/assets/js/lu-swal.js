(function (window, document) {
    "use strict";

    if (window.LuSwal) {
        return;
    }

    var styleInjected = false;

    function injectStyles() {
        if (styleInjected) {
            return;
        }

        styleInjected = true;

        var style = document.createElement("style");
        style.textContent = [
            ".lu-swal-overlay{position:fixed;inset:0;background:rgba(16,40,24,.46);backdrop-filter:blur(6px);display:flex;align-items:center;justify-content:center;padding:20px;z-index:9999;animation:luSwalFadeIn .18s ease;}",
            ".lu-swal-modal{width:min(100%,420px);background:linear-gradient(180deg,#ffffff 0%,#f6fcf7 100%);border:1px solid rgba(32,112,58,.12);border-radius:28px;box-shadow:0 28px 56px rgba(18,95,44,.2);padding:24px;color:#1f2f24;font-family:'Segoe UI',Tahoma,Geneva,Verdana,sans-serif;}",
            ".lu-swal-icon{width:64px;height:64px;border-radius:22px;display:flex;align-items:center;justify-content:center;margin:0 auto 16px;background:linear-gradient(135deg,#0f7f34,#34bf5d);color:#fff;box-shadow:0 14px 26px rgba(15,127,52,.22);font-size:28px;font-weight:700;}",
            ".lu-swal-modal h3{margin:0 0 10px;text-align:center;font-size:1.6rem;line-height:1.12;}",
            ".lu-swal-modal p{margin:0;text-align:center;color:#5f7667;line-height:1.6;}",
            ".lu-swal-actions{display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-top:22px;}",
            ".lu-swal-button{min-height:46px;border:0;border-radius:16px;font:inherit;font-weight:700;cursor:pointer;transition:transform .18s ease,background .18s ease,box-shadow .18s ease;}",
            ".lu-swal-button:hover{transform:translateY(-1px);}",
            ".lu-swal-cancel{background:rgba(15,127,52,.08);color:#0a6428;}",
            ".lu-swal-confirm{background:#0f7f34;color:#fff;box-shadow:0 14px 24px rgba(15,127,52,.18);}",
            ".lu-swal-confirm:hover{background:#0a6428;}",
            "@media (max-width:560px){.lu-swal-actions{grid-template-columns:1fr;}}",
            "@keyframes luSwalFadeIn{from{opacity:0;transform:scale(.98);}to{opacity:1;transform:scale(1);}}"
        ].join("");

        document.head.appendChild(style);
    }

    function createModal(options) {
        injectStyles();

        var overlay = document.createElement("div");
        overlay.className = "lu-swal-overlay";
        overlay.innerHTML =
            "<div class=\"lu-swal-modal\" role=\"dialog\" aria-modal=\"true\" aria-labelledby=\"luSwalTitle\">" +
                "<div class=\"lu-swal-icon\">" + (options.iconText || "!") + "</div>" +
                "<h3 id=\"luSwalTitle\">" + options.title + "</h3>" +
                "<p>" + options.text + "</p>" +
                "<div class=\"lu-swal-actions\">" +
                    "<button type=\"button\" class=\"lu-swal-button lu-swal-cancel\">" + options.cancelText + "</button>" +
                    "<button type=\"button\" class=\"lu-swal-button lu-swal-confirm\">" + options.confirmText + "</button>" +
                "</div>" +
            "</div>";

        return overlay;
    }

    function open(options) {
        return new Promise(function (resolve) {
            var config = {
                title: options && options.title ? options.title : "Are you sure?",
                text: options && options.text ? options.text : "Please confirm this action.",
                confirmText: options && options.confirmText ? options.confirmText : "Confirm",
                cancelText: options && options.cancelText ? options.cancelText : "Cancel",
                iconText: options && options.iconText ? options.iconText : "!"
            };

            var overlay = createModal(config);
            var cancelButton = overlay.querySelector(".lu-swal-cancel");
            var confirmButton = overlay.querySelector(".lu-swal-confirm");
            var modal = overlay.querySelector(".lu-swal-modal");

            function close(result) {
                document.removeEventListener("keydown", onKeyDown);
                overlay.remove();
                resolve(result);
            }

            function onKeyDown(event) {
                if (event.key === "Escape") {
                    close(false);
                }
            }

            overlay.addEventListener("click", function (event) {
                if (event.target === overlay) {
                    close(false);
                }
            });

            modal.addEventListener("click", function (event) {
                event.stopPropagation();
            });

            cancelButton.addEventListener("click", function () {
                close(false);
            });

            confirmButton.addEventListener("click", function () {
                close(true);
            });

            document.addEventListener("keydown", onKeyDown);
            document.body.appendChild(overlay);
            confirmButton.focus();
        });
    }

    function handleTrigger(event) {
        var trigger = event.target.closest("[data-swal-confirm='true']");
        if (!trigger) {
            return;
        }

        event.preventDefault();

        open({
            title: trigger.getAttribute("data-swal-title"),
            text: trigger.getAttribute("data-swal-text"),
            confirmText: trigger.getAttribute("data-swal-confirm-text"),
            cancelText: trigger.getAttribute("data-swal-cancel-text"),
            iconText: trigger.getAttribute("data-swal-icon")
        }).then(function (confirmed) {
            if (!confirmed) {
                return;
            }

            if (trigger.tagName === "A" && trigger.href) {
                window.location.href = trigger.href;
                return;
            }

            if (trigger.tagName === "FORM") {
                trigger.submit();
                return;
            }

            if (trigger.form) {
                trigger.form.submit();
            }
        });
    }

    document.addEventListener("click", handleTrigger);

    window.LuSwal = {
        fire: open
    };
})(window, document);
