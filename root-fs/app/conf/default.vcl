vcl 4.1;

# Inspired by https://raw.githubusercontent.com/CanastaWiki/Canasta-DockerCompose/refs/heads/main/config/default.vcl

backend default {
    .host = "###BACKEND_HOST###";
    .port = "###BACKEND_PORT###";
    .first_byte_timeout = 120s;
    .connect_timeout = 30s;
    .between_bytes_timeout = 120s;
}

acl purge {
    "###BACKEND_HOST###";
}

sub vcl_recv {
    # Bypass cache if the request contains a "BYPASSCACHE" cookie
    if (req.http.Cookie ~ "BYPASSCACHE") {
        return (pass);
    }

    # Serve objects up to 2 minutes past their expiry if the backend
    # is slow to respond.
    # set req.grace = 120s;

    set req.http.X-Forwarded-For = req.http.X-Forwarded-For + ", " + client.ip;

    set req.backend_hint= default;

    # This uses the ACL action called "purge". Basically if a request to
    # PURGE the cache comes from anywhere other than localhost, ignore it.
    if (req.method == "PURGE") {
        if (!client.ip ~ purge) {
            return (synth(405, "Not allowed."));
        } else {
            return (purge);
        }
    }

    # Pass requests from logged-in users directly.
    # Only detect cookies with "UserID" suffix in its name.
    # Cookie names containing "session" or "UserName" will also appear for _logged-out_ users,
    # or users that have not completed the login process,so they are not suitable for this check.
    if (req.http.Authorization || req.http.Cookie ~ "UserID=") {
        return (pass);
    } /* Not cacheable by default */

    # Pass anything other than GET and HEAD directly.
    if (req.method != "GET" && req.method != "HEAD") {
        return (pass);
    } /* We only deal with GET and HEAD by default */

    # Force lookup if the request is a no-cache request from the client.
    if (req.http.Cache-Control ~ "no-cache") {
        ban(req.url);
    }

    # normalize Accept-Encoding to reduce vary
    if (req.http.Accept-Encoding) {
        if (req.http.User-Agent ~ "MSIE 6") {
        unset req.http.Accept-Encoding;
        } elsif (req.http.Accept-Encoding ~ "gzip") {
        set req.http.Accept-Encoding = "gzip";
        } elsif (req.http.Accept-Encoding ~ "deflate") {
        set req.http.Accept-Encoding = "deflate";
        } else {
        unset req.http.Accept-Encoding;
        }
    }

    return (hash);
}

sub vcl_pipe {
    # Note that only the first request to the backend will have
    # X-Forwarded-For set.  If you use X-Forwarded-For and want to
    # have it set for all requests, make sure to have:
    # set req.http.connection = "close";

    # This is otherwise not necessary if you do not do any request rewriting.

    set req.http.connection = "close";
}

# Called if the cache has a copy of the page.
sub vcl_hit {
    if (!obj.ttl > 0s) {
        return (pass);
    }
}

# Called after a document has been successfully retrieved from the backend.
sub vcl_backend_response {
    # Don't cache 50x responses
    if (beresp.status == 500 || beresp.status == 502 || beresp.status == 503 || beresp.status == 504) {
        set beresp.uncacheable = true;
        return (deliver);
    }

    if (beresp.ttl < 48h) {
        set beresp.ttl = 48h;
    }

    if (!beresp.ttl > 0s) {
        set beresp.uncacheable = true;
        return (deliver);
    }

    if (beresp.http.Set-Cookie) {
        set beresp.uncacheable = true;
        return (deliver);
    }

    if (beresp.http.Authorization && !beresp.http.Cache-Control ~ "public") {
        set beresp.uncacheable = true;
        return (deliver);
    }

    return (deliver);
}

sub vcl_deliver {
	# Add a header to indicate a cache hit
	if (obj.hits > 0) {
		set resp.http.X-Cache = "HIT";
	} else {
		set resp.http.X-Cache = "MISS";
	}
	unset resp.http.Via;
	unset resp.http.X-Powered-By;
	unset resp.http.X-Varnish;
}