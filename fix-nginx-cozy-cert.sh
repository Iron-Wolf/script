#!/bin/sh

# fix la conf SSL de nginx si l'update de cozy casse la conf

# pre-requis :
# - run as root
# - certificat valide dans /etc/letsencrypt/live/my.domaine/

# Commande utile pour afficher les info du fichier CRT :
#  openssl x509 -noout -text -in /etc/cozy/server.crt

#===========================================================

echo "stop nginx..."
service nginx stop

# supprime les certificats auto-signés
echo "delete current cert..."
rm -rf /etc/cozy/server.crt
rm -rf /etc/cozy/server.key

# recré le bon lien symbolique
echo "create right symlink..."
ln -s /etc/letsencrypt/live/www.########.netlib.re/privkey.pem /etc/cozy/server.key
ln -s /etc/letsencrypt/live/www.########.netlib.re/fullchain.pem /etc/cozy/server.crt


echo "start nginx"
service nginx start
