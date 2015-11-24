Install: Nginx + PHP on Debian Linux distributions.

Run this script before make any changes on your Debian instalation. 

To run this scipt:
1 - Download this script. You can use:
wget https://github.com/juliosene/nginx-debian-install/blob/master/nginx-debian-install.sh
2 - Make the script executable:
chmod 700 nginx-debian-install.sh
3 - Execute script
./nginx-debian-install.sh

To verify if everything is working fine:
1 - Open your web browser and type:
http://(your-ip-address)

If you see Nginx default message, the web navigation is ok.

2 - Create a page to test PHP
on /usr/share/nginx/www/ create a new file called info.php with the code:
<?php
phpinfo();
?>

in your web browser:
http://(your-ip-address)/info.php

If all infos about your php instalation was showed, php scripts are working fine.
