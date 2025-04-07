output "az-zones" {
  value = data.aws_availability_zones.available.names
}

output "public_subnet" {
  value = aws_subnet.public[*].id
}

output "private_subnet" {
  value = aws_subnet.private[*].id
}

output "database_subnet" {
  value = aws_subnet.database[*].id
}