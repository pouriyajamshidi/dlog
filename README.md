# Docker Container Logger

This `Bash` script keeps you from running repetitive `Docker` commands when you are trying to troubleshoot or view the logs of a Docker container in realtime.

## Install

```sh
sudo curl -fsSL https://raw.githubusercontent.com/pouriyajamshidi/dlog/master/dlog.sh -o /usr/local/bin/dlog
sudo chmod +x /usr/local/bin/dlog
```

Or from a clone:

```sh
chmod +x dlog.sh
sudo cp dlog.sh /usr/local/bin/dlog
```

## Usage

Start the logger with the name of the target container:

```sh
dlog postgres
```

A partial, case-insensitive name is enough — `dlog graf` finds `Grafana`. It waits until a matching container shows up, so you can start it first and then bring the container up with `docker` or `docker compose`. Once found, you get its **IP address**, **port mappings** and the **container logs** followed live.

The container name is required; without one you get the usage text.
