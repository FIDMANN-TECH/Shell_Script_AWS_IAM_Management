#!/bin/bash

# Title: AWS IAM Cleanup Script
# Author: Omoghene Erubami
# Date: 31 July, 2025
# Purpose: Undo IAM setup by deleting users, groups, and custom policies created earlier

echo "Starting IAM Cleanup Script..."

# AWS Account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# User lists
dev_users=("John" "Alice")
ops_users=("Mark" "Emma")
audit_users=("Susan")

# Group list
groups=("developers" "operations" "auditors")

# Custom policy names
custom_policies=("DeveloperEC2FullAccess" "AnalystS3FullAccess")

# 1. Detach Policies from Groups
echo "Detaching policies from groups..."
for group in "${groups[@]}"; do
    echo "Checking group: $group"
    if aws iam get-group --group-name "$group" >/dev/null 2>&1; then
        attached_policies=$(aws iam list-attached-group-policies --group-name "$group" --query "AttachedPolicies[].PolicyArn" --output text)
        for policy_arn in $attached_policies; do
            aws iam detach-group-policy --group-name "$group" --policy-arn "$policy_arn"
            echo "Detached $policy_arn from $group"
        done
    fi
done

# 2. Delete Custom Policies
echo "Deleting custom policies..."
for policy in "${custom_policies[@]}"; do
    policy_arn="arn:aws:iam::$ACCOUNT_ID:policy/$policy"
    if aws iam get-policy --policy-arn "$policy_arn" >/dev/null 2>&1; then
        # Detach any versions (must delete all non-default versions first)
        versions=$(aws iam list-policy-versions --policy-arn "$policy_arn" --query "Versions[?IsDefaultVersion==\false\].VersionId" --output text)
        for version in $versions; do
            aws iam delete-policy-version --policy-arn "$policy_arn" --version-id "$version"
            echo "Deleted version $version of $policy"
        done
        aws iam delete-policy --policy-arn "$policy_arn"
        echo "Deleted policy: $policy"
    else
        echo "Policy $policy does not exist or already deleted."
    fi
done

# 3. Remove Users from Groups & Delete Login Profiles
echo "Removing users from groups and deleting login profiles..."
all_users=("${dev_users[@]}" "${ops_users[@]}" "${audit_users[@]}")
for user in "${all_users[@]}"; do
    # Remove from groups (if in any)
    for group in "${groups[@]}"; do
        if aws iam get-group --group-name "$group" | grep -q "$user"; then
            aws iam remove-user-from-group --user-name "$user" --group-name "$group"
            echo "Removed $user from $group"
        fi
    done

    # Delete login profile (if exists)
    if aws iam get-login-profile --user-name "$user" >/dev/null 2>&1; then
        aws iam delete-login-profile --user-name "$user"
        echo "Deleted login profile for $user"
    fi
done

# 4. Delete Users
echo "Deleting users..."
for user in "${all_users[@]}"; do
    if aws iam get-user --user-name "$user" >/dev/null 2>&1; then
        aws iam delete-user --user-name "$user"
        echo "Deleted user: $user"
    else
        echo "User $user does not exist."
    fi
done

# 5. Delete Groups
echo "Deleting groups..."
for group in "${groups[@]}"; do
    if aws iam get-group --group-name "$group" >/dev/null 2>&1; then
        aws iam delete-group --group-name "$group"
        echo "Deleted group: $group"
    else
        echo "Group $group does not exist."
    fi
done

echo "✅ IAM Cleanup Completed Successfully!"