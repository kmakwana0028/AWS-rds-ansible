# Ansible Playbook Structure

## 📁 Project Structure

```
rds_aurora/
├── deploy_rds_aurora.yml              # Deploy playbook
├── delete_rds_stack.yml               # Delete playbook
├── group_vars/
│   └── rds_aurora_vars.yml           # Shared variables
└── roles/
    ├── rds_aurora_postgresql/         # Deploy role
    │   ├── defaults/main.yml
    │   └── tasks/main.yml
    └── rds_aurora_delete/             # Delete role
        └── tasks/main.yml
```

---

Both playbooks follow the same pattern:

### Deploy Playbook
- update variables in /group_vars/rds_aurora_vars.yml for:

        # VPC ID for RDS Aurora
        rds_aurora_vpc: vpc-0293da6a0c2c6b6a1

        # Private Subnets (comma-separated)
        private_subnets: "subnet-0ae0d087f2a0ca680,subnet-02851772091045e5e"

        # VPC Security Group for Cluster
        vpc_security_group_cluster: sg-0bceef39919a6ebbf

**File**: `deploy_rds_aurora.yml`

```yaml
- name: Deploy RDS Aurora PostgreSQL Cluster
  hosts: localhost
  connection: local
  gather_facts: false

  vars_files:
    - group_vars/rds_aurora_vars.yml

  roles:
    - role: rds_aurora_postgresql

  post_tasks:
    - name: Display Deployment Summary
      # ... show results
```

**Role**: `roles/rds_aurora_postgresql/tasks/main.yml`
- Embeds CloudFormation template
- Uses variables from group_vars
- Creates CloudFormation stack
- Displays outputs
- Saves connection details

---

### Delete Playbook

**File**: `delete_rds_stack.yml`

```yaml
- name: Delete RDS Aurora PostgreSQL Stack
  hosts: localhost
  connection: local
  gather_facts: true

  vars_files:
    - group_vars/rds_aurora_vars.yml

  roles:
    - role: rds_aurora_delete

  post_tasks:
    - name: Display Deletion Summary
      # ... show results
```

**Role**: `roles/rds_aurora_delete/tasks/main.yml`
- Shows deletion warning
- Asks for confirmation
- Checks if stack exists
- Deletes CloudFormation stack
- Verifies deletion
- Saves deletion summary


**File**: `group_vars/rds_aurora_vars.yml`

Both playbooks use the same variables:

```yaml
aws_region: us-east-1
stack_name: rds-aurora-postgresql-stack
template_name: rds-ansible-postgresql
db_engine_version: "16.1"
db_instance_class: db.t3.medium
db_master_username: postgres
db_master_user_password: postgres123!
rds_aurora_vpc: vpc-0293da6a0c2c6b6a1
private_subnets: "subnet-0ae0d087f2a0ca680,subnet-02851772091045e5e"
vpc_security_group_cluster: sg-0bceef39919a6ebbf
deployment_env: dev
```

---

## 🚀 Usage

### Deploy

```bash
# Standard deployment
ansible-playbook deploy_rds_aurora.yml

# Override variables
ansible-playbook deploy_rds_aurora.yml -e "deployment_env=prod"
```

### Delete

```bash
# Interactive (with confirmation)
ansible-playbook delete_rds_stack.yml

# Skip confirmation
ansible-playbook delete_rds_stack.yml -e "confirm_delete=yes"
```

---

## 📊 Comparison

| Aspect | Deploy Playbook | Delete Playbook |
|--------|----------------|-----------------|
| **File** | `deploy_rds_aurora.yml` | `delete_rds_stack.yml` |
| **Role** | `rds_aurora_postgresql` | `rds_aurora_delete` |
| **Variables** | `group_vars/rds_aurora_vars.yml` | `group_vars/rds_aurora_vars.yml` |
| **Structure** | Role-based | Role-based |
| **gather_facts** | false | true |
| **Confirmation** | No | Yes (interactive) |
| **Output File** | `rds_cluster_output.txt` | `rds_deletion_<timestamp>.txt` |

---

## 🎯 Key Features

### Both Playbooks

✅ **Consistent Structure**: Same layout and organization
✅ **Shared Variables**: Use same configuration file
✅ **Role-Based**: Clean separation of concerns
✅ **Self-Contained**: Embedded CloudFormation template (deploy only)
✅ **Post-Tasks**: Summary display after role execution

### Deploy-Specific

✅ **Embedded Template**: CloudFormation YAML in `template_body`
✅ **No External Files**: Template is inline in tasks
✅ **Variable Substitution**: Direct variable injection
✅ **Output Display**: Shows cluster connection details
✅ **Output File**: Saves connection info to text file

### Delete-Specific

✅ **Safety First**: Warning message with details
✅ **Interactive Confirmation**: Asks user to type 'yes'
✅ **Skip Option**: `-e confirm_delete=yes` for automation
✅ **Existence Check**: Verifies stack exists before deleting
✅ **Deletion Summary**: Creates timestamped summary file
✅ **Verification**: Confirms deletion completed

---

## 📂 Role Files

### Deploy Role: `roles/rds_aurora_postgresql/`

```
rds_aurora_postgresql/
├── defaults/
│   └── main.yml              # Default variables
└── tasks/
    └── main.yml              # Deployment tasks with embedded CF template
```

**Tasks:**
1. Deploy CloudFormation stack
2. Display stack outputs
3. Save outputs to file

### Delete Role: `roles/rds_aurora_delete/`

```
rds_aurora_delete/
└── tasks/
    └── main.yml              # Deletion tasks
```

**Tasks:**
1. Display deletion warning
2. Confirm deletion
3. Check stack existence
4. Delete CloudFormation stack
5. Wait for deletion
6. Verify deletion
7. Save deletion summary

---

## 🎓 Why This Structure?

### Consistency
- Same pattern for deploy and delete
- Easy to understand and maintain
- Predictable behavior

### Modularity
- Roles separate concerns
- Reusable components
- Easy to extend

### Flexibility
- Variables in one place
- Override capability
- Environment-specific configs

### Safety
- Delete requires confirmation
- Verification steps
- Audit trail with summary files

---

## 📚 Summary

| Playbook | Purpose | Role | Variables | Confirmation |
|----------|---------|------|-----------|--------------|
| `deploy_rds_aurora.yml` | Create RDS Aurora | `rds_aurora_postgresql` | `group_vars/rds_aurora_vars.yml` | Not required |
| `delete_rds_stack.yml` | Delete RDS Aurora | `rds_aurora_delete` | `group_vars/rds_aurora_vars.yml` | Required (type 'yes') |

Both follow the same structure, use the same variables, and provide a consistent user experience! 🚀
