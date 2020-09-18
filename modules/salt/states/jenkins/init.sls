
jenkins:
  pkgrepo.managed:
    - humanname: Jenkins
    - name: deb https://pkg.jenkins.io/debian-stable binary/
    - file: /etc/apt/sources.list.d/jenkins.list
    - gpgcheck: 1
    - key_url: https://pkg.jenkins.io/debian-stable/jenkins.io.key

  pkg.latest:
    - name: jenkins
    - refresh: True

  file.managed:
    - name: /etc/default/jenkins
    - source: salt://jenkins/files/jenkins
    - require:
      - pkg: jenkins
