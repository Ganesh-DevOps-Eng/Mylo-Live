output "zone_id" {
  value = aws_route53_zone.main.zone_id
}


output "my_key_pair" {
  value = aws_key_pair.my_key_pair.key_name
}

# data "aws_acm_certificate" "my_certificate" {
#   domain = "clinicalpads.com"  # Replace with your correct domain name
# }


# output "certificate_arn" {
#   value = data.aws_acm_certificate.my_certificate.arn
# }