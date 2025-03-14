output "vpc_id" {
  description = "ID của VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID của subnet public"
  value       = aws_subnet.public.id
}

output "ec2_public_ip" {
  description = "Public IP của EC2 instance"
  value       = aws_instance.public.public_ip
}

output "key_pair_name" {
  description = "Tên của Key Pair được tạo"
  value       = aws_key_pair.key_pair.key_name
}

