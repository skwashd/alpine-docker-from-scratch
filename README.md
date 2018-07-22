# Alpine Linux from Scratch

Build Status: [![travis build status](https://api.travis-ci.com/skwashd/alpine-docker-from-scratch.svg)](https://travis-ci.com/skwashd/alpine-docker-from-scratch)

Docker Hub: [![skwashd/alpine:3.8 on docker hub](https://img.shields.io/docker/stars/skwashd/alpine.svg)](https://hub.docker.com/r/skwashd/alpine)

Image Size: [![microbadger badge](https://img.shields.io/microbadger/image-size/skwashd/alpine.svg)](https://microbadger.com/images/skwashd/alpine)

This project builds an [Alpine Linux](https://alpinelinux.org/) docker image 
from scratch using the upstream filesystem image. The official Alpine images 
on docker hub can lag a little behind the official releases. I would prefer
that my base image is up to date with the latest version of all packages.

The build script adds a user called "worker". The Dockerfile uses this user so
your workload isn't running as root in the container.

Each build is checked for vulnerabilities using [Aqua Security's 
microscanner](https://blog.aquasec.com/microscanner-free-image-vulnerability-scanner-for-developers).

If you're worried about your docker image supply chain I would recommend that
you fork this repo or use it as inspiration for your own project. This should
allow you to be confident that you are using the latest version of Alpine
Linux with all available updates. I am not suggesting that these images are
secure. You need to do your own homework on that.

## Support
I will maintain this while I am using images based off it on a best effort 
basis. If you don't understand what's happening in the scripts, then I
recommend you use the official images.

Built by [Dave Hall Consulting](https://davehall.com.au).
