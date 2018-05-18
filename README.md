# nginx-build-module

A Dockerized build environment for dynamic nginx modules.

## Info

- Status: Under Development
- Type: Utility


## Description

Newer versions of nginx support dynamically loaded modules which can
be compiled separately from the nginx into which they are loaded, but
are still likely to require compilation to target the desired version of
nginx.

This utility exists to create a Dockerized build environment which makes use
of the [pkg-oss](http://hg.nginx.org/pkg-oss) scripts to build and package
a module from a source location for a particular nginx version.

### Supported targets

Currently this utilty only targets debian packaging as that is supported by
both the pkg-oss `build_module.sh` script and the nginx standard Docker images
(and because of this is also the chosen base for the initial consumung app.

### How to Build Modules

A Makefile is provided to assist in building and working with the created
Docker container. The Makefile currently requires two parameters which are
specified as environment variables:

- `NGINX_VERSION_ARG` - The argument to pass to specify the nginx version. For Nginx Plus the value will be something like `-r 14`, for Nginx OSS the value will be something like `-v 1.14.0` (See `build_module.sh`)
- `MOD_URL` - The path to the module to build (where the module's config file lives).
- `MOD_NAME` - The name of the module to use for the package name.


An example invocation:

```
NGINX_VERSION_ARG=14 MOD_URL=https://github.com/mwhipple/ngx_upstream_jdomain.git MOD_NAME= jdomain make module
```

The resulting packages will be created in the `build/modules/` project directory.

#### MOD_URL options

This is passed to the `build_module.sh` so whatever it supports is inherited.
This includes local (mounted) directories, Git URLs, and URLs to tarballs and zip
archives. If a Git _branch_ is desired for development or pinning, then some simple
options may include adding a git submodule which can referenced as a local directory,
or using the URL for the archive for that branch (e.g. GitHub provides a zip download
link).

### Using the Built Modules

This project by itself will spit out some module packages in `build/modules`, but those
aren't going to be much use without being loaded into a built nginx. If an appropriate
package repository is available then publishing to that an using it may be a viable
option, but if working in an environment where that seems a bit heavy-handed, a lighter
weight, Docker-friendly approach is outlined here.

#### Add this Project as a Submodule for the Nginx Image

`git add submodule <this repo>` should do the trick.

#### Wire Build System to Call This Project

An example Makefile is included here. This should be adapated to match the
used build system, nginx version, etc.

```make
# Grab the NGINX version from a Dockerfile
export NGINX_VERSION     = $(shell sed -En "s/.*NGINX_VERSION=([.0-9]+).*/\1/p" Dockerfile)

# Using Nginx OSS
export NGINX_VERSION_ARG = -v ${NGINX_VERSION}

# The list of logical names for all third party modules to be built.
MODS                = jdomain

# For each module in `MODS`, define a new MOD_${name} value with the path to the module source.
MOD_jdomain         = https://github.com/mwhipple/ngx_upstream_jdomain.git

# The rest of this block uses the values from above to build the modules using
# nginx-build-module for the nginx version specified in the Dockerfile, and then
# copies the nginx module to the top level MOD_DIR so it can be installed into the
# created image. The file is accessed based on the expected package name so some
# of the verbosity is around bouncing between those expected names and the logical names.

MOD_BUILDER         = nginx-build-module
MOD_BUILDER_OUT_DIR = ${MOD_BUILDER}/build/modules/

MOD_OBJS            = $(patsubst %,${MOD_DIR}nginx-module-%_${NGINX_VERSION}-1~stretch_amd64.deb,${MODS})

MOD_DIR             = ${BUILD_DIR}modules/
modBuilt            = $(patsubst ${MOD_DIR}%,${MOD_BUILDER_OUT_DIR}%,${1})

${MOD_DIR}:
	mkdir -p $@

${MOD_DIR}nginx-module-%_${NGINX_VERSION}-1~stretch_amd64.deb: | ${MOD_DIR} 
	MOD_NAME=$* MOD_URL=$(MOD_$*) make -C ${MOD_BUILDER} module
	cp -f $(call modBuilt,$@) $@
```

#### Copy and Install Modules into Dockerfile

Add lines like the following to your Dockerfile to get the files installed in the image:

```Dockerfile
RUN mkdir /nginx-modules
COPY build/modules/* /nginx-modules
RUN dpkg -i /nginx-modules/* && rm -rf /nginx-modules
```

#### Configure Your nginx

Add the usual `load_module` lines. These are helpfully output when `dpkg` is run
during image creation.

```
load_module modules/ngx_http_upstream_jdomain_module.so;
```

#### Profit
