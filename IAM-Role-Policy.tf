# Create IAM Role and Policy
resource "aws_iam_role" "yakout-s3-role" { 
    name = "yakout-s3-role" 
    assume_role_policy = jsonencode(
        { 
            Version = "2012-10-17",
            Statement = [ 
                { Action = "sts:AssumeRole",
                Effect = "Allow",
                Principal = { Service = "ec2.amazonaws.com"
                }
                }
                ]
                }
                )
                }


resource "aws_iam_policy" "yakout-s3-policy" { 
    name = "s3_policy"
    policy = jsonencode({ 
        Version = "2012-10-17",
        Statement = [
            { Action = [ 
            "s3:ListBucket",
            "s3:GetObject",
            "s3:PutObject" ],
            Effect = "Allow",
            Resource = [ 
                "arn:aws:s3:::cloudkode-s3",
                "arn:aws:s3:::cloudkode-s3/*" 
                ] 
                }
                ]
                }
                )
                }


resource "aws_iam_role_policy_attachment" "policy-attachment" {
    role = aws_iam_role.ec2_role.name 
    policy_arn = aws_iam_policy.s3_policy.arn
    }


# Attach IAM Role to EC2 Instances
resource "aws_iam_instance_profile" "ec2_profile" {
    name = "ec2_profile"
    role = aws_iam_role.ec2_role.name
    }