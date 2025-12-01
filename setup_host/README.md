1-cr_vpc.yml. - cft template
    Creates the VPC with 2 private & 2 public subnets across 2 AZ

    CloudFormation Name = rds-vpc

----------------------------------
Setup 2-cr-security_group.yml
----------------------------------

Pre-requisite
----------------------------------
Creates Security groups for VPC with 2 private & 2 public subnets across 2 AZ



Setup 3-cr-bastion-host.yml

Sets up an EC2 instance that is used for connecting/testing the cluster. 

Stack deletion: 

The stack creates a Host Security group that is used by other bastion hosts etc. 

Required Tools:

These tools will be installed on the bastion host.
1. git client
2. psql
3. pgbench
4. jq

======================================
Setup tools on VM/Bastion Host (Linux)
======================================
1. SSH into the VM

2. Install git
sudo su -
yum install git -y

3. Clone the repository
su - ec2-user

git clone https://github.com/kmakwana0028/AWS-rds-ansible.git

4. Install the tools
# cp -r Amazon-RDS-Aurora-Postgres-v1/bin .
# mkdir cloudformation
# cp -r Amazon-RDS-Aurora-Postgres-v1/vpc/*.yml ./cloudformation
# cp -r Amazon-RDS-Aurora-Postgres-v1/replicas/*.yml ./cloudformation
# cp -r Amazon-RDS-Aurora-Postgres-v1/cluster-basic/*.yml ./cloudformation
# cp -rf Amazon-RDS-Aurora-Postgres-v1/pgbench/ pgbench

chmod -R u+x bin
sudo ./psql-pgbench-jq.sh

5. Validate the tools
psql --version
pgbench --version
jq --version

6. Setup environment variables in .bashrc

./setup-env.sh  <<AWS REGION>>

source ~/.bashrc

6. Test with psql
psql

Common Error
------------
If you missed the step below then you will get an error: 
"psql: could not connect to server: No such file or directory"

source ~/.bashrc

=====================================
install ansible to run the playbooks
======================================
pip3 install ansible boto3 botocore --user
ansible-galaxy collection install -r requirements.yml
OR
ansible-galaxy collection install amazon.aws --force

        ---Detailed steps for above requirements if any issues---

        ## What You Need (Priority Order)

        1. **boto3 and botocore** (CRITICAL) - These do the actual AWS API calls
        2. **ansible-galaxy collection** (NICE TO HAVE) - Provides cleaner syntax
        3. **AWS credentials** (CRITICAL) - Must be configured

        ---

        ## Recommended Deployment Steps

        ### Step 1: Install boto3 (Critical)
        ```bash
        pip3 install --upgrade boto3 botocore --user
        ```

        ### Step 2: Try Collection Installation (Optional)
        ```bash
        # Try without requirements file
        ansible-galaxy collection install amazon.aws --force

        # OR use the script
        ./install_dependencies.sh
        ```


## Quick Test

        Test if your setup is ready without deploying:

        ```bash
        # Test 1: Check boto3
        python3 -c "import boto3; print('boto3 OK:', boto3.__version__)"

        # Test 2: Check AWS credentials
        aws sts get-caller-identity

        # Test 3: Check syntax
        ansible-playbook deploy_rds_aurora.yml --syntax-check

        # Test 4: Check resources exist
        aws ec2 describe-vpcs --vpc-ids vpc-0293da6a0c2c6b6a1 --region us-east-1
        aws ec2 describe-subnets --subnet-ids subnet-0ae0d087f2a0ca680 subnet-02851772091045e5e --region us-east-1
        aws ec2 describe-security-groups --group-ids sg-0bceef39919a6ebbf --region us-east-1
        ```

        If all tests pass, you're ready to deploy!

        ---

        ## Still Having Issues?

        If you still get errors, please share:

        1. Output of: `pip3 show boto3 botocore`
        2. Output of: `ansible --version`
        3. Output of: `aws sts get-caller-identity`
        4. The exact error message from the playbook

================================================
(Auto) Bastion Host Setup Utility Script (Linux)
================================================
This method will setup the tools and all required scripts on your bastion host !! You may setup you own instance and just follow the steps here to setup the bastion host with required tools.


1. Login to your Bastion Host VM as ec2-user
--------------------------------------------
Copy and paste the commands in shell prompt on your bastion host

2. run following
----------------------------
./setup-bastion.sh 

3 Change mod of the file
------------------------
chmod u+x ./setup-bastion.sh 

4. Setup the environment
------------------------
./setup-bastion.sh <<Provide AWS Region>>  

If you see a message:
"An error occurred (DBClusterNotFoundFault) when calling the DescribeDBClusters operation: DBCluster rdsa-postgresql-cluster not found." then that means the DB cluster stack is not created !! 

5. Set the environment variables in the current shell
-----------------------------------------------------
source ~/.bashrc

7. Use psql
-----------
psql                                  <<Uses $PGWRITEREP; Will give error in secondary region in case of global DB>>
psql    -h $PGWRITEREP                <<Will give error in secondary region in case of global DB>>
psql    -h $PGREADEREP

Note: 
In case of error: Make sure to provide the correct AWS Region & Cluster name ; Run the script again
===========================
--if needed, install windows EC2 to run the pgadmin-----
============================
Download and install PgAdmin
============================
https://www.pgadmin.org/download/

====================================
CloudFormation Latest AMI for Linux2
====================================
https://aws.amazon.com/blogs/compute/query-for-the-latest-amazon-linux-ami-ids-using-aws-systems-manager-parameter-store/


===================================
CloudFormation Dependencies for VPC
===================================
1. Terminate all instances in your VPC
2. Delete all ENI's associated with subnets within your VPC
3. Detach all Internet and Virtual Private Gateways (you can then delete them and any VPN connections, but that's not required to delete the VPC object)
3. Disassociate all route tables from all the subnets in your VPC
4. Delete all route tables other than the "Main" table
5. Disassociate all Network ACL's from all the subnets in your VPC
6. Delete all Network ACL's other than the Default one
7. Delete all Security groups other than the Default one (note: if one group has a rule that references another, you have to delete that rule before you can delete the other security group)
8. Delete all subnets
9. Delete your VPC
10. Delete any DHCP Option Sets that had been used by the VPC

========================================
CloudFormation VPC Stack Deletion errors
========================================
Resolve dependancies due to creation of ENI in the VPC/Subnets
https://aws.amazon.com/premiumsupport/knowledge-center/troubleshoot-dependency-error-delete-vpc/
* Check for EC2>>Network Interfaces 
* Delete resources using the ENI
* Attempt the VPC deletion again
