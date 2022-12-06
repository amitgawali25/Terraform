data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*"
    ]

    # AmazonLinux 2 if you want
    # "amzn2-ami-hvm-*"
  }

  filter {
    name = "root-device-type"

    values = [
      "ebs",
    ]
  }

  filter {
    name = "architecture"

    values = [
      "x86_64",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }

  owners = [
    "amazon",
    "self",
  ]
}

# Create a new AWS Key Pair
resource "aws_key_pair" "TF_key" {
  key_name   = "TF_key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "TF-key" {
    content  = tls_private_key.rsa.private_key_pem
    filename = "tfkey"
}

# AutoScalingGroup for FE EC2s >>>>>>>>>>>>>>>>>>>>>>>>>>>>>

resource "aws_launch_template" "app_launch_template" {
  name          = "${var.project_name}-app_fe_tpl"
  #image_id     = data.aws_ami.amazon_linux.image_id  # ! Fix this
  image_id      = "ami-0b0dcb5067f052a63"
  instance_type = var.instance_type
  key_name      = aws_key_pair.TF_key.key_name
  user_data     = filebase64("${path.module}/installApp.sh")

  network_interfaces {
    associate_public_ip_address  = true
    security_groups              = ["${var.ec_security_group_id}"]
  }
  monitoring {
    enabled = true
  }
  
  tags = {
    Name = "Autoscaled Frontend EC2s",
  }
 }


resource "aws_autoscaling_group" "app_autoscaling_group" {

  name                      = "${var.project_name}-app-asg"
  max_size                  = var.max_number_of_instances
  min_size                  = var.min_number_of_instances
  desired_capacity          = var.desired_capacity
  health_check_grace_period = 300
  health_check_type         = var.asg_health_check_type                           #  "ELB" or default EC2
  force_delete              = true
  vpc_zone_identifier       = [var.public_subnet_az1_id,var.public_subnet_az2_id]
  target_group_arns         = [var.alb_target_group_arn]

  enabled_metrics = [
                        "GroupMinSize",
                        "GroupMaxSize",
                        "GroupDesiredCapacity",
                        "GroupInServiceInstances",
                        "GroupPendingInstances",
                        "GroupStandbyInstances",
                        "GroupTerminatingInstances",
                        "GroupTotalInstances"
                    ]

  metrics_granularity = "1Minute"

  launch_template {
    id      = aws_launch_template.app_launch_template.id
    version = "$Latest"
  }

}

# Scale up policy
resource "aws_autoscaling_policy" "app_scale_up_policy" {
  name                   = "${var.project_name}-asg-scale-up"
  autoscaling_group_name = aws_autoscaling_group.app_autoscaling_group.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"                      # increase instance by 1 
  cooldown               = "300"                    # delay between scaling actions
  policy_type            = "SimpleScaling"
}

# App scale up alarm
resource "aws_cloudwatch_metric_alarm" "app_scale_up_alarm" {
  alarm_name          = "${var.project_name}-asg-scale-up-alarm"
  alarm_description   = "Scale up - This metric monitors ec2 cpu utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80" # New instance will be created once CPU utilization is higher than 80 %
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.app_autoscaling_group.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.app_scale_up_policy.arn]
}

# App scale down policy
resource "aws_autoscaling_policy" "app_scale_down" {
  name                   = "${var.project_name}-asg-scale-down"
  autoscaling_group_name = aws_autoscaling_group.app_autoscaling_group.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"                         # reduce instances by 1 
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

# App scale down alarm
resource "aws_cloudwatch_metric_alarm" "app_scale_down_alarm" {
  alarm_name          = "${var.project_name}-asg-scale-down-alarm"
  alarm_description   = "Scale down - This metric monitors ec2 cpu utilization"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "10"                    # Instance will scale down when CPU utilization is lower than 10 %
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.app_autoscaling_group.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.app_scale_down.arn]
}

resource "aws_autoscaling_attachment" "asg_attach" {
  autoscaling_group_name = aws_autoscaling_group.app_autoscaling_group.id
  lb_target_group_arn    = var.alb_target_group_arn
}

# AutoScalingGroup for Bastion EC2s >>>>>>>>>>>>>>>>>>>>>>>>>>>>>

resource "aws_launch_template" "bastion_launch_template" {
  name          = "${var.project_name}-bastion_tpl"
  #image_id     = data.aws_ami.amazon_linux.image_id  # ! Fix this
  image_id      = "ami-0b0dcb5067f052a63"
  instance_type = var.instance_type
  key_name      = aws_key_pair.TF_key.key_name

  network_interfaces {
    associate_public_ip_address  = true
    security_groups              = ["${var.ec_bastion_security_group_id}"]
  }
  monitoring {
    enabled = true
  }
  
  tags = {
    Name = "Autoscaled Bastion EC2s",
  }
 }


resource "aws_autoscaling_group" "bastion_autoscaling_group" {

  name                      = "${var.project_name}-bastion-asg"
  max_size                  = var.bastion_max_number_of_instances
  min_size                  = var.bastion_min_number_of_instances
  desired_capacity          = var.bastion_desired_capacity
  health_check_grace_period = 300
  health_check_type         = var.asg_health_check_type                           #  "ELB" or default EC2
  force_delete              = true
  vpc_zone_identifier       = [var.public_subnet_az1_id,var.public_subnet_az2_id]
  #target_group_arns         = [var.alb_target_group_arn]

  enabled_metrics = [
                        "GroupMinSize",
                        "GroupMaxSize",
                        "GroupDesiredCapacity",
                        "GroupInServiceInstances",
                        "GroupPendingInstances",
                        "GroupStandbyInstances",
                        "GroupTerminatingInstances",
                        "GroupTotalInstances"
                    ]

  metrics_granularity = "1Minute"

  launch_template {
    id      = aws_launch_template.bastion_launch_template.id
    version = "$Latest"
  }

}


# AutoScalingGroup for BE EC2s >>>>>>>>>>>>>>>>>>>>>>>>>>>>>

resource "aws_launch_template" "app_be_launch_template" {
  name          = "${var.project_name}-app_be_tpl"
  #image_id     = data.aws_ami.amazon_linux.image_id  # ! Fix this
  image_id      = "ami-0b0dcb5067f052a63"
  instance_type = var.instance_type
  key_name      = aws_key_pair.TF_key.key_name
  user_data     = filebase64("${path.module}/installBe.sh")

  network_interfaces {
    associate_public_ip_address  = true
    security_groups              = ["${var.ec_be_security_group_id}"]
  }
  monitoring {
    enabled = true
  }
  
  tags = {
    Name = "Autoscaled Backend EC2s",
  }
 }


resource "aws_autoscaling_group" "app_be_autoscaling_group" {

  name                      = "${var.project_name}-be_asg"
  max_size                  = var.max_number_of_instances
  min_size                  = var.min_number_of_instances
  desired_capacity          = var.desired_capacity
  health_check_grace_period = 300
  health_check_type         = var.asg_health_check_type               #  "ELB" or default EC2
  force_delete              = true
  vpc_zone_identifier       = [var.private_app_subnet_az1_id,var.private_app_subnet_az2_id]
  #target_group_arns         = [var.alb_target_group_arn] ! check

  enabled_metrics = [
                        "GroupMinSize",
                        "GroupMaxSize",
                        "GroupDesiredCapacity",
                        "GroupInServiceInstances",
                        "GroupPendingInstances",
                        "GroupStandbyInstances",
                        "GroupTerminatingInstances",
                        "GroupTotalInstances"
                    ]

  metrics_granularity = "1Minute"

  launch_template {
    id      = aws_launch_template.app_be_launch_template.id
    version = "$Latest"
  }

}

# scale up policy
resource "aws_autoscaling_policy" "app_be_scale_up_policy" {
  name                   = "${var.project_name}-be_asg_scale_up"
  autoscaling_group_name = aws_autoscaling_group.app_be_autoscaling_group.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"                      # increase instance by 1 
  cooldown               = "300"                    # delay between scaling actions
  policy_type            = "SimpleScaling"
}

# App scale up alarm
resource "aws_cloudwatch_metric_alarm" "app_be_scale_up_alarm" {
  alarm_name          = "${var.project_name}-be_asg_scale_up_alarm"
  alarm_description   = "Scale up - This metric monitors BE ec2 cpu utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80" # New instance will be created once CPU utilization is higher than 80 %
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.app_be_autoscaling_group.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.app_be_scale_up_policy.arn]
}

# App scale down policy
resource "aws_autoscaling_policy" "app_be_scale_down" {
  name                   = "${var.project_name}-be_asg_scale_down"
  autoscaling_group_name = aws_autoscaling_group.app_be_autoscaling_group.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"                         # reduce instances by 1 
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

# App scale down alarm
resource "aws_cloudwatch_metric_alarm" "app_be_scale_down_alarm" {
  alarm_name          = "${var.project_name}-be_asg_scale_down_alarm"
  alarm_description   = "Scale down - This metric monitors BE ec2 cpu utilization"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "10"                 # Instance will scale down when CPU utilization is lower than 10 %
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.app_be_autoscaling_group.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.app_be_scale_down.arn]
}



