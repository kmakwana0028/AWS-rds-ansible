#!/bin/bash
#
# Install Dependencies for RDS Aurora PostgreSQL Ansible Deployment
# This script handles installation for older Ansible/Python versions
#

set -e  # Exit on error

echo "=========================================="
echo "Installing Dependencies"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check Python version
echo -e "${YELLOW}Checking Python version...${NC}"
python3 --version
echo ""

# Check Ansible version
echo -e "${YELLOW}Checking Ansible version...${NC}"
ansible --version | head -1
echo ""

# Upgrade pip
echo -e "${YELLOW}Upgrading pip...${NC}"
python3 -m pip install --upgrade pip --user
echo ""

# Install/upgrade boto3 and botocore
echo -e "${YELLOW}Installing/upgrading boto3 and botocore...${NC}"
pip3 install --upgrade boto3 botocore --user
echo ""

# Check boto3 version
echo -e "${YELLOW}Checking boto3/botocore versions...${NC}"
pip3 show boto3 botocore | grep -E "^Name:|^Version:"
echo ""

# Install ansible collection - try multiple methods
echo -e "${YELLOW}Installing amazon.aws collection...${NC}"

# Method 1: Try with requirements.yml first
if ansible-galaxy collection install -r requirements.yml --force 2>/dev/null; then
    echo -e "${GREEN}✓ Collection installed via requirements.yml${NC}"
else
    echo -e "${YELLOW}requirements.yml failed, trying direct installation...${NC}"

    # Method 2: Try direct installation without version
    if ansible-galaxy collection install amazon.aws --force; then
        echo -e "${GREEN}✓ Collection installed directly${NC}"
    else
        echo -e "${RED}✗ Failed to install collection via Galaxy${NC}"
        echo -e "${YELLOW}Trying manual download method...${NC}"

        # Method 3: Download and install manually
        TEMP_DIR=$(mktemp -d)
        cd "$TEMP_DIR"

        # Download a compatible version
        wget -q https://github.com/ansible-collections/amazon.aws/archive/refs/tags/6.5.0.tar.gz -O amazon-aws.tar.gz

        if [ $? -eq 0 ]; then
            tar -xzf amazon-aws.tar.gz
            cd amazon.aws-6.5.0
            ansible-galaxy collection build
            ansible-galaxy collection install amazon-aws-*.tar.gz --force
            echo -e "${GREEN}✓ Collection installed manually${NC}"
        else
            echo -e "${RED}✗ Manual installation failed${NC}"
            echo -e "${YELLOW}Please install manually using pip:${NC}"
            echo "pip3 install ansible boto3 botocore --user"
        fi

        cd - > /dev/null
        rm -rf "$TEMP_DIR"
    fi
fi

echo ""

# Verify collection installation
echo -e "${YELLOW}Verifying amazon.aws collection installation...${NC}"
if ansible-galaxy collection list | grep -q amazon.aws; then
    echo -e "${GREEN}✓ amazon.aws collection is installed${NC}"
    ansible-galaxy collection list amazon.aws
else
    echo -e "${RED}✗ amazon.aws collection not found${NC}"
    echo -e "${YELLOW}The playbook may still work if boto3 is installed correctly${NC}"
fi

echo ""
echo "=========================================="
echo -e "${GREEN}Dependency installation complete!${NC}"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Clean up failed stack: ansible-playbook cleanup_failed_stack.yml"
echo "2. Deploy RDS cluster: ansible-playbook deploy_rds_aurora.yml"
echo ""
