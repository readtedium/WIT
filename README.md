# WIT - W3 Interactive Talk

A Dockerized version of the historical WIT (W3 Interactive Talk) software, originally created by Ari Luotonen at CERN in June 1994.

## About WIT

WIT was one of the first web-based discussion forums, developed at CERN alongside the World Wide Web itself. It allowed users to:

- Create discussion topics
- Add proposals to topics
- Argue for or against proposals
- Build threaded discussions with agree/disagree opinions

This is a modernized version that runs in Docker, making it easy to deploy and share on the web.

## Why Build This?

In part because this software wasn't available on the W3C website, unlike so many other pieces of early Web history. When researching this topic for Tedium, I was really surprised that this very fundamental software was not actually available.

The original code is set in place. But some modest updates to modernize it are also in the folder. If you want to take a stab at running the original software, definitely go for it. But keep in mind that it is 32-year-old forum software and likely has 32 years of security issues hididing within it.

## Quick Start

### Using Pre-Built Image (Recommended)

```bash
# Download the docker-compose file
curl -O https://raw.githubusercontent.com/readtedium/wit/main/docker-compose.yml

# Start WIT (uses pre-built image from GitHub Container Registry)
docker compose up -d

# Access WIT in your browser
open http://localhost:1994
```

### Building Locally

```bash
# Clone the repository
git clone https://github.com/readtedium/wit.git
cd wit

# Build and start
docker compose -f docker-compose.local.yml up -d --build

# Access WIT in your browser
open http://localhost:1994
```

### Using Docker Directly

```bash
# Run pre-built image
docker run -d -p 1994:80 ghcr.io/readtedium/wit:main

# Or build locally
docker build -t wit-server .
docker run -d -p 1994:80 wit-server
```

## Web Server Choice

WIT supports two web servers:

| Server | Pros | Cons |
|--------|------|------|
| **nginx** (default) | Faster, lower memory, better for CGI | More complex config |
| **Apache** | Original compatible, simpler setup | Slower, forks per request |

To switch servers, set `WIT_SERVER` environment variable to `nginx` or `apache` in `docker-compose.yml`.

## Usage

1. **Subscribe**: Visit `/cgi-bin/wit-subscribe` to create your username
2. **Browse Topics**: Visit `/cgi-bin/wit` to see available topics
3. **Create Topics**: Click "New Topic" to start a discussion
4. **Discuss**: Add proposals and arguments to topics
5. **Post**: Browser will prompt for login when posting

## URLs

- **Main Page**: `http://localhost:1994/`
- **Topic List**: `http://localhost:1994/cgi-bin/wit`
- **Subscribe**: `http://localhost:1994/cgi-bin/wit-subscribe`

## Data Persistence

WIT data is stored in a Docker volume named `wit-data`. This ensures your discussions persist across container restarts.

To backup your data:

```bash
docker cp wit-server:/opt/wit/data ./wit-backup
```

To restore data:

```bash
docker cp ./wit-backup/. wit-server:/opt/wit/data
```

## Customization

### Environment Variables

- `WIT_ROOT`: Root directory for WIT files (default: `/opt/wit`)
- `WIT_SERVER`: Web server to use: `nginx` or `apache` (default: `nginx`)

### Ports

By default, WIT runs on port 1994 (year WIT was created). To change this, modify the `ports` section in `docker-compose.yml`:

```yaml
ports:
  - "YOUR_PORT:80"
```

## Architecture

The application consists of:

- **nginx + fcgiwrap** or **Apache**: Serves static files and executes CGI scripts
- **Shell Scripts**: Generate HTML dynamically (original WIT design)
- **Docker Volume**: Persists discussion data

## Historical Context

WIT was created in June 1994 by Ari Luotonen at CERN. It represents one of the earliest web-based discussion systems, built when the World Wide Web was still in its infancy. The original software ran on the CERN HTTPD server and used CERN-specific tools like `cgiparse` and `htadm`.

This modernized version preserves the original functionality while making it accessible on modern systems through Docker.

## License

This software is preserved for historical purposes. The original WIT software was created at CERN.

## Troubleshooting

### Container won't start

Check the logs:
```bash
docker logs wit-server
```

### Permission issues

If you encounter permission errors, ensure the Docker volume has correct permissions:
```bash
docker exec -it wit-server chown -R www-data:www-data /opt/wit/data
```

### Can't access the application

- Ensure the container is running: `docker ps`
- Check if port 1994 is available
- Check container logs: `docker logs wit-server`

### Slow performance

If you experience slowness, switch to nginx (default) if using Apache:
```yaml
environment:
  - WIT_SERVER=nginx
```
