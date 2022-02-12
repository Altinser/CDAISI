import os
import shutil
import re
import sys
import socket

IMG_FORMAT = [".jpg"] 
IMG_OUTPUT_FILE = "image_output"
IP_REGEX = r"(\b25[0-5]|\b2[0-4][0-9]|\b[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}"

def is_image(file):
    for f in IMG_FORMAT:
        if file.endswith(f):
            return True
    return False

def affichage(list_ip,imgs):
    cpt = 0
    for k in list_ip:
        for ip in list_ip[k]:
            cpt += 1
            print("IP n°"+str(cpt),"from",k,":",ip)
    print("\n\t******** Images ********")
    cpt = 0
    for img in imgs:
        cpt += 1
        print("Image n°"+str(cpt),":",img)

def img_name():
    list_img_name = []
    for root, dirs, files in os.walk(IMG_OUTPUT_FILE):
        for img in files:
            list_img_name.append(img.split(".")[0])
    return list_img_name

def find(path):
    dic_ip = {}
    hostname = socket.gethostname()
    local_ip = socket.gethostbyname(hostname)
    len_tail = len(local_ip.split(".")[3])+1
    local_ip = local_ip[:-len_tail]

    for root, dirs, files in os.walk(path):
        for file in files:
            list_tmp = []
            full_path = os.path.join(root, file)
            if is_image(file):
                shutil.copy2(full_path,IMG_OUTPUT_FILE)
            elif file.endswith(".txt"):
                regex = re.compile(IP_REGEX)
                f = open(full_path,'r')
                for line in f:
                    ip = regex.match(line)
                    if ip and ip.group().startswith(local_ip):
                        list_tmp.append(ip.group())
            dic_ip[file] = list_tmp
    return dic_ip

if __name__ == '__main__':
    path = sys.argv[1]
    if not os.path.isdir(IMG_OUTPUT_FILE):
        os.mkdir(IMG_OUTPUT_FILE)

    dic_ip = find(path) 
    img_name = img_name() 
    affichage(dic_ip,img_name) 
