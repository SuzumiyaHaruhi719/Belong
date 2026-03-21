# Task 0: Register & Onboard (one-time)

## 0.1 Create Account

### 0.1.1 Enter .edu email
- **Frontend:** Text input with .edu validation regex
- **Backend:** `POST /api/auth/check-email`
  - Validate email ends with .edu
  - Check if email already registered in users table
  - Return `{ available: true/false, valid_edu: true/false }`
- **DB:** `SELECT FROM users WHERE email = :email`

### 0.1.2 Receive & enter OTP
- **Frontend:** 6-digit OTP input, resend button with 60s cooldown
- **Backend:** `POST /api/auth/send-otp`
  - Generate 6-digit random code
  - Store in otp_codes table (expires in 10 min)
  - Send email via SendGrid/Resend/AWS SES
  - Rate limit: max 3 OTPs per email per hour
- **Backend:** `POST /api/auth/verify-otp`
  - Check code matches and not expired
  - Mark OTP as used
  - Return `{ verified: true, temp_token: "..." }`
- **DB:** `INSERT INTO otp_codes; UPDATE otp_codes SET used = true`

### 0.1.3 Set password
- **Frontend:** Password input with realtime validation indicators
  - ≥8 characters
  - Uppercase + lowercase
  - At least 1 number
  - At least 1 special character (!@#$%^&*)
- **Backend:** Validation happens on both frontend AND backend
- **Backend:** Hash with bcrypt (salt rounds = 12)

### 0.1.4 Set username
- **Frontend:** Text input, realtime availability check (debounced 500ms)
- **Backend:** `GET /api/auth/check-username?q=:username`
  - Validate: 3-30 chars, alphanumeric + underscore only
  - Check uniqueness in users table
  - Check against reserved words list
- **DB:** `SELECT FROM users WHERE username = :username`

### 0.1.5 Account created
- **Backend:** `POST /api/auth/register`
  - Verify temp_token from OTP step
  - Hash password with bcrypt
  - `INSERT INTO users (email, password_hash, username, email_verified=true)`
  - Generate JWT access_token + refresh_token
  - Return `{ user, access_token, refresh_token }`
- **DB:** `INSERT INTO users`

## 0.2 Profile Setup

### 0.2.1 Choose avatar
- **Frontend:** Grid of 8 preset emoji avatars + upload button
- **Backend (preset):** `PATCH /api/users/me { default_avatar_id: 3 }`
- **Backend (upload):** `POST /api/users/me/avatar` (multipart/form-data)
  - Accept jpg/png, max 5MB
  - Resize to 256x256, compress
  - Upload to Supabase Storage / S3 bucket
  - Update users.avatar_url
- **DB:** `UPDATE users SET avatar_url/default_avatar_id`

### 0.2.2 Username already set in 0.1.4 (skip)

### 0.2.3 Set app language preference
- **Frontend:** List of language options with flags
- **Backend:** `PATCH /api/users/me { app_language: "zh" }`
- **Frontend:** Store in AsyncStorage for immediate UI switch
- **DB:** `UPDATE users SET app_language`

## 0.3 Location & School (REQUIRED)

### 0.3.1 Select city
- **Frontend:** Searchable dropdown / autocomplete
- **Backend:** `GET /api/locations/cities?q=:query`
  - Return list of cities from predefined cities table
- **DB:** `SELECT FROM cities WHERE name ILIKE '%:query%' LIMIT 10`

### 0.3.2 Select school
- **Frontend:** Dropdown filtered by selected city
- **Backend:** `GET /api/locations/schools?city=:city`
  - Return schools in that city
- **Backend:** `PATCH /api/users/me { city, school }`
- **DB:** `UPDATE users SET city, school`

## 0.4 Cultural Tags (SKIPPABLE)

### 0.4.1 Select cultural background tags
- **Frontend:** Multi-select chip cloud
- **Backend:** `GET /api/tags/presets?category=cultural_background`
- **Tags:** Korean, Chinese, Filipino, Indian, Japanese, Ghanaian, Mexican, Brazilian, Vietnamese, Nigerian, Pakistani, Thai, Haitian, Colombian, Jamaican, Egyptian, Ethiopian, etc.

### 0.4.2 Select language tags
- **Frontend:** Multi-select chip cloud
- **Backend:** `GET /api/tags/presets?category=language`
- **Tags:** English, Mandarin, Cantonese, Korean, Tagalog, Hindi, Spanish, Japanese, Portuguese, French, Arabic, Twi, etc.

### 0.4.3 Select interest/vibe tags
- **Frontend:** Multi-select chip cloud
- **Backend:** `GET /api/tags/presets?category=interest_vibe`
- **Tags:** Food, Study, Music, Sports, Faith, Art, Dancing, Low-key hangout, Cooking, Gaming, Movies, Hiking, etc.

### 0.4.4 Skip for now → fill later in Profile (Task 5)

### Submit all tags
- **Backend:** `POST /api/users/me/tags { tags: [...] }`
  - Delete existing tags for user
  - Bulk insert new tags
- **DB:** `DELETE FROM user_tags WHERE user_id; INSERT INTO user_tags (batch)`
