
jenkins:
  firewall.check:
    - name: 'HTTP'
    - port: 80
    - proto: 'tcp'

  pkgrepo.managed:
    - humanname: Jenkins
    - name: deb https://pkg.jenkins.io/debian binary/
    - file: /etc/apt/sources.list.d/jenkins.list
    - gpgcheck: 1
    - key_url: https://pkg.jenkins.io/debian/jenkins.io.key

  pkg.latest:
    - name: jenkins
    - refresh: True

  file.managed:
    - name: /etc/default/jenkins
    - source: salt://jenkins/files/jenkins
    - require:
      - pkg: jenkins

  firewalld.present:
    - name: jenkins
    - ports:
      - 80/tcp
      - 22/tcp
