gearstack
=========

The Ruby on Rails implementation of Gearstack, the gear sharing app.

## TODO

###User authentication, no CSRF
1. Creating users:
    - POST to /users with email, password, and confirmation
    - json response with errors or 200
1. Logging in users (custom sessions controller):
    - POST to /users/sign_in
    - respond with auth token for API calls
1. Authenticate API requests with auth token
1. Log out -> invalidates auth token (DELETE to /users/sign_out)

###User auth, with CSRF
1. First get request sets XSRF cookie
2. Create users:
    - POST to /users/sign_up
        - includes the XSRF token in the POST
    - json with errors or success
3. Signing in:
    - POST to /users/sign_in
    - Rails sets new XSRF token in the cookie
        - All future requests (until sign-out) include token
    - Does signing out invalidate the token?
