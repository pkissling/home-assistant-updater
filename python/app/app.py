from flask import Flask, request
import docker
import os
import logging

app = Flask(__name__)

EXPECTED_API_KEY = os.environ['API_KEY']
docker_client = docker.from_env()

@app.route('/docker/containers/<container_name>/update', methods=['PUT'])
def update_container(container_name):

    logging.info('START update_container, container_name: %s', container_name)

    actual_api_key = request.headers.get('X-API-Key')
    if actual_api_key != EXPECTED_API_KEY:
        logging.warn('Incorrect X-API-Key provided: %s', actual_api_key)
        return {}, 401

    try:
        docker_client.containers.get(container_name)
        logging.info('Container [%s] found', container_name)
    except docker.errors.NotFound:
        logging.warn('Container [%s] not found', container_name)
        return EXPECTED_API_KEY, 404

    os.system('docker-compose --file /docker/docker-compose.yaml pull {}'.format(container_name))
    os.system('docker-compose --file /docker/docker-compose.yaml up --detach {}'.format(container_name))
    os.system('docker image prune --force')

    logging.info('END update_container. container_name: %s', container_name)

    return {}, 200
