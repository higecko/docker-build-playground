FROM ubuntu:18.04
ARG BDS_VERSION=0

ENV VERSION=$BDS_VERSION

RUN groupadd -r -g 1000 minecraft && \
    useradd --no-log-init -r -g minecraft -u 1000 minecraft

# Install dependencies
RUN apt-get update && \
    apt-get install -y unzip curl libcurl4 libssl1.0.0 screen gosu && \
    rm -rf /var/lib/apt/lists/*

# Download and extract the bedrock server
RUN if [ "$VERSION" = "latest" ] ; then \
        LATEST_VERSION=$( \
            curl -v --silent  https://www.minecraft.net/en-us/download/server/bedrock/ 2>&1 | \
            grep -o 'https://minecraft.azureedge.net/bin-linux/[^"]*' | \
            sed 's#.*/bedrock-server-##' | sed 's/.zip//') && \
        export VERSION=$LATEST_VERSION && \
        echo "Setting VERSION to $LATEST_VERSION" ; \
    else echo "Using VERSION of $VERSION"; \
    fi && \
    curl https://minecraft.azureedge.net/bin-linux/bedrock-server-${VERSION}.zip --output bedrock-server.zip && \
    unzip bedrock-server.zip -d bedrock-server && \
    rm bedrock-server.zip && \
    chown -R minecraft:minecraft /bedrock-server && \
    chmod ug=rx,o=r /bedrock-server/bedrock_server

# Create a separate folder for configurations move the original files there and create links for the files
RUN mkdir /bedrock-server/config && \
    mkdir /bedrock-server/worlds && \
    mkdir /bedrock-server/defaultconfig && \
    chmod a+rw /bedrock-server/worlds && \
    chmod a+rw /bedrock-server/config && \
    chmod a+rw /bedrock-server/defaultconfig && \
    mv /bedrock-server/server.properties /bedrock-server/defaultconfig && \
    mv /bedrock-server/permissions.json /bedrock-server/defaultconfig && \
    mv /bedrock-server/whitelist.json /bedrock-server/defaultconfig

COPY ./docker-entrypoint.sh /
COPY ./start-server.sh /

RUN chmod a+x /docker-entrypoint.sh && \
    chmod a+x /start-server.sh

# RUN echo "screen -x \`screen -ls | grep Attached | cut -f2\`\nexit" >> /etc/bash.bashrc

EXPOSE 19132/udp

VOLUME /bedrock-server/worlds /bedrock-server/config
WORKDIR /bedrock-server

ENV LD_LIBRARY_PATH=.
ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "./bedrock_server" ]
