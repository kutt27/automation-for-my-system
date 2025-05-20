## Introduction

**ConvertX** is a powerful, self-hosted file converter that supports over a thousand formats. Running ConvertX on a Raspberry Pi is efficient and cost-effective, letting you convert files securely on your own hardware.  
With **Docker Compose**, you can easily deploy and manage ConvertX using a simple configuration file, making setup and updates straightforward.

Convertx repo link: https://github.com/C4illin/ConvertX

#### My-system

Hardware: Raspberry Pi Model 4B(4GB RAM)
Hosting: Locally on docker-compose

---

## Docker Compose Configuration

```yaml
services:
  convertx:
    image: ghcr.io/c4illin/convertx
    container_name: convertx
    restart: unless-stopped
    ports:
      - "5000:3000"
    environment:
      - JWT_SECRET=yourSuperSecretJWTstringHere #you can update the token with a better string
      - HTTP_ALLOWED=true #added because of login redirection through registration
    volumes:
      - ./data:/app/data
```

---

Just save this as `docker-compose.yml` and run `docker compose up -d` on your Raspberry Pi to start using ConvertX!

---

Directory Structure:
```bash
kutt@raspberrypi:~/convertx $ ls
data  docker-compose.yml

```
