import requests
import json
import sys
import getopt
from icecream import ic
import os

ic.configureOutput(prefix='Debug | ')
#ic.disable()

# form target URL for IMDSv1
targetBaseUrl = 'http://169.254.169.254'
defaultApiVersion = 'latest'
rootNodeKey = "meta-data/"
targetUrl = targetBaseUrl + "/" + defaultApiVersion + "/"
ic(targetUrl)

# Constants
ec_username = "ec2-user"

# Recursive Nested lookup into a JSON object for a key
def searchForKeyValues(data, values, trail, targetKey):

    if isinstance(data, dict):
        for currKey, currValue in data.items():
            trail.append(currKey)
            if isinstance(currValue, (dict, list)):
                searchForKeyValues(currValue, values, trail, targetKey)
            elif currKey == targetKey:
                values.append(currValue)
    elif isinstance(data, list):
        for currItem in data:
            searchForKeyValues(currItem, values, trail, targetKey)
    
    return values

def nestedLookup(jsonData, targetKey):
    values = []
    trail = []

    result = searchForKeyValues(jsonData, values, trail, targetKey)
    ic(trail)

    return result


def buildTree(path, nodes):
    outTree = {}
    for key in nodes:
        currentUrl = path + key
        response = requests.get(currentUrl)
        text = response.text
        if key[-1] == "/":
            moreNodes = response.text.splitlines()
            outTree[key[:-1]] = buildTree(currentUrl, moreNodes)
        elif isValidJson(text):
            outTree[key] = json.loads(text)
        else:
            outTree[key] = text

    return outTree


def buildMetadataTree():
    rootNode = [rootNodeKey]
    result = buildTree(targetUrl, rootNode)

    return result


def buildJsonMetadata():    
    
    rawMeta = buildMetadataTree()
    jsonMeta = json.dumps(rawMeta, indent=4, sort_keys=True)
    
    f = open('output.json', "w")
    f.write(jsonMeta)
    f.close()
    
    return jsonMeta


def isValidJson(inputStr):
    try:
        json.loads(inputStr)
    except ValueError:
        return False
    return True

def buildJsonByKey(key):  

    user = os.environ.get("USER")
    ic(user)
  
    if(user != ec_username):
        ic("Running locally - using sample JSON")
        # Using a sample file for local testing.
        f = open('/Users/amit/Development/Terraform/Challenge-2/output.json',"r")
        jsonMeta = json.load(f)
        result = nestedLookup(jsonMeta, key)
    else:
        ic("Running on an EC2 instance - using IMDSv1 apis")

        jsonMetaStr = buildJsonMetadata()
        jsonMeta = json.loads(jsonMetaStr)
        result = nestedLookup(json.loads(jsonMetaStr), key)

    return result


# main()
if __name__ == '__main__':
    # No options specified return complete JSON tree.
    if(len(sys.argv) == 1): 
         print(buildJsonMetadata())

    else:
        ic("options given")
        ic(sys.argv[1:])
        try:
            opts, args = getopt.getopt(sys.argv[1:], 'k:h', ['key=','help'])
            ic(opts)
            ic(args)
        except:
            print("Invalid input syntax - use getMetaData -h for help")
            exit(2)

        for opt, arg in opts:
            ic("current opt -", opt)
            if opt in ['-k', '--key']:
                key  = arg
                print("==> key -", key)
                print("==> value(s)", buildJsonByKey(key))
            elif opt in ['-h', '--help']:
                print("Usage: getMetaData -[options] ")
                print("All keys are output if no specific key is mentioned with -k option")
                print("Availble options:")
                print("-h or --help : Help ")
                print("-k or --key : specify indiviual key")
                print("              example - getMetaData -k public-ipv4")



