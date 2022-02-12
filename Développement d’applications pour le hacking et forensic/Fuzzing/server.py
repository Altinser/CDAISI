import socket

user = "1234"
password = "1234"

receive_user, receive_password = "", ""

host, port = "127.0.0.1", 1920
s = socket.socket()
s.bind((host, port))
s.listen()
s_client, a_client = s.accept()
print("En écoute")


receive_user = s_client.recv(512).decode()
while receive_user != user:
    s_client.send("Login incorrect !".encode())
    receive_user = s_client.recv(512).decode()
    print("Tentative de connection login:", receive_user)
s_client.send("User correct !".encode())
print("Le login et correct : ", user)

receive_password = s_client.recv(512).decode()
while receive_password != password:
    s_client.send("Mot de passe incorrect ! ".encode())
    receive_password = s_client.recv(512).decode()
    print("Tentative de connection password:", receive_password)
s_client.send("Connexion réussie !".encode())
print("Vous avez trouvé les bons login :", user,password)

s_client.close()
s.close()
