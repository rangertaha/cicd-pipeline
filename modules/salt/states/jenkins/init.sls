
jenkins:
  pkgrepo.managed:
    - humanname: Jenkins
    - name: deb https://pkg.jenkins.io/debian binary
    - file: /etc/apt/sources.list.d/jenkins.list
    - key_url: https://pkg.jenkins.io/debian/jenkins.io.key

  pkg.latest:
    - name: jenkins
    - refresh: True
