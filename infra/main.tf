# Create vpc
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = {Name = "luan-github-action"}
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true
  tags                    = {Name = "luan-public-subnet"}
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = {Name = "luan-gtw"}
}

resource "aws_route_table" "public" {
  vpc_id       = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags         = {Name = "public-route-table"}
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
  depends_on     = [aws_internet_gateway.igw]
}

resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "public-sg"
  }
}

# Create EC2 instance

# tạo khóa SSH
resource "tls_private_key" "key_pem" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Tạo Key Pair trong AWS
resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.key_pem.public_key_openssh
}

# Lưu private key cục bộ
resource "local_file" "private_key" {
  content   = tls_private_key.key_pem.private_key_pem
  filename = "${path.module}/${var.key_name}.pem" # Lưu tệp private key với định dạng PEM
}

# tao EC2
resource "aws_instance" "public" {
  ami           = data.aws_ami.ubuntu.id 
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public.id
  key_name      = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  associate_public_ip_address = true
  tags = {
    Name = "git-action-EC2"
  }
}

# Fetch AMI for Amazon Linux 2
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical - Nhà cung cấp chính thức của Ubuntu

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
