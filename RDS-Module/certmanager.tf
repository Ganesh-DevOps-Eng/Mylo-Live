resource "tls_self_signed_cert" "self_signed_cert" {
  private_key_pem = tls_private_key.my_private_key.private_key_pem

  subject {
    common_name  = var.root_domain_name
    organization = "Matellio India Pvt Ltd"
  }

  validity_period_hours = 12

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}
resource "aws_iam_server_certificate" "self_signed_cert" {
  name              = "my-self-signed-cert"
  private_key       = tls_private_key.my_private_key.private_key_pem
  certificate_body  = tls_self_signed_cert.self_signed_cert.cert_pem
}


# resource "aws_acm_certificate" "my_certificate" {
#   domain_name               = var.root_domain_name
#   subject_alternative_names = ["*.${var.root_domain_name}"]
#   validation_method         = "DNS"
# }

resource "aws_route53_zone" "main" {
  name = var.root_domain_name
}


# locals {
#   domain_validation_list = tolist(aws_acm_certificate.my_certificate.domain_validation_options)
# }


# resource "aws_route53_record" "route53_record" {
#   count = length(local.domain_validation_list)
#
#   name            = local.domain_validation_list[count.index].resource_record_name
#   records         = [local.domain_validation_list[count.index].resource_record_value]
#   type            = local.domain_validation_list[count.index].resource_record_type
#   zone_id         = aws_route53_zone.main.zone_id
#   ttl             = 60
#   allow_overwrite = true
# }

resource "aws_route53_record" "lb_record" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.${var.root_domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.my_load_balancer.dns_name
    zone_id                = aws_lb.my_load_balancer.zone_id
    evaluate_target_health = true
  }
}


# resource "aws_acm_certificate_validation" "acm_certificate_validation" {
#   certificate_arn         = aws_acm_certificate.my_certificate.arn
#   validation_record_fqdns = [for r in local.domain_validation_list : r.resource_record_name]
#   depends_on              = [aws_route53_record.route53_record]
# }
