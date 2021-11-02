resource "aws_lb" "tfe_lb" {
  #checkov:skip=CKV_AWS_150:Given we are automating this for the most part we can recover from a deleted load-balancer. Okay for now.
  name                             = "${var.friendly_name_prefix}-tfe-nlb"
  internal                         = true
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = true
  subnets                          = var.network_private_subnets

  dynamic "access_logs" {
    for_each = var.logging_bucket != null ? [var.logging_bucket] : []
    content {
      bucket  = var.logging_bucket
      prefix  = var.logging_prefix
      enabled = true
    }
  }
}

resource "aws_lb_listener" "tfe_listener_443" {
  load_balancer_arn = aws_lb.tfe_lb.arn
  port              = 443
  protocol          = "TLS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tfe_tg_443.arn
  }
}

resource "aws_lb_target_group" "tfe_tg_443" {
  name     = "${var.friendly_name_prefix}-tfe-nlb-tg-443"
  port     = 443
  protocol = "TLS"
  vpc_id   = var.network_id

  health_check {
    protocol = "HTTPS"
    path     = "/_health_check"
    matcher  = "200-399"
  }
}

resource "aws_lb_listener" "tfe_listener_8800" {
  count             = var.active_active ? 0 : 1
  load_balancer_arn = aws_lb.tfe_lb.arn
  port              = 8800
  protocol          = "TLS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tfe_tg_8800[0].arn
  }
}

resource "aws_lb_target_group" "tfe_tg_8800" {
  count    = var.active_active ? 0 : 1
  name     = "${var.friendly_name_prefix}-tfe-nlb-tg-8800"
  port     = 8800
  protocol = "TCP"
  vpc_id   = var.network_id

  health_check {
    path     = "/"
    protocol = "TCP"
  }
}

data "aws_route53_zone" "tfe" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "tfe" {
  zone_id = data.aws_route53_zone.tfe.zone_id
  name    = var.fqdn
  type    = "A"

  alias {
    name                   = aws_lb.tfe_lb.dns_name
    zone_id                = aws_lb.tfe_lb.zone_id
    evaluate_target_health = true
  }
}
