# Alpine Linux from Scratch

This project builds a [Alpine Linux](https://alpinelinux.org/) docker images
from scratch using the upstream filesystem image. The official Alpine images
on docker hub can lag a little behind the official releases. I would prefer
that my base image is up to date with the latest version of all packages.

Each night this project builds new versions of supported versions of Alpine 
Linux for amd64. 

The build script adds a user called "worker". This makes it easier to run 
your workload as a non privileged user in the container.

Each build is checked for vulnerabilities using [Aqua Security's
trivy](https://aquasecurity.github.io/trivy).

If you're worried about your docker image supply chain I recommend you fork
this repo or use it as inspiration for your own project. This should allow
you to be confident that you are using the latest version of Alpine Linux
with all available updates. I am not suggesting that these images are secure.
You need to do your own homework on that.

## Support
I will maintain this while I am using images based off it on a best effort
basis. If you don't understand what's happening in the scripts, then I
recommend you use the official images.

Built by [Dave Hall Consulting](https://davehall.com.au).
