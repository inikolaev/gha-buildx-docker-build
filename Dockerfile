#######################################
# Base layer with global dependencies #
#######################################
FROM python:3.10-slim as base

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends tini apt-transport-https libsodium-dev=1.0.18-1 \
    && rm -rf /var/lib/apt/lists/* \
    && ln -s /usr/bin/tini /sbin/tini

RUN groupadd -r -g 1000 user \
    && adduser --uid 1000 --gid 1000 --gecos "" --disabled-password --disabled-login user

ENV PYTHONPATH=/app

RUN chown -R user:user /app


###################################
# Layer with release dependencies #
###################################
FROM base as base-release

WORKDIR /app

COPY Pipfile /app
COPY Pipfile.lock /app

RUN pip --no-cache-dir install pipenv \
    && pipenv install --system --deploy \
    && rm -rf /root/.cache


################################
# Layer with test dependencies #
################################
FROM base-release as base-test

WORKDIR /app

# Install dev dependencies
RUN pipenv install --system --deploy --dev


#################
# Release layer #
#################
FROM base-release as release

WORKDIR /app


##############
# Test Layer #
##############
FROM base-test as test

WORKDIR /app


####################
# Production layer #
####################
FROM release as production
