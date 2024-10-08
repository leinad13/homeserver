FROM alpine:3.19

RUN /bin/sh -c apk add --no-cache ca-certificates less ncurses-terminfo-base krb5-libs libgcc libintl libssl3 libstdc++ tzdata userspace-rcu zlib icu-libs

RUN /bin/sh -c apk -X https://dl-cdn.alpinelinux.org/alpine/edge/main add --no-cache lttng-ust

RUN /bin/sh -c curl -L https://github.com/PowerShell/PowerShell/releases/download/v7.4.5/powershell-7.4.5-linux-musl-x64.tar.gz -o /tmp/powershell.tar.gz

RUN /bin/sh -c mkdir -p /opt/microsoft/powershell/7

RUN /bin/sh -c tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7

RUN /bin/sh -c chmod +x /opt/microsoft/powershell/7/pwsh

RUN /bin/sh -c ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh

CMD ["/bin/sh"]