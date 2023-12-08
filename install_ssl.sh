# get domain name from command line

if [ $# -eq 0 ]; then
    echo "No arguments supplied"
    # echo "Usage: ./install_ssl.sh <domain>"
    exit 1
fi

domain=$1

# stop nginx
sudo service nginx stop

# Step 1: Install acme.sh
curl https://get.acme.sh | sh

# Step 2: Issue a certificate for your domain
~/.acme.sh/acme.sh --issue --standalone -d $domain -d "www.$domain"

# carete a directory for the certificate
sudo mkdir -p "/etc/nginx/ssl/$domain"

# Step 3: Install the issued certificate to your Nginx configuration
~/.acme.sh/acme.sh --install-cert -d $domain \
    --fullchain-file "/etc/nginx/ssl/$domain/fullchain.cer" \
    --key-file "/etc/nginx/ssl/$domain/$domain.key" \

# start nginx
sudo service nginx start
