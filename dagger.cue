// usage: dagger-cue do hello --log-format=plain
package pipeline

import (
	"dagger.io/dagger"
	"dagger.io/dagger/core"
	//"universe.dagger.io/alpine"
	"universe.dagger.io/bash"
	"universe.dagger.io/docker"
	//"universe.dagger.io/docker/cli"
	//"universe.dagger.io/netlify"
)

dagger.#Plan & {
	//_nodeModulesMount: "/src/node_modules": {
	//	dest:     "/src/node_modules"
	//	type:     "cache"
	//	contents: core.#CacheDir & {
	//		id: "todoapp-modules-cache"
	//	}
	//
	//}
	client: {
		filesystem: {
			"./": read: {
				contents: dagger.#FS
				exclude: [
					//"README.md",
					"_build",
                    "sdlc",
                    "singularity",
					//"dagger.cue",
					//"node_modules",
				]
			},
			"/home/reycheng/cov-analysis-linux64-2022.12.0": read: {
				contents: dagger.#FS
			},
			"./_build": write: contents: actions.build.contents.output
		}
		network: "unix:///var/run/docker.sock": connect: dagger.#Socket
		//env: {
		//	APP_NAME:      string
		//	NETLIFY_TEAM:  string
		//	NETLIFY_TOKEN: dagger.#Secret
		//}
	}
	actions: {
		deps: docker.#Build & {
			steps: [
				docker.#Pull & {
					source: "index.docker.io/gcc:12.2.0"
				},
                //docker.#Dockerfile & {
				//	source: client.filesystem."./".read.contents
				//	dockerfile: path: "Dockerfile.coverity"
				//},
				docker.#Copy & {
					contents: client.filesystem."./".read.contents
					dest:     "/workspace"
				},
				docker.#Copy & {
					contents: client.filesystem."/home/reycheng/cov-analysis-linux64-2022.12.0".read.contents
					dest:     "/opt/coverity"
				},
			]
		}
		//run: cli.#Run & {
		//	host: client.network."unix:///var/run/docker.sock".connect
		//	command: name: "run coverity-singularity"
		//}
		build: {
			run: bash.#Run & {
				input:   deps.output
				//mounts:  _nodeModulesMount
				workdir: "/workspace"
				script: contents: #"""
					mkdir build
					/opt/coverity/bin/cov-configure --config build/covertiy.xml --gcc --template
					/opt/coverity/bin/cov-build --dir build/.covbuild --config build/covertiy.xml gcc source/test.c -o build/test
					#gcc source/test.c -o build/a.out
				"""#
			}
			contents: core.#Subdir & {
				input: run.output.rootfs
				path:  "/workspace/build"
			}
		}
		//deploy: netlify.#Deploy & {
		//	contents: build.contents.output
		//	site:     client.env.APP_NAME
		//	token:    client.env.NETLIFY_TOKEN
		//	team:     client.env.NETLIFY_TEAM
		//}
	}
}
