# get domain name from command line
# get port number from command line
# get https port number from command line

# ----------------------------------------------------------------
# Notice: remenber to include the sites-enabled in nginx.conf !!!!
# Config the firewall to let the port open !!!
# ----------------------------------------------------------------

if [ $# -lt 3 ]; then
    echo "No arguments supplied"
    # echo "Usage: ./deploy_web.sh <domain> <port> <https_port>"
    exit 1
fi

domain=$1
port=$2
https_port=$3

# Create a new directory for your website
sudo mkdir -p "/var/www/$domain"

#  Create an index.html file in the new directory
echo "<h1>Welcome to My Website</h1>" | sudo tee "/var/www/$domain/index.html"

#  Configure Nginx to serve your website
echo "server {
    listen $port;
    server_name $port www.$port;
    location / {
        root /var/www/$domain;
        index index.html;
    }
}" | sudo tee /etc/nginx/sites-available/$domain

#  Configure Nginx to serve your website over HTTPS
echo "server {
    listen $https_port ssl;
    server_name $domain www.$domain;
    ssl_certificate /etc/nginx/ssl/$domain/fullchain.cer;
    ssl_certificate_key /etc/nginx/ssl/$domain/$domain.key;
    root /var/www/$domain;

    location /api {
        proxy_pass http://localhost:3800;
    }

    location /videos {
        proxy_pass http://localhost:3800;
    }

    location / {
        index index.html;
        try_files \$uri \$uri/ /index.html;
    }
}" | sudo tee /etc/nginx/sites-available/$domain

# Enable the website
sudo ln -s /etc/nginx/sites-available/$domain /etc/nginx/sites-enabled/

# firewall
sudo iptables -A INPUT -p tcp --dport $port -j ACCEPT
sudo iptables -A INPUT -p tcp --dport $https_port -j ACCEPT

# Restart Nginx to apply the changes
sudo systemctl restart nginx
