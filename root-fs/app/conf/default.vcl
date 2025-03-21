vcl 4.1;

backend default {
    .host = "###BACKEND_HOST###";
    .port = "###BACKEND_PORT###";
}

sub vcl_recv {
    # Bypass cache if the request contains a "BYPASSCACHE" cookie
    if (req.http.Cookie ~ "BYPASSCACHE") {
        return (pass);
    }

    # Cache specific paths and static assets
    if (req.url ~ "load.php" ||
        req.url ~ "\.(js|css|woff2?|ttf|otf|eot|svg|gif|png|jpe?g|webp|ico)(\?.*)?$") {
        return (hash);
    }

    # Pass through all other requests
    return (pass);
}

sub vcl_backend_response {
    # Cache load.php for 5 minutes
    if (bereq.url ~ "load.php") {
        set beresp.ttl = 5m;
    }

    # Cache static files (JS, CSS, Fonts, Images) for 30 minutes
    if (bereq.url ~ "\.(js|css|woff2?|ttf|otf|eot|svg|gif|png|jpe?g|webp|ico)(\?.*)?$") {
        set beresp.ttl = 30m;
    }

    # Cache dynamically served images (e.g. "dynamic file dispatcher")
    if ( beresp.http.Content-Type ~ "image/(png|jpeg|jpg|gif|webp)") {
        set beresp.ttl = 30m;
    }
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