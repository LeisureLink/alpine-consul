# leisurelink/alpine-consul

A minimal alpine base image with s6-overlay and consul.

## Intent

This image is intended as a base image for hosting [consul](https://www.consul.io/). This image builds on [`leisurelink/alpine-base`](https://hub.docker.com/r/leisurelink/alpine-base/) in order to launch and host a consul agent. Unlike [`progrium/consul`](https://hub.docker.com/r/progrium/consul/), which we have used in production for well over a year, this image is not operator controlled via the command line, rather, appropriate configuration files must be mounted into the container in order to control consul's behavior.

Derived images can run in `agent` or `server` mode with an appropriate configuration.

## Customizing

To specialize this image, place configuration files in `/etc/consul.d`.

This container tries to discover a consul cluster from the environment. It does so by querying dns for `consul.service.consul`, and failing that, uses `getent hosts consul-agent` to discover a linked container. Failure to provide an environment where the container can discover consul will result in the following alert:

```
ERROR: Unable to discover the consul cluster; tried CONSUL_SERVICE_NAME=consul.service.consul and CONSUL_HOST_NAME=consul-agent.
       Either specify DNS service name in CONSUL_SERVICE_NAME,
       or the name of a linked consul container in CONSUL_HOST_NAME.
```

## Tags (Asset Versions)

* **1.0.0** (Alpine 3.2, S6 Overlay v1.17.1.1, Consul v0.6.3)

## License

[MIT](https://github.com/LeisureLink/alpine-consul/blob/master/LICENSE)
