output "Consul server public address" {
  value = "${aws_instance.consul_server.public_ip}"
}


