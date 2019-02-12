# Consts.
CWD							:= $(shell pwd)
REGION						:= us-central1
FUNCTIONS_GCS_BUCKET		:= gcs-functions-bucket
FUNCTIONS_ZIPS_DIR			:= $(CWD)/tmp
FUNCTIONS_FUNCTIONS_DIR		:= $(CWD)/functions
FUNCTIONS_VENDOR_DIR		:= $(CWD)/vendor
FUNCTIONS_SHARED_LIB_FULL	:= $(CWD)/lib

# Shared Params.
FUNCTIONS_SHARED_RELATIVE				:= $(subst $(GOPATH)/src/,,$(FUNCTIONS_SHARED_LIB_FULL))
FUNCTIONS_SHARED_LIB_FULL_WITHOUT_ROOT	:= $(dir $(FUNCTIONS_SHARED_RELATIVE))
SHARED_IN_VENDOR						:= $(FUNCTIONS_VENDOR_DIR)/$(FUNCTIONS_SHARED_LIB_FULL_WITHOUT_ROOT)

# Preperation for for-loops.
functions 					:= $(wildcard $(FUNCTIONS_FUNCTIONS_DIR)/*)
function_names 				:= $(notdir $(functions))
function_zips 				:= $(patsubst %, $(FUNCTIONS_ZIPS_DIR)/%.zip, $(function_names))
function_zips_toupload 		:= $(addsuffix .upload, $(function_zips))
function_vendor_tounlink 	:= $(addsuffix /vendor.unlink, $(functions))

# Detect OS - Linux and Mac "ln" flags are differnt. Meh.
UNAME_S := $(shell uname -s)
LN := ln -s -f
ifeq ($(UNAME_S),Darwin)
	LN += -h
endif
ifeq ($(UNAME_S),Linux)
	LN += -n
endif

##### Build #####
.PHONY: .link-dirs .empty-zips-dir .zip-functions build-functions
$(FUNCTIONS_ZIPS_DIR)/%.zip: $(FUNCTIONS_FUNCTIONS_DIR)/%
	# Link master vendor dir to function vendor.
	$(LN) $(FUNCTIONS_VENDOR_DIR) $</vendor
	# Zip.
	cd $< && zip -r $@ .

.link-dirs:
	# Prepare shared lib in master vendor dir.
	mkdir -p $(SHARED_IN_VENDOR)
	# Link shared lib to master vendor.
	$(LN) $(FUNCTIONS_SHARED_LIB_FULL) $(SHARED_IN_VENDOR)

.empty-zips-dir:
	rm -rvf $(FUNCTIONS_ZIPS_DIR)/*

.zip-functions: $(function_zips)

build-functions: .link-dirs .empty-zips-dir .zip-functions

##### Deploy #####
$(FUNCTIONS_ZIPS_DIR)/%.upload: $(FUNCTIONS_ZIPS_DIR)/%
	# Upload zip go GCS.
	gsutil cp $< gs://$(FUNCTIONS_GCS_BUCKET)
	# Create function.
	gcloud functions deploy $(notdir $(basename $<)) --runtime go111 --trigger-http --source gs://$(FUNCTIONS_GCS_BUCKET)/$(notdir $<) --region $(REGION)

.PHONY: deploy-functions
deploy-functions: $(function_zips_toupload)

##### Update #####
.PHONY: update-functions
update-functions: build-functions deploy-functions

##### Clean #####
.PHONY: .clean-function-vendors .clean-master-vendor clean
%.unlink: %
	unlink $<

.clean-function-vendors: $(function_vendor_tounlink)

.clean-master-vendor:
	GO111MODULE=on go mod vendor

clean: .clean-function-vendors .clean-master-vendor .empty-zips-dir

##### Deps #####
.PHONY: deps
deps:
	-GO111MODULE=on go mod init # Ignoring error as init only works the first time.
	GO111MODULE=on go mod tidy
	GO111MODULE=on go mod vendor