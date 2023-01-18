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

If you don't have an available certificate yet, you can obtain one for **free** by Cerbot, the official [ACME](https://datatracker.ietf.org/doc/html/rfc8555) software provided by Let's Encrypt.

This certificate will be **valid for 90 days**. After expiration, Cerbot will **automatically renew** it for 90 days (as long as Cerbot does not shut down, it will be permanently valid).

As we recommend, it would be a good idea to deploy Cerbot as a container. To this end, Let's Encrypt provides an official [Docker container](https://hub.docker.com/r/certbot/certbot). At the same time, Let's Encrypt has cooperation with many cloud service providers. If your network infrastructure provider is on this [list](https://hub.docker.com/u/certbot), you can choose a container optimized specifically for your provider. For example, to use Certbot for [Amazon Route 53](https://aws.amazon.com/route53), you'd use [`certbot/dns-route53`](https://hub.docker.com/r/certbot/dns-route53).

```yml
---
version: 2.1

services:
  certbot:
    image: certbot/dns-route53
    command: certonly --dns-route53 -d example.com --agree-tos
    environment:
      - AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
      - AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
    volumes:
      - certificates:/etc/letsencrypt/live/example.com/
    container_name: certbot

  yabtt:
    image: ghcr.io/mogeko/yabtt:latest
    volumes:
      - certificates:/etc/yabtt/ssl/
    container_name: yabtt
    depends_on:
      - certbot
    ports:
      - 8080:8080

volumes:
  certificates:
```

Read more [documents about `certbot/certbot`](https://eff-certbot.readthedocs.io/en/stable/install.html#alternative-1-docker).

Read more [documents about `certbot/dns-route53`](https://certbot-dns-route53.readthedocs.io/en/stable).

## Obtain certificate files by acme.sh

If you don't like Cerbot, you can also use acme.sh to obtain certificate files.

Similar to Cerbot, acme.sh also supports deploying it as a container, the same automatic renew when the certificate expires. It also supports Amazon Route 53.

```yml
---
version: 2.1

services:
  acme.sh:
    image: neilpang/acme.sh
    command: --issue --dns dns_aws -d example.com
    environment:
      - AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
      - AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
    volumes:
      - certificates:/acme.sh
    container_name: acme.sh

  yabtt:
    image: ghcr.io/mogeko/yabtt:latest
    volumes:
      - certificates:/etc/yabtt/ssl/
    container_name: yabtt
    depends_on:
      - acme.sh
    ports:
      - 8080:8080

volumes:
  certificates:
```

The [official documents](https://github.com/acmesh-official/acme.sh/wiki) for acme.sh/

Learn more about [run acme.sh in container](https://github.com/acmesh-official/acme.sh/wiki/Run-acme.sh-in-docker).

Learn more about [use Amazon Route53 domain API](https://github.com/acmesh-official/acme.sh/wiki/dnsapi#10-use-amazon-route53-domain-api).

## R.I.P. Mr. Peter

<img src="https://user-images.githubusercontent.com/26341224/212175638-94333d89-f5fc-4975-b498-a111e81347ca.jpg"
     title="Peter Eckersley in San Francisco (March 2022)"
     alt="Peter Eckersley"
     width="400px"
     />

He is [Peter Eckersley](https://www.eff.org/about/staff/peter-eckersley).

He and his friends founded Let's Encrypt.

His work allows every website to obtain HTTPS certificates for free.

Unfortunately, he died on September 2, 2022[^1].

Let's say: **Thank you, Peter!** :hearts:

[^1]: [Peter Eckersley, may his memory be a blessing](https://community.letsencrypt.org/t/peter-eckersley-may-his-memory-be-a-blessing/183854)
