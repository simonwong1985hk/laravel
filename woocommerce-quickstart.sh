#!/bin/bash

# check parameter
if [ $# -eq 0 ]; then
    echo 'requires one parameter'
    exit 1
fi

# prerequisite
domain=''
docroot=''
db_name=''
db_user=''
db_pass=''
admin_user=''
admin_pass=''
admin_email=''

# check if a directory does not exist
if [ ! -d $docroot ] 
then
    echo "no such directory $docroot"
    exit 1
fi

# change to docroot
cd $docroot

# delete all files
rm -rf {.,}*

# download core
/usr/local/bin/ea-php74 /usr/local/bin/wp core download

# configure database
/usr/local/bin/ea-php74 /usr/local/bin/wp core config --dbname=$db_name --dbuser=$db_user --dbpass=$db_pass

# reset database
/usr/local/bin/ea-php74 /usr/local/bin/wp db reset --yes

# install
/usr/local/bin/ea-php74 /usr/local/bin/wp core install --url=https://$domain --title=WooCommerce --admin_user=$admin_user --admin_password=$admin_pass --admin_email=$admin_email

# create .htaccess
echo '# Redirect HTTP to HTTPS
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
</IfModule>

<IfModule mod_rewrite.c>
RewriteEngine On
RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>' >> .htaccess

# change timezone
/usr/local/bin/ea-php74 /usr/local/bin/wp option update timezone_string 'Asia/Hong_Kong'

# set permalink structure
/usr/local/bin/ea-php74 /usr/local/bin/wp rewrite structure '/%category%/%postname%/'

# install storefront
/usr/local/bin/ea-php74 /usr/local/bin/wp theme install storefront

# set up & activate child theme
/usr/local/bin/ea-php74 /usr/local/bin/wp scaffold child-theme storefront-child --parent_theme=storefront --theme_name='Storefront Child' --activate

# set up thumbnail for child theme
cp wp-content/themes/storefront/screenshot.* wp-content/themes/storefront-child/

# delete themes
/usr/local/bin/ea-php74 /usr/local/bin/wp theme delete twentynineteen twentytwenty

# update themes
/usr/local/bin/ea-php74 /usr/local/bin/wp theme update --all

# install & activate classic editor
/usr/local/bin/ea-php74 /usr/local/bin/wp plugin install classic-editor --activate

# install & activate woocommerce
/usr/local/bin/ea-php74 /usr/local/bin/wp plugin install woocommerce --activate

# delete plugins
/usr/local/bin/ea-php74 /usr/local/bin/wp plugin delete akismet hello

# show wordpress version
/usr/local/bin/ea-php74 /usr/local/bin/wp core version

# execute bash script
exec bash
