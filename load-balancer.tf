# Create Load Balancer (ALB)
resource "aws_lb" "test" {
name = "Yakout-LoadBalancer"
internal =false
load_balancer_type = "application"
security_groups = [aws_security_group.SEIF-SG.id]
subnets = [aws_subnet.subnet1.id, aws_subnet.subnet3.id]
enable_deletion_protection = false
tags = {
Name = "Yakout-LoadBalancer" }
}
# Create Target Group
resource "aws_lb_target_group" "test" {
name = "privateinstances"
port = 80
protocol = "HTTP"
vpc_id = aws_vpc.main.id
health_check {
protocol = "HTTP"
path = "/"
}
tags = {
Name = "privateinstances"
}
}

# Create Listener for ALB
resource "aws_lb_listener" "test" {
load_balancer_arn = aws_lb.test.arn
port = "80"
protocol = "HTTP"
default_action {
type = "forward"
target_group_arn = aws_lb_target_group.test.arn
}
}