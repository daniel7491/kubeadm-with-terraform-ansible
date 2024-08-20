terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }

    ansible = {
      source  = "ansible/ansible"
      version = "1.3.0"
    }
  }

}

provider "aws" {
  region = "ca-central-1"
}

resource "aws_vpc" "kubeadm_daniel_pj_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "kubeadm_daniel_pj_vpc"
  }

}
resource "aws_subnet" "kubeadm_daniel_pj_subnet" {
  vpc_id                  = aws_vpc.kubeadm_daniel_pj_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "kubeadm_daniel_pj_subnet"
  }
}

resource "aws_internet_gateway" "kubeadm_daniel_pj_gateway" {
  vpc_id = aws_vpc.kubeadm_daniel_pj_vpc.id

  tags = {
    Name = "kubeadm_daniel_pj_gateway"
  }
}

resource "aws_route_table" "kubeadm_daniel_pj_route_table" {
  vpc_id = aws_vpc.kubeadm_daniel_pj_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kubeadm_daniel_pj_gateway.id
  }

  tags = {
    Name = "kubeadm_daniel_pj_route_table"
  }
}


resource "aws_route_table_association" "kubeadm_route_table_association_daniel_pj" {
  subnet_id      = aws_subnet.kubeadm_daniel_pj_subnet.id
  route_table_id = aws_route_table.kubeadm_daniel_pj_route_table.id

}


resource "aws_security_group" "kubeadm_daniel_pj_sj_common" {

  name = "kubeadm_pj_daniel_common"
  tags = {
    Name = "kubeadm_pj_daniel_common"
  }
  vpc_id = aws_vpc.kubeadm_daniel_pj_vpc.id

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


resource "aws_security_group" "daniel_pj_security_group_control_plane" {

  name = "kubeadm_pj_daniel_control_plane"
  tags = {
    Name = "kubeadm_pj_daniel_control_plane"
  }
  vpc_id = aws_vpc.kubeadm_daniel_pj_vpc.id

  ingress {
    description = "kubernetes api server"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Kubelet api"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Kube-scheduler"
    from_port   = 10259
    to_port     = 10259
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Kube-controller-manager"
    from_port   = 10257
    to_port     = 10257
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Etcd server client api"
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "kubeadm_daniel_pj_sg_worker_nodes" {

  name = "kubeadm_pj_daniel_worker_nodese"
  tags = {
    Name = "kubeadm_pj_daniel_worker_nodes"
  }
  vpc_id = aws_vpc.kubeadm_daniel_pj_vpc.id

  ingress {
    description = "Kubelet api"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "NodePort Services"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "kubeadm_daniel_pj_sg_flannel" {
  name = "kubeadm_daniel_pj_sg_flannel"
  tags = {
    Name = "kubeadm_daniel_pj_sg_flannel"
  }
  vpc_id = aws_vpc.kubeadm_daniel_pj_vpc.id

  ingress {
    description = "udp backend"
    from_port   = 8285
    to_port     = 8285
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "udp vxlan backend"
    from_port   = 8472
    to_port     = 8472
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "tls_private_key" "kubeadm_daniel_privet_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
  provisioner "local-exec" {
    command = "echo '${self.public_key_pem}' > ./pubkey.pem"
  }
}

resource "aws_key_pair" "kubeadm_daniel_key_pj" {
  key_name   = var.kubeadm_daniel_pj_key_name
  public_key = tls_private_key.kubeadm_daniel_privet_key.public_key_openssh

  provisioner "local-exec" {
    command = "echo '${tls_private_key.kubeadm_daniel_privet_key.private_key_pem}' > C:/Users/dnai7/terraform-project-class/private_key.pem"
  }
}

resource "null_resource" "write_private_key" {
  provisioner "local-exec" {
    command = "echo '${tls_private_key.kubeadm_daniel_privet_key.private_key_pem}' > private_key.pem"
  }
}

resource "aws_instance" "kubeadm_pj_daniel_control_plane_instance" {
  instance_type = "t2.large"
  ami           = var.kubeadm_daniel_pj_ami

  key_name                    = "daniel-2"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.kubeadm_daniel_pj_subnet.id
  vpc_security_group_ids = [
    aws_security_group.kubeadm_daniel_pj_sj_common.id,
    aws_security_group.daniel_pj_security_group_control_plane.id,
    aws_security_group.kubeadm_daniel_pj_sg_flannel.id,
  ]
  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }
  tags = {
    Name = "kubeadm control plane-daniel"
    Role = "master node"

  }

  provisioner "local-exec" {
    command = "echo 'master ${self.public_ip} >> ./files.hosts"
  }
}

resource "aws_instance" "kubeadm-workernodes-daniel" {
  count                       = var.kubeadm_instance_count
  ami                         = var.kubeadm_daniel_pj_ami
  instance_type               = var.kubeadm_instance_type
  key_name                    = "daniel-2"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.kubeadm_daniel_pj_subnet.id

  vpc_security_group_ids = [
    aws_security_group.kubeadm_daniel_pj_sj_common.id,
    aws_security_group.kubeadm_daniel_pj_sg_worker_nodes.id,
    aws_security_group.kubeadm_daniel_pj_sg_flannel.id,
  ]

  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }
  tags = {
    Name = "kubeadm worker-daniel ${count.index}"
    Role = "worker node"
  }
  provisioner "local-exec" {
    command = "echo 'worker -${count.index} ${self.public_ip} >> ./files.hosts"
  }
}

resource "ansible_host" "kubeadm_daniel_controlplane_host" {
  depends_on = [
    aws_instance.kubeadm_pj_daniel_control_plane_instance
  ]

  name   = "control_plane"
  groups = ["master"]
  variables = {
    ansible_user                = "ubuntu"
    ansible_host                = aws_instance.kubeadm_pj_daniel_control_plane_instance.public_ip
    ansible_ssh_privat_key_file = "C:\\Users\\dnai7\\Downloads\\daniel-2.pem"
    node_hostname               = "master"

  }

}

resource "ansible_host" "kubeadm_daniel_worker_nodes_host" {
  depends_on = [
    aws_instance.kubeadm-workernodes-daniel
  ]
  count  = var.kubeadm_instance_count
  name   = "worker-${count.index}"
  groups = ["workers"]
  variables = {
    ansible_user                = "ubuntu"
    ansible_host                = aws_instance.kubeadm-workernodes-daniel[count.index].public_ip
    ansible_ssh_privat_key_file = "C:\\Users\\dnai7\\Downloads\\daniel-2.pem"
    node_hostname               = "worker-${count.index}"

  }

}