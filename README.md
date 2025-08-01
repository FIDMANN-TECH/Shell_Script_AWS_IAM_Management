# 🔐 AWS IAM Management Automation Project

## 📌 Project Overview

This project automates the provisioning of AWS IAM users, groups, custom policies, and login profiles for a fictional fintech company, *Zappy e-Bank*. The objective is to implement access control based on roles (Dev, Ops, Audit) while enforcing security best practices like strong password policies and the principle of least privilege.

## 🛠 Technologies Used

- *AWS CLI* (v2)
- *Bash Scripting*
- *IAM Policies (Managed & Custom)*
- *Linux Terminal (Ubuntu)*
- *AWS Console for Testing*

## 👤 Author

*Name:* Omoghene Erubami  
*Date:* 31 July – 1 August, 2025  
*Role:* DevOps Engineer  


## 🧾 Project Files

| Filename                    | Purpose                                                         |
|----------------------------|-----------------------------------------------------------------|
| iam-setup.sh             | Automates creation of users, groups, and custom IAM policies    |
| assign-login-profiles.sh | Assigns passwords, login access, and permissions to IAM users   |
| developer-ec2-policy.json| Defines EC2 access policy for developers                        |
| audit-s3-policy.json     | Defines S3 access policy for auditors                          |
| README.md                | Project documentation with testing results                      |

---

## 🧪 Functional Breakdown

### 🧱 1. IAM Setup Script (iam-setup.sh)

This script does the following:

- Creates three IAM groups: developers, operations, auditors
- Adds users to each group:
  - Developers: *John, **Alice*
  - Operations: *Mark, **Emma*
  - Auditors: *Susan*
- Creates custom IAM policies:
  - DeveloperEC2FullAccess (EC2 full access for developers)
  - AnalystS3FullAccess (S3 full access for auditors)
- Attaches the following policies:
  - Developers → EC2 custom policy
  - Auditors → S3 custom policy
  - Operations → AWS Managed ReadOnlyAccess policy


### 🔐 2. Assign Login Profiles (assign-login-profiles.sh)

This script assigns passwords and login permissions:

- Creates login profiles for each user with the default password: ZappySecure@2025
- Enforces password reset on first login
- Attaches AWS managed policy: IAMUserChangePassword
- Configures account-level password policy (symbols, upper/lowercase, numbers)


## 🔍 Testing & Verification

### ✅ User Login Test

- Attempted to log in with  *Alice, **Emma, **Susan
- Verified that:
  - Password reset was required on first login
  - Login success/failure was logged


### 🚫 Permissions Validation

Performed permission tests for various users:

| User   | Group      | Action Attempted  | Result                      | Screenshot? |
|--------|------------|-------------------|-----------------------------|-------------|
| Emma   | Operations | Create S3 bucket  | ❌ Access Denied (as expected) | ✅ Yes       |
| Susan  | Auditors   | Launch EC2 instance | ❌ Access Denied (as expected) | ✅ Yes       |
| John   | Developers | Launch EC2 instance | ✅ Allowed                    | ✅ Yes       |
| Susan  | Auditors   | Access S3 bucket  | ✅ Allowed                    | ✅ Yes       |

These tests confirmed that:
- IAM policies were correctly attached
- Users could only access resources permitted by their group's policy


## 📦 How to Run

1. *Prerequisites*:
   - AWS CLI configured (aws configure)
   - IAM admin permissions

2. *Execution*:
   ```bash
   chmod +x iam-setup.sh assign-login-profiles.sh
   ./iam-setup.sh
   ./assign-login-profiles.sh
   ```

   ## Below are screenshots of workflow:

   ![iam_setup.sh](./img/01_iam_setup_aws_cli.png)
   ![script-setup.sh](./img/02_setup_script.png)
   ![aws_cli_grup_output](./img/03_aws_cli_group_created.png)
   ![aws_cli_usr_output](./img/04_awscli_created_usr.png)
   ![aws_cli_usr_added_gurp_output](./img/05_awscli_created_usr_add_grup.png)
   ![aws_cli_policies_attached_output](./img/06_created_policies_attached_group.png)
   ![aws_iam_grp](./img/07_AWS_IAM_grup_console.png)
   ![aws_iam_usr](./img/08_AWS_IAM_usr_console.png)
   ![aws_iam_policy_attached_auditor](./img/09_policy_attached%20_auditor.png)
   ![aws_iam_policy_attached_developer](./img/10_policy_attached%20_developers.png)
   ![aws_iam_policy_attached_operation](./img/11_policy_attached%20_operations.png)
   ![aws_iam_alice_john_assigned_developer](./img/12_alice_john_assigned_developers.png)
   ![aws_iam_susan_assigned_audtor](./img/13_susan_assigned_auditors.png)
   ![aws_iam_emma_mark_assigned_operation](./img/14_emma_mark_assigned_operations.png)
   ![aws_login_access_denied](./img/15_alice_login_DENIED.png)
   ![script_usr_profile_login](./img/16_usr_profile_login_script.png)
   ![continue-usr-profile-login](./img/17_continue_usr_profile_login_script.png)
   ![run_output_profile_login](./img/18_output_profile_login_creation.png)
   ![password_polcy_attached](./img/19_attached_alice_passwrd_policy.png)
   ![alice_changed_passwrd](./img/20_alice_changed_passwrd.png)
   ![alice_testing_ec2_launched](./img/21_alice_launched_EC2.png)
   ![alice-testing_s3_denied](./img/22_alice_s3_DENIED.png)
   ![emma-testing](./img/23_emma_readonlyaccess.png)
   ![emma-testing-s3-denied](./img/24_emma_s3_DENIED.png)
   ![susan-testing_created_s3](./img/25_susan_created-s3.png)
   ![susan-testing-s3-denied](./img/26_susan_ec2-DENIED.png)