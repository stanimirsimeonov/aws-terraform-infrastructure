# Generate new private key
# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  rsa_bits  = 4096

}

# Generate a key-pair with above key
# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
resource "aws_key_pair" "bastion" {
  key_name   = "bastion-${local.project.slug}-key"
  public_key = tls_private_key.bastion.public_key_openssh
}

resource "local_file" "bastion-private-key" {
  content  = tls_private_key.bastion.private_key_pem
  filename = "bundles/${terraform.workspace}/bastion-${local.project.slug}-key.pem"
  file_permission = "0400"
}
resource "local_file" "bastion-public-key" {
  content  = tls_private_key.bastion.public_key_openssh
  filename = "bundles/${terraform.workspace}/bastion-${local.project.slug}-key.pub"
  file_permission = "0400"
}



#EC2 for bastion host
# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
resource "aws_instance" "bastion_host" {
  ami           = "ami-0f540e9f488cfa27d"
  instance_type = "t2.micro"
  key_name      = "bastion-${local.project.slug}-key"
  subnet_id     = aws_subnet.public[0].id

  vpc_security_group_ids = [aws_security_group.bastion.id]

  user_data = <<EOF
		 #! /bin/bash
             sudo apt update
             sudo apt install wget curl git ca-certificates postgresql-client
      EOF
  # write the public file in the host machine

  provisioner "local-exec" {
    command = "mkdir -p bundles/${terraform.workspace}/"
  }

  provisioner "local-exec" {
    command = "mkdir -p echo ${aws_instance.bastion_host.public_ip} > bundles/${terraform.workspace}/publicIP.txt"
  }


  connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key =  tls_private_key.bastion.private_key_pem
    host     = self.public_ip
  }

  tags = {
    Name = "tbc.eks.bastion.${local.project.slug}"
  }
}