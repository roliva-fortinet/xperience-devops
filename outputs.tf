output "public_ip" {
  value = aws_instance.apache_server.public_ip
}