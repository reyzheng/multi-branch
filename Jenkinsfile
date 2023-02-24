node {
    // Bring up CTC pipeline framework
    def pf
    dir('pf-bringup') {
        deleteDir()
        if (isUnix() == true) {
            sh "GIT_SSL_NO_VERIFY=true git clone https://github.com/reyzheng/jenkins-pipeline.git ."
        }
        else {
            bat "set GIT_SSL_NO_VERIFY=true && git clone https://github.com/reyzheng/jenkins-pipeline.git ."
        }
        pf = load("hera.groovy")
    }
    pf.start()
}
