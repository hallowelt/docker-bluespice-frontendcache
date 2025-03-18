# BlueSpice "Frontend-Cache" service

This currently is just a regular Varnish server.

ATTENTION: Currently this image is only meant to be used in a `bluespice-deploy` setup. The `wiki-web` service is hardcoded as a backend!

In a `docker-compose.yml` it must be wired like this:
```yaml
  frontendcache:
	image: bluespice/frontendcache:4.5
	environment:
		VIRTUAL_HOST: ${WIKI_HOST}
		VIRTUAL_PORT: 80
		VIRTUAL_PATH: /
	tmpfs:
		- /var/lib/varnish/varnishd:exec
```

Make sure to remove `VIRTUAL_HOST`, `VIRTUAL_PORT` and `VIRTUAL_PATH` from the `wiki-web` service!

## How to release a new version

### Build a new version of the image
```sh
docker build -t bluespice/frontendcache:latest .
```

### Apply proper tags
HINT: We align the image tags with the version of BlueSpice that it is compatible with.

Example:
```sh
docker tag bluespice/frontendcache:latest bluespice/frontendcache:4
docker tag bluespice/frontendcache:latest bluespice/frontendcache:4.4
docker tag bluespice/frontendcache:latest bluespice/frontendcache:4.4.1
```

### Push the image to the registry
Example:
```sh
docker push bluespice/frontendcache:latest
docker push bluespice/frontendcache:4
docker push bluespice/frontendcache:4.4
docker push bluespice/frontendcache:4.4.1
```

## Testing
Install `trivy` and run `trivy image bluespice/frontendcache` to check for vulnerabilities.