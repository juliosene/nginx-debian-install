#!/bin/bash
apt-get update
apt-get -fy dist-upgrade
apt-get -fy upgrade
REL=`lsb_release -sc`
wget http://nginx.org/keys/nginx_signing.key
echo "deb http://nginx.org/packages/debian/ $REL nginx" >> /etc/apt/sources.list
echo "deb-src http://nginx.org/packages/debian/ $REL nginx" >> /etc/apt/sources.list
apt-key add nginx_signing.key
apt-get update
apt-get install -fy nginx
apt-get install -fy php5-fpm php5-cli php5-mysql
apt-get install -fy php-apc php5-gd
# substituir todos os locais onde aparece o usuário www-data pelo usuário nginx no arquivo /etc/php5/fpm/pool.d/www.conf
sed -i 's/www-data/nginx/g' /etc/php5/fpm/pool.d/www.conf
service php5-fpm restart
mkdir /etc/nginx/conf-bkp
cp /etc/nginx/conf.d/default.conf /etc/nginx/conf-bkp/default.conf
# Substituir o arquivo default.conf pela configuração padrão
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
 
        location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
                expires max;
                log_not_found off;
        }
}' > /etc/nginx/conf.d/default.conf
#
service php5-fpm restart
service nginx restart
