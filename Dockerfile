############################
# STEP 1 build executable binary
############################
FROM golang:1.13.11-alpine AS builder

# # CA Certificates
# # Need curl and ca-certificates packages
# RUN apk add --update --no-cache ca-certificates
# # Update CA certificates.
# RUN update-ca-certificates --fresh -v

# Go requirements.
RUN apk --update add \
    go \
    git \
    musl-dev


# Clone and build ran.
WORKDIR /
RUN git clone https://github.com/m3ng9i/ran
WORKDIR /ran
RUN CGO_ENABLE=0 go build -a -ldflags \
  "-linkmode external -extldflags '-static' -s -w" -o /bin/ran


# Clone swagger-ui.
WORKDIR /
RUN git clone https://github.com/swagger-api/swagger-ui
RUN find /swagger-ui/dist

FROM nginx:1.19-alpine

COPY --from=builder /bin/ran /bin/ran

RUN apk --no-cache add nodejs

ENV API_KEY "**None**"
ENV SWAGGER_JSON "/app/swagger.json"
ENV PORT 8080
ENV BASE_URL ""
ENV SWAGGER_JSON_URL ""

WORKDIR /
COPY --from=builder /swagger-ui/docker/cors.conf /etc/nginx/
COPY --from=builder /swagger-ui/docker/nginx.conf /etc/nginx/
# copy swagger files to the `/js` folder
COPY --from=builder /swagger-ui/dist/* /usr/share/nginx/html/
COPY --from=builder /swagger-ui/docker/run.sh /usr/share/nginx/
COPY --from=builder /swagger-ui/docker/configurator /usr/share/nginx/configurator
RUN chmod +x /usr/share/nginx/run.sh && \
    chmod -R a+rw /usr/share/nginx && \
    chmod -R a+rw /etc/nginx && \
    chmod -R a+rw /var && \
    chmod -R a+rw /var/run

# ENV API_URL "http://127.0.0.1:3333/swagger.yaml"
EXPOSE 8080
EXPOSE 3333

COPY run.sh .
RUN chmod +x run.sh
CMD ["./run.sh"]
