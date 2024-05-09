
# CBC Emails before dev team involvement


## Todd Shuster


...Based Lev's back of the napkin math If we had 50 rentals each lasting less than give hours, updating location once eery five minutes per day it would be free to host the servers. If we had a thousand rentals per day it would be under $9 per year. He said sign up could be password free just email address verification (no passwords) or signing in with a google account...

...I said to start we were looking for real time ability to see renters and lessons on a map and have the ability to send up a flare if they are in trouble. He suggested adding a push notification that could tell people to come in immediately if there was a storm etc...


## Dave Tempero

...
From a feature perspective here are some thoughts/ideas for them to consider.
- Ideally the client would have the option to choose an activity/event.  This would drive slightly different behavior (for example rental might be  5 minute GPS updates whereas  race might want every 30 seconds) – maybe race UI shows other racers, rental doesn’t?
- Ideally integrating with mapping software to indicate location would be ideal (and indicate geofence for activity if it exists)
- Facility view could be a web or app view which shows all craft associated with that facility color coded by activity
- Race view/replay could use something like this modified to replay multiple tracks - https://pelmers.com/gpx-replay/ (I know the R2AK has a replay feature where you can slide forward/backward on the timeline)
- From a privacy and misuse perspective it might be a good idea to have a boundary area identified for each operator or event and not report data outside of this.  For example if a client chose an activity that was part of CBC as an operator we could send the client a large perimeter under which the client should send data, but not outside of this.  This would ensure if someone left their phone active we wouldn’t track them wherever they go.  This would be larger than the geofence activity area.  This could be done either server or client side – one advantage to client filtering is it is easier to say the information doesn’t leave the device when outside of the “water boundary”.

Anyway, just some thoughts – I’m interested in what tools and frameworks they are considering.

## Phases Proposed by devs based on initial emails

Phase one features

- Login with google (2fa, never store PID besides location data) - 2 hours
- Client view (map of users current and past locations, help button with link to call for help, set activity type and boat ID), Able to start and stop a trip - 15 hours
- Admin view (map of all users current location (can't see past locations), different activities are different colors, able to switch back and forth between admin and client view) - 15 hours
- Initially only website designed for mobile usage - 6 hours
- manually add users to admin view using database GUI - 1 hour

Phase two features
- Run in background on android - 8 hours
- run in background on ios - 8 hours
- face-lift top bar - 2 hours
- clients can see live lat and long so they can better describe their location on the phone - 1 hour
- clients "send up a flare" which only changes their icon to red on admin panel, so if they are on a call with the community boating center, the center can better identify which boat is calling - 5 hours
- admin can send push notificaiton to all apps user active in the last 20 minutes (example, weather update, or race anoucments) - 4 hours
- if a client forgets to end trip, auto turn off once they reach the comunity boating center parking lot - 4 hours
- auto-delete trip data after 30 days - 4 hours
- host as progressive web app - 6 hours
- only admin can read from database (currently anyone can read or write) - 2 hours
- remove sams api key from application - 3 hours


Additional features after phase three
- publish on android app store - 6 hours
- publish on ios app store - 6 hours
- host on compunity boating center website - 8 hours
- log in with Apple - 1 hour
- log in with email (no password) - 5 hours
- let admin (or super admin?) invite new admin so devs don't need to be involved in user management - 4 hours
- desktop apps (linux, mac, windows) - 3 hours per platform
- geo fencing (if a client goes outside of a certain area, the admin is notified, overlayed on user map) - 6 hours
- admin set custom map views (specific zoom, centerpoint, direction to meet specific use cases)- 12 hours
- if a user forgets to end trip, if they exit a geo fence, the app will auto end the trip - 6 hours
- persistent app notifications that trip is active, to remind users to end trip - 2 hours
- let admin augment user view maps with custom markers (add geo fence, racing marks, notes about hazards, etc.) - 20 hours.
- racers can see each other's locations - 8 hours
- students can see admin's location for lessons/camps - 8 hours
- admin can see client nicknames or phone numbers on map - 3 hours
- if a user doesn't end a trip, but they havn't send any update to the server in the last 15 minutes. flag last known location in case of emergency - 8 hours

