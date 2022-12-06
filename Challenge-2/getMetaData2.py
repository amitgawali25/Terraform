import boto3
import json
import sys
import getopt
from icecream import ic
from getMetaData import nestedLookup


ic.configureOutput(prefix='Debug | ')
ic.disable()

region = 'us-east-1'


def buildJsonMetadata(instance_id):    
    ic("using boto3 apis to get metadata without key")

    client = boto3.client('ec2', region_name=region)
    response = client.describe_instances(InstanceIds=[instance_id]).get("Reservations")
    jsonMeta = json.dumps(response, indent=4, default=str)

    f = open('output_boto.json', "w")
    f.write(jsonMeta)
    f.close()


    print(jsonMeta)


def buildJsonByKey(instance_id,key):  

    ic("using boto3 apis to get metadata with key")

    client = boto3.client('ec2', region_name=region)
    reservations = client.describe_instances(InstanceIds=[instance_id]).get("Reservations")

    # Using manual nested lookup
    #result = nestedLookup(reservations, key)
    #print(result)

    ic("Using boto3 lookup")
    for reservation in reservations:
        for instance in reservation['Instances']:
            print(instance.get(key))



# main()
if __name__ == '__main__':

    key=""
    instance_id=""

    if(len(sys.argv) <= 1): 
        print("Invalid input syntax - use getMetaData2 -h for help")
        exit(2)
    else:
        ic("options given")
        ic(sys.argv[1:])
        try:
            opts, args = getopt.getopt(sys.argv[1:], 'k:h:i', ['key=','id=','help'])
            ic(opts)
            ic(args)
        except:
            print("Invalid input syntax - use getMetaData2 -h for help")
            exit(2)

        for opt, arg in opts:
            ic("current opt -", opt)
            if opt in ['-k', '--key']:
                key = arg
                print("==> key -", key)
            elif opt in ['-i', '--id']:
                instance_id = arg
                print("==> instance_id -", instance_id)

            elif opt in ['-h', '--help']:
                print("Usage: getMetaData2 -[options] ")
                print("All keys are output if no specific key is mentioned with -k option")
                print("Available options:")
                print("-h or --help : Help ")
                print("-i or --id : EC2 instance id ")
                print("-k or --key : specify indiviual key")
                print("              example - getMetaData2 -i i-082ba0539e9dfe4fd -k InstanceType")

    if len(key) > 0 and len(instance_id) > 0:
        buildJsonByKey(instance_id,key)
    elif len(instance_id) > 0:
        buildJsonMetadata(instance_id)
    else:
        print("Invalid input syntax - use getMetaData2 -h for help")

