#!/bin/bash


#-------------------------------- DEAMON --------------------------------

#Vous créez une unité /etc/systemd/system/mydaemon.service.

#[Unit]
#Description=My daemon

#[Service]
#ExecStart=/usr/bin/mydaemon
#Restart=on-failure

#[Install]
#WantedBy=multi-user.target 

#systemctl start mydaemon.service 

#systemctl enable mydaemon.service

#-------------------------------- NETCAT CLIENT-----------------------------------


# apt install netcat-openbsd

# nc localhost 4521


ARP_TABLE="/proc/net/arp"
ARP_SAVE="IP_MAC.txt"
ADMIN="root"
PORT=4521

regex_IP="(\b25[0-5]|\b2[0-4][0-9]|\b[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}"
regex_MAC="[a-fA-F0-9]{2}(:[a-fA-F0-9]{2}){5}"

if [[ ! -e $ARP_SAVE ]]; then
	touch $ARP_SAVE
fi

add(){
	ip=$1
	mac=$2
	echo -e "$ip\t\t$mac" >> IP_MAC.txt
}

delete(){ 
	grep="$1.*$2"
	line=$(grep -n "$grep" $ARP_SAVE | cut -d : -f1)
	sed -i $line'd' $ARP_SAVE
}

IP_allowed(){
	ip=$1
	mac=$2
	iptables -I INPUT -s $ip -j DROP
	iptables -A INPUT -m mac --mac-source $mac -j DROP
}

match(){ 
	ip=$1
	mac=$2

	save=$(cat $ARP_SAVE)

	if echo $save | grep -q $mac ; then
		save_line=$(echo $save | grep $ip)
		if ! echo $save_line | grep -q $ip$'\t' ; then
			return 1
		fi
	fi

	if echo $save | grep -q $ip$'\t' ; then
		save_line=$(echo $save | grep $ip$'\t')
		if ! echo $save_line | grep -q $mac ; then
			return 1
		fi
	fi

	if echo $save | grep -q $mac && echo $save | grep -q $ip$'\t' ; then
		return 0
	else
		return 2
	fi
}

coproc nc -k -p $PORT -l
echo "[*] Commande : Effacer <IP> <MAC> ; Autoriser <IP> <MAC> ; Lister" >&"${COPROC[1]}"
echo "[!] 30 seconde d'attente aprés une commande" >&"${COPROC[1]}"

while true ; do
	arp=$(cat $ARP_TABLE | sed "1d")

	if [[ $arp != "" ]]; then
		while IFS= read -r line; do
			ip=$(echo $line | grep -E -o $regex_IP) 
			mac=$(echo $line | grep -E -o $regex_MAC) 

			if [[ $mac == "" ]]; then
				mac="(incomplete)"
			fi

			match "$ip" "$mac" 

			case $? in 
				1)	echo "Address IP - MAC suspect:" $ip " - " $mac | mail -s "[ALERT] Modification de la table ARP" $ADMIN
					IP_allowed "$ip" "$mac";;

				2)	echo "Nouvelle address  IP - MAC :" $ip " - " $mac | mail -s "[ALERT] Nouvelle address dans la table ARP" $ADMIN
					add "$ip" "$mac";;
			esac
		done <<< "$arp"
	fi

	sleep 30
	read -t 1 nc_read <&"${COPROC[0]}"

	echo "$nc_read"
	if [[ $nc_read == [Ee]"ffacer"* ]]; then
		ip=$(echo $nc_read | grep -E -o $regex_IP)
		mac=$(echo $nc_read | grep -E -o $regex_MAC)
		if [[ $ip != "" && $mac != "" ]]; then
			echo "[*] Blocage des IP/MAC suivante : IP - " "$ip" " MAC - " "$mac" >&"${COPROC[1]}"
			IP_allowed "$ip" "$mac"
			echo "[*] Blocage terminer" >&"${COPROC[1]}"
		fi
	elif [[ $nc_read == [Aa]"utoriser"* ]]; then
		ip=$(echo $nc_read | grep -E -o $regex_IP)
		mac=$(echo $nc_read | grep -E -o $regex_MAC)
		if [[ $ip != "" && $mac != "" ]]; then
			echo "[*] Ajout dans les IP/MAC Autoriser : IP - " "$ip" " MAC - " "$mac" >&"${COPROC[1]}"
			add "$ip" "$mac"
			echo "[*] Ajout terminer" >&"${COPROC[1]}"
		fi
	elif [[ $nc_read == [Ll]"ister"* ]]; then
		cat $ARP_SAVE >&"${COPROC[1]}"
	fi
done

