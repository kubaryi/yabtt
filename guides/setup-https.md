# Set up HTTPS

In order to enable HTTPS, we need three additional files:

- `cert.pem` - A CA-signed certificate from a trusted Certificate Authority
- `privkey.pem` - A private key associated with a valid certificate
- `chain.pem` - An additional certificate that make up the ['CA chain'](https://en.wikipedia.org/wiki/Chain_of_trust)

If you already have the above files, you can start [here](#manually-manage-certificate-files). If you don't, [here](#obtain-certificate-files-by-cerbot) you can learn how to get them (signed by [Let's Encrypt](https://letsencrypt.org)) automatically and FREE by [Cerbot](https://certbot.eff.org) or [acme.sh](https://github.com/acmesh-official/acme.sh).

## Manually manage certificate files

We just need to make sure that the certificate files are located under the `/etc/yabtt/ssl/` path in the container. We can easily do it by Docker's ['Bind mounts'](https://docs.docker.com/storage/bind-mounts) function.

We need to store the certificate files in the same local directory (please make sure that the file name is correct) and bind the path into the container.

```shell
docker run -d \
  --name yabtt \
  -v /path/for/certs/:/etc/yabtt/ssl/ \
  -p 8080:8080 \
  ghcr.io/mogeko/yabtt:latest
```

Or run with Docker Compose:

```yml
---
version: 2.1
services:
  yabtt:
    image: ghcr.io/mogeko/yabtt:latest
    volumes:
      - /path/for/certs/:/etc/yabtt/ssl/
    container_name: yabtt
    ports:
      - 8080:8080
```

## Obtain certificate files by Cerbot

## Obtain certificate files by acme.sh
