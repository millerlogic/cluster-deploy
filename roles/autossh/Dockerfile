# Use -e AUTOSSH_ARGS=... to specify the forward switches like -L ... or -R ...
# You'll need either to expose the port you want, use --net=host, or --net=container:name

FROM debian:7

RUN apt-get update

RUN apt-get install openssh-client openssh-server -y
RUN apt-get install autossh -y

RUN adduser -u 28105 --system --group --shell /bin/false \
    --home /var/lib/autossh --disabled-password autossh || echo

USER 28105
CMD while true; do \
    autossh -M 0 -q -N -o ServerAliveCountMax=2 -o ServerAliveInterval=30 \
    -o StrictHostKeyChecking=no $AUTOSSH_ARGS; \
    echo "autossh exited"; sleep 60; echo "trying again"; done
