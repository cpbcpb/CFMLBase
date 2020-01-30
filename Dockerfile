FROM amazonlinux:2

# We probably should add some labels. Reference: https://docs.docker.com/config/labels-custom-metadata/
LABEL version="1.0"
LABEL description="A Base Image\
for coldFusion applications with commandbox."

# We add the commandbox repo definition so we can install our software.
COPY commandbox.repo /etc/yum.repos.d/commandbox.repo

RUN yum update --security -y && \
    yum install -y \
        java-1.8.0 \
        commandbox-4.8.0-1 \
        which && \
    rm -rf /var/cache/yum /var/lib/yum && \
    yum clean all

ENV WORK_ENVIRONMENT=DEVELOP \
    JAVA_MAXHEAP=1024 \
    WEB_PORT=8080

# I changed /cfml to /web for testing out taxlien
ONBUILD WORKDIR /web
ONBUILD COPY server.json ./

# external libs, e.g Redis and AWS
ONBUILD COPY lib lib

# Pre-warm servlet container
# I changed wwwroot to root for testing out taxlien
ONBUILD RUN mkdir ROOT && \
    box server start && box server stop && \
    box artifacts clean --force

# ONBUILD RUN echo "<H1>Hello.</H1> Blank project here. Did you forget to bind your volume?" > /web/ROOT/index.cfm 

# TODO: setup healthcheck, healthcheck should probably also be in onbuild?
# HEALTHCHECK --interval=20s --timeout=30s --retries=15 CMD curl --fail ${HEALTHCHECK_URI} || exit 1
# TODO: can delete lib and server.json from this CPBCPB
EXPOSE 8080 8443

CMD ["box","server","start","console=true"]