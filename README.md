# cdn77-devops-task
Hiring take-home assignment for a DevOps position at CDN77


## Introduction

The assignment is worked out using [docker-compose](https://docs.docker.com/compose/). Individual services are realized as docker containers, most of which are based on the Debian image. This is sufficient for configuring services which only need copying files from host or setting environment variables. Additional configuration files are templated and  pushed using Ansible.

## Deployed services
|  Service name  | Exposed ports (on hypervisor) | Description                                                           |
|:--------------:|-------------------------------|-----------------------------------------------------------------------|
| nginx-1        | :8080                         | Web server hosting static content.                                    |
| nginx-2        | :8081                         | Reverse proxy caching server for nginx-1                              |
| kafka-1        | :9000                         | Kafka broker #1, set up as a cluster named 'local-kafka'              |
| kafka-2        | :9001                         | Kafka broker #2, set up as a cluster named 'local-kafka'              |
| kafka-ui       | :8082                         | WebUI for Kafka                                                       |
| zookeeper-1    | :2181                         | Zookeeper instance #1                                                 |
| zookeeper-2    | :2182                         | Zookeeper instance #2                                                 |
| prometheus     | :9090                         | Prometheus instance, scraping metrics from kafka and nginx-1          |
| nginx-exporter | none                          | Exposes nginx stub\_status metrics for Prometheus to scrape            |
| otel-collector | none                          | Collects metrics from kafka cluster                                   |
| grafana        | :3000                         | Grafana instance, displays dashboard with metrics from nginx-exporter |


The stack runs on an internal docker bridge network `cdn77-net`.


### nginx servers

Two nginx servers are running and reachable from hypervisor on http://localhost:8080 and http://localhost:8081. The first one, nginx-1, hosts a boilerplate static content website. The second one, nginx-2, acts as a reverse caching prxoy for nginx-1. nginx-1 exposes a stub status page reachable on http://localhost:8080/stub_status . These servers are deployed with ansible playbooks playbook/nginx.yml and playbook/cache.yml and use Jinja2 templated configuration files files/nginx.conf.j2 and files/reverse-proxy.conf.j2.


### Monitoring tools 

Several metrics monitoring tools are running. All collected metrics are sent to Prometheus, available on http://localhost:9090 . Additionally, a Grafana instance is running on http://localhost:3000 with a dashboard of nginx-1 stub status data.

### Kafka+Zookeeper cluster

kafka-1, kafka-2, zookeeper-1, zookeper-2 are running and interacting as a distributed cluster. An overview of kafka is available on web UI on http://localhost:8082. Here we can add new topics or view active kafka brokers, controllers.


## Prerequisites

[![works badge](https://cdn.jsdelivr.net/gh/nikku/works-on-my-machine@v0.2.0/badge.svg)](https://github.com/nikku/works-on-my-machine)

Python3, Ansible, Docker and Docker Compose must be available on the host machine to deploy and test all services.
On Debian, execute make setup in the root directory of the repository to install all prerequisites in one go.
Otherwise, you will have to look up specific guides on how to make this software available on your system.

## Running the stack

In the root directory, run make deploy.
To remove all containers, run make clean.

## Testing service functionality

### Load testing nginx

Let's run a script that will send thousands of requests to both `nginx-1` and `nginx-2`.
This will cause the stub status page available on `http://localhost:8080/stub_status`.
`nginx-exporter` fetches this data, converts it into appropriate Prometheus metrics types and exposes them on an internal endpoint.
This endpoint is periodically scraped by Prometheus and finally, Grafana displays it in a nginx-exporter dashboard, which is imported by default during setup.

Run the script with make test.

### Killing a Kafka broker

The two Kafka containers are set up to work as a single cluster. By killing the `kafka-1` instance, we can observe new leader elections for the cluster. The cluster will continue to operate with a single broker `kafka-2`. Additionally, `otel-collector` expports the broker count as a Prometheus metric `dev_space_kafka_brokers`. `alertmanager` registers the change in metric value and creates an alert, visible in the Web UI on `http://localhost:9093`.

Kill Kafka broker with:
`docker kill kafka-1`

## Missing requirements

* Wireguard
* Logging script managed with daemontools

Due to the lightweight nature of docker containers, recommended to run only a single process by paradigm, as opposed to fully-fledged virtual machines, and further time constraints, these requirements are left unimplemented. By intuition, implementation could be realized as follows:

* Run a playbook such as the one seen in the repository [automation-wireguard](https://github.com/jawher/automation-wireguard) on systemd-booted virtual machines to generate public/private keypairs for each machine and create the wg0 Wireguard network interface. Assign static IPs to each machine and limit routing of the wg0 interface to requests on IPs within the subnet mask of the wg0 interface.
* Deploy a logging script with Ansible's [builtin systemd module](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/systemd_module.html).
 
