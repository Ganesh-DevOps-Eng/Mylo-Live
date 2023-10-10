# Launch Template
resource "aws_launch_template" "my_launch_template" {
  name_prefix            = "${var.project_name}-launch-template"
  image_id               = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.my_key_pair.key_name
  vpc_security_group_ids = [module.VPC-Module.server_sg]
  user_data = filebase64("C:\\Users\\Ganesh\\Desktop\\Mylo\\RDS-Module\\userdata.txt")
  lifecycle {
    create_before_destroy = true
  }
}

# Autoscaling Group
resource "aws_autoscaling_group" "my_autoscaling_group" {
  name                      = "${var.project_name}-autoscaling-group"
  target_group_arns         = [aws_lb_target_group.my_target_group.arn]
  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 1
  health_check_type         = "EC2"
  health_check_grace_period = 300
  vpc_zone_identifier       = module.VPC-Module.subnet-private[*]
  launch_template {
    id      = aws_launch_template.my_launch_template.id
    version = "$Latest"
  }
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [load_balancers]
  }
}


# Autoscalling Dynamic Policy for add instance 

resource "aws_autoscaling_policy" "highcpu_policy" {
  name                   = "${var.project_name}-highcpu_policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.my_autoscaling_group.name
}

resource "aws_cloudwatch_metric_alarm" "hightcpu_alarm" {
  alarm_name          = "${var.project_name}-asg-highcpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1 # 5 datapoint
  datapoints_to_alarm = 1 # 2 datapoint (datapoints_to_alarm) out of 5 (evaluation_periods)
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "60"

  dimensions = {
    autoscaling_group_name = aws_autoscaling_group.my_autoscaling_group.name
  }

  alarm_description = "This mertic monitor EC2 instance CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.highcpu_policy.arn]

}

# Autoscalling Dynamic Policy for remove instance 

resource "aws_autoscaling_policy" "downcpu_policy" {
  name                   = "${var.project_name}-downcpu_policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.my_autoscaling_group.name
}

resource "aws_cloudwatch_metric_alarm" "downtcpu_alarm" {
  alarm_name          = "${var.project_name}-asg-downcpu-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1 # 5 datapoint
  datapoints_to_alarm = 1 # 2 datapoint (datapoints_to_alarm) out of 5 (evaluation_periods)
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "20"

  dimensions = {
    autoscaling_group_name = aws_autoscaling_group.my_autoscaling_group.name
  }

  alarm_description = "This mertic monitor EC2 instance CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.downcpu_policy.arn]

}