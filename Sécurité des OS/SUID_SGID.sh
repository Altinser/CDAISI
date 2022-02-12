#!/bin/bash

send_mail () {
	mail -s "$1" root <<<$2
}

if [[ $# == 0 ]]
then
	echo "vous devez mettre un argument (search/check)"
fi

if [[ $1 == 'search' ]]
then
	find / -perm /4000 -exec md5sum "{}" + > suid 2>/dev/null
	find / -perm /2000 -exec md5sum "{}" + > sgid 2>/dev/null

	md5sum suid > controle
	md5sum sgid >> controle

elif [[ $1 == 'check' ]]
then
	if [[ $(md5sum suid) != $(sed -n '1p' controle) && $(md5sum sgid) != $(sed -n '2p' controle) ]]
	then
		send_mail "Erreur, fichier modifier" "Les deux fichier suid et sgid on étais modifié manuellement ce qui rend la vérification obselète"
		exit 0
	elif [[ $(md5sum suid) != $(sed -n '1p' controle) ]]
	then
		send_mail "Erreur, fichier modifier" "Le fichier suid a étais modifier manuellement ce qui rend la vérification obselète"
		exit 0
	elif [[ $(md5sum sgid) != $(sed -n '2p' controle) ]]
	then 
		send_mail "Erreur, fichier modifier" "Le fichier sgid a étais modifier manuellement ce qui rend la vérification obselète"
		exit 0
	fi

	find / -perm /4000 -exec md5sum "{}" + > .tmp_suid 2>/dev/null
	find / -perm /2000 -exec md5sum "{}" + > .tmp_sgid 2>/dev/null
	diff -r suid .tmp_suid > .res_suid 
	diff -r sgid .tmp_sgid > .res_sgid

	while read p; do
		symbole=$(echo $p | cut -d" " -f1) 
		if [[ ${#p} > 6 && $symbole == "<" ]] 
		then
			hash=$(echo $p | cut -d" " -f2) 
			name=$(echo $p | cut -d" " -f3) 
			before+=" $hash|$name" 
		fi

		if [[ ${#p} > 6 && $symbole == ">" ]]
		then
			new_hash=$(echo $p | cut -d" " -f2)
			new_name=$(echo $p | cut -d" " -f3)
			after+=" $new_hash|$new_name" 
		fi
	done <<<$(paste -d "\n" .res_suid .res_sgid) 

	for line_before in $before; do
		hash=$(echo $line_before | cut -d"|" -f1)
		name=$(echo $line_before | cut -d"|" -f2)
		for line_after in $after; do
			new_hash=$(echo $line_after | cut -d"|" -f1)
			new_name=$(echo $line_after | cut -d"|" -f2)

			if [[ $hash == $new_hash && $name != $new_name ]]
			then
				sujet="Anomalie, changement de nom/chemin detecter"
				msg="Le fichier $name a changer de nom et est devenue $new_name \n sont MD5 est $hash"
			elif [[ $name == $new_name && $hash != $new_hash ]]
			then
				sujet="Anomalie, MD5 modifier detecter"
				msg="Le fichier $name a changer de MD5 celui ci passe de $hash a $new_hash"
			fi
		done
		if [[ $msg == "" ]]
		then
			sujet="Anomalie, fichier supprimer detecter"
			msg="Le fichier $name a étais supprimer, il avait le MD5 suivant : $hash"
		fi
		send_mail "$sujet" "$msg"
	done

	for line_after in $after; do
		msg=""
		hash=$(echo $line_after | cut -d"|" -f1)
		name=$(echo $line_after | cut -d"|" -f2)
		for line_before in $before; do 
			new_hash=$(echo $line_before | cut -d"|" -f1)
			new_name=$(echo $line_before | cut -d"|" -f2)

			if [[ $hash == $new_hash && $name != $new_name ]]
			then
				msg="s"
			elif [[ $name == $new_name && $hash != $new_hash ]]
			then
				msg="s"
			fi
		done
		if [[ $msg == "" ]]
		then
			send_mail "Anomalie, nouveau fichier detecter" "Un nouveau fichier qui est : $name et qui a le MD5 suivant : $hash"
		fi
	done

	rm .res_suid
	rm .res_sgid
	rm .tmp_suid
	rm .tmp_sgid
fi
