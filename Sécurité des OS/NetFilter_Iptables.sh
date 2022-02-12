#!/bin/bash

# [Service]
# Type=oneshot
# RemainAfterExit=yes
# ExecStart=/<path du de ce fichier>/tp3.sh start
# 
# En suite exécuter les commandes :
#
# systemctl --user enable <nom du service>.service
# systemctl --user start <nom du service>.service
#


ON="\e[92mON \e[90mOFF"
OFF="\e[90mON \e[91mOFF"

IP_SERVER="192.168.50.1"
IP_LOCAL="192.168.50.0/24"
IP_INTERNET="0.0.0.0"
IP_ADMIN="192.168.50.250"
IP_EXTERNE="192.168.50.254"

path_save_file="save.txt"

launch(){

	#Suppression des filtres
	iptables -P INPUT ACCEPT
	iptables -P OUTPUT ACCEPT
	iptables -P FORWARD ACCEPT
	iptables -F
	iptables -X
	iptables -t nat -F
	iptables -t nat -X
	iptables -t mangle -F
	iptables -t mangle -X	

	#Blockage 
	iptables -t filter -P INPUT DROP
	iptables -t filter -P OUTPUT DROP
	iptables -t filter -P FORWARD DROP	

	#localhost
	iptables -A INPUT -i lo -j ACCEPT
	iptables -A OUTPUT -o lo -j ACCEPT

	#réseaux local (filaire comme sur le sujet)
	iptables -A INPUT -i eth0 -j ACCEPT
	iptables -A OUTPUT -o eth0 -j ACCEPT

	#Accès FTP, HTTP depuis le réseau local
	if [[ "$1" == "$ON" ]]; then
		iptables -t filter -A INPUT -p tcp -s $IP_LOCAL --sport 21 -d $IP_SERVER --dport 21 -j ACCEPT
		iptables -t filter -A INPUT -p tcp -s $IP_LOCAL --sport 80 -d $IP_SERVER --dport 21 -j ACCEPT
		iptables -t filter -A INPUT -p tcp -s $IP_LOCAL --sport 21 -d $IP_SERVER --dport 80 -j ACCEPT
		iptables -t filter -A INPUT -p tcp -s $IP_LOCAL --sport 80 -d $IP_SERVER --dport 80 -j ACCEPT
	fi
	#FTP, HTTP depuis INTERNET	
	if [[ "$2" == "$ON" ]]; then
		iptables -t filter -A INPUT -p tcp -s $IP_EXTERNE --sport 21 -d $IP_SERVER --dport 21 -j ACCEPT
		iptables -t filter -A INPUT -p tcp -s $IP_EXTERNE --sport 80 -d $IP_SERVER --dport 21 -j ACCEPT
		iptables -t filter -A INPUT -p tcp -s $IP_EXTERNE --sport 21 -d $IP_SERVER --dport 80 -j ACCEPT
		iptables -t filter -A INPUT -p tcp -s $IP_EXTERNE --sport 80 -d $IP_SERVER --dport 80 -j ACCEPT
	fi
	#WEB depuis réseau local
	if [[ "$3" == "$ON" ]]; then
		iptables -t filter -A OUTPUT -p tcp -s $IP_LOCAL --dport 80 -j ACCEPT
		iptables -t filter -A OUTPUT -p udp -s $IP_LOCAL --dport 80 -j ACCEPT
		iptables -t filter -A OUTPUT -p tcp -s $IP_LOCAL --dport 443 -j ACCEPT
		iptables -t filter -A OUTPUT -p udp -s $IP_LOCAL --dport 443 -j ACCEPT
	    
		iptables -t filter -A OUPUT -o $IP_SERVER -p tcp --dport 80 --sport 0:1024 -j ACCEPT #port < 1024
		iptables -t filter -A OUPUT -o $IP_SERVER -p tcp --dport 443 --sport 0:1024 -j ACCEPT
	fi
	#Accès INTERNET depuis le server
	if [[ "$4" == "$ON" ]]; then
		iptables -t filter -A OUTPUT -p tcp -s $IP_SERVER -d $IP_INTERNET -j ACCEPT
		iptables -t filter -A OUTPUT -p udp -s $IP_SERVER -d $IP_INTERNET -j ACCEPT
	fi

	#INTERNET poste ADMIN
	iptables -t filter -A OUTPUT -p tcp -s $IP_ADMIN -d $IP_INTERNET -j ACCEPT
	iptables -t filter -A OUTPUT -p udp -s $IP_ADMIN -d $IP_INTERNET -j ACCEPT    
    
	#FTP, HTTP poste ADMIN
	iptables -t filter -A INPUT -p tcp -s $IP_ADMIN --sport 21 -d $IP_SERVER --dport 21 -j ACCEPT
	iptables -t filter -A INPUT -p tcp -s $IP_ADMIN --sport 80 -d $IP_SERVER --dport 21 -j ACCEPT
	iptables -t filter -A INPUT -p tcp -s $IP_ADMIN --sport 21 -d $IP_SERVER --dport 80 -j ACCEPT
	iptables -t filter -A INPUT -p tcp -s $IP_ADMIN --sport 80 -d $IP_SERVER --dport 80 -j ACCEPT
    
	#SSH poste ADMIN
	iptables -t filter -A INPUT -p tcp -s $IP_ADMIN --sport 22 -d $IP_SERVER --dport 80 -j ACCEPT
	iptables -t filter -A INPUT -p tcp -s $IP_ADMIN --sport 80 -d $IP_SERVER --dport 22 -j ACCEPT
	iptables -t filter -A INPUT -p tcp -s $IP_ADMIN --sport 22 -d $IP_SERVER --dport 22 -j ACCEPT
    
	#Paquets RELATED, ESTABLISHED autorisé
	iptables -A INPUT -i $IP_SERVER -m conntrack --ctstate RELATED -j ACCEPT
	iptables -A OUTPUT -o $IP_SERVER -m conntrack --ctstate RELATED -j ACCEPT
	iptables -A INPUT -i $IP_SERVER -m conntrack --ctstate ESTABLISHED -j ACCEPT
	iptables -A OUTPUT -o $IP_SERVER -m conntrack --ctstate ESTABLISHED -j ACCEPT
    
	#DNS Connexion
	iptables -A INPUT -p udp --sport 53 -m state --state ESTABLISHED,RELATED -j ACCEPT
	iptables -A OUTPUT -d 8.8.8.8 -p udp --destination-port 53 -j ACCEPT
    
	#Interdiction du reste    
	iptables --append INPUT --protocol tcp --src 0.0.0.0 --dst 0.0.0.0 --jump REJECT
	iptables --append INPUT --protocol udp --src 0.0.0.0 --dst 0.0.0.0 --jump REJECT
	iptables --append INPUT --protocol icmp --src 0.0.0.0 --dst 0.0.0.0 --jump REJECT

	#Sauvegarde de la configuration de iptable
	iptables-save > /root/dsl.fw


	exit
}

save(){
	echo "$1|$2|$3|$4" > $path_save_file
}

interface(){
	etat_1=$1
	etat_2=$2
	etat_3=$3
	etat_4=$4
	
	echo -e "==================================\e[93mMain Menu\e[39m=================================="
	echo -e "\t \e[93m1: \e[39mAccès FTP, HTTP depuis le réseau local		  $etat_1"
	echo -e "\t \e[93m2: \e[39mAccès FTP, HTTP depuis INTERNET			  $etat_2"
	echo -e "\t \e[93m3: \e[39mAccès INTERNET depuis serveur			  $etat_3" 
	echo -e "\t \e[93m4: \e[39mAccès WEB depuis le réseau local			  $etat_4"
	echo -e "\t \e[93m5: \e[39mValider"
	echo -e "=============================================================================\n"

	echo -e -n "\e[5m>\e[0m"
	read choix

	case $choix in
		1)	if [[ "$etat_1" == "$OFF" ]]; then
				etat_1="$ON"
			else
				etat_1="$OFF"
			fi;;
		2)  if [[ "$etat_2" == "$OFF" ]]; then
				etat_2="$ON"
			else
				etat_2="$OFF"
			fi;;
		3)	if [[ "$etat_3" == "$OFF" ]]; then
				etat_3="$ON"
			else
				etat_3="$OFF"
			fi;;
		4)	if [[ "$etat_4" == "$OFF" ]]; then
				etat_4="$ON"
			else
				etat_4="$OFF"
			fi;;
		5) 	save "$etat_1" "$etat_2" "$etat_3" "$etat_4"
			launch "$etat_1" "$etat_2" "$etat_3" "$etat_4";;
	esac
	clear
	interface "$etat_1" "$etat_2" "$etat_3" "$etat_4"
}

clear
if [[ $# == 0 ]]; then
	if [[ -f "$path_save_file" ]]; then

		file=$(cat $path_save_file)
		param1=$(echo "$file" | cut -d"|" -f1)
		param2=$(echo "$file" | cut -d"|" -f2)
		param3=$(echo "$file" | cut -d"|" -f3)
		param4=$(echo "$file" | cut -d"|" -f4)
		param5=$(echo "$file" | cut -d"|" -f5)
		
		interface "$param1" "$param2" "$param3" "$param4"
	else
		interface "$OFF" "$OFF" "$OFF" "$OFF"
	fi
elif [[ $1 == "start" ]]; then
	iptables-restore < /root/dsl.fw
fi
