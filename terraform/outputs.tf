 output "k8s_node_ips" { value = aws_instance.k8s_node[*].public_ip }
 output "jenkins_ip" {
   value = aws_instance.jenkins.public_ip
 }