FROM alpine:3.8

ENV ANSIBLE_VERSION 2.6.0

ENV RUNTIME_DEPENDENCIES \
	tar \
	git \
	bash \
	curl \
	python \
	sshpass \
	openssh-client \
	py-boto \
	py-dateutil \
	py-httplib2 \
	py-jinja2 \
	py-paramiko \
	py-pip \
	py-yaml \
	ca-certificates


# Install build dependencies
RUN apk --update add --virtual build-dependencies \
	gcc \
	musl-dev \
	libffi-dev \
	openssl-dev \
	python-dev

# Install runtime dependencies
RUN apk add --no-cache ${RUNTIME_DEPENDENCIES}

# Upgrare pip
RUN pip install --upgrade pip python-keyczar docker-py

# Install ansible
RUN pip install ansible==${ANSIBLE_VERSION}

RUN mkdir /etc/ansible/ /ansible
RUN echo "[local]" >> /etc/ansible/hosts && \
    echo "localhost" >> /etc/ansible/hosts

# Cleanup
RUN apk del build-dependencies && \
    rm -rf /var/cache/apk/*

ENV ANSIBLE_GATHERING smart
ENV ANSIBLE_HOST_KEY_CHECKING false
ENV ANSIBLE_RETRY_FILES_ENABLED false
ENV ANSIBLE_ROLES_PATH /ansible/playbooks/roles
ENV ANSIBLE_SSH_PIPELINING True
ENV PYTHONPATH /ansible/lib
ENV PATH /ansible/bin:$PATH
ENV ANSIBLE_LIBRARY /ansible/library

WORKDIR /ansible/playbooks

# Add custom scripts
COPY scripts/* /usr/local/bin
RUN chmod -R +x /usr/local/bin/
