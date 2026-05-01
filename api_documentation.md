# 🚀 FormForge AI Backend - API Documentation

Base URL: `http://localhost:5000`

---

## 👥 User & Waitlist Endpoints

### 1. Join Waitlist
Joins the waitlist and triggers a confirmation email.

- **URL:** `/api/users/join`
- **Method:** `POST`
- **Body (JSON):**
```json
{
    "email": "user@example.com",
    "device": "iPhone",
    "interest": "Fitness Gaming",
    "referredByCode": "ABC123" (Optional)
}
```
- **Success Response (201 Created):**
```json
{
    "success": true,
    "message": "Successfully joined the waitlist!",
    "data": {
        "user": {
            "email": "user@example.com",
            "referralCode": "XYZ789",
            "referralCount": 0
        },
        "position": 150
    }
}
```

---

### 2. Check Waitlist Status
Gets current rank and referral details for a specific user.

- **URL:** `/api/users/status/:email`
- **Method:** `GET`
- **Success Response (200 OK):**
```json
{
    "success": true,
    "data": {
        "user": {
            "email": "user@example.com",
            "referralCode": "XYZ789",
            "referralCount": 5
        },
        "position": 12
    }
}
```

---

### 3. Get Total Signups (Social Proof)
Returns the total number of users who have joined.

- **URL:** `/api/users/stats`
- **Method:** `GET`
- **Success Response (200 OK):**
```json
{
    "success": true,
    "count": 12540
}
```

---

### 4. Get Leaderboard
Returns the top 10 users based on their referral count.

- **URL:** `/api/users/leaderboard`
- **Method:** `GET`
- **Success Response (200 OK):**
```json
{
    "success": true,
    "data": [
        { "email": "user1@example.com", "referralCount": 50, "referralCode": "TOP1" },
        { "email": "user2@example.com", "referralCount": 45, "referralCode": "TOP2" }
    ]
}
```

---

## 🛠️ Error Handling
All errors follow this format:

```json
{
    "success": false,
    "message": "Error message here",
    "stack": "..." (Only in development mode)
}
```

---

## 📧 Email Configuration
Make sure your `.env` is configured with correct SMTP details for emails to work.
