#
# Ubuntu Dockerfile
#
# https://github.com/dockerfile/ubuntu
#

# Pull base image.
FROM ubuntu:14.04


# Add Project Environment Variables
ENV APP_ROOT /data/web
ENV APP_USER ${APP_USER}
ENV PROJECT_NAME placement
ENV APP_USER_PASSWORD ${APP_USER_PASSWORD}

# Add MySql Environment Variables
ENV MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
    MYSQL_DATABASE=${MYSQL_DATABASE} \
    MYSQL_USER=${MYSQL_USER} \
    MYSQL_PASSWORD=${MYSQL_PASSWORD}

RUN mkdir -p ${APP_ROOT}/${PROJECT_NAME}/static

# Add user
RUN groupadd -r ${APP_USER} \
    && useradd -r -u 1000 -m \
    -g ${APP_USER} ${APP_USER} \
    && adduser ${APP_USER} sudo --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password \
    && echo "${APP_USER}:${APP_USER_PASSWORD}" | sudo chpasswd \
    && sh -c "echo '${APP_USER}    ALL=(ALL:ALL) ALL' >> /etc/sudoers"


# Avoid ERROR: invoke-rc.d: policy-rc.d denied execution of start.
RUN sed -i "s/^exit 101$/exit 0/" /usr/sbin/policy-rc.d

# Install utilities
RUN locale-gen ru_RU.UTF-8 \
    && echo 'LANG="ru_RU.UTF-8"' > /etc/default/locale \
    && sed -i 's/archive.ubuntu.com\/ubuntu\//ubuntu.volia.net\/ubuntu-archive\//g' /etc/apt/sources.list \
    && sed -i 's/security.ubuntu.com\/ubuntu\//security.ubuntu.volia.net\/ubuntu-archive\//g' /etc/apt/sources.list \
    && apt-get update \
    && apt-get install --assume-yes --force-yes \
        build-essential \
        curl \
        git \
        nano \
        software-properties-common \
        zlib1g-dev


# Install python3.6, pip, mysql
RUN add-apt-repository -y ppa:jonathonf/python-3.6 \
    && apt-get update \
    && { \
        echo "mysql-server-5.6 mysql-server/root_password password ${MYSQL_ROOT_PASSWORD}"; \
        echo "mysql-server-5.6 mysql-server/root_password_again password ${MYSQL_ROOT_PASSWORD}"; \
    } | debconf-set-selections \
    && apt-get -y install --assume-yes --force-yes \
        mysql-server-5.6 \
        mysql-client-5.6 \
        python-pip \
        python3.6 \
        libpq-dev \
        python3.6-dev \
        libffi-dev \
        libssl-dev \
    && curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py" \
    && python get-pip.py \
    && pip install -U pip setuptools


ADD mysql/my.cnf /etc/mysql/conf.d/my.cnf

COPY mysql/entrypoint.sh /data/entrypoint.sh
COPY ./run_services.sh /data/run_services.sh

RUN chmod 755 /data/entrypoint.sh
RUN chmod 755 /data/run_services.sh

EXPOSE 3306/tcp

RUN /data/entrypoint.sh


# Nginx setup
RUN apt-get install -y nginx \
    && rm /etc/nginx/sites-enabled/default

ADD sites-enabled/ /etc/nginx/sites-enabled

EXPOSE 80


# Clean setup
RUN apt-get remove -y curl \
    software-properties-common \
  && rm -rf /var/lib/apt/lists/*

# Set environment variables.
ENV HOME /home

# Define working directory.
WORKDIR /${APP_ROOT}/${PROJECT_NAME}

VOLUME ["/home/crate/Dev/Docker/Images/Ubuntu14.04/web/placement"]

# Define default command.
CMD ["bash"]
