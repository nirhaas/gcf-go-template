CWD							= $(shell pwd)
REGION						= us-central1
FUNCTIONS_GCS_BUCKET		= gcs-functions-bucket
FUNCTIONS_ZIPS_DIR			= ${CWD}/tmp
FUNCTIONS_FUNCTIONS_DIR		= ${CWD}/functions
FUNCTIONS_VENDOR_DIR		= ${CWD}/vendor
FUNCTIONS_SHARED_LIB_FULL	= ${CWD}/lib
FUNCTIONS_SHARED_RELATIVE	= $(subst ${GOPATH}/src/,,${FUNCTIONS_SHARED_LIB_FULL})

deps:
	-GO111MODULE=on go mod init # Ignoring error as init only works the first time.
	GO111MODULE=on go mod tidy
	GO111MODULE=on go mod vendor

build-functions: 
	chmod +x ./build_functions.sh
	echo Building && \
		FUNCTIONS_FUNCTIONS_DIR=${FUNCTIONS_FUNCTIONS_DIR} \
		FUNCTIONS_ZIPS_DIR=${FUNCTIONS_ZIPS_DIR} \
		FUNCTIONS_VENDOR_DIR=${FUNCTIONS_VENDOR_DIR} \
		FUNCTIONS_SHARED_RELATIVE=${FUNCTIONS_SHARED_RELATIVE} \
		FUNCTIONS_SHARED_LIB_FULL=${FUNCTIONS_SHARED_LIB_FULL} \
		./build_functions.sh

deploy-functions:
	chmod +x ./deploy_functions.sh
	echo Deploying && \
		REGION=${REGION} \
		FUNCTIONS_GCS_BUCKET=${FUNCTIONS_GCS_BUCKET} \
		FUNCTIONS_ZIPS_DIR=${FUNCTIONS_ZIPS_DIR} \
		./deploy_functions.sh

update-functions: build-functions deploy-functions
