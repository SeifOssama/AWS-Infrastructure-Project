 # Create Auto Scaling Group 
resource "aws_launch_configuration" "app" {
name          = "app-launch-configuration"
image_id      = "ami-013efd7d9f40467af"
instance_type = "t2.micro"
key_name      = "security.pem"
iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
security_groups      = [aws_security_group.SEIF-SG.id]
user_data = <<-EOF
#!/bin/bash
# Install Apache and PHP
yum update -y
yum install -y httpd php

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Fetch instance metadata
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 || echo "Not Assigned")
LOCAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# Create a PHP script with metadata
cat <<EOP > /var/www/html/index.php
<?php
// Fetch EC2 instance metadata
$az = shell_exec('curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone');
$instance_id = shell_exec('curl -s http://169.254.169.254/latest/meta-data/instance-id');
$public_ip = shell_exec('curl -s http://169.254.169.254/latest/meta-data/public-ipv4');
$local_ip = shell_exec('curl -s http://169.254.169.254/latest/meta-data/local-ipv4');

// Handle file upload
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_FILES['file_upload'])) {
    // File details
    $fileName = $_FILES['file_upload']['name'];
    $fileTmpPath = $_FILES['file_upload']['tmp_name'];

    // S3 bucket details
    $bucketName = 'your-bucket-name';
    $keyName = 'uploads/' . $fileName;

    // Upload file to S3
    $command = "aws s3 cp $fileTmpPath s3://$bucketName/$keyName";
    $output = shell_exec($command);

    if (strpos($output, 'upload:') !== false) {
        $uploadMessage = '<p>File uploaded successfully to S3!</p>';
    } else {
        $uploadMessage = '<p>Failed to upload file to S3.</p>';
    }
} else {
    $uploadMessage = '';
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>EC2 Instance Details & S3 Upload</title>
</head>
<body>
    <h1>Welcome to the Instance</h1>
    <h2>Instance Details:</h2>
    <ul>
        <li>Availability Zone: <?php echo htmlspecialchars($az); ?></li>
        <li>Instance ID: <?php echo htmlspecialchars($instance_id); ?></li>
        <li>Public IP: <?php echo htmlspecialchars($public_ip); ?></li>
        <li>Local IP: <?php echo htmlspecialchars($local_ip); ?></li>
    </ul>

    <!-- File Upload Section -->
    <h3>Upload File to S3</h3>
    <form method="POST" enctype="multipart/form-data">
        <input type="file" name="file_upload" required>
        <button type="submit">Upload</button>
    </form>
    <?php echo $uploadMessage; ?>

    <!-- Display Uploaded Files -->
    <h3>Uploaded Files in S3</h3>
    <ul>
    <?php
		// S3 bucket details
		$bucketName = 'your-bucket-name';

		// Use AWS CLI to list files in the S3 bucket
		$output = shell_exec("aws s3 ls s3://$bucketName/uploads/ 2>&1");
		if (strpos($output, 'NoSuchBucket') !== false) {
			echo "<p>Error: Bucket not found. Please check your bucket name.</p>";
		} else {
			// Parse the AWS CLI output to display only existing files
			foreach (explode("\n", $output) as $line) {
				if (trim($line) != '') {
					// Extract the file name (3rd column from aws s3 ls output)
					$fileName = preg_split('/\s+/', $line)[3];
					echo "<li><a href='https://$bucketName.s3.amazonaws.com/uploads/$fileName' target='_blank'>$fileName</a></li>";
				}
			}
		}
		?>
    </ul>
</body>
</html>

EOP

# Set permissions
chmod 644 /var/www/html/index.php

# Restart Apache
systemctl restart httpd

EOF
}

resource "aws_autoscaling_group" "SEIF-ASG" { 
name = "SEIF-ASG"
launch_configuration = aws_launch_configuration.app.id
min_size             = 2
max_size             = 3
desired_capacity     = 2
vpc_zone_identifier  = [aws_subnet.subnet2.id, aws_subnet.subnet4.id] 
target_group_arns = [aws_lb_target_group.test.arn] 
    tag { 
        key                 = "Name"
        value               = "SEIF-ASG"
        propagate_at_launch = true
    } 
} 
