#!/bin/bash

# Title: Assign Console Passwords to IAM Users with Proper Permissions
# Author: Omoghene Erubami
# Date: 1 August, 2025
# Purpose: Assign IAM user login profiles and permissions for password reset

echo "Assigning login passwords to IAM users..."

# Define users
dev_users=("John" "Alice")
ops_users=("Mark" "Emma")
audit_users=("Susan")

# Combine all users into a single array
all_users=("${dev_users[@]}" "${ops_users[@]}" "${audit_users[@]}")

# Default password
DEFAULT_PASSWORD="ZappySecure@2025"

# 1. Assign login profiles
for user in "${all_users[@]}"; do
    echo "🔐 Creating login profile for: $user"
    aws iam create-login-profile \
        --user-name "$user" \
        --password "$DEFAULT_PASSWORD" \
        --password-reset-required \
        && echo "✅ Login profile created for $user" \
        || echo "⚠  Could not create login profile for $user (may already exist)"
done

# 2. Attach permission to change password
echo "🔑 Attaching IAMUserChangePassword policy..."
for user in "${all_users[@]}"; do
    aws iam attach-user-policy \
        --user-name "$user" \
        --policy-arn arn:aws:iam::aws:policy/IAMUserChangePassword \
        && echo "✅ Policy attached for $user" \
        || echo "⚠  Could not attach policy for $user"
done

# 3. Set secure password policy for account
echo "📜 Setting account password policy..."
aws iam update-account-password-policy \
    --minimum-password-length 8 \
    --require-symbols \
    --require-numbers \
    --require-uppercase-characters \
    --require-lowercase-characters \
    --allow-users-to-change-password \
    && echo "✅ Password policy configured." \
    || echo "⚠  Failed to configure password policy."

echo "✅ All login profiles and permissions processed."