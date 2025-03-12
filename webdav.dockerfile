FROM debian:latest

ARG OWNER_NAME
ARG OWNER_ID
ARG CONFIG_FILE
ARG AUTH_FILE

ENV OWNER_NAME ${OWNER_NAME}
ENV OWNER_ID ${OWNER_ID}
ENV CONFIG_FILE=${CONFIG_FILE}
ENV AUTH_FILE=${AUTH_FILE}

RUN apt-get update && apt-get install -y nginx-extras

RUN groupadd --gid ${OWNER_ID} ${OWNER_NAME}
RUN useradd -s /bin/bash -u ${OWNER_ID} -g ${OWNER_NAME} --no-create-home ${OWNER_NAME}

COPY ${CONFIG_FILE} /etc/nginx/nginx.conf
COPY ${AUTH_FILE} /etc/nginx/.htpasswd

# Append the user directive to use the owner name defined in the .env file
RUN sed -i "1 i user ${OWNER_NAME} ${OWNER_NAME};" /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
