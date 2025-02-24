<p align="center">
    <img width=auto height=auto src="https://cdn-s3-000.quyit.id.vn/logo-nqdev.png" />
</p>

<p align="center">
    <a href="https://twitter.com/nqdev"><img src="https://badgen.net/badge/twitter/@nqdev/1DA1F2?icon&label" /></a>
    <a href="https://github.com/nqdev-group/containers"><img src="https://badgen.net/github/stars/nqdev-group/containers?icon=github" /></a>
    <a href="https://github.com/nqdev-group/containers"><img src="https://badgen.net/github/forks/nqdev-group/containers?icon=github" /></a>
</p>

# The `Cẩm nang NQDEV` Containers Library

Popular applications, provided by [Cẩm nang NQDEV](https://blogs.nhquydev.net/docker/docker-hub?utm_source=github&utm_medium=containers), containerized and ready to launch.

## Why use NQDEV Images?

## Get an image

The recommended way to get any of the NQDEV Images is to pull the prebuilt image from the [Docker Hub Registry](https://hub.docker.com/u/nqdev/?utm_source=github&utm_medium=containers).

```console
docker pull nqdev/APP
```

To use a specific version, you can pull a versioned tag.

```console
docker pull nqdev/APP:[TAG]
```

If you wish, you can also build the image yourself by cloning the repository, changing to the directory containing the Dockerfile, and executing the `docker build` command.

```console
git clone https://github.com/nqdev-group/containers.git
cd nqdev/APP/VERSION/OPERATING-SYSTEM
docker build -t nqdev/APP .
```

> [!TIP]
> Remember to replace the `APP`, `VERSION`, and `OPERATING-SYSTEM` placeholders in the example command above with the correct values.

## Run the application using Docker Compose

The main folder of each application contains a functional `docker-compose.yml` file. Run the application using it as shown below:

```console
curl -sSL https://raw.githubusercontent.com/nqdev-group/containers/main/nqdev/APP/docker-compose.yml > docker-compose.yml
docker-compose up -d
```

> [!TIP]
> Remember to replace the `APP` placeholder in the example command above with the correct value.

## Contributing

We'd love for you to contribute to those container images. You can request new features by creating an [issue](https://github.com/nqdev-group/containers/issues/new/choose), or submit a [pull request](https://github.com/nqdev-group/containers/pulls) with your contribution.

## License

[LICENSE](./LICENSE?utm_source=github&utm_medium=containers)
