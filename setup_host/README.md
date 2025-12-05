1-cr_vpc.yml. - cft template
    Creates the VPC with 2 private & 2 public subnets across 2 AZ

    CloudFormation Name = rds-vpc

----------------------------------
Setup 2-cr-security_group.yml
----------------------------------

Pre-requisite:
Creates Security groups for VPC with 2 private & 2 public subnets across 2 AZ


----------------------------------
Setup 3-cr-bastion-host.yml
----------------------------------
Sets up an EC2 instance that is used for connecting/testing the cluster. 

Stack deletion: 

The stack creates a Host Security group that is used by other bastion hosts etc. 

Required Tools:

These tools will be installed on the bastion host.
1. git client
2. psql
3. pgbench
4. jq

----------------------------------
Setup tools on VM/Bastion Host (Linux)
----------------------------------
1. SSH into the VM

2. Install git
sudo su -
dnf install git -y

3. Clone the repository
su - ec2-user
    mkdir rds
    cd rds
    git clone https://github.com/kmakwana0028/AWS-rds-ansible.git

4. Install the tools

   Follow 4-Install-packages.txt

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


Set the environment variables in the current shell
-----------------------------------------------------
source ~/.bashrc

Use psql
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

