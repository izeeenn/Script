#!/bin/bash
clear
#//////////////////////////////////
#//
#//
#//     FUNCIONES Y VARAIBLES
#//
#//


function test-email() {
        local validezemail="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"

        if [[ "$email" =~ $validezemail ]]; then
                return 0
        else
                return 1
        fi
}
function passwd-check() {
        if [[ "$passwd" == "$passwd2" ]]; then
                return 0
        else
                return 1
        fi
} 


#//////////////////////////////////
#//
#//
#//      TOMA DE VARAIBLES
#//
#//


#Obtencion de variables necesarias

echo -e "Bienvenido a RIMOGO enterprise, ha ejecutado el programa para darse de alta en nustros servicios de hosting."
echo -e "Diganos el nombre de usuario que quiere"
read user
echo -e "Su contraseña:"
while true; do
        read passwd
        read passwd2
        passwd-check
        if [ $? -eq 0 ]; then
                break
        else
                echo "La contraseña no coincide, introduzcala de nuevo"
         fi
done
echo -e "Que nombre quiere para tu pagina web ej. jaime.com"
read domain

while true; do
        echo "Por favor escirba su email: "
        read email

        test-email "$email"
        if [ $? -eq 0 ]; then
                break
        else
                echo "El E-mail que has escrito no es correcto, por favor escribalo de nuevo."
        fi

done



#/////////////////////////////////
#//
#//
#//           SCRIPT
#//
#//

CHROOTDIR=/var/www/$domain
LOGFILE="/etc/nginx/logs/$domain.log"
ERRFILE="/etc/nginx/logs/$domain.err"
void=""
mkdir -p /etc/nginx/logs
apt install ssh >/devnull 2>&1
#// WEB SERVER SCRIPT

mkdir -p /var/www/"$domain"/html
echo -e "<h1>Sitio web de "$user"</h1>" > /var/www/"$domain"/html/index.html

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/"$domain".key -out /etc/ssl/certs/"$domain".crt <<EOF >>$LOGFILE 2>$ERRFILE
ES
SPAIN
BCN
IJR Security Manager
IJR Security Manager
$domain
$email
EOF

echo -e "
server {
        listen 443 ssl;
        listen [::]:443 ssl;

        ssl_certificate /etc/ssl/certs/$domain.crt;
        ssl_certificate_key /etc/ssl/private/$domain.key;
        include snippets/ssl-params.conf;

        root /var/www/$domain/html;
        index index.html index.htm index.nginx-debian.html;
        server_name $domain     www.$domain;

        location / {
                try_files \$uri \$uri/ =404;
        }
}
server {
        listen 80;
        listen [::]:80;
        server_name $domain www.$domain;
        return 302 https://\$server_name\$request_uri;
}
" >> /etc/nginx/sites-available/$domain

cp /etc/nginx/sites-available/"$domain" /etc/nginx/sites-enabled/"$domain"

nginx -t >>$LOGFILE 2>$ERRFILE
systemctl restart nginx.service >>$LOGFILE 2>$ERRFILE


#// SFTP ACCESS SCRIPT
read user
read domain
CHROOTDIR=/var/www/$domain
useradd -m -d $CHROOTDIR $user
if [ ! -f "$CHROOTDIR/.ssh/id_rsa" ]; then
    sudo -u $user ssh-keygen -t rsa -b 4096 -N "" -f "$CHROOTDIR/.ssh/id_rsa"
fi
chmod 700 "$CHROOT_DIR/.ssh"
chmod 600 "$CHROOT_DIR/.ssh/authorized_keys"
cat "$CHROOT_DIR/.ssh/id_rsa.pub" >> "$CHROOT_DIR/.ssh/authorized_keys"