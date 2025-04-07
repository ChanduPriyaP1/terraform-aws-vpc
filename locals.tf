locals {
  resource-name = "${var.project_name}-${var.environmen}"
  az_zones = slice(data.aws_availability_zones.available.names, 0, 2)
}