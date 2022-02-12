#! /usr/bin/python
from logging import getLogger, ERROR
getLogger("scapy.runtime").setLevel(ERROR)
from scapy.all import *
import random
import time
import sys
import subprocess as sub
import argparse
import re

min_ports = 50
max_ports = 1024

if len(sys.argv) > 1:
    dst_ip = sys.argv[1] 
else:
    print("Besoin d'une ip en argument")
    sys.exit()
if len(sys.argv) == 3:
    interface = sys.argv[2] 
else:
    interface = ""

ports = list(range(min_ports,max_ports+1))
random.shuffle(ports) 

SYNACK = 0x12
RSTACK = 0x14
waiting_time = 0.1 

def conect(dst_port):
    srcport = RandShort() 
    conf.verb = 0 
    
    pktSYNACK = sr1(IP(dst=dst_ip)/TCP(sport = srcport, dport=dst_port,flags="S"),timeout=waiting_time) 
    if pktSYNACK is None: 
        return 2
        
    elif(pktSYNACK.haslayer(TCP)):
        pktflags = pktSYNACK.getlayer(TCP).flags
        
        pktRST = IP(dst = dst_ip)/TCP(sport = srcport, dport = dst_port, flags = "R")
        send(pktRST) 
        if pktflags == SYNACK:
            return 1 
        else:
            return 0 
   
def rand_mac(): 
    return "%02x:%02x:%02x:%02x:%02x:%02x" % (
        random.randint(0, 255),
        random.randint(0, 255),
        random.randint(0, 255),
        random.randint(0, 255),
        random.randint(0, 255),
        random.randint(0, 255)
        )

def change_mac():
    new_mac = rand_mac()
    sub.call(['sudo', 'ifconfig', interface, 'down'])
    sub.call(['sudo', 'ifconfig', interface, 'hw', 'ether', new_mac])
    sub.call(['sudo', 'ifconfig', interface, 'up'])
  
    command_args = get_args()

    change_mac(command_args.interface, command_args.new_mac)


def main():
    print("[*] Scanning commence a "+time.strftime("%H:%M:%S") + "!")
    start_clock = datetime.now()
    for port in ports: 
        if interface:
            change_mac()
        sleeping_time = random.randint(1, 10) / 100 
        time.sleep(sleeping_time) 
        status = conect(port)
        if status == 1:
            print("Connection TCP : port "+ str(port) +" IP "+str(dst_ip))
        elif status == 2:
            print("Filtré TCP : port "+ str(port) +" IP "+str(dst_ip))
    stop_clock = datetime.now()
    total_time = stop_clock - start_clock 
    print("[*] Scanning terminer")
    print("[*] Durée total du scan: "+str(total_time))

main()
