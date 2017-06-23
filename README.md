# docker-squid

Run squid as a caching proxy in a docker container. 

## Build

```bash
docker build -t docker-squid github.com/engelhardtm/docker-squid
```

## Quickstart

```bash
docker run -d -p 3128:3128 engelhardtm/docker-squid
```