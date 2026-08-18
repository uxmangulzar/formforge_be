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

Signup uses a **6-digit email OTP** stored in `resetPasswordToken` / `resetPasswordExpire` (20-minute expiry). After signup, verify email before login.

### 1. Register
Creates a new account and an initial profile. Sends a verification OTP to the user's email. **No JWT is returned** until email is verified.

- **URL:** `/api/auth/register`
- **Method:** `POST`
- **Body:** `{ "email": "...", "password": "..." }`

**Example response:**
```json
{
  "success": true,
  "message": "User registered successfully. Please verify your email with the OTP sent to your inbox.",
  "data": {
    "id": "uuid",
    "email": "user@example.com",
    "is_verified": false,
    "requiresVerification": true,
    "profile": { ... }
  }
}
```

**Notes:**
- If the email exists but is **not verified**, a new OTP is sent and the password is updated.
- If the email is **already verified**, returns `User already exists`.

### 2. Verify Email
Verifies the signup OTP and returns a JWT token.

- **URL:** `/api/auth/verify-email`
- **Method:** `POST`
- **Body:** `{ "email": "...", "otp": "123456" }`

**Example response:**
```json
{
  "success": true,
  "message": "Email verified successfully",
  "data": {
    "id": "uuid",
    "email": "user@example.com",
    "is_verified": true,
    "token": "jwt-token-here",
    "profile": { ... }
  }
}
```

**Errors:**
- `Invalid OTP` — wrong code
- `OTP has expired. Please request a new OTP.` — use resend endpoint
- `Email is already verified` — user can log in directly

### 3. Resend Verification OTP
Sends a **new 6-digit OTP** to an unverified account. The previous OTP is replaced in the database (new hash + new 20-minute expiry).

- **URL:** `/api/auth/resend-verification-otp`
- **Method:** `POST`
- **Body:** `{ "email": "..." }`

**Example response:**
```json
{
  "success": true,
  "message": "A new verification OTP has been sent to your email.",
  "data": {
    "email": "user@example.com"
  }
}
```

**Errors:**
- `User not found with this email`
- `Email is already verified`

### 4. Login
Returns user data, profile, and JWT token. **Only works after email verification** for app users.

- **URL:** `/api/auth/login`
- **Method:** `POST`
- **Body:** `{ "email": "...", "password": "..." }`

**Error (unverified user):** `Please verify your email before logging in`

### 5. Social Login (Google / Apple)
Sign in or sign up with Google or Apple. **No OTP** — the account is treated as verified immediately. If the email already exists, the user is logged in; otherwise a new account is created.

- **URL:** `/api/auth/social-login`
- **Method:** `POST`
- **Body:**
```json
{
  "provider": "google",
  "email": "user@gmail.com",
  "full_name": "John Doe",
  "avatar_url": "https://lh3.googleusercontent.com/..."
}
```

| Field | Required | Description |
|-------|----------|-------------|
| `provider` | Yes | `google` or `apple` |
| `email` | Yes | Email from Google / Apple SDK |
| `full_name` | No | Display name — saved to profile |
| `avatar_url` | No | Photo URL — saved to profile |

**New user response (`201`):**
```json
{
  "success": true,
  "message": "Account created successfully",
  "data": {
    "id": "uuid",
    "email": "user@gmail.com",
    "is_verified": true,
    "token": "jwt-token-here",
    "isNewUser": true,
    "provider": "google",
    "profile": {
      "full_name": "John Doe",
      "avatar_url": "https://..."
    }
  }
}
```

**Existing user response (`200`):**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "id": "uuid",
    "email": "user@gmail.com",
    "is_verified": true,
    "token": "jwt-token-here",
    "isNewUser": false,
    "provider": "apple",
    "profile": { ... }
  }
}
```

**Notes:**
- Existing email/password users with the same email can use social login — they are logged in and marked verified (no OTP).
- Profile `full_name` / `avatar_url` are updated when new values are sent.
- Social accounts get a random internal password (not used for login).
- Admin accounts cannot use this endpoint.

**Errors:**
- `provider must be google or apple`
- `Social login is not available for this account` (admin email)
- `Account is not active`

### 6. Forgot Password
Sends a **6-digit OTP** to the user's email (30-minute expiry). Use with `/api/auth/reset-password`.

- **URL:** `/api/auth/forgot-password`
- **Method:** `POST`
- **Body:** `{ "email": "..." }`

**Example response:**
```json
{
  "success": true,
  "message": "Password reset OTP has been sent to your email.",
  "data": {
    "email": "user@example.com"
  }
}
```

### 7. Reset Password
Updates password using the OTP from the forgot-password email.
- **URL:** `/api/auth/reset-password`
- **Method:** `POST`
- **Body:** `{ "otp": "...", "password": "..." }`

### 8. Logout
- **URL:** `/api/auth/logout`
- **Method:** `POST`

---

## 👤 Profile & Onboarding

### 1. Get Profile
Fetches user and profile details.
- **URL:** `/api/profile/:userId`
- **Method:** `GET`

### 2. Update Profile
Updates specific profile fields (`full_name`, `avatar_url`, `age`, `fitness_level`, `goal`, `injury_history`, `preferred_language`).
- **URL:** `/api/profile/:userId`
- **Method:** `PUT`
- **Body:** `{ "full_name": "...", "avatar_url": "/uploads/...", "age": 25, "fitness_level": "beginner", ... }`

### 3. Complete Onboarding
Updates profile and marks `is_profile_completed` as true.
- **URL:** `/api/profile/onboarding`
- **Method:** `POST`
- **Body:** `{ "userId": "...", "full_name": "...", "goal": "...", ... }`

### 4. User Mobile Dashboard
Aggregates user's average form score, last completed workout log XP, total accumulated XP, real-time streak computed directly from exercise logs (`workout_sessions`), `today_streak_completed` boolean (true if `>= 2` workouts logged today), and recent workout logs sorted in descending order (`completed_at DESC`).
- **URL:** `/api/profile/dashboard` or `/api/workouts/dashboard`
- **Method:** `GET`
- **Auth:** Required (`Authorization: Bearer <token>`)
- **Headers:** `x-timezone` (optional, e.g. `Asia/Karachi`)
- **Query Params:** `limit` (optional, default `10`, max `50`)

**Example response:**
```json
{
  "success": true,
  "data": {
    "avg_form_score": 89.5,
    "last_completed_log_xp": 100,
    "total_xp_earned": 450,
    "streak": {
      "current_streak": 5,
      "longest_streak": 12,
      "last_activity_date": "2026-08-12",
      "today_workouts_count": 2,
      "today_streak_completed": true,
      "timezone": "Asia/Karachi"
    },
    "recent_workout_logs": [
      {
        "id": "workout-uuid",
        "exercise_id": "exercise-uuid",
        "mode": "train",
        "form_score": 92,
        "reps": 15,
        "sets": 3,
        "duration_sec": 180,
        "calories": 50,
        "xp_earned": 100,
        "mistakes": ["Knees over toes"],
        "completed_at": "2026-08-12T17:45:00.000Z",
        "exercise": {
          "id": "exercise-uuid",
          "name": "Push Ups",
          "type": "train",
          "difficulty": "beginner",
          "gif_url": "/uploads/pushup.gif",
          "exerciseCategory": {
            "slug": "upper_body",
            "display_name": "Upper Body"
          }
        }
      }
    ]
  }
}
```

### 5. Upload User Avatar Image
Uploads a profile picture file to `/uploads/` directory.
- **URL:** `/api/upload/avatar`
- **Method:** `POST`
- **Auth:** Required (`Authorization: Bearer <token>`)
- **Body:** `multipart/form-data` with field key `file` (Allowed: JPG, PNG, WebP | Max 5MB)

**Example response:**
```json
{
  "success": true,
  "message": "Avatar uploaded successfully",
  "url": "/uploads/file-1723485600000-987654321.jpg"
}
```

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

## 🎯 Training Modes (Mobile App)

Experience modes for **Train**, **Play (Gaming)**, and **Recover (Rehab)**. Public read-only; only active modes and active exercises are returned.

### 1. List Training Modes
Returns active modes sorted by `sort_order`, with pagination.
- **URL:** `/api/training-modes`
- **Method:** `GET`
- **Auth:** None
- **Query Params:**
  - `page` (optional, default `1`) — page number
  - `limit` (optional, default `10`, max `50`) — items per page

**Example:** `/api/training-modes?page=1&limit=10`

**Example response:**
```json
{
  "success": true,
  "count": 3,
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 3,
    "totalPages": 1,
    "hasPrev": false,
    "hasNext": false
  },
  "data": [
    {
      "id": "a0000001-0001-4001-8001-000000000001",
      "slug": "training",
      "display_name": "Training",
      "description": "Standard strength and conditioning style work.",
      "sort_order": 0
    }
  ]
}
```

### 2. Get Training Mode (with exercises)
Returns one active mode and its linked active exercises. Accepts **UUID** or **slug** (e.g. `training`, `rehab`, `gaming`).
- **URL:** `/api/training-modes/:idOrSlug`
- **Method:** `GET`
- **Auth:** None

**Examples:**
- `/api/training-modes/training`
- `/api/training-modes/rehab`
- `/api/training-modes/a0000001-0001-4001-8001-000000000003`

**Example response:**
```json
{
  "success": true,
  "data": {
    "id": "a0000001-0001-4001-8001-000000000001",
    "slug": "training",
    "display_name": "Training",
    "description": "Standard strength and conditioning style work.",
    "sort_order": 0,
    "exercises": [
      {
        "id": "...",
        "name": "Squat",
        "type": "train",
        "category": "lower_body",
        "category_display_name": "Lower Body",
        "difficulty": "beginner",
        "description": "...",
        "demo_url": "...",
        "gif_url": "...",
        "data_url": "...",
        "target_muscles": ["quads", "glutes"],
        "logic_config": {},
        "rep_counting_logic": {}
      }
    ]
  }
}
```

---

## 🏆 Challenges (Mobile App)

Published challenges only. Join and progress endpoints require a **user JWT** from `/api/auth/login`, `/api/auth/verify-email`, or `/api/auth/social-login` (`Authorization: Bearer <token>`).

### 1. List Challenges
Returns published challenges with pagination.
- **URL:** `/api/challenges`
- **Method:** `GET`
- **Auth:** None
- **Query Params:**
  - `page` (optional, default `1`)
  - `limit` (optional, default `10`, max `50`)
  - `active` (optional, `true`) — only challenges where `starts_at <= now < ends_at`

**Example:** `/api/challenges?page=1&limit=10&active=true`

### 2. Get Challenge Detail
Full challenge with stages, exercises, badges, and participant count.
- **URL:** `/api/challenges/:id`
- **Method:** `GET`
- **Auth:** None

### 3. Challenge Leaderboard
Rankings for a **specific challenge** by `total_points_earned` (highest first). Tie-break: earlier `joined_at` ranks higher.

Only **published** challenges return data; draft/archived IDs return `404`.

- **URL:** `/api/challenges/:id/leaderboard`
- **Method:** `GET`
- **Auth:** None (public)
- **Query Params:**
  - `page` (optional, default `1`)
  - `limit` (optional, default `20`, max `100`)

**Example:** `/api/challenges/c286a95c-b236-442f-b7a2-3682f4d17b29/leaderboard?page=1&limit=20`

**Example response:**
```json
{
  "success": true,
  "challenge": {
    "id": "c286a95c-b236-442f-b7a2-3682f4d17b29",
    "name": "Summer Squat Challenge"
  },
  "count": 1,
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 1,
    "totalPages": 1,
    "hasPrev": false,
    "hasNext": false
  },
  "data": [
    {
      "rank": 1,
      "user_id": "13cfa403-8c93-48ed-aaaa-3b18771cb4dd",
      "display_name": "Alex",
      "avatar_url": "https://cdn.example.com/avatar.jpg",
      "total_points": 450,
      "status": "in_progress",
      "joined_at": "2026-06-22T07:05:24.000Z"
    }
  ]
}
```

| Field | Description |
|-------|-------------|
| `rank` | Position on this page (accounts for `page` offset) |
| `display_name` | Profile `full_name`, or `"Athlete"` if empty |
| `total_points` | Points earned in this challenge |
| `status` | User enrollment: `joined`, `in_progress`, `completed`, `failed`, `expired` |

**Notes:**
- Only users who **joined** the challenge appear in the list.
- Points come from saved challenge exercise progress (`POST /api/challenges/:id/progress`).
- Use this endpoint on the challenge detail / leaderboard screen in the mobile app — no JWT required.

### 4. Join Challenge
Creates enrollment and initializes stage/exercise progress rows.
- **URL:** `/api/challenges/:id/join`
- **Method:** `POST`
- **Auth:** User JWT

### 5. My Challenges
Lists challenges the logged-in user has joined.
- **URL:** `/api/challenges/my`
- **Method:** `GET`
- **Auth:** User JWT
- **Query Params:** `page`, `limit`, `status` (optional: `joined`, `in_progress`, `completed`, `failed`, `expired`)

### 6. My Progress on a Challenge
Returns enrollment, stage progress, and per-exercise progress (including `form_score` and `mistakes` when saved).
- **URL:** `/api/challenges/:id/my-progress`
- **Method:** `GET`
- **Auth:** User JWT

### 7. Save Exercise Progress (single)
Saves sets, reps, optional form score and mistakes. Awards points, advances stages, and may grant badges.
- **URL:** `/api/challenges/:id/progress`
- **Method:** `POST`
- **Auth:** User JWT
- **Body (absolute values):**
```json
{
  "challenge_stage_exercise_id": "uuid-of-stage-exercise-row",
  "sets_completed": 3,
  "reps_logged": 45,
  "form_score": 87,
  "mistakes": ["knees caving inward", "insufficient depth"]
}
```
- **Body (increment after each set):**
```json
{
  "challenge_stage_exercise_id": "uuid-of-stage-exercise-row",
  "increment_sets": 1,
  "increment_reps": 15,
  "form_score": 82,
  "mistakes": ["back not straight"]
}
```

**Alias:** `PATCH /api/challenges/:id/progress/exercise` (same body and behaviour).

### 8. Save Exercise Progress (bulk)
Save multiple exercises in one request (e.g. after a full workout). Max 50 items.
- **URL:** `/api/challenges/:id/progress/bulk`
- **Method:** `POST`
- **Auth:** User JWT
- **Body:**
```json
{
  "exercises": [
    {
      "challenge_stage_exercise_id": "uuid-1",
      "sets_completed": 3,
      "reps_logged": 45,
      "form_score": 90
    },
    {
      "challenge_stage_exercise_id": "uuid-2",
      "increment_sets": 1,
      "increment_reps": 12,
      "form_score": 78,
      "mistakes": ["tempo too fast"]
    }
  ]
}
```

**Notes:**
- User must **join** the challenge before saving progress (`POST /api/challenges/:id/join`).
- Exercise is marked **complete** when `sets_completed >= target_sets`.
- Response includes updated `data` (full progress) and `badges_earned` when rules trigger.
- Run migration `25_challenge_exercise_progress_form.sql` for `form_score` / `mistakes` columns (or rely on Sequelize sync in dev).

---

## 📝 Workout Logs (Mobile App)

General workout history — **kis user ne kaun si exercise kab ki**. Separate from challenge progress (`user_challenge_exercise_progress`). Requires **user JWT**.

**Migration:** `node scripts/migrate.js 26_create_workout_sessions.sql`

### 1. Log a Workout
Save after Train / Play / Recover session completes.
- **URL:** `/api/workouts`
- **Method:** `POST`
- **Auth:** User JWT
- **Body:**
```json
{
  "exercise_id": "uuid-of-exercise",
  "mode": "train",
  "form_score": 87,
  "reps": 42,
  "sets": 3,
  "duration_sec": 600,
  "calories": 208,
  "xp_earned": 120,
  "mistakes": ["knees caving inward", "insufficient depth"],
  "notes": "Felt strong today",
  "challenge_id": "optional-challenge-uuid",
  "completed_at": "2026-06-19T10:30:00.000Z"
}
```
- `mode` defaults to the exercise `type` if omitted.
- `xp_earned` adds to profile `total_xp` when greater than 0.
- Response includes **`streak`** object (current streak updated automatically).

### 2. List My Workout History
- **URL:** `/api/workouts`
- **Method:** `GET`
- **Auth:** User JWT
- **Query Params:**
  - `page`, `limit` (default 10, max 50)
  - `exercise_id` — filter by exercise
  - `mode` — `train`, `play`, or `recover`
  - `challenge_id` — workouts linked to a challenge
  - `from`, `to` — ISO date range on `completed_at`

**Example:** `/api/workouts?exercise_id=uuid&page=1&limit=10`

Each row includes nested `exercise` (name, category, gif_url, etc.).

### 3. Workout Stats & Summary
- **URL:** `/api/workouts/stats`
- **Method:** `GET`
- **Auth:** User JWT
- **Query Params:** `exercise_id`, `mode` (optional filters)

Returns totals, best form score, recent 5 sessions, and per-exercise breakdown (session count, best/avg score).

### 4. Get Single Workout Log
- **URL:** `/api/workouts/:id`
- **Method:** `GET`
- **Auth:** User JWT

---

## 💳 Subscriptions (Mobile App)

Uses existing `subscription_plans` and `user_subscriptions` tables. Admin panel unchanged.

### 1. List Subscription Plans
Active plans only (for paywall / pricing screen).
- **URL:** `/api/subscriptions/plans`
- **Method:** `GET`
- **Auth:** None
- **Query Params:** `page`, `limit` (default 10, max 50)

**Response fields:** `name`, `description`, `price`, `currency`, `free_trials`, `features`, `play_store_sub_id`, `app_store_sub_id`

### 2. My Subscription Status
- **URL:** `/api/subscriptions/me`
- **Method:** `GET`
- **Auth:** User JWT

**Response:**
```json
{
  "success": true,
  "data": {
    "is_premium": true,
    "subscription": {
      "id": "...",
      "status": "active",
      "platform": "google_play",
      "expires_at": "...",
      "auto_renew": true,
      "is_active": true,
      "plan": { "name": "Pro", "price": "9.99", ... }
    },
    "history": []
  }
}
```

### 3. Subscribe (after in-app purchase)
Verifies purchase with Google Play or App Store, then creates/updates `user_subscriptions`.
- **URL:** `/api/subscriptions/subscribe`
- **Method:** `POST`
- **Auth:** User JWT
- **Body:**
```json
{
  "subscription_plan_id": "uuid-from-plans-api",
  "platform": "google_play",
  "purchase_token": "google-play-purchase-token"
}
```

**iOS example:**
```json
{
  "subscription_plan_id": "uuid",
  "platform": "app_store",
  "purchase_token": "original-transaction-id"
}
```

Requires Google/Apple store credentials in server `.env` (same as admin store provisioning).

### 4. Restore Purchases
Same body as subscribe — re-verifies store token and refreshes subscription.
- **URL:** `/api/subscriptions/restore`
- **Method:** `POST`
- **Auth:** User JWT

---

## 🔥 Workout Streaks (Mobile App)

Streak = **consecutive calendar days** with at least one logged workout (`POST /api/workouts`).

Optional header for local day boundaries: `X-Timezone: Asia/Karachi` (defaults to `UTC`).

**Migration:** `node scripts/migrate.js 27_add_profile_streak_fields.sql`

### 1. My Streak Summary
- **URL:** `/api/streaks/me`
- **Method:** `GET`
- **Auth:** User JWT
- **Headers:** `X-Timezone` (optional)

**Example response:**
```json
{
  "success": true,
  "data": {
    "current_streak": 7,
    "longest_streak": 14,
    "last_activity_date": "2026-06-19",
    "streak_active_today": true,
    "workouts_today": 2,
    "streak_increased": false,
    "timezone": "Asia/Karachi"
  }
}
```

If the user missed yesterday, `current_streak` returns `0` until the next workout starts a new streak.

### 2. Streak Calendar (Progress screen)
Days in a month when the user logged at least one workout.
- **URL:** `/api/streaks/calendar`
- **Method:** `GET`
- **Auth:** User JWT
- **Query Params:** `year`, `month` (1–12), optional `timezone`
- **Headers:** `X-Timezone` (optional)

**Example:** `/api/streaks/calendar?year=2026&month=6`

### Streak rules
| Event | Streak |
|-------|--------|
| First workout ever | `current_streak = 1` |
| Workout on consecutive day | `+1` |
| Another workout same day | unchanged |
| Gap of 2+ days | resets to `1` on next workout |
| `longest_streak` | max ever achieved |

---

## 🔒 Admin API (Challenges & Leaderboard)

Admin endpoints require **Admin JWT** from `POST /api/admin/auth/login`  
Header: `Authorization: Bearer <admin_token>`

Base path: `/api/admin/challenges`

### 1. Challenge Leaderboard (Admin)
Same ranking as the mobile leaderboard, but works for **any challenge status** (draft, published, archived) and includes admin-only fields.

- **URL:** `/api/admin/challenges/:id/leaderboard`
- **Method:** `GET`
- **Auth:** Admin JWT
- **Query Params:**
  - `page` (optional, default `1`)
  - `limit` (optional, default `20`, max `100`)

**Example:** `/api/admin/challenges/c286a95c-b236-442f-b7a2-3682f4d17b29/leaderboard?page=1&limit=50`

**Example response:**
```json
{
  "success": true,
  "challenge": {
    "id": "c286a95c-b236-442f-b7a2-3682f4d17b29",
    "name": "Summer Squat Challenge",
    "status": "published",
    "starts_at": "2026-05-13T14:03:00.000Z",
    "ends_at": "2034-06-20T14:03:00.000Z"
  },
  "count": 1,
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 1,
    "totalPages": 1,
    "hasPrev": false,
    "hasNext": false
  },
  "data": [
    {
      "rank": 1,
      "user_id": "13cfa403-8c93-48ed-aaaa-3b18771cb4dd",
      "email": "user@example.com",
      "display_name": "Alex",
      "avatar_url": null,
      "user_status": "active",
      "total_points": 450,
      "challenge_status": "in_progress",
      "joined_at": "2026-06-22T07:05:24.000Z",
      "completed_at": null
    }
  ]
}
```

| Field | Mobile API | Admin API |
|-------|------------|-----------|
| `email` | — | User account email |
| `user_status` | — | `active`, `inactive`, etc. |
| `challenge_status` | — | User's enrollment status in this challenge |
| `completed_at` | — | When user finished the challenge (if applicable) |
| Challenge `status` | Only `published` returned | Any status in `challenge` object |

**Related admin challenge routes:**

| Method | URL | Description |
|--------|-----|-------------|
| GET | `/api/admin/challenges` | List all challenges (all statuses) |
| POST | `/api/admin/challenges` | Create challenge |
| GET | `/api/admin/challenges/:id` | Challenge detail |
| PUT | `/api/admin/challenges/:id` | Update challenge |
| DELETE | `/api/admin/challenges/:id` | Delete challenge |

**Global app leaderboard** (all users by total XP — not per challenge):  
`GET /api/admin/leaderboard/users` (Admin JWT)

---

## 🛠️ Error Handling
All errors follow this format:
```json
{
    "success": false,
    "message": "Error message here"
}
```
