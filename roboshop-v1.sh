#!/bin/bash

ami_id="ami-0055977a6e828a4f4"
instance_type="t3.micro"
domain_name="alekyameda.store"
hosted_zone_id="Z00935121F2I3EKC44I96"

for instance in  $@
do 

    echo "Creating instance: $instance"

    instance_id=$(aws ec2 run-instances \
              --image-id $ami_id \
              --instance-type $instance_type \
              --security-groups "roboshop-common" "roboshop-$instance" \
              --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=roboshop-$instance}]" \
              --query 'Instances[0].InstanceId' \
              --output text
    )

    echo "$instance instance ID: $instance_id"
    
    if [ $instance != "frontend" ]; then
          IP=$( aws ec2 describe-instances --instance-ids $instance_id \
                --query 'Reservations[].Instances[].PrivateIpAddress' --output text 
          )
          r53_record="${instance}.${domain_name}"
     
    else
        
           IP=$( aws ec2 describe-instances --instance-ids $instance_id \
                  --query 'Reservations[].Instances[].PublicIpAddress' --output text
            )
            r53_record="${instance}.${domain_name}"
    
    fi
done