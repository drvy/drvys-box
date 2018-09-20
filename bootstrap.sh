#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive

sudo apt-get -y update
sudo apt-get -y dist-upgrade

# ------------------------------------------
# Default config for MySQL server
# ------------------------------------------
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password toor'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password toor'


# ------------------------------------------
# Install Packages.
# ------------------------------------------

# Curl, PHP, MySQL, NGINX
sudo apt-get -y install curl
sudo apt-get -y install php-cli php-fpm php-curl php-dev php-zip php-gd php-xml php-mysql php-mbstring php-json php-sqlite3 php-xdebug
sudo apt-get -y install mysql-server mysql-client
sudo apt-get -y install nginx

# Github Pages
sudo apt-get -y install ruby ruby-dev jekyll zlib1g-dev
sudo gem install jekyll-paginate jekyll-sitemap jekyll-gist github-pages


# ------------------------------------------
# Generate SSL Certificates
# ------------------------------------------
sudo mkdir -p /etc/nginx/conf.d/certs
sudo openssl req -nodes -new -x509 -subj "/C=ES/ST=NA/L=NA/O=dMDev/OU=DevOps/CN=192.168.30.10/emailAddress=dev@localhost.com" -keyout /etc/nginx/conf.d/certs/dmdev.key -out /etc/nginx/conf.d/certs/dmdev.cert


# ------------------------------------------
# Configure the default NGINX site
# ------------------------------------------
sudo rm /etc/nginx/sites-available/default
sudo touch /etc/nginx/sites-available/default

sudo cat > /etc/nginx/sites-available/default <<'EOF'
server {
    listen 80 default_server;
    listen 443 ssl;

    root /var/www;
    server_name _;

    access_log /var/log/nginx/default.access.log;
    error_log /var/log/nginx/default.error.log;

    ssl_certificate      /etc/nginx/conf.d/certs/dmdev.cert;
    ssl_certificate_key  /etc/nginx/conf.d/certs/dmdev.key;

    include /etc/nginx/include.d/all-common;
}
EOF


# ------------------------------------------
# This should be included in all sites
# ------------------------------------------
sudo mkdir -p /etc/nginx/include.d
sudo touch /etc/nginx/include.d/all-common

sudo -s cat > /etc/nginx/include.d/all-common <<'EOF'
index index.html index.php;

location / {
    try_files $uri $uri/ /index.php?q=$uri&$args;
}

location ~ /\.ht { deny all; }
location = /favicon.ico { log_not_found off; access_log off; }

location ~ \.php$ {
    include snippets/fastcgi-php.conf;
    fastcgi_pass unix:/run/php/php7.2-fpm.sock;
}
EOF


# ------------------------------------------
# Create WWW dir and give permissions
# Also remove NGINX default folder.
# ------------------------------------------
sudo mkdir -p /var/www
sudo adduser vagrant www-data
sudo chown vagrant:www-data -R /var/www
sudo chmod 0755 -R /var/www
sudo chmod g+s -R /var/www

sudo rm -rf /var/www/html


# ------------------------------------------
# Create an example PHP file.
# ------------------------------------------
touch /var/www/index.php
cat > /var/www/index.php <<'EOF'
<?php
    if(isset($_GET['phpinfo'])){
        echo phpinfo();
        die();
    }
?>

<!DOCTYPE html>
<html lang='en'>
<head>
    <meta charset='utf-8'>
    <title>Drvy's Vagrant Box</title>
    <style type='text/css'>
        html, body {
            margin: 0; padding: 0; font-size: 16px;
            color: #111; font-family: Monospace;
            text-align: center; background: #f5f5f5;
        }
        .box { max-width: 600px; margin: 5% auto 0 auto; padding: 5px; }
        h1 { font-size: 2.1em; letter-spacing: -1px; } h1 em { color: #069; }
        ul { list-style: square inside; text-align: left; } li { padding: 2px; }
        a, a:visited { color: #069; padding: 2px; text-decoration: none; border-bottom: 1px dashed #ccc;}
        a:hover, a:active { color: #111; text-decoration: none; border-bottom: 1px solid #111; }
        code { background: #fff; padding: 1px; }
        .heart { color: #A93232; }
    </style>
</head>
<body>
    <div class='box'>
        <h1>Welcome to <em><code>Drvy's Vagrant Box</code></em>!</h1>
        <ul>
            <li><a href='?phpinfo=true'>Check PHP Config</a></li>
            <li><a href='https://github.com/drvy/drvys-box' target='_blank'>Fork the project on GitHub</a></li>
            <li>
                <a href='https://www.navicat.com/' target='_blank'>Navicat</a> /
                <a href='https://www.heidisql.com/' target='_blank'>HeidiSQL</a> /
                <a href='https://www.mysql.com/products/workbench/' target='_blank'>MySQL Workbench</a>
            </li>
        </ul>

        <p>You can now start running and developing your projects.</p>
        <p>Read the included <code>README.md</code> for documentation.</p>
        <small>
            Version 4.0 |
            Made with by <span class='heart'>&#10084;</span>
            <a href='https://github.com/drvy' target='_blank'>Dragomir Yordanov</a>
        </small>
    </div>
</body>
</html>
EOF


# ------------------------------------------
# Configure PHP-FPM to use local socket.
# ------------------------------------------
sudo cp /etc/php/7.2/fpm/pool.d/www.conf /etc/php/7.2/fpm/pool.d/www.conf.bak
sudo sed -ie 's/listen = 127.0.0.1:9000/listen = \/run\/php7.0-fpm.sock/g' /etc/php/7.2/fpm/pool.d/www.conf
sudo sed -ie 's/;listen.owner = www-data/listen.owner = www-data/g' /etc/php/7.2/fpm/pool.d/www.conf
sudo sed -ie 's/;listen.group = www-data/listen.group = www-data/g' /etc/php/7.2/fpm/pool.d/www.conf
sudo sed -ie 's/;listen.mode = 0660/listen.mode = 0660/g' /etc/php/7.2/fpm/pool.d/www.conf


# ------------------------------------------
# Set PHP INI.
# ------------------------------------------
sudo cp /etc/php/7.2/fpm/php.ini /etc/php/7.2/fpm/php.ini.bak
sudo sed -ie 's/display_errors = Off/display_errors = On/g' /etc/php/7.2/fpm/php.ini


# ------------------------------------------
# Virtualbox & Vagrant bug related to sendFile.
# https://github.com/mitchellh/vagrant/issues/351#issuecomment-1339640
# ------------------------------------------
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
sudo sed -ie 's/sendfile on;/sendfile off;/g' /etc/nginx/nginx.conf


# ------------------------------------------
# Install Composer
# ------------------------------------------
cd /tmp
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
cd ~


# ------------------------------------------
# BASH (.bashrc) Enhancement
# ------------------------------------------

# Force Colour.
sed -ie 's/#force_color_prompt=/force_color_prompt=/g' ~/.bashrc


# ------------------------------------------
# Restart services
# ------------------------------------------
sudo service php7.2-fpm restart
sudo service nginx restart
sudo service mysql restart
