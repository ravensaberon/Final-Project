package com.lulibrisync.api.dto;

import javax.validation.constraints.Email;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Size;

public class AuthRegisterRequest {

    @NotBlank(message = "First name is required.")
    @Size(min = 2, max = 50, message = "First name must be 2 to 50 characters.")
    private String firstName;

    @Size(max = 50, message = "Middle name must be 50 characters or less.")
    private String middleName;

    @NotBlank(message = "Last name is required.")
    @Size(min = 2, max = 50, message = "Last name must be 2 to 50 characters.")
    private String lastName;

    @NotBlank(message = "Email is required.")
    @Email(message = "Email format is invalid.")
    @Size(max = 120, message = "Email must be 120 characters or less.")
    private String email;

    @NotBlank(message = "Password is required.")
    @Size(min = 12, max = 100, message = "Password must be 12 to 100 characters long.")
    private String password;

    @NotBlank(message = "Confirm password is required.")
    private String confirmPassword;

    @NotBlank(message = "Contact number is required.")
    @Size(max = 30, message = "Contact number must be 30 characters or less.")
    private String contactNumber;

    @NotBlank(message = "Birth date is required.")
    private String birthDate;

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getMiddleName() {
        return middleName;
    }

    public void setMiddleName(String middleName) {
        this.middleName = middleName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getConfirmPassword() {
        return confirmPassword;
    }

    public void setConfirmPassword(String confirmPassword) {
        this.confirmPassword = confirmPassword;
    }

    public String getContactNumber() {
        return contactNumber;
    }

    public void setContactNumber(String contactNumber) {
        this.contactNumber = contactNumber;
    }

    public String getBirthDate() {
        return birthDate;
    }

    public void setBirthDate(String birthDate) {
        this.birthDate = birthDate;
    }
}
