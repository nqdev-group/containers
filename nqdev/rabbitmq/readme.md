# RabbitMQ Docker Container - NQDev# RabbitMQ Docker Container - NQDev

## Giới thiệu## Giới thiệu

RabbitMQ là một message broker mã nguồn mở được thiết kế cho các kịch bản messaging có tính khả dụng cao (both synchronous và asynchronous).RabbitMQ là một message broker mã nguồn mở được thiết kế cho các kịch bản messaging có tính khả dụng cao (both synchronous và asynchronous).

- **Phiên bản**: RabbitMQ 4.1.4[Tài liệu chính thức RabbitMQ](https://www.rabbitmq.com)

- **Erlang**: 27.3.4

- **Base OS**: Debian 12 (Bookworm)## Sử dụng nhanh

[Tài liệu chính thức RabbitMQ](https://www.rabbitmq.com)```bash

# Chạy với Docker Compose (khuyến nghị)

## Sử dụng nhanhdocker-compose up -d

````bash# Hoặc chạy trực tiếp với Docker

# Khởi động với Docker Compose (khuyến nghị)docker run --name rabbitmq -p 15672:15672 -p 5672:5672 bitnamilegacy/rabbitmq:4.1

docker-compose up -d```



# Hoặc chạy trực tiếp với Docker## Cấu hình dự án

docker run --name rabbitmq -p 15672:15672 -p 5672:5672 bitnamilegacy/rabbitmq:4.1

```### Docker Compose



## Cấu hình Docker ComposeFile `docker-compose.yml` cấu hình container RabbitMQ với các thiết lập tối ưu:



```yaml## ⚠️ Important Notice: Upcoming changes to the Bitnami Catalog

services:

  rabbitmq:Beginning August 28th, 2025, Bitnami will evolve its public catalog to offer a curated set of hardened, security-focused images under the new [Bitnami Secure Images initiative](https://news.broadcom.com/app-dev/broadcom-introduces-bitnami-secure-images-for-production-ready-containerized-applications). As part of this transition:

    image: docker.io/bitnamilegacy/rabbitmq:4.1

    ports:- Granting community users access for the first time to security-optimized versions of popular container images.

      - '4369:4369'      # Erlang Port Mapper Daemon- Bitnami will begin deprecating support for non-hardened, Debian-based software images in its free tier and will gradually remove non-latest tags from the public catalog. As a result, community users will have access to a reduced number of hardened images. These images are published only under the “latest” tag and are intended for development purposes

      - '5551:5551'      # RabbitMQ clustering port- Starting August 28th, over two weeks, all existing container images, including older or versioned tags (e.g., 2.50.0, 10.6), will be migrated from the public catalog (docker.io/bitnami) to the “Bitnami Legacy” repository (docker.io/bitnamilegacy), where they will no longer receive updates.

      - '5552:5552'      # RabbitMQ clustering port- For production workloads and long-term support, users are encouraged to adopt Bitnami Secure Images, which include hardened containers, smaller attack surfaces, CVE transparency (via VEX/KEV), SBOMs, and enterprise support.

      - '5672:5672'      # AMQP port

      - '25672:25672'    # Inter-node communicationThese changes aim to improve the security posture of all Bitnami users by promoting best practices for software supply chain integrity and up-to-date deployments. For more details, visit the [Bitnami Secure Images announcement](https://github.com/bitnami/containers/issues/83267).

      - '15672:15672'    # Management UI

    environment:## Why use Bitnami Secure Images?

      - RABBITMQ_SECURE_PASSWORD=yes

      - RABBITMQ_LOGS=-- Bitnami Secure Images and Helm charts are built to make open source more secure and enterprise ready.

    volumes:- Triage security vulnerabilities faster, with transparency into CVE risks using industry standard Vulnerability Exploitability Exchange (VEX), KEV, and EPSS scores.

      - 'rabbitmq_data:/bitnami/rabbitmq/mnesia'- Our hardened images use a minimal OS (Photon Linux), which reduces the attack surface while maintaining extensibility through the use of an industry standard package format.

- Stay more secure and compliant with continuously built images updated within hours of upstream patches.

volumes:- Bitnami containers, virtual machines and cloud images use the same components and configuration approach - making it easy to switch between formats based on your project needs.

  rabbitmq_data:- Hardened images come with attestation signatures (Notation), SBOMs, virus scan reports and other metadata produced in an SLSA-3 compliant software factory.

    driver: local

```Only a subset of BSI applications are available for free. Looking to access the entire catalog of applications as well as enterprise support? Try the [commercial edition of Bitnami Secure Images today](https://www.arrow.com/globalecs/uk/products/bitnami-secure-images/).



## Custom Dockerfile## How to deploy RabbitMQ in Kubernetes?



Dự án bao gồm Dockerfile tùy chỉnh tại `4.1/debian-12/Dockerfile` với các tối ưu hóa:Deploying Bitnami applications as Helm Charts is the easiest way to get started with our applications on Kubernetes. Read more about the installation in the [Bitnami RabbitMQ Chart GitHub repository](https://github.com/bitnami/charts/tree/master/bitnami/rabbitmq).



- **Base image**: `bitnami/minideb:bookworm`## Why use a non-root container?

- **Non-root user**: Container chạy với user ID 1001 để tăng bảo mật

- **Scripts tự động**: Cấu hình và khởi động tự độngNon-root container images add an extra layer of security and are generally recommended for production environments. However, because they run as a non-root user, privileged tasks are typically off-limits. Learn more about non-root containers [in our docs](https://techdocs.broadcom.com/us/en/vmware-tanzu/application-catalog/tanzu-application-catalog/services/tac-doc/apps-tutorials-work-with-non-root-containers-index.html).

- **Locale**: Cấu hình đa ngôn ngữ (UTF-8)

## Supported tags and respective `Dockerfile` links

### Build custom image

Learn more about the Bitnami tagging policy and the difference between rolling tags and immutable tags [in our documentation page](https://techdocs.broadcom.com/us/en/vmware-tanzu/application-catalog/tanzu-application-catalog/services/tac-doc/apps-tutorials-understand-rolling-tags-containers-index.html).

```bash

# Build từ DockerfileYou can see the equivalence between the different tags by taking a look at the `tags-info.yaml` file present in the branch folder, i.e `bitnami/ASSET/BRANCH/DISTRO/tags-info.yaml`.

cd 4.1/debian-12

docker build -t nqdev/rabbitmq:4.1 .Subscribe to project updates by watching the [bitnami/containers GitHub repo](https://github.com/bitnami/containers).



# Chạy với custom image## Get this image

docker run -d --name rabbitmq \

  -p 15672:15672 \The recommended way to get the Bitnami RabbitMQ Docker Image is to pull the prebuilt image from the [Docker Hub Registry](https://hub.docker.com/r/bitnami/rabbitmq).

  -p 5672:5672 \

  nqdev/rabbitmq:4.1```console

```docker pull bitnami/rabbitmq:latest

````

## Truy cập Management UI

To use a specific version, you can pull a versioned tag. You can view the [list of available versions](https://hub.docker.com/r/bitnami/rabbitmq/tags/) in the Docker Hub Registry.

Sau khi container chạy thành công:

````console

- **URL**: http://localhost:15672docker pull bitnami/rabbitmq:[TAG]

- **Username**: `user` (mặc định)```

- **Password**: Được tạo tự động, xem logs:

If you wish, you can also build the image yourself by cloning the repository, changing to the directory containing the Dockerfile and executing the `docker build` command. Remember to replace the `APP`, `VERSION` and `OPERATING-SYSTEM` path placeholders in the example command below with the correct values.

```bash

docker-compose logs rabbitmq | grep "password"```console

```git clone https://github.com/bitnami/containers.git

cd bitnami/APP/VERSION/OPERATING-SYSTEM

## Quản lý Containerdocker build -t bitnami/APP:latest .

````

### Khởi động và dừng

## Persisting your application

````bash

# Khởi độngIf you remove the container all your data will be lost, and the next time you run the image the database will be reinitialized. To avoid this loss of data, you should mount a volume that will persist even after the container is removed.

docker-compose up -d

For persistence you should mount a directory at the `/bitnami/rabbitmq/mnesia` path. If the mounted directory is empty, it will be initialized on the first run.

# Xem logs

docker-compose logs -f rabbitmq```console

docker run \

# Dừng    -v /path/to/rabbitmq-persistence:/bitnami/rabbitmq/mnesia \

docker-compose down    bitnami/rabbitmq:latest

````

# Dừng và xóa data (cẩn thận!)

docker-compose down -v> NOTE: As this is a non-root container, the mounted files and directories must have the proper permissions for the UID `1001`.

```````

## Connecting to other containers

### Kiểm tra trạng thái

Using [Docker container networking](https://docs.docker.com/engine/userguide/networking/), a RabbitMQ server running inside a container can easily be accessed by your application containers.

```bash

# Kiểm tra containerContainers attached to the same network can communicate with each other using the container name as the hostname.

docker-compose ps

### Using the Command Line

# Xem resource usage

docker stats $(docker-compose ps -q)In this example, we will create a RabbitMQ client instance that will connect to the server instance that is running on the same docker network as the client.



# Vào container để debug#### Step 1: Create a network

docker-compose exec rabbitmq bash

``````console

docker network create app-tier --driver bridge

## Environment Variables```



### Cấu hình cơ bản#### Step 2: Launch the RabbitMQ server instance



| Biến                              | Mô tả                                    | Giá trị mặc định |Use the `--network app-tier` argument to the `docker run` command to attach the RabbitMQ container to the `app-tier` network.

|-----------------------------------|------------------------------------------|------------------|

| `RABBITMQ_USERNAME`               | Tên đăng nhập                           | `user`           |```console

| `RABBITMQ_PASSWORD`               | Mật khẩu (nếu SECURE_PASSWORD=no)      | `bitnami`        |docker run -d --name rabbitmq-server \

| `RABBITMQ_SECURE_PASSWORD`        | Tạo mật khẩu ngẫu nhiên                 | `yes`            |    --network app-tier \

| `RABBITMQ_VHOST`                  | Virtual host mặc định                   | `/`              |    bitnami/rabbitmq:latest

| `RABBITMQ_NODE_PORT_NUMBER`       | Port AMQP                               | `5672`           |```

| `RABBITMQ_MANAGEMENT_PORT_NUMBER` | Port Management UI                      | `15672`          |

#### Step 3: Launch your RabbitMQ client instance

### Cấu hình clustering

Finally we create a new container instance to launch the RabbitMQ client and connect to the server created in the previous step:

| Biến                              | Mô tả                                    | Giá trị mặc định |

|-----------------------------------|------------------------------------------|------------------|```console

| `RABBITMQ_ERL_COOKIE`             | Erlang cookie cho clustering            | `nil`            |docker run -it --rm \

| `RABBITMQ_NODE_TYPE`              | Loại node (stats/queue-disc/queue-ram) | `stats`          |    --network app-tier \

| `RABBITMQ_NODE_NAME`              | Tên node                                | `rabbit@localhost` |    bitnami/rabbitmq:latest rabbitmqctl -n rabbit@rabbitmq-server status

| `RABBITMQ_CLUSTER_NODE_NAME`      | Node để join cluster                    | `nil`            |```



## RabbitMQ Clustering### Using a Docker Compose file



### Cấu hình Cluster với Docker ComposeWhen not specified, Docker Compose automatically sets up a new network and attaches all deployed services to that network. However, we will explicitly define a new `bridge` network named `app-tier`. In this example we assume that you want to connect to the RabbitMQ server from your own custom application image which is identified in the following snippet by the service name `myapp`.



```yaml```yaml

version: "3.8"version: "2"



services:networks:

  rabbitmq-node1:  app-tier:

    image: docker.io/bitnamilegacy/rabbitmq:4.1    driver: bridge

    container_name: rabbitmq-node1

    environment:services:

      - RABBITMQ_NODE_TYPE=stats  rabbitmq:

      - RABBITMQ_NODE_NAME=rabbit@node1    image: bitnami/rabbitmq:latest

      - RABBITMQ_ERL_COOKIE=s3cr3tc00ki3    networks:

      - RABBITMQ_USERNAME=admin      - app-tier

      - RABBITMQ_PASSWORD=admin123  myapp:

    ports:    image: YOUR_APPLICATION_IMAGE

      - "15672:15672"    networks:

      - "5672:5672"      - app-tier

    volumes:```

      - rabbitmq1_data:/bitnami/rabbitmq/mnesia

    networks:> **IMPORTANT**:

      - rabbitmq-cluster>

> 1. Please update the **YOUR_APPLICATION_IMAGE** placeholder in the above snippet with your application image

  rabbitmq-node2:> 2. In your application container, use the hostname `rabbitmq` to connect to the RabbitMQ server

    image: docker.io/bitnamilegacy/rabbitmq:4.1

    container_name: rabbitmq-node2Launch the containers using:

    environment:

      - RABBITMQ_NODE_TYPE=queue-disc```console

      - RABBITMQ_NODE_NAME=rabbit@node2docker-compose up -d

      - RABBITMQ_CLUSTER_NODE_NAME=rabbit@node1```

      - RABBITMQ_ERL_COOKIE=s3cr3tc00ki3

    volumes:## Configuration

      - rabbitmq2_data:/bitnami/rabbitmq/mnesia

    networks:### Environment variables

      - rabbitmq-cluster

    depends_on:#### Customizable environment variables

      - rabbitmq-node1

| Name                                           | Description                                                                                                                                                                                      | Default Value                        |

  rabbitmq-node3:| ---------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------ |

    image: docker.io/bitnamilegacy/rabbitmq:4.1| `RABBITMQ_CONF_FILE`                           | RabbitMQ configuration file.                                                                                                                                                                     | `${RABBITMQ_CONF_DIR}/rabbitmq.conf` |

    container_name: rabbitmq-node3| `RABBITMQ_DEFINITIONS_FILE`                    | Whether to load external RabbitMQ definitions. This is incompatible with setting the RabbitMQ password securely.                                                                                 | `/app/load_definition.json`          |

    environment:| `RABBITMQ_SECURE_PASSWORD`                     | Whether to set the RabbitMQ password securely. This is incompatible with loading external RabbitMQ definitions.                                                                                  | `no`                                 |

      - RABBITMQ_NODE_TYPE=queue-ram| `RABBITMQ_UPDATE_PASSWORD`                     | Whether to update the password on container restart.                                                                                                                                             | `no`                                 |

      - RABBITMQ_NODE_NAME=rabbit@node3| `RABBITMQ_CLUSTER_NODE_NAME`                   | RabbitMQ cluster node name. When specifying this, ensure you also specify a valid hostname as RabbitMQ will fail to start otherwise.                                                             | `nil`                                |

      - RABBITMQ_CLUSTER_NODE_NAME=rabbit@node1| `RABBITMQ_CLUSTER_PARTITION_HANDLING`          | RabbitMQ cluster partition recovery mechanism.                                                                                                                                                   | `ignore`                             |

      - RABBITMQ_ERL_COOKIE=s3cr3tc00ki3| `RABBITMQ_DISK_FREE_RELATIVE_LIMIT`            | Disk relative free space limit of the partition on which RabbitMQ is storing data.                                                                                                               | `1.0`                                |

    volumes:| `RABBITMQ_DISK_FREE_ABSOLUTE_LIMIT`            | Disk absolute free space limit of the partition on which RabbitMQ is storing data (takes precedence over the relative limit).                                                                    | `nil`                                |

      - rabbitmq3_data:/bitnami/rabbitmq/mnesia| `RABBITMQ_ERL_COOKIE`                          | Erlang cookie to determine whether different nodes are allowed to communicate with each other.                                                                                                   | `nil`                                |

    networks:| `RABBITMQ_VM_MEMORY_HIGH_WATERMARK`            | High memory watermark for RabbitMQ to block publishers and prevent new messages from being enqueued. Can be specified as an absolute or relative value (as percentage or value between 0 and 1). | `nil`                                |

      - rabbitmq-cluster| `RABBITMQ_LOAD_DEFINITIONS`                    | Whether to load external RabbitMQ definitions. This is incompatible with setting the RabbitMQ password securely.                                                                                 | `no`                                 |

    depends_on:| `RABBITMQ_MANAGEMENT_BIND_IP`                  | RabbitMQ management server bind IP address.                                                                                                                                                      | `0.0.0.0`                            |

      - rabbitmq-node1| `RABBITMQ_MANAGEMENT_PORT_NUMBER`              | RabbitMQ management server port number.                                                                                                                                                          | `15672`                              |

| `RABBITMQ_MANAGEMENT_ALLOW_WEB_ACCESS`         | Allow web access to RabbitMQ management portal for RABBITMQ_USERNAME                                                                                                                             | `false`                              |

volumes:| `RABBITMQ_NODE_NAME`                           | RabbitMQ node name.                                                                                                                                                                              | `rabbit@localhost`                   |

  rabbitmq1_data:| `RABBITMQ_NODE_DEFAULT_QUEUE_TYPE`             | RabbitMQ default queue type node-wide.                                                                                                                                                           | `nil`                                |

    driver: local| `RABBITMQ_USE_LONGNAME`                        | Whether to use fully qualified names to identify nodes                                                                                                                                           | `false`                              |

  rabbitmq2_data:| `RABBITMQ_NODE_PORT_NUMBER`                    | RabbitMQ node port number.                                                                                                                                                                       | `5672`                               |

    driver: local| `RABBITMQ_NODE_TYPE`                           | RabbitMQ node type.                                                                                                                                                                              | `stats`                              |

  rabbitmq3_data:| `RABBITMQ_VHOST`                               | RabbitMQ vhost.                                                                                                                                                                                  | `/`                                  |

    driver: local| `RABBITMQ_VHOSTS`                              | List of additional virtual host (vhost). Default queue type can be set using colon separator (RABBITMQ_VHOSTS=queue_name_0 queue_name_1:quorum)                                                  | `nil`                                |

| `RABBITMQ_CLUSTER_REBALANCE`                   | Rebalance the RabbitMQ Cluster.                                                                                                                                                                  | `false`                              |

networks:| `RABBITMQ_CLUSTER_REBALANCE_ATTEMPTS`          | Max attempts for the rebalance check to run                                                                                                                                                      | `100`                                |

  rabbitmq-cluster:| `RABBITMQ_USERNAME`                            | RabbitMQ user name.                                                                                                                                                                              | `user`                               |

    driver: bridge| `RABBITMQ_PASSWORD`                            | RabbitMQ user password.                                                                                                                                                                          | `bitnami`                            |

```| `RABBITMQ_FORCE_BOOT`                          | Force a node to start even if it was not the last to shut down                                                                                                                                   | `no`                                 |

| `RABBITMQ_ENABLE_LDAP`                         | Enable the LDAP configuration.                                                                                                                                                                   | `no`                                 |

## Cấu hình SSL/TLS| `RABBITMQ_LDAP_TLS`                            | Enable secure LDAP configuration.                                                                                                                                                                | `no`                                 |

| `RABBITMQ_LDAP_SERVERS`                        | Comma, semi-colon or space separated list of LDAP server hostnames.                                                                                                                              | `nil`                                |

### Tạo self-signed certificates| `RABBITMQ_LDAP_SERVERS_PORT`                   | LDAP servers port.                                                                                                                                                                               | `389`                                |

| `RABBITMQ_LDAP_USER_DN_PATTERN`                | DN used to bind to LDAP in the form cn=$${username},dc=example,dc=org.                                                                                                                           | `nil`                                |

```bash| `RABBITMQ_NODE_SSL_PORT_NUMBER`                | RabbitMQ node port number for SSL connections.                                                                                                                                                   | `5671`                               |

# Tạo thư mục certs| `RABBITMQ_SSL_CACERTFILE`                      | Path to the RabbitMQ server SSL CA certificate file.                                                                                                                                             | `nil`                                |

mkdir -p ./certs| `RABBITMQ_SSL_CERTFILE`                        | Path to the RabbitMQ server SSL certificate file.                                                                                                                                                | `nil`                                |

cd certs| `RABBITMQ_SSL_KEYFILE`                         | Path to the RabbitMQ server SSL certificate key file.                                                                                                                                            | `nil`                                |

| `RABBITMQ_SSL_PASSWORD`                        | RabbitMQ server SSL certificate key password.                                                                                                                                                    | `nil`                                |

# Tạo CA private key| `RABBITMQ_SSL_DEPTH`                           | Maximum number of non-self-issued intermediate certificates that may follow the peer certificate in a valid certification path.                                                                  | `nil`                                |

openssl genrsa -out ca-key.pem 4096| `RABBITMQ_SSL_FAIL_IF_NO_PEER_CERT`            | Whether to reject TLS connections if client fails to provide a certificate.                                                                                                                      | `no`                                 |

| `RABBITMQ_SSL_VERIFY`                          | Whether to enable peer SSL certificate verification. Valid values: verify_none, verify_peer.                                                                                                     | `verify_none`                        |

# Tạo CA certificate| `RABBITMQ_MANAGEMENT_SSL_PORT_NUMBER`          | RabbitMQ management server port number for SSL/TLS connections.                                                                                                                                  | `15671`                              |

openssl req -new -x509 -days 365 -key ca-key.pem -sha256 -out ca.pem \| `RABBITMQ_MANAGEMENT_SSL_CACERTFILE`           | Path to the RabbitMQ management server SSL CA certificate file.                                                                                                                                  | `$RABBITMQ_SSL_CACERTFILE`           |

  -subj "/C=VN/ST=HCM/L=HCM/O=NQDev/CN=RabbitMQ-CA"| `RABBITMQ_MANAGEMENT_SSL_CERTFILE`             | Path to the RabbitMQ server SSL certificate file.                                                                                                                                                | `$RABBITMQ_SSL_CERTFILE`             |

| `RABBITMQ_MANAGEMENT_SSL_KEYFILE`              | Path to the RabbitMQ management server SSL certificate key file.                                                                                                                                 | `$RABBITMQ_SSL_KEYFILE`              |

# Tạo server private key| `RABBITMQ_MANAGEMENT_SSL_PASSWORD`             | RabbitMQ management server SSL certificate key password.                                                                                                                                         | `$RABBITMQ_SSL_PASSWORD`             |

openssl genrsa -out server-key.pem 4096| `RABBITMQ_MANAGEMENT_SSL_DEPTH`                | Maximum number of non-self-issued intermediate certificates that may follow the peer certificate in a valid certification path, for the RabbitMQ management server.                              | `nil`                                |

| `RABBITMQ_MANAGEMENT_SSL_FAIL_IF_NO_PEER_CERT` | Whether to reject TLS connections if client fails to provide a certificate for the RabbitMQ management server.                                                                                   | `yes`                                |

# Tạo server certificate request| `RABBITMQ_MANAGEMENT_SSL_VERIFY`               | Whether to enable peer SSL certificate verification for the RabbitMQ management server. Valid values: verify_none, verify_peer.                                                                  | `verify_peer`                        |

openssl req -subj "/C=VN/ST=HCM/L=HCM/O=NQDev/CN=rabbitmq" \

  -sha256 -new -key server-key.pem -out server.csr#### Read-only environment variables



# Sign server certificate| Name                          | Description                                            | Value                                                             |

openssl x509 -req -days 365 -sha256 -in server.csr \| ----------------------------- | ------------------------------------------------------ | ----------------------------------------------------------------- |

  -CA ca.pem -CAkey ca-key.pem -out server.pem -CAcreateserial| `RABBITMQ_VOLUME_DIR`         | Persistence base directory.                            | `/bitnami/rabbitmq`                                               |

```| `RABBITMQ_BASE_DIR`           | RabbitMQ installation directory.                       | `/opt/bitnami/rabbitmq`                                           |

| `RABBITMQ_BIN_DIR`            | RabbitMQ executables directory.                        | `${RABBITMQ_BASE_DIR}/sbin`                                       |

### Docker Compose với SSL| `RABBITMQ_DATA_DIR`           | RabbitMQ data directory.                               | `${RABBITMQ_VOLUME_DIR}/mnesia`                                   |

| `RABBITMQ_CONF_DIR`           | RabbitMQ configuration directory.                      | `${RABBITMQ_BASE_DIR}/etc/rabbitmq`                               |

```yaml| `RABBITMQ_DEFAULT_CONF_DIR`   | RabbitMQ default configuration directory.              | `${RABBITMQ_BASE_DIR}/etc/rabbitmq.default`                       |

services:| `RABBITMQ_CONF_ENV_FILE`      | RabbitMQ configuration file for environment variables. | `${RABBITMQ_CONF_DIR}/rabbitmq-env.conf`                          |

  rabbitmq:| `RABBITMQ_HOME_DIR`           | RabbitMQ home directory.                               | `${RABBITMQ_BASE_DIR}/.rabbitmq`                                  |

    image: docker.io/bitnamilegacy/rabbitmq:4.1| `RABBITMQ_LIB_DIR`            | RabbitMQ lib directory.                                | `${RABBITMQ_BASE_DIR}/var/lib/rabbitmq`                           |

    ports:| `RABBITMQ_INITSCRIPTS_DIR`    | RabbitMQ init scripts directory.                       | `/docker-entrypoint-initdb.d`                                     |

      - '5671:5671'      # AMQPS port| `RABBITMQ_LOGS_DIR`           | RabbitMQ logs directory.                               | `${RABBITMQ_BASE_DIR}/var/log/rabbitmq`                           |

      - '15671:15671'    # Management UI HTTPS| `RABBITMQ_PLUGINS_DIR`        | RabbitMQ plugins directory.                            | `${RABBITMQ_BASE_DIR}/plugins`                                    |

    environment:| `RABBITMQ_MOUNTED_CONF_DIR`   | RabbitMQ directory for mounted configuration files.    | `${RABBITMQ_VOLUME_DIR}/conf`                                     |

      - RABBITMQ_SECURE_PASSWORD=yes| `RABBITMQ_DAEMON_USER`        | RabbitMQ system user name.                             | `rabbitmq`                                                        |

      - RABBITMQ_SSL_CACERTFILE=/certs/ca.pem| `RABBITMQ_DAEMON_GROUP`       | RabbitMQ system user group.                            | `rabbitmq`                                                        |

      - RABBITMQ_SSL_CERTFILE=/certs/server.pem| `RABBITMQ_MNESIA_BASE`        | Path to RabbitMQ mnesia directory.                     | `$RABBITMQ_DATA_DIR`                                              |

      - RABBITMQ_SSL_KEYFILE=/certs/server-key.pem| `RABBITMQ_COMBINED_CERT_PATH` | Path to the RabbitMQ server SSL certificate key file.  | `${RABBITMQ_COMBINED_CERT_PATH:-/tmp/rabbitmq_combined_keys.pem}` |

      - RABBITMQ_SSL_VERIFY=verify_peer

      - RABBITMQ_SSL_FAIL_IF_NO_PEER_CERT=noWhen you start the rabbitmq image, you can adjust the configuration of the instance by passing one or more environment variables either on the docker-compose file or on the `docker run` command line. If you want to add a new environment variable:

    volumes:

      - 'rabbitmq_data:/bitnami/rabbitmq/mnesia'- For docker-compose add the variable name and value under the application section in the [`docker-compose.yml`](https://github.com/bitnami/containers/blob/main/bitnami/rabbitmq/docker-compose.yml) file present in this repository: :

      - './certs:/certs:ro'

``````yaml

rabbitmq:

## Monitoring & Health Check  ...

  environment:

### Health Check Script    - RABBITMQ_PASSWORD=my_password

  ...

```bash```

#!/bin/bash

# health-check.sh- For manual execution add a `-e` option with each variable and value.



rabbitmqctl status > /dev/null 2>&1### Setting up a cluster

if [ $? -eq 0 ]; then

    echo "RabbitMQ is healthy"#### Using Docker Compose

    exit 0

elseThis is the simplest way to run RabbitMQ with clustering configuration:

    echo "RabbitMQ is not healthy"

    exit 1##### Step 1: Add a stats node in your `docker-compose.yml`

fi

```Copy the snippet below into your docker-compose.yml to add a RabbitMQ stats node to your cluster configuration.



### Prometheus Monitoring```yaml

version: "2"

RabbitMQ có plugin prometheus built-in:

services:

```bash  stats:

# Enable prometheus plugin    image: bitnami/rabbitmq:latest

docker-compose exec rabbitmq rabbitmq-plugins enable rabbitmq_prometheus    environment:

      - RABBITMQ_NODE_TYPE=stats

# Metrics endpoint      - RABBITMQ_NODE_NAME=rabbit@stats

curl http://localhost:15692/metrics      - RABBITMQ_ERL_COOKIE=s3cr3tc00ki3

```    ports:

      - 15672:15672

## Backup và Restore    volumes:

      - rabbitmqstats_data:/bitnami/rabbitmq/mnesia

### Backup```



```bash> **Note:** The name of the service (**stats**) is important so that a node could resolve the hostname to cluster with. (Note that the node name is `rabbit@stats`)

# Backup definitions (queues, exchanges, bindings, users, etc.)

curl -u admin:password http://localhost:15672/api/definitions -o backup-$(date +%Y%m%d).json##### Step 2: Add a queue node in your configuration



# Backup data directoryUpdate the definitions for nodes you want your RabbitMQ stats node cluster with.

docker run --rm -v rabbitmq_data:/data -v $(pwd):/backup \

  alpine tar czf /backup/rabbitmq-data-$(date +%Y%m%d).tar.gz /data```yaml

```queue-disc1:

  image: bitnami/rabbitmq:latest

### Restore  environment:

    - RABBITMQ_NODE_TYPE=queue-disc

```bash    - RABBITMQ_NODE_NAME=rabbit@queue-disc1

# Restore definitions    - RABBITMQ_CLUSTER_NODE_NAME=rabbit@stats

curl -u admin:password -X POST -H "Content-Type: application/json" \    - RABBITMQ_ERL_COOKIE=s3cr3tc00ki3

  -d @backup-20241112.json http://localhost:15672/api/definitions  volumes:

    - rabbitmqdisc1_data:/bitnami/rabbitmq/mnesia

# Restore data```

docker run --rm -v rabbitmq_data:/data -v $(pwd):/backup \

  alpine tar xzf /backup/rabbitmq-data-20241112.tar.gz -C /> **Note:** Again, the name of the service (**queue-disc1**) is important so that each node could resolve the hostname of this one.

```````

We are going to add a ram node too:

## Troubleshooting

````yaml

### Common Issuesqueue-ram1:

  image: bitnami/rabbitmq:latest

1. **Container không start được**  environment:

   ```bash    - RABBITMQ_NODE_TYPE=queue-ram

   # Xem logs chi tiết    - RABBITMQ_NODE_NAME=rabbit@queue-ram1

   docker-compose logs rabbitmq    - RABBITMQ_CLUSTER_NODE_NAME=rabbit@stats

       - RABBITMQ_ERL_COOKIE=s3cr3tc00ki3

   # Kiểm tra quyền truy cập volume  volumes:

   ls -la /var/lib/docker/volumes/    - rabbitmqram1_data:/bitnami/rabbitmq/mnesia

````

2. **Không truy cập được Management UI**##### Step 3: Add the volume description

   ````bash

   # Kiểm tra port binding```yaml

   docker-compose psvolumes:

   netstat -tlnp | grep 15672  rabbitmqstats_data:

   ```    driver: local
   ````

rabbitmqdisc1_data:

3. **Memory issues** driver: local

   ````bash rabbitmqram1_data:

   # Cấu hình memory limit    driver: local

   environment:```

     - RABBITMQ_VM_MEMORY_HIGH_WATERMARK=0.6

   ```The `docker-compose.yml` will look like this:

   ````

4. **Clustering issues**```yaml

   ````bashversion: "2"

   # Reset cluster

   docker-compose exec rabbitmq rabbitmqctl stop_appservices:

   docker-compose exec rabbitmq rabbitmqctl reset  stats:

   docker-compose exec rabbitmq rabbitmqctl start_app    image: bitnami/rabbitmq:latest

   ```    environment:

      - RABBITMQ_NODE_TYPE=stats
   ````

### Useful Commands - RABBITMQ_NODE_NAME=rabbit@stats

      - RABBITMQ_ERL_COOKIE=s3cr3tc00ki3

````bash ports:

# Xem cluster status      - 15672:15672

docker-compose exec rabbitmq rabbitmqctl cluster_status    volumes:

      - rabbitmqstats_data:/bitnami/rabbitmq/mnesia

# List queues  queue-disc1:

docker-compose exec rabbitmq rabbitmqctl list_queues    image: bitnami/rabbitmq:latest

    environment:

# List exchanges      - RABBITMQ_NODE_TYPE=queue-disc

docker-compose exec rabbitmq rabbitmqctl list_exchanges      - RABBITMQ_NODE_NAME=rabbit@queue-disc1

      - RABBITMQ_CLUSTER_NODE_NAME=rabbit@stats

# List users      - RABBITMQ_ERL_COOKIE=s3cr3tc00ki3

docker-compose exec rabbitmq rabbitmqctl list_users    volumes:

      - rabbitmqdisc1_data:/bitnami/rabbitmq/mnesia

# Add user  queue-ram1:

docker-compose exec rabbitmq rabbitmqctl add_user newuser password123    image: bitnami/rabbitmq:latest

    environment:

# Set user tags      - RABBITMQ_NODE_TYPE=queue-ram

docker-compose exec rabbitmq rabbitmqctl set_user_tags newuser administrator      - RABBITMQ_NODE_NAME=rabbit@queue-ram1

```      - RABBITMQ_CLUSTER_NODE_NAME=rabbit@stats

      - RABBITMQ_ERL_COOKIE=s3cr3tc00ki3

## Performance Tuning    volumes:

      - rabbitmqram1_data:/bitnami/rabbitmq/mnesia

### Cấu hình tối ưu cho Production

volumes:

```yaml  rabbitmqstats_data:

services:    driver: local

  rabbitmq:  rabbitmqdisc1_data:

    image: docker.io/bitnamilegacy/rabbitmq:4.1    driver: local

    deploy:  rabbitmqram1_data:

      resources:    driver: local

        limits:```

          memory: 2G

          cpus: '2'### Configuration file

        reservations:

          memory: 1GA custom `rabbitmq.conf` configuration file can be mounted to the `/bitnami/rabbitmq/conf` directory. If no file is mounted, the container will generate a default one based on the environment variables. You can also mount on this directory your own `advanced.config` (using classic Erlang terms) and `rabbitmq-env.conf` configuration files.

          cpus: '1'

    environment:As an alternative, you can also mount a `custom.conf` configuration file and mount it to the `/bitnami/rabbitmq/conf` directory. In this case, the default configuation file will be generated and, later on, the settings available in the `custom.conf` configuration file will be merged with the default ones. For example, in order to override the `listeners.tcp.default` directive:

      - RABBITMQ_VM_MEMORY_HIGH_WATERMARK=0.6

      - RABBITMQ_DISK_FREE_ABSOLUTE_LIMIT=2GB#### Step 1: Write your custom.conf configuation file with the following content

      - RABBITMQ_CLUSTER_PARTITION_HANDLING=autoheal

    ulimits:```ini

      nofile: 65536listeners.tcp.default=1337

````

## Security Best Practices#### Step 2: Run RabbitMQ mounting your custom.conf configuation file

1. **Thay đổi mật khẩu mặc định**```console

2. **Sử dụng SSL/TLS cho production**docker run -d --name rabbitmq-server \

3. **Giới hạn network access** -v /path/to/custom.conf:/bitnami/rabbitmq/conf/custom.conf:ro \

4. **Regular backup** bitnami/rabbitmq:latest

5. **Monitor logs và metrics**```

6. **Update thường xuyên**

After that, your changes will be taken into account in the server's behaviour.

## Tài liệu tham khảo

### FIPS configuration in Bitnami Secure Images

- [RabbitMQ Official Documentation](https://www.rabbitmq.com/documentation.html)

- [Bitnami RabbitMQ](https://github.com/bitnami/containers/tree/main/bitnami/rabbitmq)The Bitnami RabbitMQ Docker image from the [Bitnami Secure Images](https://www.arrow.com/globalecs/uk/products/bitnami-secure-images/) catalog includes extra features and settings to configure the container with FIPS capabilities. You can configure the next environment variables:

- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)

- `OPENSSL_FIPS`: whether OpenSSL runs in FIPS mode or not. `yes` (default), `no`.

---

## Permission of SSL/TLS certificate and key files

**NQDev Team** - Container Solutions
If you bind mount the certificate and key files from your local host to the container, make sure to set proper ownership and permissions of those files:

```console
sudo chown 1001:root <your cert/key files>
sudo chmod 400 <your cert/key files>
```

## Enabling LDAP support

LDAP configuration parameters must be specified if you wish to enable LDAP support for RabbitMQ. The following environment variables are available to configure LDAP support:

- `RABBITMQ_ENABLE_LDAP`: Enable the LDAP configuration. Defaults to `no`.
- `RABBITMQ_LDAP_TLS`: Enable secure LDAP configuration. Defaults to `no`.
- `RABBITMQ_LDAP_SERVERS`: Comma, semi-colon or space separated list of LDAP server hostnames. No defaults.
- `RABBITMQ_LDAP_SERVERS_PORT`: LDAP servers port. Defaults: **389**
- `RABBITMQ_LDAP_USER_DN_PATTERN`: DN used to bind to LDAP in the form `cn=$${username},dc=example,dc=org`.No defaults.

> Note: To escape `$` in `RABBITMQ_LDAP_USER_DN_PATTERN` you need to use `$$`.

Follow these instructions to use the [Bitnami Docker OpenLDAP](https://github.com/bitnami/containers/blob/main/bitnami/openldap) image to create an OpenLDAP server and use it to authenticate users on RabbitMQ:

### Step 1: Create a network and start an OpenLDAP server

```console
docker network create app-tier --driver bridge
docker run --name openldap \
  --env LDAP_ADMIN_USERNAME=admin \
  --env LDAP_ADMIN_PASSWORD=adminpassword \
  --env LDAP_USERS=user01,user02 \
  --env LDAP_PASSWORDS=password1,password2 \
  --network app-tier \
  bitnami/openldap:latest
```

### Step 3: Create an advanced.config file

To configure authorization, you need to create an advanced.config file, following the [clasic config format](https://www.rabbitmq.com/configure.html#erlang-term-config-file), and add your authorization rules. For instance, use the file below to grant all users the ability to use the management plugin, but make none of them administrators:

```text
[{rabbitmq_auth_backend_ldap,[
    {tag_queries, [{administrator, {constant, false}},
                   {management,    {constant, true}}]}
]}].
```

More information at [https://www.rabbitmq.com/ldap.html#authorisation](https://www.rabbitmq.com/ldap.html#authorisation).

### Step 4: Start RabbitMQ with LDAP support

```console
docker run --name rabbitmq \
  --env RABBITMQ_ENABLE_LDAP=yes \
  --env RABBITMQ_LDAP_TLS=no \
  --env RABBITMQ_LDAP_SERVERS=openldap \
  --env RABBITMQ_LDAP_SERVERS_PORT=1389 \
  --env RABBITMQ_LDAP_USER_DN_PATTERN=cn=$${username},ou=users,dc=example,dc=org \
  --network app-tier \
  -v /path/to/your/advanced.config:/bitnami/rabbitmq/conf/advanced.config:ro \
  bitnami/rabbitmq:latest
```

## Logging

The Bitnami RabbitMQ Docker image sends the container logs to the `stdout`. To view the logs:

```console
docker logs rabbitmq
```

or using Docker Compose:

```console
docker-compose logs rabbitmq
```

You can configure the containers [logging driver](https://docs.docker.com/engine/admin/logging/overview/) using the `--log-driver` option if you wish to consume the container logs differently. In the default configuration docker uses the `json-file` driver.

## Maintenance

### Upgrade this application

Bitnami provides up-to-date versions of RabbitMQ, including security patches, soon after they are made upstream. We recommend that you follow these steps to upgrade your container.

#### Step 1: Get the updated image

```console
docker pull bitnami/rabbitmq:latest
```

or if you're using Docker Compose, update the value of the image property to
`bitnami/rabbitmq:latest`.

#### Step 2: Stop and backup the currently running container

Stop the currently running container using the command

```console
docker stop rabbitmq
```

or using Docker Compose:

```console
docker-compose stop rabbitmq
```

Next, take a snapshot of the persistent volume `/path/to/rabbitmq-persistence` using:

```console
rsync -a /path/to/rabbitmq-persistence /path/to/rabbitmq-persistence.bkp.$(date +%Y%m%d-%H.%M.%S)
```

#### Step 3: Remove the currently running container

```console
docker rm -v rabbitmq
```

or using Docker Compose:

```console
docker-compose rm -v rabbitmq
```

#### Step 4: Run the new image

Re-create your container from the new image.

```console
docker run --name rabbitmq bitnami/rabbitmq:latest
```

or using Docker Compose:

```console
docker-compose up rabbitmq
```

## Notable changes

### 4.1.1-debian-12-r3

- The environment variable `RABBITMQ_VHOSTS` can be used to set the default queue type for each virtual host using `:` separator: `RABBITMQ_VHOSTS=queue_name_0 queue_name_1:quorum`
- New enviroment variable `RABBITMQ_NODE_DEFAULT_QUEUE_TYPE` to set default queue type node-wide.

### 3.8.16-debian-10-r28

- Added several minor changes to make the container compatible with the [RabbitMQ Cluster Operator](https://github.com/rabbitmq/cluster-operator/):
  - Add `/etc/rabbitmq`, `/var/log/rabbitmq` and `/var/lib/rabbitmq` as symlinks to the corresponding folders in `/opt/bitnami/rabbitmq`.
  - Set the `RABBITMQ_SECURE_PASSWORD` password to `no` by default. This does not affect the Bitnami RabbitMQ helm as it sets that variable to `yes` by default.
  - Enable the `rabbitmq-prometheus` plugin by default.

### 3.8.9-debian-10-r82

- Add script to be used as preStop hook on K8s environments. It waits until queues have synchronised
  mirror before shutting down.

### 3.8.9-debian-10-r42

- The environment variable `RABBITMQ_HASHED_PASSWORD` has not been used for some time. It is now
  removed from documentation and validation.
- New boolean environment variable `RABBITMQ_LOAD_DEFINITIONS` to get behavior compatible with using
  the `load_definitions` configuration. Initially this means that the password of
  `RABBITMQ_USERNAME` is not changed using `rabbitmqctl change_password`.

### 3.8.3-debian-10-r109

- The default configuration file is created following the "sysctl" or "ini-like" format instead of using Erlang terms. Check [Official documentation](https://www.rabbitmq.com/configure.html#config-file-formats) for more information about supported formats.
- Migrating data/configuration from unsupported locations is not performed anymore.
- New environment variable `RABBITMQ_FORCE_BOOT` to force a node to start even if it was not the last to shut down.
- New environment variable `RABBITMQ_PLUGINS` to indicate a list of plugins to enable during the initialization.
- Add healthcheck scripts to be used on K8s environments.

### 3.8.0-r17, 3.8.0-ol-7-r26

- LDAP authentication

### 3.7.15-r18, 3.7.15-ol-7-r19

- Decrease the size of the container. Node.js is not needed anymore. RabbitMQ configuration logic has been moved to bash scripts in the `rootfs` folder.
- Configuration is not persisted anymore.

### 3.7.7-r35

- The RabbitMQ container includes a new environment variable `RABBITMQ_HASHED_PASSWORD` that allows setting password via SHA256 hash (consult [official documentation](https://www.rabbitmq.com/passwords.html) for more information about password hashes).
- Please note that password hashes must be generated following the [official algorithm](https://www.rabbitmq.com/passwords.html#computing-password-hash). You can use [this Python script](https://gist.githubusercontent.com/anapsix/4c3e8a8685ce5a3f0d7599c9902fd0d5/raw/1203a480fcec1982084b3528415c3cad26541b82/rmq_passwd_hash.py) to generate them.

### 3.7.7-r19

- The RabbitMQ container has been migrated to a non-root user approach. Previously the container ran as the `root` user and the RabbitMQ daemon was started as the `rabbitmq` user. From now on, both the container and the RabbitMQ daemon run as user `1001`. As a consequence, the data directory must be writable by that user. You can revert this behavior by changing `USER 1001` to `USER root` in the Dockerfile.

### 3.6.5-r2

The following parameters have been renamed:

| From                       | To                           |
| -------------------------- | ---------------------------- |
| `RABBITMQ_ERLANG_COOKIE`   | `RABBITMQ_ERL_COOKIE`        |
| `RABBITMQ_NODETYPE`        | `RABBITMQ_NODE_TYPE`         |
| `RABBITMQ_NODEPORT`        | `RABBITMQ_NODE_PORT`         |
| `RABBITMQ_NODENAME`        | `RABBITMQ_NODE_NAME`         |
| `RABBITMQ_CLUSTERNODENAME` | `RABBITMQ_CLUSTER_NODE_NAME` |
| `RABBITMQ_MANAGERPORT`     | `RABBITMQ_MANAGER_PORT`      |

## Using `docker-compose.yaml`

Please be aware this file has not undergone internal testing. Consequently, we advise its use exclusively for development or testing purposes. For production-ready deployments, we highly recommend utilizing its associated [Bitnami Helm chart](https://github.com/bitnami/charts/tree/main/bitnami/rabbitmq).

If you detect any issue in the `docker-compose.yaml` file, feel free to report it or contribute with a fix by following our [Contributing Guidelines](https://github.com/bitnami/containers/blob/main/CONTRIBUTING.md).

## Contributing

We'd love for you to contribute to this Docker image. You can request new features by creating an [issue](https://github.com/bitnami/containers/issues) or submitting a [pull request](https://github.com/bitnami/containers/pulls) with your contribution.

## Issues

If you encountered a problem running this container, you can file an [issue](https://github.com/bitnami/containers/issues/new/choose). For us to provide better support, be sure to fill the issue template.

## License

Copyright &copy; 2025 Broadcom. The term "Broadcom" refers to Broadcom Inc. and/or its subsidiaries.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
