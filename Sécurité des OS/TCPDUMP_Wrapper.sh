#!/bin/bash

helper(){
	echo -e "
	-i\tInterface réseaux\n
	-c\tNombre de paquets\n
	-P\tProtocole(s)\n
	-p\tFiltre par port(s)\n
	-l\tCapture les logins\n
	-ip\tFiltre par IP\n
	-vC\tVisualiser les captures de trame\n
	-vL\tVisualiser les captures de login\n"
}

capture_data(){ 
	while read p; do 
		form_ip=$(echo "$p" | cut -d" " -f3)
		proto=$(echo "$p" | cut -d" " -f7)	

		if [[ $proto == *"," ]]; then
			proto=${proto::-1}
		fi

		if [[ $proto == "UDP" || $proto == "tcp" ]]; then 
			nothing=0
			case $form_ip in 

				"IP")	date=$(echo "$p" | cut -d" " -f1)
						time=$(echo "$p" | cut -d" " -f2)
						time=${time::-7}
						ipsrc=$(echo "$p" | cut -d" " -f4)
						ipdest=$(echo "$p" | cut -d" " -f6)
						ipdest=${ipdest::-1}
						portsrc=$(echo "$ipsrc" | cut -d"." -f5)
						ipsrc=${ipsrc::-${#portsrc}-1}
						portdest=$(echo "$ipdest" | cut -d"." -f5)
						ipdest=${ipdest::-${#portdest}-1};;

				"IP6")	date=$(echo "$p" | cut -d" " -f1)
						time=$(echo "$p" | cut -d" " -f2)
						time=${time::-7}
						ipsrc=$(echo "$p" | cut -d" " -f4)
						ipdest=$(echo "$p" | cut -d" " -f6)
						ipdest=${ipdest::-1}
						portsrc=$(echo "$ipsrc" | cut -d"." -f2)
						ipsrc=${ipsrc::-${#portsrc}-1}
						portdest=$(echo "$ipdest" | cut -d"." -f2)
						ipdest=${ipdest::-${#portdest}-1};;

				*)		nothing=1 		
						echo -e "$p" >> capture.log;;
						
			esac

			if [[ $nothing != 1 ]]; then
				if [[ $((${#ipsrc}+${#portsrc})) > 25 ]]; then
					portsrc=$portsrc'\t'
				elif [[ $((${#ipsrc}+${#portsrc})) > 14 ]]; then
					portsrc=$portsrc'\t\t'
				elif [[ $((${#ipsrc}+${#portsrc})) > 10 ]]; then
					portsrc=$portsrc'\t\t\t'
				fi
				if [[ $((${#ipdest}+${#portdest})) < 15 ]]; then
					portdest=$portdest'\t'
				fi
				echo -e "$date\t$time\t$ipsrc:$portsrc\t$ipdest:$portdest\t$proto" >> capture.log # Enregistrement dans le fichier capture.log
			fi	
		else
			echo -e "$p" >> capture.log 
		fi

	done <.res_tmp 
}

capture_login(){ 
	while read p; do
		if [[ $(echo "$p" | cut -d" " -f1) =~ [0-9]{4}\-+[0-9]{2}\-+[0-9]{2} ]]; then 
			nothing=0
			case $form_ip in 
				"IP")	form_ip=$(echo "$p" | cut -d" " -f3)
						date=$(echo "$p" | cut -d" " -f1)
						time=$(echo "$p" | cut -d" " -f2)
						time=${time::-7}
						ipsrc=$(echo "$p" | cut -d" " -f4)
						ipdest=$(echo "$p" | cut -d" " -f6)
						ipdest=${ipdest::-1}
						portsrc=$(echo "$ipsrc" | cut -d"." -f5)
						ipsrc=${ipsrc::-${#portsrc}-1}
						portdest=$(echo "$ipdest" | cut -d"." -f5)
						ipdest=${ipdest::-${#portdest}-1};;

				"IP6")	
						form_ip=$(echo "$p" | cut -d" " -f3)
						date=$(echo "$p" | cut -d" " -f1)
						time=$(echo "$p" | cut -d" " -f2)
						time=${time::-7}
						ipsrc=$(echo "$p" | cut -d" " -f4)
						ipdest=$(echo "$p" | cut -d" " -f6)
						ipdest=${ipdest::-1}
						portsrc=$(echo "$ipsrc" | cut -d"." -f2)
						ipsrc=${ipsrc::-${#portsrc}-1}
						portdest=$(echo "$ipdest" | cut -d"." -f2)
						ipdest=${ipdest::-${#portdest}-1};;
				*)		nothing=1;;
			esac

			if [[ nothing != 1 ]]; then	
				if [[ $((${#ipsrc}+${#portsrc})) > 25 ]]; then
					portsrc=$portsrc'\t'
				elif [[ $((${#ipsrc}+${#portsrc})) > 14 ]]; then
					portsrc=$portsrc'\t\t'
				elif [[ $((${#ipsrc}+${#portsrc})) > 10 ]]; then
					portsrc=$portsrc'\t\t\t'
				fi
				if [[ $((${#ipdest}+${#portdest})) < 15 ]]; then
					portdest=$portdest'\t'
				fi
			else
				trame=$p
			fi
		else
			login=$(echo "$p" | egrep -i -B5 'uname=|log=|login=|user=|username=|user:|username:|login:|user ')
			pass=$(echo "$p" | egrep -i -B5 'pass=|pwd=|pw=|passw=|passwd=|password=|pass:|password:|pass ')

			if [[ $login != "" ]]; then
				if [[ $notion != 1 ]]; then
					echo -e "$date\t$time\t$ipsrc:$portsrc\t$ipdest:$portdest\t$login" >> login.log
				else
					echo -e "$trame\t$login" >> login.log
				fi
			fi
			if [[ $pass != "" ]]; then 
				if [[ $notion != 1 ]]; then
					echo -e "$date\t$time\t$ipsrc:$portsrc\t$ipdest:$portdest\t$pass" >> login.log
				else
					echo -e "$trame\t$pass" >> login.log
				fi
			fi
		fi
	done <.res_tmp
}



exec_tcpdump(){ 
	command="tcpdump -tttt -n -q" 
	login=0
	infini=0

	if [[ $1 != "" ]]; then
		command="$command host $1"
	fi

	if [[ $2 != "" ]]; then
		command="$command port $2"
	fi

	if [[ $3 != "" ]]; then
		command="$command -i $3"
	fi

	if [[ $4 != "" ]]; then
		command="$command -c $4"
	else
		command="$command -c 50"
		infini=1
	fi

	if [[ $5 != "" ]]; then
		command="$command $5"
	fi

	if [[ $6 == "\e[92mON" ]]; then
		command="$command -A"
		login=1
	fi


	if [[ $infini == 1 && $login == 1 ]]; then 
		while true; do
			result=$(eval $command)
			echo "$result" > .res_tmp
			capture_login
		done
	elif [[ $infini == 1 && $login == 0 ]]; then
		while true; do
			result=$(eval $command)
			echo "$result" > .res_tmp
			capture_data
		done
	else
		result=$(eval $command)
		echo "$result" > .res_tmp

		if [[ $login == 1 ]]; then
			capture_login
		else
			capture_data 
		fi
	fi
}

Option(){ 
	interface_reseau=$3
	nb_paquets=$4
	protocoles=$5
	login=$6
	interface=$(tcpdump -D)
	for inter in $interface; do
		if [[ $inter  =~ [0-9]\. ]]; then
			inter=${inter:2}
			list_interface+="$inter, "
		fi
	done

	echo -e "==================================\e[93mOption Menu\e[39m================================"
	echo -e "\t Interface réseau disponible \n\t \e[36m[$list_interface]\n"
	echo -e "\t \e[93m1: \e[39mInterface réseau \e[92m[$interface_reseau]"
	echo -e "\t \e[93m2: \e[39mNombre de paquets \e[92m[$nb_paquets]"
	echo -e "\t \e[93m3: \e[39mProtocoles \e[92m[$protocoles]"
	echo -e "\t \e[93m4: \e[39mValider"
	echo -e "=============================================================================\n"

	echo -e -n "\e[5m>\e[0m"
	read choix

	case $choix in
		1)	echo "Entrée une ou plusieur interface réseau :"
			read interface_reseau;;
		2)	echo "Entrée le nombre de paquets a réaliser :"
			read nb_paquets;;
		3)	echo "Entrée un ou plusieur protocole"
			read protocoles;;
		4)	echo "Entrée un ou plusieur port"
	esac

	interactif "$ips" "$ports" "$interface_reseau" "$nb_paquets" "$protocoles" "$login" # Rappelle de la fonction interface
}


interactif(){ 
	ips=$1
	ports=$2

	interface_reseau=$3
	nb_paquets=$4
	protocoles=$5
	if [[ $6 == "" ]]; then
		login='\e[91mOFF'
	else
		login=$6
	fi 

	options="\tInterface réseau : $interface_reseau\n \t\t\t\tNombre de paquets : $nb_paquets\n \t\t\t\tProtocoles : $protocoles"

	echo -e "==================================\e[93mMain Menu\e[39m=================================="
	echo -e "\t \e[93m1: \e[39mOption de capture \e[92m[$options]"
	echo -e "\t \e[93m2: \e[39mCapturer les mots de pass et/ou login  $login"
	echo -e "\t \e[93m3: \e[39mChoix addresse(s) IP \e[92m[$ips]" 
	echo -e "\t \e[93m4: \e[39mChoix port(s) \e[92m[$ports]"
	echo -e "\t \e[93m5: \e[39mVisualiser un des fichiers log"
	echo -e "\t \e[93m6: \e[39mQuitter le script"
	echo -e "\t \e[93m7: \e[39mLancer tcpdump"
	echo -e "=============================================================================\n"

	echo -e -n "\e[5m>\e[0m"
	read choix

	case $choix in
		1)	Option "$ips" "$ports" "$interface_reseau" "$nb_paquets" "$protocoles" "$login";;
		2)	if [[ $login == '\e[92mON' ]]; then
				login='\e[91mOFF'
			else
				login='\e[92mON'
			fi;;
		3)	echo "Entrée une ou plusieur ip"
			read ips;;
		4)	echo "Entrée un ou plusieur port"
			read ports;;
		5)	echo -e "\t \e[93m1: \e[39mCapture.log"
			echo -e "\t \e[93m2: \e[39mLogin.log"
			echo -e -n "\e[5m>\e[0m"
			read file
			if [[ $file == 1 ]]; then
				cat capture.log
			elif [[ $file == 2 ]]; then
				cat login.log
			fi
			echo "Enter for finish"
			read pass;;
		6) exit 0;;
		7) exec_tcpdump "$ips" "$ports" "$interface_reseau" "$nb_paquets" "$protocoles" "$login"
	esac
	interactif "$ips" "$ports" "$interface_reseau" "$nb_paquets" "$protocoles" "$login"
}

if [[ $# == 0 ]]; then
	interactif 

else 
	type_param=""
	ips=""
	ports=""
	interface_reseau=""
	nb_paquets=""
	protocoles=""
	login=""
	nothing=0
	for var in "$@"; do
		if [[ $type_param == "" ]]; then
			case $var in
				'-i')	type_param="-i";;
				'-c')	type_param="-c";;
				'-P')	type_param="-P";;
				'-p')	type_param="-p";;
				'-l')	type_param="-l";;
				'-ip')	type_param="-ip";;
				'-vC')	type_param="-vC";;
				'-vL')	type_param="-vL";;
				*)	nothing=1;;
			esac
		else
			case $type_param in
				'-i') interface_reseau=$var;;
				'-c') nb_paquets=$var;;
				'-P')	protocoles=$var;;
				'-p')	ports=$var;;
				'-l')	login='\e[92mON';;
				'-ip')	ips=$var;;
				'-vC')	cat capture.log;;
				'-vL')	cat login.log;;
			esac
			type_param=""
		fi
	done
	if [[ $nothing == 0 ]]; then
		exec_tcpdump "$ips" "$ports" "$interface_reseau" "$nb_paquets" "$protocoles" "$login" #Appelle de la fonction permetant l'execution de tcpdump
	else
		helper
	fi
fi
