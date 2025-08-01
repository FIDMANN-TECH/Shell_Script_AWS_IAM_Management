#!/bin/bash

# Title: AWS IAM Management Automation Script
# Author: Omoghene Erubami
# Date: 31 July, 2025
# Purpose: Automate the setup of IAM users, groups, and policies for development, operations, and audit teams.

echo "Starting IAM Automation Script..."

# AWS Account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Declare arrays for users
dev_users=("John" "Alice")
ops_users=("Mark" "Emma")
audit_users=("Susan")

# Define groups
groups=("developers" "operations" "auditors")

# 1. Create IAM Groups
echo "Creating IAM Groups..."
for group in "${groups[@]}"; do
    aws iam create-group --group-name "$group" 2>/dev/null && echo "Group $group created." || echo "Group $group already exists."
done

# 2. Create IAM Users and add them to respective groups
echo "Creating Users and Adding to Groups..."
for user in "${dev_users[@]}"; do
    aws iam create-user --user-name "$user" 2>/dev/null && echo "User $user created." || echo "User $user already exists."
    aws iam add-user-to-group --user-name "$user" --group-name developers
done

for user in "${ops_users[@]}"; do
    aws iam create-user --user-name "$user" 2>/dev/null && echo "User $user created." || echo "User $user already exists."
    aws iam add-user-to-group --user-name "$user" --group-name operations
done

for user in "${audit_users[@]}"; do
    aws iam create-user --user-name "$user" 2>/dev/null && echo "User $user created." || echo "User $user already exists."
    aws iam add-user-to-group --user-name "$user" --group-name auditors
done

# 3. Create custom policies if they don't exist
echo "Creating Custom Policies..."

# Developer EC2 Full Access
dev_policy_name="DeveloperEC2FullAccess"
dev_policy_arn="arn:aws:iam::$ACCOUNT_ID:policy/$dev_policy_name"
if ! aws iam get-policy --policy-arn "$dev_policy_arn" >/dev/null 2>&1; then
    cat > developer-ec2-policy.json <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "ec2:*",
            "Resource": "*"
        }
    ]
}
EOF
    aws iam create-policy --policy-name "$dev_policy_name" --policy-document file://developer-ec2-policy.json
    echo "$dev_policy_name policy created."
else
    echo "$dev_policy_name policy already exists."
fi

# Analyst S3 Full Access
audit_policy_name="AnalystS3FullAccess"
audit_policy_arn="arn:aws:iam::$ACCOUNT_ID:policy/$audit_policy_name"
if ! aws iam get-policy --policy-arn "$audit_policy_arn" >/dev/null 2>&1; then
    cat > audit-s3-policy.json <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "*"
        }
    ]
}
EOF
    aws iam create-policy --policy-name "$audit_policy_name" --policy-document file://audit-s3-policy.json
    echo "$audit_policy_name policy created."
else
    echo "$audit_policy_name policy already exists."
fi

# 4. Attach policies to groups (with checks)
echo "Attaching Policies to Groups..."

# Attach DeveloperEC2FullAccess to developers
aws iam attach-group-policy \
    --group-name developers \
    --policy-arn "$dev_policy_arn" || echo "Failed to attach DeveloperEC2FullAccess to developers"

# Attach AnalystS3FullAccess to auditors
aws iam attach-group-policy \
    --group-name auditors \
    --policy-arn "$audit_policy_arn" || echo "Failed to attach AnalystS3FullAccess to auditors"

# Attach ReadOnlyAccess (AWS managed) to operations
aws iam attach-group-policy \
    --group-name operations \
    --policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess || echo "Failed to attach ReadOnlyAccess to operations"

echo "✅ IAM Setup Completed Successfully!"