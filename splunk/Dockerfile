FROM splunk/splunk:6.6.3

RUN apt-get update && \
    apt-get install -y curl jq && \
    rm -rf /var/lib/apt/lists/*

ADD scripts/* /opt/splunk/bin/scripts/
