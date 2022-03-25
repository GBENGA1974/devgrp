# ROUTE53 POINTED TO LOAD BALANCER

resource "aws_route53_zone" "interviewees-devopsgroup-co" {
    name = "interviewees.devopsgroup.co"
}


resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.interviewees-devopsgroup-co.zone_id
  name    = "www.interviewees.devopsgroup.co"
  type    = "A"

  alias {
    name                   = aws_alb.tf_alb.dns_name
    zone_id                = aws_alb.tf_alb.zone_id
    evaluate_target_health = true
  }
}

output "ns-servers" {
    value = "${aws_route53_zone.interviewees-devopsgroup-co.name_servers}"
  
}