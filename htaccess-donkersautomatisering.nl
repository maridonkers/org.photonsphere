RewriteEngine On
RewriteCond %{HTTPS} !=on
# This checks to make sure the connection is not already HTTPS
RewriteRule ^/?(.*) https://%{HTTP_HOST}%{REQUEST_URI} [R,L]
Header set Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" env=HTTPS

Redirect 301 /blog/2011/06/29/serializing-arbitrarily-sized-objects-to-a-random-access-file https://photonsphere.org/post/2011-06-29-serializing-any-size-objects-to-a-random-access-file
Redirect 301 /2011/06/29/serializing-arbitrarily-sized-objects-to-a-random-access-file https://photonsphere.org/post/2011-06-29-serializing-any-size-objects-to-a-random-access-file

RedirectMatch "/blog/2011/06/29/serializing-arbitrarily-sized-objects-to-a-random-access-file/?$" "https://photonsphere.org/post/2011-06-29-serializing-any-size-objects-to-a-random-access-file/"
RedirectMatch "/2011/06/29/serializing-arbitrarily-sized-objects-to-a-random-access-file/?$" "https://photonsphere.org/post/2011-06-29-serializing-any-size-objects-to-a-random-access-file/"
