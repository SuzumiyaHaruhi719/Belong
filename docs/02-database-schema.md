# Database Schema

All tables for the Belong platform. PostgreSQL (Supabase).

## users

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,  -- must be .edu
  email_verified BOOLEAN DEFAULT false,
  phone TEXT,
  password_hash TEXT NOT NULL,
  username TEXT UNIQUE NOT NULL,
  display_name TEXT,
  avatar_url TEXT,  -- null = use default avatar_id
  default_avatar_id INT,  -- references preset avatars
  bio TEXT,
  city TEXT NOT NULL,
  school TEXT NOT NULL,
  app_language TEXT DEFAULT 'en',  -- 'en', 'zh', 'ko', 'es', etc.
  privacy_profile TEXT DEFAULT 'public',  -- 'public', 'school_only', 'followers_only'
  privacy_dm TEXT DEFAULT 'mutual_only',  -- 'mutual_only', 'everyone'
  notifications_enabled BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  last_active_at TIMESTAMPTZ DEFAULT now()
);
```

## user_tags

```sql
CREATE TABLE user_tags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  category TEXT NOT NULL,  -- 'cultural_background', 'language', 'interest_vibe'
  tag_value TEXT NOT NULL,  -- e.g. 'Korean', 'Mandarin', 'Food'
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, category, tag_value)
);

CREATE INDEX idx_user_tags_user ON user_tags(user_id);
CREATE INDEX idx_user_tags_tag ON user_tags(tag_value);
```

## follows

```sql
CREATE TABLE follows (
  follower_id UUID REFERENCES users(id) ON DELETE CASCADE,
  following_id UUID REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (follower_id, following_id)
);

-- Mutual follow = both rows exist
-- Query mutual:
-- SELECT * FROM follows f1 JOIN follows f2
--   ON f1.follower_id = f2.following_id AND f1.following_id = f2.follower_id
--   WHERE f1.follower_id = :user_id;
```

## blocks

```sql
CREATE TABLE blocks (
  blocker_id UUID REFERENCES users(id) ON DELETE CASCADE,
  blocked_id UUID REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (blocker_id, blocked_id)
);
```

## reports

```sql
CREATE TABLE reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id UUID REFERENCES users(id),
  target_type TEXT NOT NULL,  -- 'user', 'post', 'gathering', 'message'
  target_id UUID NOT NULL,
  reason TEXT NOT NULL,
  details TEXT,
  status TEXT DEFAULT 'pending',  -- 'pending', 'reviewed', 'resolved'
  created_at TIMESTAMPTZ DEFAULT now()
);
```

## gatherings

```sql
CREATE TABLE gatherings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  host_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  template_type TEXT,  -- 'food', 'study', 'hangout', 'cultural', 'faith', 'active'
  emoji TEXT,  -- e.g. '🍜'
  image_url TEXT,
  city TEXT NOT NULL,
  school TEXT,
  location_name TEXT NOT NULL,  -- e.g. 'Gen Korean BBQ, Allston'
  latitude FLOAT,
  longitude FLOAT,
  starts_at TIMESTAMPTZ NOT NULL,
  ends_at TIMESTAMPTZ,
  max_attendees INT DEFAULT 6,
  visibility TEXT DEFAULT 'matching_tags',  -- 'open', 'matching_tags', 'invite_only'
  vibe TEXT DEFAULT 'low_key',  -- 'low_key', 'hype', 'chill', 'welcoming'
  status TEXT DEFAULT 'upcoming',  -- 'upcoming', 'ongoing', 'completed', 'cancelled'
  is_draft BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_gatherings_city ON gatherings(city);
CREATE INDEX idx_gatherings_starts ON gatherings(starts_at);
CREATE INDEX idx_gatherings_status ON gatherings(status);
```

## gathering_tags

```sql
CREATE TABLE gathering_tags (
  gathering_id UUID REFERENCES gatherings(id) ON DELETE CASCADE,
  tag_value TEXT NOT NULL,
  PRIMARY KEY (gathering_id, tag_value)
);

CREATE INDEX idx_gathering_tags_tag ON gathering_tags(tag_value);
```

## gathering_members

```sql
CREATE TABLE gathering_members (
  gathering_id UUID REFERENCES gatherings(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'joined',  -- 'joined', 'maybe', 'saved', 'left'
  joined_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (gathering_id, user_id)
);
```

## gathering_feedback

```sql
CREATE TABLE gathering_feedback (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  gathering_id UUID REFERENCES gatherings(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  emoji_rating TEXT NOT NULL,  -- 'meh', 'okay', 'good', 'great', 'amazing'
  rating_score INT NOT NULL,  -- 1-5 mapped from emoji
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(gathering_id, user_id)
);
-- This table is KEY for the recommendation feedback loop
```

## posts

```sql
CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id UUID REFERENCES users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  visibility TEXT DEFAULT 'public',  -- 'public', 'school_only', 'followers_only'
  linked_gathering_id UUID REFERENCES gatherings(id) ON DELETE SET NULL,
  city TEXT NOT NULL,
  school TEXT,
  latitude FLOAT,
  longitude FLOAT,
  like_count INT DEFAULT 0,
  comment_count INT DEFAULT 0,
  save_count INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_posts_author ON posts(author_id);
CREATE INDEX idx_posts_city ON posts(city);
CREATE INDEX idx_posts_created ON posts(created_at DESC);
```

## post_images

```sql
CREATE TABLE post_images (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  display_order INT DEFAULT 0,
  width INT,
  height INT
);
```

## post_tags (hashtags)

```sql
CREATE TABLE post_tags (
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  tag_value TEXT NOT NULL,  -- stored without #, e.g. 'KoreanBBQ'
  PRIMARY KEY (post_id, tag_value)
);

CREATE INDEX idx_post_tags_tag ON post_tags(tag_value);
```

## post_likes

```sql
CREATE TABLE post_likes (
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (post_id, user_id)
);
```

## post_comments

```sql
CREATE TABLE post_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  author_id UUID REFERENCES users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  parent_comment_id UUID REFERENCES post_comments(id),  -- for nested replies
  created_at TIMESTAMPTZ DEFAULT now()
);
```

## post_saves (bookmarks)

```sql
CREATE TABLE post_saves (
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (post_id, user_id)
);
```

## conversations (DMs)

```sql
CREATE TABLE conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type TEXT NOT NULL,  -- 'dm', 'gathering_group'
  gathering_id UUID REFERENCES gatherings(id),  -- null for DMs
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()  -- last message time
);
```

## conversation_members

```sql
CREATE TABLE conversation_members (
  conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  last_read_at TIMESTAMPTZ,
  PRIMARY KEY (conversation_id, user_id)
);
```

## messages

```sql
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
  sender_id UUID REFERENCES users(id) ON DELETE CASCADE,
  content TEXT,
  image_url TEXT,
  shared_post_id UUID REFERENCES posts(id),  -- for sharing posts in chat
  message_type TEXT DEFAULT 'text',  -- 'text', 'image', 'shared_post', 'system'
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_messages_conv ON messages(conversation_id, created_at DESC);
```

## notifications

```sql
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  recipient_id UUID REFERENCES users(id) ON DELETE CASCADE,
  actor_id UUID REFERENCES users(id),
  type TEXT NOT NULL,
  -- Types: 'like', 'comment', 'follow', 'mention', 'gathering_reminder',
  --   'gathering_joined', 'new_post_from_following', 'new_gathering_from_following',
  --   'dm_message', 'follow_suggestion'
  target_type TEXT,  -- 'post', 'gathering', 'comment', 'user'
  target_id UUID,
  message TEXT,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_notif_recipient ON notifications(recipient_id, created_at DESC);
CREATE INDEX idx_notif_unread ON notifications(recipient_id, is_read) WHERE is_read = false;
```

## browse_history

```sql
CREATE TABLE browse_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  target_type TEXT NOT NULL,  -- 'post', 'gathering'
  target_id UUID NOT NULL,
  viewed_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_history_user ON browse_history(user_id, viewed_at DESC);
```

## otp_codes

```sql
CREATE TABLE otp_codes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT NOT NULL,
  code TEXT NOT NULL,  -- 6-digit
  expires_at TIMESTAMPTZ NOT NULL,  -- now() + 10 minutes
  used BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);
```

## user_tag_affinity (recommendation engine)

```sql
CREATE TABLE user_tag_affinity (
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  tag_value TEXT NOT NULL,
  affinity_score FLOAT DEFAULT 3.0,
  sample_count INT DEFAULT 0,
  updated_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (user_id, tag_value)
);
-- Updated via: new_score = (old_score * count + new_rating) / (count + 1)
```
