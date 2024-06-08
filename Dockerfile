FROM quay.io/soketi/soketi:1.4-16-debian

COPY ./config/config.json /app/bin/config.json

ENV SOKETI_DEBUG='1'
ENV SOKETI_APP_MANAGER_DRIVER='dynamodb'
ENV SOKETI_APP_MANAGER_DYNAMODB_TABLE='soketi-apps'
ENV SOKETI_APP_MANAGER_DYNAMODB_REGION='ap-northeast-2'

# ENV AWS_ACCESS_KEY_ID=''
# ENV AWS_SECRET_ACCESS_KEY=''
# ENV SOKETI_APP_MANAGER_DYNAMODB_ENDPOINT='http://dynamodb:8000'

# CMD [ "node", "/app/bin/server.js", "start", "--config=/app/bin/config.json" ]
CMD [ "node", "/app/bin/server.js", "start" ]