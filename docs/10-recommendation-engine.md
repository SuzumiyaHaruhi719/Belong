# Recommendation Engine

## Algorithm: `recommend_gatherings`

```python
def recommend_gatherings(user_id, limit=1):
    user = get_user(user_id)
    user_tags = get_user_tags(user_id)
    user_affinities = get_user_tag_affinities(user_id)  # from feedback loop
    user_following = get_following_ids(user_id)
    user_blocks = get_blocked_ids(user_id)

    # Step 1: Base query
    candidates = query("""
        SELECT g.*, array_agg(gt.tag_value) as tags,
               COUNT(gm.user_id) as attendee_count
        FROM gatherings g
        LEFT JOIN gathering_tags gt ON g.id = gt.gathering_id
        LEFT JOIN gathering_members gm ON g.id = gm.gathering_id AND gm.status = 'joined'
        WHERE g.city = :city
          AND g.status = 'upcoming'
          AND g.starts_at > now()
          AND g.host_id NOT IN (:blocked_ids)
          AND g.id NOT IN (SELECT gathering_id FROM gathering_members WHERE user_id = :user_id)
        GROUP BY g.id
    """)

    # Step 2: Score each candidate
    for g in candidates:
        score = 0

        # Tag matching (base)
        for tag in g.tags:
            if tag in user_tags['cultural_background']:
                score += 10
            elif tag in user_tags['language']:
                score += 8
            elif tag in user_tags['interest_vibe']:
                score += 5

        # Affinity from feedback history (THE FEEDBACK LOOP)
        for tag in g.tags:
            if tag in user_affinities:
                affinity = user_affinities[tag]  # 1.0 - 5.0
                score += (affinity - 3.0) * 3  # range: -6 to +6

        # Social signals
        if g.host_id in user_following:
            score += 5
        mutual_attending = count_mutual_friends_attending(user_id, g.id)
        score += mutual_attending * 2

        # Same school bonus
        if g.school == user.school:
            score += 3

        # Freshness (prefer sooner events)
        days_until = (g.starts_at - now()).days
        if days_until <= 2:
            score += 4
        elif days_until <= 7:
            score += 1
        else:
            score -= 3

        # Spots urgency
        spots_left = g.max_attendees - g.attendee_count
        if spots_left <= 2:
            score += 3  # urgency boost

        g.score = score

    # Step 3: Sort and return
    candidates.sort(key=lambda g: g.score, reverse=True)
    return candidates[:limit]
```

## Scoring Summary

| Signal | Points | Notes |
|--------|--------|-------|
| Matching cultural_background tag | +10 | Per matching tag |
| Matching language tag | +8 | Per matching tag |
| Matching interest_vibe tag | +5 | Per matching tag |
| Same school | +3 | Boolean |
| Host is followed | +5 | Boolean |
| Mutual friend attending | +2 | Per mutual friend |
| Tag affinity (from feedback) | -6 to +6 | Based on historical ratings |
| Starts within 2 days | +4 | Freshness boost |
| Starts within 7 days | +1 | Moderate boost |
| Starts > 7 days away | -3 | Prefer sooner |
| < 2 spots left | +3 | Urgency boost |

## Feedback Loop

```
User attends gathering
    ↓
User rates with emoji (1-5)
    ↓
System updates user_tag_affinity for all gathering's tags
    ↓
Formula: new_score = (old_score * sample_count + new_rating) / (sample_count + 1)
    ↓
Next recommendation uses updated affinity scores
```

## Fallback Strategy

When a user has NO tags (new user who skipped Task 0.4):
1. Same city
2. Same school
3. Soonest events first
4. Most popular (highest attendee count)

## Post Feed Algorithm

```
Scoring: recency * 0.3 + relevance * 0.4 + popularity * 0.3
```

Sources (weighted):
1. Posts from users I follow (weight: high)
2. Posts from same city (weight: medium)
3. Posts from same school (weight: medium-high)
4. Posts matching my cultural tags (weight: medium)
5. Trending posts in my city (like_count > threshold)

Filters:
- Blocked users excluded
- Reported posts excluded
- Already-seen posts de-prioritized (optional)
