node {
    // Bring up CTC pipeline framework
    def pf
    dir('pf-bringup') {
        /*
        deleteDir()
        if (isUnix() == true) {
            sh "GIT_SSL_NO_VERIFY=true git clone https://mirror.rtkbf.com/gerrit/sdlc/jenkins-pipeline -b develop ."
        }
        else {
            bat "set GIT_SSL_NO_VERIFY=true && git clone https://mirror.rtkbf.com/gerrit/sdlc/jenkins-pipeline -b develop ."
        }
        */
        pf = load("hera.groovy")
    }
    pf.start()
}
