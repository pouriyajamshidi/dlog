# Docker Container Logger

This `Bash` script keeps you from running repetitive `Docker` commands when you are trying to troubleshoot or view the logs of a Docker container in realtime.

## Usage

Place the script in your `usr/bin/` directory to be able to just run it independent of the directory you are in or place it in your desired location and give it the `execute` permission:

```sh
chmod +x dlog.sh 
cp dlog.sh /usr/bin/dlog
```

Start the logger with the name of the target container :

```sh
dlog postgres
```

Then start the container with `docker-compose` or `docker` command and you will be able to see the assigned **IP address**, **port mappings** and the **container logs**.
