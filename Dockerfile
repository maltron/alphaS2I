FROM rhel7.2:latest

ENV JAVA_HOME   /usr/java/jdk1.8.0_112
ENV MAVEN_HOME  /opt/apache/maven

# Set the labels that are used for OpenShift to describe the builder image.
LABEL io.k8s.description="Compilation of a Maven Application" \
    io.k8s.display-name="Alpha S2I" \
    io.openshift.expose-services="8080:http" \
    io.openshift.tags="builder,webserver,java" \
    # this label tells s2i where to find its mandatory scripts
    # (run, assemble, save-artifacts)
    io.openshift.s2i.scripts-url="image:///usr/libexec/s2i"

### Install all the necessary tooling
RUN printf "[rhel-7-server-rpms]\n\
name=Red Hat Enterprise Linux 7\n\
baseurl=http://192.168.1.138/repos/rhel-7-server-rpms\n\
enabled=1\n\
gpgcheck=0" > /etc/yum.repos.d/alpha.repo && \
     yum -y update && yum -y install unzip tar && yum clean all && \
### ORIGINAL JDK: http://download.oracle.com/otn-pub/java/jdk/8u112-b15/jdk-8u112-linux-x64.rpm
    curl -O -v -j -k -L -H "Cookie: oraclelicense=accept-securebackup-cookie" http://192.168.1.138/software/jdk-8u112-linux-x64.rpm && \
### ORIGINAL MAVEN: http://ftp.unicamp.br/pub/apache/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
    curl -O http://192.168.1.138/software/apache-maven-3.3.9-bin.tar.gz  && \
### Install Java Development Kit
    rpm -iv jdk-8u112-linux-x64.rpm && \
### Install Maven
    tar zxvf /apache-maven-3.3.9-bin.tar.gz && \
    mkdir --parents ${MAVEN_HOME} && rm -rf ${MAVEN_HOME} && mv apache-maven-3.3.9 /opt/apache && mv /opt/apache/apache-maven-3.3.9 ${MAVEN_HOME} && \
    mkdir --parents ${HOME}/.m2 && \
    export PATH=${PATH}:${MAVEN_HOME}/bin && \
### User
    groupadd --system alpha --gid 1001 && \
    useradd --uid 1001 --system --gid alpha --create-home \
             --home-dir /home/alpha --shell /sbin/nologin --comment "Alpha User" alpha && chmod 755 /home/alpha && \
### Clean Up
    rm -rf /jdk-8u112-linux-x64.rpm && \
    rm -rf /apache-maven-3.3.9-bin.tar.gz

# Copy the S2I scripts to /usr/libexec/s2i since we set the label that way
COPY  ["run", "assemble", "save-artifacts", "usage", "/usr/libexec/s2i/"]

EXPOSE 8080
WORKDIR /home/alpha
USER 1001

CMD ["/usr/libexec/s2i/usage"]


