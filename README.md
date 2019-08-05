# nginx-reverse-proxy

nginx reverse proxy with an ephemeral certificate generated on start-up

This container was primarily developed as a sidecar container for an ECS task. It was initially used for .Net Core APIs & webs hosted in ECS Fargate.

## Usage

The container expects the following environment variables to be present:

- `PROXY_ADDRESS`: instruct where nginx will proxy requests
- `DOMAIN`: used for the certificate generation.
- `COUNTRY`: used for the certificate generation.
- `STATE`: used for the certificate generation.
- `LOCALITY`: used for the certificate generation.
- `ORGANIZATION`: used for the certificate generation.
- `ORGANIZATIONAL_UNIT`: used for the certificate generation.
- `EMAIL_ADDRESS`: used for the certificate generation.

### In `docker-compose.yml`

```yml
version: '2'
services:
  web:
    ...
    expose:
      - "80"
  reverse_proxy:
    image: aoggz/nginx-reverse-proxy:latest
    expose:
      - "443:443"
    environment:
      - PROXY_ADDRESS
      - DOMAIN
      - COUNTRY
      - STATE
      - LOCALITY
      - ORGANIZATION
      - ORGANIZATIONAL_UNIT
      - EMAIL_ADDRESS
    links:
      - web
```

### In an ECS task definition

```json
[
  {
    "name": "web",
    "cpu": 8675309,
    "image": "ecr_repository_url_here:latest",
    "memory": 8675309,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80
      }
    ]
  },
  {
    "name": "reverse_proxy",
    "cpu": 8675309,
    "image": "aoggz/nginx-reverse-proxy:latest",
    "memory": 8675309,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 443,
        "hostPort": 443
      }
    ],
    "environment": [
      {
        "name": "DOMAIN",
        "value": "your-super-awesome-doma.in"
      },
      {
        "name": "PROXY_ADDRESS",
        "value": "127.0.0.1"
      },
      {
        "name": "COUNTRY",
        "value": "US"
      },
      {
        "name": "STATE",
        "value": "PA"
      },
      {
        "name": "LOCALITY",
        "value": "Pittsburgh"
      },
      {
        "name": "ORGANIZATIONAL_UNIT",
        "value": "Testing enterprises, ltd."
      },
      {
        "name": "EMAIL_ADDRESS",
        "value": "test@test.com"
      },
    ]
  }
  ...
]
```
