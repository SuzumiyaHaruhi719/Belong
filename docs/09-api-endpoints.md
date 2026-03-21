# API Endpoint Reference

## AUTH

```
POST   /api/auth/check-email        # validate .edu
POST   /api/auth/send-otp           # send verification code
POST   /api/auth/verify-otp         # verify code
GET    /api/auth/check-username      # username availability
POST   /api/auth/register           # create account
POST   /api/auth/login              # email + password → tokens
POST   /api/auth/refresh            # refresh_token → new access_token
POST   /api/auth/logout             # invalidate session
```

## USERS

```
GET    /api/users/me                # my full profile
PATCH  /api/users/me                # update profile fields
POST   /api/users/me/avatar         # upload avatar
POST   /api/users/me/tags           # set cultural tags
PATCH  /api/users/me/settings       # privacy, notifications
GET    /api/users/me/following       # who I follow
GET    /api/users/me/followers       # who follows me
GET    /api/users/me/mutuals         # mutual friends
GET    /api/users/me/blocked         # blocked users
GET    /api/users/me/gatherings      # my gatherings
GET    /api/users/me/posts           # my posts
GET    /api/users/:id                # view other user profile
POST   /api/users/:id/follow         # follow user
DELETE /api/users/:id/follow         # unfollow
POST   /api/users/:id/block          # block user
DELETE /api/users/:id/block          # unblock
```

## GATHERINGS

```
GET    /api/gatherings/recommended   # top pick (algorithm)
GET    /api/gatherings/feed          # paginated feed
GET    /api/gatherings/templates     # creation templates
POST   /api/gatherings               # create gathering
GET    /api/gatherings/:id           # gathering detail
PATCH  /api/gatherings/:id           # edit (host only)
DELETE /api/gatherings/:id           # cancel (host only)
POST   /api/gatherings/:id/join      # join
POST   /api/gatherings/:id/maybe     # express interest
POST   /api/gatherings/:id/save      # bookmark
DELETE /api/gatherings/:id/leave     # leave
GET    /api/gatherings/:id/attendees # attendee list
POST   /api/gatherings/:id/feedback  # emoji rating
GET    /api/gatherings/:id/calendar  # .ics download
```

## POSTS

```
GET    /api/posts/feed               # paginated feed (algorithm)
POST   /api/posts                    # create post
GET    /api/posts/:id                # post detail
DELETE /api/posts/:id                # delete (author only)
POST   /api/posts/:id/like           # toggle like
GET    /api/posts/:id/comments       # paginated comments
POST   /api/posts/:id/comments       # add comment
DELETE /api/posts/:id/comments/:cid  # delete comment
POST   /api/posts/:id/save           # bookmark
DELETE /api/posts/:id/save           # unsave
```

## CONVERSATIONS

```
GET    /api/conversations             # list my conversations
POST   /api/conversations             # create new DM
GET    /api/conversations/:id/messages # paginated messages
POST   /api/conversations/:id/messages # send message
```

## NOTIFICATIONS

```
GET    /api/notifications             # paginated notification feed
PATCH  /api/notifications/read-all    # mark all read
PATCH  /api/notifications/:id/read    # mark one read
```

## UPLOADS

```
POST   /api/uploads/images            # upload image
```

## TAGS

```
GET    /api/tags/presets               # preset tag lists by category
GET    /api/tags/trending              # trending hashtags (autocomplete)
```

## LOCATIONS

```
GET    /api/locations/cities           # city search
GET    /api/locations/schools          # schools by city
```

## HISTORY

```
GET    /api/history                    # browse history
POST   /api/history                    # record view
```

## REPORTS

```
POST   /api/reports                    # report content/user
```
