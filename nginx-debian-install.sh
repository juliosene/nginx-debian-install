#!/bin/bash
# Install Nginx + php-fpm + apc cache for Ubuntu and Debian distributions
cd ~
apt-get update
apt-get -fy dist-upgrade
apt-get -fy upgrade
REL=`lsb_release -sc`
DISTRO=`lsb_release -is | tr [:upper:] [:lower:]`
wget http://nginx.org/keys/nginx_signing.key
echo "deb http://nginx.org/packages/$DISTRO/ $REL nginx" >> /etc/apt/sources.list
echo "deb-src http://nginx.org/packages/$DISTRO/ $REL nginx" >> /etc/apt/sources.list
apt-key add nginx_signing.key
apt-get update
apt-get install -fy nginx
apt-get install -fy php5-fpm php5-cli php5-mysql
apt-get install -fy php-apc php5-gd
# replace www-data to nginx into /etc/php5/fpm/pool.d/www.conf
sed -i 's/www-data/nginx/g' /etc/php5/fpm/pool.d/www.conf
service php5-fpm restart
# backup default Nginx configuration
mkdir /etc/nginx/conf-bkp
cp /etc/nginx/conf.d/default.conf /etc/nginx/conf-bkp/default.conf
# replace Nginx default.conf
#
echo -e '# Upstream to abstract backend connection(s) for php
upstream php {
	server unix:/var/run/php5-fpm.sock;
#        server unix:/tmp/php-cgi.socket;
#        server 127.0.0.1:9000;
}
 
server {
    	listen       80;

    	#charset koi8-r;
    	#access_log  /var/log/nginx/log/host.access.log  main;
        ## Your website name goes here.
        server_name localhost;
        ## Your only path reference.
        root /usr/share/nginx/html;
        ## This should be in your http block and if it is, it`s not needed here.
        index index.htm index.html index.php;
  	gzip on;
	gzip_types text/css text/x-component application/x-javascript application/javascript text/javascript text/x-js text/richtext image/svg+xml text/plain text/xsd text/xsl text/xml image/x-icon;

        location = /favicon.ico {
                log_not_found off;
                access_log off;
        }
 
        location = /robots.txt {
                allow all;
                log_not_found off;
                access_log off;
        }
 
        location / {
                # This is cool because no php is touched for static content. 
                # include the "?$args" part so non-default permalinks doesn`t break when using query string
                try_files $uri $uri/ /index.php?$args;
        }
        location ~ \.php$ {
                #NOTE: You should have "cgi.fix_pathinfo = 0;" in php.ini
#	    	root           html;
    		#    fastcgi_pass   127.0.0.1:9000;
    		fastcgi_index  index.php;
    		fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
    		include        fastcgi_params;
                # include fastcgi.conf;
            	fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                fastcgi_intercept_errors on;
                fastcgi_pass php;
        }
	location ~ \.(ttf|ttc|otf|eot|woff|font.css)$ {
   		add_header Access-Control-Allow-Origin "*";
	}
        location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
                expires max;
                log_not_found off;
        }
}' > /etc/nginx/conf.d/default.conf

# Memcache client installation
apt-get install -fy php-pear
apt-get install -fy php5-dev
printf "\n" |pecl install -fy memcache
echo -e '
; /etc/php.d/memcache.ini

extension = memcache.so

memcache.allow_failover = 1
memcache.max_failover_attempts = 20
memcache.chunk_size = 32768
memcache.default_port = 11211
memcache.hash_strategy = standard
memcache.hash_function = crc32
' > /etc/php5/mods-available/memcache.ini
 ln -s /etc/php5/mods-available/memcache.ini  /etc/php5/fpm/conf.d/20-memcache.ini
#
# Services restart
#
service php5-fpm restart
service nginx restart
