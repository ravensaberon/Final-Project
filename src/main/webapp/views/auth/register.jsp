<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String error = request.getParameter("error");
    String firstNameValue = request.getParameter("firstName");
    String middleNameValue = request.getParameter("middleName");
    String lastNameValue = request.getParameter("lastName");
    String contactNumberValue = request.getParameter("contactNumber");
    String birthDateValue = request.getParameter("birthDate");
    String emailValue = request.getParameter("email");

    if (firstNameValue == null) {
        firstNameValue = "";
    }
    if (middleNameValue == null) {
        middleNameValue = "";
    }
    if (lastNameValue == null) {
        lastNameValue = "";
    }
    if (contactNumberValue == null) {
        contactNumberValue = "";
    }
    if (birthDateValue == null) {
        birthDateValue = "";
    }
    if (emailValue == null) {
        emailValue = "";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Account | LU Librisync</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/librisync.css">
    <style>
        :root {
            --bg: #eef6f0;
            --surface: rgba(255, 255, 255, 0.96);
            --surface-strong: #ffffff;
            --text: #1f2f24;
            --muted: #5f7667;
            --line: rgba(32, 112, 58, 0.16);
            --accent: #0f7f34;
            --accent-dark: #0a6428;
            --accent-soft: rgba(15, 127, 52, 0.12);
            --success: #2f6b43;
            --success-soft: #e2f1e7;
            --warning: #8d5c09;
            --warning-soft: #f8e7c5;
            --danger: #b6453d;
            --danger-soft: #f9e1dd;
            --shadow: 0 24px 48px rgba(18, 95, 44, 0.12);
        }

        body {
            background:
                radial-gradient(circle at top left, rgba(32, 182, 77, 0.18), transparent 30%),
                radial-gradient(circle at bottom right, rgba(11, 123, 47, 0.14), transparent 28%),
                linear-gradient(180deg, #f8fcf8 0%, #e8f2ea 100%);
        }

        .hero-panel {
            background:
                linear-gradient(180deg, rgba(11, 123, 47, 0.96), rgba(18, 145, 58, 0.92)),
                #0e7b32;
            color: #f4fff7;
        }

        .hero-panel .brand-pill {
            background: rgba(255, 255, 255, 0.16);
        }

        .hero-panel p,
        .hero-panel li {
            color: rgba(241, 255, 245, 0.88);
        }

        .info-card {
            background: rgba(255, 255, 255, 0.12);
            border-color: rgba(225, 255, 234, 0.26);
        }

        .form-panel {
            background: linear-gradient(180deg, rgba(255, 255, 255, 0.98), rgba(246, 253, 247, 0.95));
        }

        .form-panel .form-grid {
            align-items: start;
        }

        .form-panel .form-grid .field-group {
            align-content: start;
        }

        .form-panel .field-group input[type="text"],
        .form-panel .field-group input[type="password"],
        .form-panel .field-group input[type="date"] {
            height: 52px;
        }

        .form-panel .field-help {
            min-height: 24px;
        }

        .form-panel input[readonly] {
            background: #f5faf6;
            color: #415c4c;
        }

        .field-error {
            margin: 6px 0 0;
            min-height: 18px;
            color: var(--danger);
            font-size: 0.83rem;
            line-height: 1.35;
        }

        .field-group input.input-invalid {
            border-color: rgba(182, 69, 61, 0.45);
            box-shadow: 0 0 0 3px rgba(182, 69, 61, 0.12);
        }

        .field-group input.input-valid {
            border-color: rgba(15, 127, 52, 0.42);
            box-shadow: 0 0 0 3px rgba(15, 127, 52, 0.08);
        }

        .checkbox-error {
            margin: 6px 0 0 28px;
            color: var(--danger);
            font-size: 0.83rem;
            min-height: 18px;
        }
    </style>
</head>
<body>
    <div class="page-shell hero-split">
        <section class="hero-panel">
            <div class="brand-pill">LU</div>
            <h1>Register a student account.</h1>
            <p>Create your LU Librisync student profile with complete personal details and system-generated student ID.</p>

            <ul>
                <li>Student ID format: YEAR-XXXX (example: 2026-0001)</li>
                <li>Contact number and birthday are required for student records</li>
                <li>Age is auto-calculated from your birthday</li>
            </ul>

            <div class="info-card">
                <strong>Registration Tip</strong>
                <p>Use your real details so borrowing and return records stay accurate.</p>
            </div>
        </section>

        <section class="form-panel">
            <h2>Create Account</h2>
            <p class="subtitle">Fill in the form below. Student ID will be generated automatically.</p>

            <% if ("missing".equals(error)) { %>
                <div class="alert error">Please complete all required registration fields.</div>
            <% } else if ("name".equals(error)) { %>
                <div class="alert error">Names must be at least 2 letters, no digits/symbols, and no triple repeated letters (ex: rrr or dddd).</div>
            <% } else if ("name_length".equals(error)) { %>
                <div class="alert error">Combined full name is too long. Please shorten your name entries.</div>
            <% } else if ("contact".equals(error)) { %>
                <div class="alert error">Enter a valid contact number (10 to 15 digits, optional + prefix).</div>
            <% } else if ("birth_date".equals(error)) { %>
                <div class="alert error">Enter a valid birth date.</div>
            <% } else if ("birth_date_future".equals(error)) { %>
                <div class="alert error">Birth date cannot be in the future.</div>
            <% } else if ("birth_date_age".equals(error)) { %>
                <div class="alert error">Computed age is out of allowed range. Please verify birth date.</div>
            <% } else if ("email".equals(error)) { %>
                <div class="alert error">Use a valid lowercase email and supported provider domain (example: gmail.com, outlook.com, yahoo.com, or school .edu/.edu.ph).</div>
            <% } else if ("password_length".equals(error)) { %>
                <div class="alert error">Your password must be at least 12 characters long.</div>
            <% } else if ("password_format".equals(error)) { %>
                <div class="alert error">Use at least one uppercase, one lowercase, one number, and one special character.</div>
            <% } else if ("password_common".equals(error)) { %>
                <div class="alert error">That password is too common. Please choose a stronger password.</div>
            <% } else if ("password_repeated".equals(error)) { %>
                <div class="alert error">Avoid repeated characters (like AAAA or 1111) in your password.</div>
            <% } else if ("password_personal".equals(error)) { %>
                <div class="alert error">Password must not contain your personal details (name, email, contact, or birth date).</div>
            <% } else if ("password_mismatch".equals(error)) { %>
                <div class="alert error">Password and confirm password do not match.</div>
            <% } else if ("email_exists".equals(error)) { %>
                <div class="alert error">That email is already registered in LU Librisync.</div>
            <% } else if ("terms".equals(error)) { %>
                <div class="alert error">Please confirm your details before submitting.</div>
            <% } else if ("server".equals(error)) { %>
                <div class="alert error">The system could not create your account right now. Please try again.</div>
            <% } %>

            <form class="form-stack" action="<%= request.getContextPath() %>/register" method="post" novalidate>
                <div class="form-grid">
                    <div class="field-group">
                        <label for="firstName">First Name</label>
                        <input id="firstName" name="firstName" type="text" value="<%= firstNameValue %>" placeholder="Enter first name" minlength="2" maxlength="50" required>
                        <p class="field-error" id="firstNameError"></p>
                    </div>

                    <div class="field-group">
                        <label for="middleName">Middle Name</label>
                        <input id="middleName" name="middleName" type="text" value="<%= middleNameValue %>" placeholder="Enter middle name (optional)" maxlength="50">
                        <p class="field-error" id="middleNameError"></p>
                    </div>
                </div>

                <div class="field-group">
                    <label for="lastName">Last Name</label>
                    <input id="lastName" name="lastName" type="text" value="<%= lastNameValue %>" placeholder="Enter last name" minlength="2" maxlength="50" required>
                    <p class="field-error" id="lastNameError"></p>
                </div>

                <div class="field-group">
                    <label for="email">Email Address</label>
                    <input id="email" name="email" type="text" value="<%= emailValue %>" placeholder="Enter your email" maxlength="120" autocomplete="email" inputmode="email" required>
                    <p class="field-error" id="emailError"></p>
                </div>

                <div class="field-group">
                    <label for="contactNumber">Contact Number</label>
                    <input id="contactNumber" name="contactNumber" type="text" value="<%= contactNumberValue %>" placeholder="Example: 0917 123 4567" maxlength="20" autocomplete="tel" inputmode="tel" required>
                    <p class="field-help">Use 10 to 15 digits. You may include + prefix.</p>
                    <p class="field-error" id="contactNumberError"></p>
                </div>

                <div class="form-grid">
                    <div class="field-group">
                        <label for="birthDate">Birthday</label>
                        <input id="birthDate" name="birthDate" type="date" value="<%= birthDateValue %>" required>
                        <p class="field-error" id="birthDateError"></p>
                    </div>

                    <div class="field-group">
                        <label for="age">Age (Auto Computed)</label>
                        <input id="age" type="text" placeholder="Auto-computed from birthday" readonly>
                    </div>
                </div>

                <div class="form-grid">
                    <div class="field-group">
                        <label for="password">Password</label>
                        <input id="password" name="password" type="password" placeholder="Create a password" maxlength="100" autocomplete="new-password" required>
                        <p class="field-help">12+ chars with uppercase, lowercase, number, and special character.</p>
                        <p class="field-error" id="passwordError"></p>
                    </div>

                    <div class="field-group">
                        <label for="confirmPassword">Confirm Password</label>
                        <input id="confirmPassword" name="confirmPassword" type="password" placeholder="Re-enter your password" maxlength="100" autocomplete="new-password" required>
                        <p class="field-error" id="confirmPasswordError"></p>
                    </div>
                </div>

                <div class="checkbox-row">
                    <input id="agree" name="agree" type="checkbox" value="yes" required>
                    <label for="agree">I confirm that the registration details above are correct and can be used for my student library account.</label>
                </div>
                <p class="checkbox-error" id="agreeError"></p>

                <button class="button" type="submit">Create Student Account</button>
            </form>

            <p class="inline-link">Already have an account? <a href="<%= request.getContextPath() %>/views/auth/login.jsp">Sign in here</a>.</p>
        </section>
    </div>

    <script>
        (function () {
            var form = document.querySelector("form");
            if (!form) {
                return;
            }

            form.setAttribute("novalidate", "novalidate");

            var firstName = document.getElementById("firstName");
            var middleName = document.getElementById("middleName");
            var lastName = document.getElementById("lastName");
            var email = document.getElementById("email");
            var contactNumber = document.getElementById("contactNumber");
            var password = document.getElementById("password");
            var confirmPassword = document.getElementById("confirmPassword");
            var birthDate = document.getElementById("birthDate");
            var age = document.getElementById("age");
            var agree = document.getElementById("agree");

            var NAME_ALLOWED_REGEX = /^[A-Za-z](?:[A-Za-z .'-]{0,48}[A-Za-z])?$/;
            var MIN_NAME_LETTERS = 2;
            var MAX_NAME_TOKEN_LENGTH = 12;
            var EMAIL_REGEX = /^[a-z0-9+_.-]+@[a-z0-9.-]+\.[a-z]{2,}$/;
            var ALLOWED_EMAIL_DOMAINS = {
                "gmail.com": true,
                "yahoo.com": true,
                "yahoo.com.ph": true,
                "outlook.com": true,
                "hotmail.com": true,
                "live.com": true,
                "icloud.com": true,
                "proton.me": true,
                "protonmail.com": true,
                "aol.com": true,
                "gmx.com": true,
                "mail.com": true
            };
            var CONTACT_REGEX = /^\+?\d{10,15}$/;
            var PASSWORD_REGEX = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z\d\s]).{12,100}$/;
            var COMMON_PASSWORDS = {
                "password": true,
                "password123": true,
                "12345678": true,
                "123456789": true,
                "qwerty123": true,
                "admin123": true,
                "welcome123": true,
                "letmein123": true,
                "iloveyou": true,
                "abc12345": true,
                "passw0rd": true,
                "student123": true,
                "adminadmin": true,
                "11111111": true,
                "12341234": true
            };

            var errors = {
                firstName: document.getElementById("firstNameError"),
                middleName: document.getElementById("middleNameError"),
                lastName: document.getElementById("lastNameError"),
                email: document.getElementById("emailError"),
                contactNumber: document.getElementById("contactNumberError"),
                birthDate: document.getElementById("birthDateError"),
                password: document.getElementById("passwordError"),
                confirmPassword: document.getElementById("confirmPasswordError"),
                agree: document.getElementById("agreeError")
            };

            function setFieldState(input, errorElement, message) {
                if (!input) {
                    return;
                }

                if (message) {
                    input.classList.add("input-invalid");
                    input.classList.remove("input-valid");
                    input.setCustomValidity(message);
                    if (errorElement) {
                        errorElement.textContent = message;
                    }
                    return;
                }

                input.setCustomValidity("");
                if (errorElement) {
                    errorElement.textContent = "";
                }

                if (input.value && !input.readOnly) {
                    input.classList.remove("input-invalid");
                    input.classList.add("input-valid");
                } else {
                    input.classList.remove("input-invalid");
                    input.classList.remove("input-valid");
                }
            }

            function normalizeToken(value) {
                return (value || "").toLowerCase().replace(/[^a-z0-9]/g, "");
            }

            function normalizeContact(value) {
                return (value || "").replace(/[ .\-()]/g, "");
            }

            function getEmailLocalPart(value) {
                var at = value.indexOf("@");
                if (at > 0) {
                    return value.substring(0, at);
                }
                return value;
            }

            function hasInvalidEmailDots(value) {
                var at = value.indexOf("@");
                if (at <= 0 || at >= value.length - 1) {
                    return true;
                }

                var local = value.substring(0, at);
                var domain = value.substring(at + 1);

                return local.startsWith(".")
                    || local.endsWith(".")
                    || local.indexOf("..") !== -1
                    || domain.startsWith(".")
                    || domain.endsWith(".")
                    || domain.indexOf("..") !== -1;
            }

            function getEmailDomain(value) {
                var at = value.indexOf("@");
                if (at <= 0 || at >= value.length - 1) {
                    return "";
                }
                return value.substring(at + 1);
            }

            function isAllowedEmailDomain(domain) {
                if (!domain) {
                    return false;
                }

                return !!ALLOWED_EMAIL_DOMAINS[domain]
                    || domain.endsWith(".edu")
                    || domain.endsWith(".edu.ph");
            }

            function hasRepeatedSequence(text, minLen) {
                var repeats = 1;
                for (var i = 1; i < text.length; i++) {
                    if (text.charAt(i) === text.charAt(i - 1)) {
                        repeats++;
                        if (repeats >= minLen) {
                            return true;
                        }
                    } else {
                        repeats = 1;
                    }
                }
                return false;
            }

            function countLetters(text) {
                var matches = (text || "").match(/[A-Za-z]/g);
                return matches ? matches.length : 0;
            }

            function hasTripleRepeatedLetters(text) {
                return /([A-Za-z])\1{2,}/i.test(text || "");
            }

            function hasTooLongNameToken(text) {
                var tokens = (text || "").split(/[ .'-]+/);
                for (var i = 0; i < tokens.length; i++) {
                    if (tokens[i] && tokens[i].length > MAX_NAME_TOKEN_LENGTH) {
                        return true;
                    }
                }
                return false;
            }

            function normalizeName(text) {
                return (text || "").trim().replace(/\s+/g, " ");
            }

            function validateNameValue(value, label, optional) {
                if (!value) {
                    if (optional) {
                        return "";
                    }
                    return label + " is required.";
                }

                if (!NAME_ALLOWED_REGEX.test(value)) {
                    return "Use letters only. Spaces, apostrophe, hyphen, and period are allowed.";
                }

                if (countLetters(value) < MIN_NAME_LETTERS) {
                    return label + " must be at least 2 letters.";
                }

                if (hasTripleRepeatedLetters(value)) {
                    return "Avoid triple repeated letters (ex: rrr, dddd).";
                }

                if (hasTooLongNameToken(value)) {
                    return "Please avoid random long letter sequences in names.";
                }

                return "";
            }

            function containsPersonalInfo(passwordText) {
                var lowerPassword = (passwordText || "").toLowerCase();
                var tokens = [
                    normalizeToken(firstName.value),
                    normalizeToken(middleName.value),
                    normalizeToken(lastName.value),
                    normalizeToken(getEmailLocalPart(email.value)),
                    normalizeToken(normalizeContact(contactNumber.value)),
                    normalizeToken(birthDate.value)
                ];

                for (var i = 0; i < tokens.length; i++) {
                    if (tokens[i].length >= 3 && lowerPassword.indexOf(tokens[i]) !== -1) {
                        return true;
                    }
                }

                return false;
            }

            function validateNameField(input, errorElement, label) {
                var value = normalizeName(input.value);
                var message = validateNameValue(value, label, false);
                if (message) {
                    setFieldState(input, errorElement, message);
                    return false;
                }

                setFieldState(input, errorElement, "");
                return true;
            }

            function validateOptionalNameField(input, errorElement, label) {
                var value = normalizeName(input.value);
                var message = validateNameValue(value, label, true);
                if (message) {
                    setFieldState(input, errorElement, message);
                    return false;
                }

                setFieldState(input, errorElement, "");
                return true;
            }

            function validateEmailField() {
                var value = (email.value || "").trim();
                if (!value) {
                    setFieldState(email, errors.email, "Email address is required.");
                    return false;
                }

                if (value !== value.toLowerCase()) {
                    setFieldState(email, errors.email, "Use lowercase email only (example: name@gmail.com).");
                    return false;
                }

                if (!EMAIL_REGEX.test(value) || hasInvalidEmailDots(value)) {
                    setFieldState(email, errors.email, "Enter a valid email address.");
                    return false;
                }

                if (!isAllowedEmailDomain(getEmailDomain(value))) {
                    setFieldState(email, errors.email, "Use a supported provider (gmail, outlook, yahoo, or school .edu/.edu.ph).");
                    return false;
                }

                setFieldState(email, errors.email, "");
                return true;
            }

            function validateContactField() {
                var raw = (contactNumber.value || "").trim();
                if (!raw) {
                    setFieldState(contactNumber, errors.contactNumber, "Contact number is required.");
                    return false;
                }

                var normalized = normalizeContact(raw);
                if (!CONTACT_REGEX.test(normalized)) {
                    setFieldState(contactNumber, errors.contactNumber, "Use 10 to 15 digits (optional + prefix).");
                    return false;
                }

                setFieldState(contactNumber, errors.contactNumber, "");
                return true;
            }

            function computeAge(showRequiredError) {
                if (!birthDate.value) {
                    age.value = "";
                    if (showRequiredError) {
                        setFieldState(birthDate, errors.birthDate, "Birthday is required.");
                        return false;
                    }
                    setFieldState(birthDate, errors.birthDate, "");
                    return true;
                }

                var selectedDate = new Date(birthDate.value + "T00:00:00");
                if (Number.isNaN(selectedDate.getTime())) {
                    age.value = "";
                    setFieldState(birthDate, errors.birthDate, "Enter a valid birth date.");
                    return false;
                }

                var today = new Date();
                var years = today.getFullYear() - selectedDate.getFullYear();
                var monthDiff = today.getMonth() - selectedDate.getMonth();
                var dayDiff = today.getDate() - selectedDate.getDate();

                if (monthDiff < 0 || (monthDiff === 0 && dayDiff < 0)) {
                    years--;
                }

                if (years < 0) {
                    age.value = "";
                    setFieldState(birthDate, errors.birthDate, "Birth date cannot be in the future.");
                    return false;
                }

                if (years < 5 || years > 120) {
                    age.value = String(years);
                    setFieldState(birthDate, errors.birthDate, "Age must be between 5 and 120.");
                    return false;
                }

                age.value = String(years);
                setFieldState(birthDate, errors.birthDate, "");
                return true;
            }

            function validatePasswordField() {
                var value = password.value || "";
                if (!value) {
                    setFieldState(password, errors.password, "Password is required.");
                    return false;
                }

                if (value.length < 12) {
                    setFieldState(password, errors.password, "Password must be at least 12 characters.");
                    return false;
                }

                if (!PASSWORD_REGEX.test(value)) {
                    setFieldState(password, errors.password, "Include uppercase, lowercase, number, and special character.");
                    return false;
                }

                if (COMMON_PASSWORDS[value.toLowerCase()]) {
                    setFieldState(password, errors.password, "This password is too common.");
                    return false;
                }

                if (hasRepeatedSequence(value, 4)) {
                    setFieldState(password, errors.password, "Avoid repeated characters (AAAA / 1111).");
                    return false;
                }

                if (containsPersonalInfo(value)) {
                    setFieldState(password, errors.password, "Password must not include your personal details.");
                    return false;
                }

                setFieldState(password, errors.password, "");
                return true;
            }

            function validateMatch() {
                var confirmValue = confirmPassword.value || "";
                if (!confirmValue) {
                    setFieldState(confirmPassword, errors.confirmPassword, "Confirm password is required.");
                    return false;
                }

                if (password.value !== confirmValue) {
                    setFieldState(confirmPassword, errors.confirmPassword, "Passwords do not match.");
                    return false;
                }

                setFieldState(confirmPassword, errors.confirmPassword, "");
                return true;
            }

            function validateAgree() {
                if (!agree.checked) {
                    errors.agree.textContent = "You must confirm the details before submitting.";
                    agree.setCustomValidity("Please confirm your details.");
                    return false;
                }

                errors.agree.textContent = "";
                agree.setCustomValidity("");
                return true;
            }

            function validateAll() {
                var valid = true;
                valid = validateNameField(firstName, errors.firstName, "First name") && valid;
                valid = validateOptionalNameField(middleName, errors.middleName, "Middle name") && valid;
                valid = validateNameField(lastName, errors.lastName, "Last name") && valid;
                valid = validateEmailField() && valid;
                valid = validateContactField() && valid;
                valid = computeAge(true) && valid;
                valid = validatePasswordField() && valid;
                valid = validateMatch() && valid;
                valid = validateAgree() && valid;
                return valid;
            }

            function normalizeFormValues() {
                firstName.value = normalizeName(firstName.value);
                middleName.value = normalizeName(middleName.value);
                lastName.value = normalizeName(lastName.value);
                email.value = (email.value || "").trim();
                contactNumber.value = normalizeContact((contactNumber.value || "").trim());
            }

            firstName.addEventListener("input", function () {
                validateNameField(firstName, errors.firstName, "First name");
                if (password.value) {
                    validatePasswordField();
                }
            });
            middleName.addEventListener("input", function () {
                validateOptionalNameField(middleName, errors.middleName, "Middle name");
                if (password.value) {
                    validatePasswordField();
                }
            });
            lastName.addEventListener("input", function () {
                validateNameField(lastName, errors.lastName, "Last name");
                if (password.value) {
                    validatePasswordField();
                }
            });
            email.addEventListener("input", function () {
                validateEmailField();
                if (password.value) {
                    validatePasswordField();
                }
            });
            contactNumber.addEventListener("input", function () {
                validateContactField();
                if (password.value) {
                    validatePasswordField();
                }
            });
            birthDate.addEventListener("input", function () {
                computeAge(true);
                if (password.value) {
                    validatePasswordField();
                }
            });
            birthDate.addEventListener("change", function () {
                computeAge(true);
                if (password.value) {
                    validatePasswordField();
                }
            });
            password.addEventListener("input", function () {
                validatePasswordField();
                validateMatch();
            });
            confirmPassword.addEventListener("input", validateMatch);
            agree.addEventListener("change", validateAgree);

            form.addEventListener("submit", function (event) {
                normalizeFormValues();
                if (!validateAll()) {
                    event.preventDefault();
                }
            });

            computeAge(false);
        })();
    </script>
</body>
</html>
