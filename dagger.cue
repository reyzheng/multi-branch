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
					//"dagger.cue",
					//"node_modules",
				]
			},
            "./_build": write: contents: actions.build.contents.output
			"/home/reycheng/cov-analysis-linux64-2022.12.0": read: {
				contents: dagger.#FS
			},
            //"./sdlc": write: contents: actions.buildcov.contents.output
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
                    // docker image with toolchain and singularity
                    //source: "devops.realtek.com:30443/dagger/rey-gcc:0.1"
				},
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
		//depscov: docker.#Build & {
		//	steps: [
		//		docker.#Pull & {
		//			source: "devops.realtek.com:30443/dagger/rey-coverity"
		//		},
        //        //docker.#Dockerfile & {
		//		//	source: client.filesystem."./".read.contents
		//		//	dockerfile: path: "Dockerfile.coverity"
		//		//},
		//	]
		//}
		//run: cli.#Run & {
		//	host: client.network."unix:///var/run/docker.sock".connect
		//	command: name: "run coverity-singularity"
		//}
		//buildcov: {
		//	run: bash.#Run & {
		//		input:   depscov.output
		//		workdir: "/"
        //        script: contents: #"""
        //            mkdir _build
        //            cp -a /opt/cov-analysis-linux64-2022.12.0 _build
        //        """#
		//	}
		//	contents: core.#Subdir & {
		//		input: run.output.rootfs
		//		path:  "/_build"
		//	}
        //}
		build: {
			run: bash.#Run & {
				input:   deps.output
				//mounts:  _nodeModulesMount
				workdir: "/workspace"
                script: contents: #"""
                    # coverity.sif pre-download at jenkins pipeline stage
                    mkdir build
                    mkdir .cov
                    echo '#FLEXnet (do not delete this line)' > .cov/.coverity.license.config
                    # 1123@papyrus.realtek.com
                    # TODO: change name server in docker, required to export local /etc/resolv.conf maybe
                    echo 'license-server 1123@172.21.2.224' >> .cov/.coverity.license.config
                    echo '' >> .cov/.coverity.license.config
                    /opt/coverity/bin/cov-configure --config .cov/covertiy.xml --gcc --template
                    /opt/coverity/bin/cov-build --dir .cov/.covbuild --config .cov/covertiy.xml gcc source/test.c -o build/test
                    /opt/coverity/bin/cov-analyze -sf .cov/.coverity.license.config --dir .cov/.covbuild
                """#
			}
			//run: bash.#Run & {
			//	input:   deps.output
			//	//mounts:  _nodeModulesMount
			//	workdir: "/workspace"
            //    script: contents: #"""
            //        # coverity.sif pre-download at jenkins pipeline stage
            //        mkdir build
            //        mkdir .cov
            //        singularity --version
            //        singularity --version
            //        echo '#FLEXnet (do not delete this line)' > .cov/.coverity.license.config
            //        # 1123@papyrus.realtek.com
            //        # TODO: change name server in docker, required to export local /etc/resolv.conf maybe
            //        echo 'license-server 1123@172.21.2.224' >> .cov/.coverity.license.config
            //        echo '' >> .cov/.coverity.license.config
            //        singularity exec coverity-2022.12.0.sif cov-configure --config .cov/covertiy.xml --gcc --template
            //        singularity exec coverity-2022.12.0.sif cov-build --dir .cov/.covbuild --config .cov/covertiy.xml gcc source/test.c -o build/test
            //        singularity exec coverity-2022.12.0.sif cov-analyze -sf .cov/.coverity.license.config --dir .cov/.covbuild
            //    """#
			//}
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
