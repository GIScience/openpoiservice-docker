FROM debian:stable

# Removed sources list
RUN rm /etc/apt/sources.list


# Add stable & unstable repo
COPY preferences/stable.list /etc/apt/sources.list.d/stable.list
COPY preferences/unstable.list /etc/apt/sources.list.d/unstable.list

# Set `stable` to default
COPY preferences/default-releases /etc/apt/apt.conf.d/my-default-release

RUN apt-get update
RUN apt-get install -y postgresql-common netcat wget
RUN apt-get install -y -t unstable postgresql-12 postgresql-client-12 postgresql-12-postgis-3 postgresql-12-postgis-3-scripts

# Open port 5432 so linked containers can see them
EXPOSE 5432

# Run any additional tasks here that are too tedious to put in
# this dockerfile directly.
ADD env-data.sh /env-data.sh
ADD setup.sh /setup.sh
RUN chmod +x /setup.sh
RUN /setup.sh

ADD locale.gen /etc/locale.gen
RUN /usr/sbin/locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
RUN update-locale ${LANG}

# We will run any commands in this when the container starts
ADD docker-entrypoint.sh /docker-entrypoint.sh
ADD setup-conf.sh /
ADD setup-database.sh /
ADD setup-pg_hba.sh /
ADD setup-replication.sh /
ADD setup-user.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT /docker-entrypoint.sh