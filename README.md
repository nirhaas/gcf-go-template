# GCF Go Template
## Purpose
A template project to quickly start writing and deploying Google Cloud Functions using Go (Golang).

## Usage
Build functions (create zip files).
`make build-functions`

Deploy functions from pre-built zip files.
`make deploy-functions`

Both of them.
`make update-functions`

Clean everything.
`make clean`

**Note**: Only macOS and Linux are supported.

## The problem
According to the docs, you can either provide go.mod, or provide the vendor directory. But what if you want to use both a 3rd party module, and also a local shared module to be used by all of your functions (and the rest of the project?)

## Solutions
* Easily use both a local shared module that is on your GOPATH (no relative imports) and 3rd party modules.
* Vendor once. Use everywhere.
* No unecessary copying of shared code / directories between functions.
* Easily upload multiple functions.

## How is this working?
Taking advantage of the feature that symlinks are followed when zipping.
* Linking the the right spot in `vendor` directory to local shared module. 
    * I guess that this is a bad practice, but it is overrided if we `go mod vendor` again so there are no implications.
* Linking each function directory to the `vendor` directory.
* Zipping each function.
* Uploading to GCS bucket.
* Creating functions from GCS.

## Tree
This is basically the directory structure after building.

```.
.
├── Makefile
├── README.md
├── functions
│   ├── HelloWorld
│   │   ├── fn.go
│   │   └── vendor -> /path/to/my/project/vendor
│   └── HelloWorld2
│       ├── fn.go
│       └── vendor -> /path/to/my/project/vendor
├── go.mod
├── go.sum
├── lib
│   └── consts.go
├── tmp
│   ├── HelloWorld.zip
│   └── HelloWorld2.zip
└── vendor
    ├── path
    │   └── to
    │       └── my
    │           └── project
    │               └── lib -> /path/to/my/project/lib
    ├── github.com
    │   ...
    └── modules.txt
```

## TODO
* Automatically figure out local shared libs.