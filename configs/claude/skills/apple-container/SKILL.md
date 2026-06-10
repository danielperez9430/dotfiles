---
name: apple-container
description: Apple Container OCI toolkit for macOS 26 — run Linux containers as lightweight VMs on Apple Silicon. Docker-compatible CLI (build, run, stop, logs). Use this skill when the user mentions Apple Container, container build, container run, or wants to containerize a project without Docker Desktop.
---

# Apple Container — macOS-Native OCI Runtime

Apple Container ([github.com/apple/container](https://github.com/apple/container)) creates and runs Linux containers as lightweight virtual machines on Apple Silicon Macs. It consumes and produces OCI-compatible images and uses a CLI nearly identical to Docker. Written in Swift, optimized for macOS 26+.

**Key difference from Docker**: containers run as VMs (not shared-kernel), so they get their own Linux kernel but with near-native performance via macOS virtualization.

---

## Prerequisites & Installation

- **Hardware**: Mac with Apple Silicon (M1/M2/M3/M4)
- **OS**: macOS 26+
- **Install**: download signed `.pkg` from [GitHub Releases](https://github.com/apple/container/releases) → installs to `/usr/local`
- **Update**: `update-container.sh`
- **Uninstall**: `uninstall-container.sh`

After install, start the daemon once (survives restarts):

```bash
container system start
```

---

## CLI Quick Reference

Apple Container mirrors Docker's CLI surface. The tool is `container`, subcommands use spaces (not hyphens).

### Build

```bash
container build -t <name>:<tag> .
container build --target <stage> -t <name>:<tag> .
container build -f <path/to/Dockerfile> -t <name>:<tag> .
container build --no-cache -t <name>:<tag> .
```

Reads `Dockerfile` first, falls back to `Containerfile`. Respects `.dockerignore` and `.containerignore`.

### Run

```bash
container run -d --rm --name <name> -p <host>:<container> --env-file .env <image>
container run -it <image> /bin/sh
container run -d --name web -p 8080:80 -v /host/path:/container/path nginx:latest
```

Key flags: `-d` (detach), `--rm` (remove on stop), `-p` (publish port), `-v` (bind mount), `-e` (env var), `--env-file`, `-it` (interactive tty), `--cpus`, `--memory`, `--name`

### Manage

```bash
container list                   # running containers
container list -a                # all containers
container stop <id>              # graceful stop
container kill <id>              # force kill
container delete <id>            # remove container
container logs -f <id>           # follow logs
container exec -it <id> /bin/sh  # shell into container
container inspect <id>           # JSON details
container stats <id>             # live resource usage
container prune                  # remove stopped containers
```

### Images

```bash
container image list             # local images
container image pull <ref>       # pull from registry
container image push <ref>       # push to registry
container image tag <src> <dst>  # re-tag
container image delete <img>     # remove image
container image prune -a         # remove unused images
```

### Builder (BuildKit)

```bash
container builder start          # start build daemon
container builder stop           # stop (frees ~2GB RAM)
container builder status         # check if running
```

The builder auto-starts on `container build`. Stop it after building to free resources — it's only needed during builds.

### Networks & Volumes

```bash
container network create <name> --subnet 192.168.100.0/24
container network list
container volume create <name> -s 1G
container volume list
container volume prune            # remove unused volumes
```

---

## Project Makefile Template

Drop this into any project to standardize Apple Container workflows:

```makefile
NAME       := $(shell basename $(CURDIR))
IMAGE_PROD := $(NAME):prod
IMAGE_DEV  := $(NAME):dev
PORT       := 3001
DEVPORT    := 3000

.DEFAULT_GOAL := help

.PHONY: help build build-dev run dev stop logs shell clean inspect stats all

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-14s\033[0m %s\n", $$1, $$2}'

build: ## Build production image
	container build --target runner -t $(IMAGE_PROD) .
	@container builder stop 2>/dev/null || true

build-dev: ## Build dev image (with devDeps)
	container build --target dev -t $(IMAGE_DEV) .
	@container builder stop 2>/dev/null || true

run: ## Start production container
	container run -d --rm --name $(NAME) -p $(PORT):$(PORT) --env-file .env $(IMAGE_PROD)

dev: build-dev ## Start dev with hot-reload
	container run -d --rm --name $(NAME)-dev -p $(DEVPORT):$(DEVPORT) \
		--env-file .env -v "$(CURDIR)/src:/app/src" $(IMAGE_DEV)

stop: ## Stop all containers
	-container stop $(NAME) 2>/dev/null; true
	-container stop $(NAME)-dev 2>/dev/null; true

logs: ## Follow production logs
	container logs -f $(NAME)

logs-dev: ## Follow dev logs
	container logs -f $(NAME)-dev

shell: ## Shell into production
	container exec -it $(NAME) /bin/sh

shell-dev: ## Shell into dev
	container exec -it $(NAME)-dev /bin/sh

clean: stop ## Remove everything
	-container delete $(NAME) 2>/dev/null; true
	-container delete $(NAME)-dev 2>/dev/null; true
	-container image delete $(IMAGE_PROD) 2>/dev/null; true
	-container image delete $(IMAGE_DEV) 2>/dev/null; true

inspect: ## Show container details
	container inspect $(NAME)

stats: ## Live resource usage
	container stats $(NAME)

all: build run ## Build + start production

start-builder: ## Start build daemon
	container builder start

stop-builder: ## Stop build daemon (frees ~2GB)
	-container builder stop 2>/dev/null; true
```

---

## Dockerfile Pattern

Apple Container reads standard Dockerfiles. Recommended multi-stage pattern:

```dockerfile
# Stage 1 — Build
FROM node:24-alpine AS builder
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci --ignore-scripts
COPY . .
RUN npm run build

# Stage 2 — Production runner
FROM node:24-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=3001
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public
EXPOSE 3001
CMD ["node", "server.js"]

# Stage 3 — Dev (hot-reload via bind mounts)
FROM node:24-alpine AS dev
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci
COPY . .
CMD ["npm", "run", "dev"]
```

Key points:
- Always use `linux/arm64` base images (Apple Silicon native, no emulation)
- `--target <stage>` to build a specific stage
- Bind-mount source dirs in dev (`-v`) for hot-reload
- `.dockerignore` should exclude `node_modules`, `.next`, `.git`, `.env*`

---

## Troubleshooting

### `container: command not found`
The daemon isn't running: `container system start`

### Container starts but curl returns empty
The app might still be booting. Check logs: `container logs <id>`. Next.js/Turbopack takes a few seconds on first start.

### Wrong CMD running (dev server instead of production)
You built without `--target`. `container build` without `--target` uses the last stage in the Dockerfile as default. Always specify `--target runner` for production builds.

### Port already in use
```bash
container list  # find the container using that port
container stop <id> && container delete <id>
```

### Builder consuming ~2GB RAM after build
This is the BuildKit daemon. It auto-starts and stays running. Stop it after builds: `container builder stop`

### Bind mounts not syncing changes
Apple Container bind mounts should sync instantly. If not, try restarting the container. For config file changes (package.json, next.config.ts), rebuild the image — bind mounts only cover the directories you explicitly mount.

### Image pull slow or failing
Check network connectivity. For private registries: `container registry login <server>`

---

## Key Differences from Docker

| Docker | Apple Container |
|---|---|
| `docker` | `container` |
| `docker compose` | not available (use Makefile) |
| shared kernel | lightweight VM per container |
| Docker Desktop ~4GB RAM | daemon ~200MB + builder ~2GB (only during builds) |
| Linux, macOS, Windows | macOS 26+ only |
| BuildKit always running | Builder is explicit, can be stopped |
| anonymous volumes auto-cleanup with `--rm` | anonymous volumes do NOT auto-cleanup with `--rm` |