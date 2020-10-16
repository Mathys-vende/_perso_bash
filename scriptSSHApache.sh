#!/bin/bash
# exec manually
# exec -> 2
echo "Bonjour, ce script va vous permettre d'installer les groupes sudoers, un utilisateur, sa clé ssh, un service ftp, et git, pour notre machine apache"
#on demande le nom de notre utilisateur
valid=true
while [ $valid ]
do
	clear
	echo "Quel sera le nom de votre utilisateur sudo ?"
	read userApache
	echo "utilisateur sudo entrer : $userApache"
	echo "cela vous convient-il ? y(oui)/n(non)"
	read validation
	if [ $validation == 'y' ] || [ $validation == 'Y' ];
	then
		break
	fi
done
clear
echo "utilisateur validé : $userApache"

# puis son mot de passe
while [ $valid ]
do
	clear
	echo "Quel sera le mot de passe de votre utilisateur ?"
	read userPass
	echo "mdp entrer : $userPass"
	echo "cela vous convient-il ? y(oui)/n(non)"
	read validation
	if [ $validation == 'y' ] || [ $validation == 'Y' ];
	then
		break
	fi
done
clear
echo "utilisateur validé : $userApache"
echo "utilisateur validé : $userPass"

# la clé ssh de la machine hote
while [ $valid ]
do
	clear
	echo "Quel est la clé ssh publique de votre machine hôte ?"
	read sshpubkey
	echo "clé ssh : $sshpubkey"
	echo "cela vous convient-il ? y(oui)/n(non)"
	read validation
	if [ $validation == 'y' ] || [ $validation == 'Y' ];
	then
		break
	fi
done
clear
echo "utilisateur validé : $userApache"
echo "utilisateur validé : $userPass"
echo "clé publique validée : $sshpubkey"

apt update -y
apt upgrade -y
apt install vim -y
apt install nano -y
apt install fish -y
apt install openssh-server -y
apt install sudo -y
apt install git -y
apt install vsftpd -y

if [ $(id -u) -eq 0 ]; then
	egrep "^$userApache" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo "$userApache exists!"
		exit 1
	else
		pass=$(perl -e 'print crypt($ARGV[0], "password")' $userPass)
		useradd -m -p "$pass" "$userApache"
		[ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!"
	fi
else
	echo "Only root may add a user to the system."
exit 2
fi

echo "PermitRootLogin no
PubkeyAuthentication yes
AuthorizedKeysFile      /home/$userApache/.ssh/authorized_keys
PasswordAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding yes
PrintMotd no
AcceptEnv LANG LC_*
Subsystem       sftp    /usr/lib/openssh/sftp-server" > /etc/ssh/sshd_config

adduser $userApache sudo
mkdir /home/$userApache/.ssh
chown $userApache:$userApache /home/$userApache/.ssh
chmod 700 /home/$userApache/.ssh
echo $sshpubkey > /home/$userApache/.ssh/authorized_keys
chown $userApache:$userApache /home/$userApache/.ssh/authorized_keys
chmod 600 /home/$userApache/.ssh/authorized_keys

echo "Listen=NO
listen_ipv6=YES

anonymous_enable=NO
local_enable=YES

write_enable=YES

local_umask=022

dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES

secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
ssl_enable=NO

allow_writeable_chroot=YES" > /etc/vsftpd.conf

while [ $valid ]
do
	clear
	echo "Quel est le nom de votre utilisateur de Bdd ?"
	read userBdd
	echo "utilisateur bdd entrer : $userBdd"
	echo "cela vous convient-il ? y(oui)/n(non)"
	read validation
	if [ $validation == 'y' ] || [ $validation == 'Y' ];
	then
		break
	fi
done
clear
echo "utilisateur bdd validé : $userBdd"

# puis son mot de passe
while [ $valid ]
do
	clear
	echo "Quel sera le mot de passe de votre utilisateur de Bdd ?"
	read userBddPass
	echo "mdp entrer : $userBddPass"
	echo "cela vous convient-il ? y(oui)/n(non)"
	read validation
	if [ $validation == 'y' ] || [ $validation == 'Y' ];
	then
		break
	fi
done
clear
echo "mot de passe bdd validé : $userBddPass"

# et enfin son ip
while [ $valid ]
do
	clear
	echo "Quel est l'ip de votre machine Bdd ?"
	read userBddIp
	echo "mdp entrer : $userBddIp"
	echo "cela vous convient-il ? y(oui)/n(non)"
	read validation
	if [ $validation == 'y' ] || [ $validation == 'Y' ];
	then
		break
	fi
done
clear
echo "mot de passe bdd validé : $userBddIp"

/root/_perso_bash/scriptApache2.sh $userApache $userPass $userBdd $userBddPass $userBddIp