# Introduction

Simple dockerfile to install [jsonnet](https://github.com/google/jsonnet) and [go-jsonnet](https://github.com/google/go-jsonnet) into a runnable container.

# Usage

You can run the C++ binary directly with a command like:
```
docker run --rm -it -v `pwd`:/src mexisme/jsonnet jsonnet ${ARGS}
```
or, for the Go binary:
```
docker run --rm -it -v `pwd`:/src mexisme/jsonnet go-jsonnet ${ARGS}
```

Note that it will mount the current directory into the Docker image before running it, so if you're importing other Jsonnet
files, they will need to a sub-dir of the current directory.

## Shell Aliases:

You can add aliases to your profile to reduce typing. For example, in your `~/.zshrc` add

```
alias jsonnet='docker run --rm -it -v `pwd`:/src mexisme/jsonnet jsonnet'
alias go-jsonnet='docker run --rm -it -v `pwd`:/src mexisme/jsonnet go-jsonnet'
```

# Building

The [Dockerfile](./Dockerfile) and [Makefile](./Makefile) can build either Alpine Linux or Debian versions:

## Make all:
```
make
```

## Alpine:
```
make alpine
```

## Debian:
```
make debian
```

# Updating local copies of `jsonnet` and `go-jsonnet`:
In an attempt to stay reasonably hermetic, the Jsonnet code for C++ and Go has been vendored into the `subrepo/` directory.
This also helps Docker to decide when it needs to use a cached layer or re-run the build steps.

In order to update the contents of the vendored code, you must first install https://github.com/ingydotnet/git-subrepo and then run the following:
```
make update
```
