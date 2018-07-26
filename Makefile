export APP_NAME      = nginx_build_module
export VERSION       = 0.1.1
export BUILD_DIR     = build/
export MOD_BUILD_DIR = ${BUILD_DIR}/modules/
DOCKER_ORG           = mwhipple

DOCKER_BIN          ?= docker
GIT_BIN             ?= git

SRC_OBJ              = Dockerfile \
		       Makefile
IIDFILE              = ${BUILD_DIR}latest_image

${BUILD_DIR}:
	mkdir -p $@

${MOD_BUILD_DIR}:
	mkdir -p $@

.PHONY: dockerImage

dockerImage: ${IIDFILE}
${IIDFILE}: ${SRC_OBJ} | ${BUILD_DIR}
	${DOCKER_BIN} build \
		--tag ${DOCKER_ORG}/${APP_NAME}:${VERSION} \
		--iidfile $@ .

.PHONY: module
module: ${IIDFILE} | ${MOD_BUILD_DIR}
	${DOCKER_BIN} run \
		--mount type=bind,source=$(realpath ${MOD_BUILD_DIR}),target=/mod_build \
		${DOCKER_ORG}/${APP_NAME}:${VERSION} -y \
			${NGINX_VERSION_ARG} \
			-o /mod_build \
			-n ${MOD_NAME} \
			${MOD_URL}

clean:
	rm -rf ${BUILD_DIR}
