# 🚀 FormForge AI Backend - API Documentation

Base URL: `http://localhost:5000`

---

## 👥 Waitlist Endpoints (Landing Page)

### 1. Join Waitlist
Joins the viral waitlist.
- **URL:** `/api/waitlist/join`
- **Method:** `POST`
- **Body:** `{ "email": "...", "device": "...", "interest": "...", "referredByCode": "..." }`

### 2. Check Waitlist Status
- **URL:** `/api/waitlist/status/:email`
- **Method:** `GET`

---

## 🔐 Authentication Endpoints

### 1. Register
Creates a new account and an initial profile.
- **URL:** `/api/auth/register`
- **Method:** `POST`
- **Body:** `{ "email": "...", "password": "..." }`

### 2. Login
Returns user data, profile, and JWT token.
- **URL:** `/api/auth/login`
- **Method:** `POST`
- **Body:** `{ "email": "...", "password": "..." }`

### 3. Forgot Password
Generates a reset token (OTP).
- **URL:** `/api/auth/forgot-password`
- **Method:** `POST`
- **Body:** `{ "email": "..." }`

### 4. Reset Password
Updates password using the OTP.
- **URL:** `/api/auth/reset-password`
- **Method:** `POST`
- **Body:** `{ "otp": "...", "password": "..." }`

### 5. Logout
- **URL:** `/api/auth/logout`
- **Method:** `POST`

---

## 👤 Profile & Onboarding

### 1. Get Profile
Fetches user and profile details.
- **URL:** `/api/profile/:userId`
- **Method:** `GET`

### 2. Update Profile
Updates specific profile fields.
- **URL:** `/api/profile/:userId`
- **Method:** `PUT`
- **Body:** `{ "full_name": "...", "age": 25, "fitness_level": "beginner", ... }`

### 3. Complete Onboarding
Updates profile and marks `is_profile_completed` as true.
- **URL:** `/api/profile/onboarding`
- **Method:** `POST`
- **Body:** `{ "userId": "...", "full_name": "...", "goal": "...", ... }`

---

## 🏋️ Exercise Endpoints

### 1. Get All Exercises
Fetches a list of all active exercises. Supports filtering via query params.
- **URL:** `/api/exercises`
- **Method:** `GET`
- **Query Params:** `type`, `category`, `difficulty` (Optional)

### 2. Get Exercise by ID
- **URL:** `/api/exercises/:id`
- **Method:** `GET`

### 3. Create Exercise (Admin)
- **URL:** `/api/exercises`
- **Method:** `POST`
- **Body:** `{ "name": "...", "type": "...", "category": "...", "logic_config": {...}, ... }`

### 4. Update Exercise (Admin)
- **URL:** `/api/exercises/:id`
- **Method:** `PUT`

### 5. Delete Exercise (Admin)
Performs a soft delete (sets `is_active` to false).
- **URL:** `/api/exercises/:id`
- **Method:** `DELETE`

---

## 🛠️ Error Handling
All errors follow this format:
```json
{
    "success": false,
    "message": "Error message here"
}
```
