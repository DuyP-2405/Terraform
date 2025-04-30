#!/bin/bash

# Update package lists and upgrade installed packages
sudo apt update -y
sudo apt upgrade -y

# Install Apache2 web server
sudo apt install apache2 -y

# Enable Apache2 to start at boot
sudo systemctl enable apache2

# Start Apache2 service
sudo systemctl start apache2

# Create or modify the index.html file to include your custom content
echo "<!DOCTYPE html>
<html>
<head>
    <title>Welcome to CyberWatch Web Server</title>
</head>
<body>
    <h1>Hello, Class! This is CyberWatch's  Web Server.</h1>
</body>
</html>" | sudo tee /var/www/html/index.html > /dev/null

# Restart Apache to apply changses
sudo systemctl restart apache2

echo "Apache web server setup completed and index.html modified successfully."
