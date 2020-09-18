
output "public_ip" {
  value = aws_eip.jenkins.public_ip
}