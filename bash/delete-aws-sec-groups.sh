#!/bin/bash

#install from: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

#🐙 ~ ➤ aws configure
#AWS Access Key ID [None]: <REDACTED>
#AWS Secret Access Key [None]: <REDACTED>
#Default region name [None]: us-west-1
#Default output format [None]: json

# for each region
for REGION in "us-east-1" "us-east-2" "us-west-1" "us-west-2"; do
    # get active security groups
    active=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].SecurityGroups[*].GroupId' --output text --region $REGION);
    # for every security group..
    for secgroup in $(aws ec2 describe-security-groups --query 'SecurityGroups[*].GroupId' --output text --region $REGION); do
        ## if the security group is not in the list of active security groups, delete it.
        if [[ ! "${active[*]}" =~ "${secgroup}" ]]; then
            #echo "[#] deleting ${secgroup}";
            aws ec2 delete-security-group --group-id $secgroup --region $REGION
        fi;
    done;
done;
