# Authentication Policy
# Enforces authentication requirements for AI/ML systems
# ISO 27001:2022 A.5.17 (Authentication Information), ISO 27701:2025 6.2.1, ISO 42001:2023 6.1.3

package security.authentication

import future.keywords.if
import future.keywords.in

# Default deny
default allow = false

# Deny if IAM user lacks MFA
deny[msg] if {
    input.resource_type == "AWS::IAM::User"
    input.has_console_access
    not input.mfa_enabled
    msg := sprintf(
        "VIOLATION: IAM user '%s' with console access must have MFA enabled. Control: ISO 27001:2022 A.5.17 (Authentication Information)",
        [input.user_name]
    )
}

# Deny if root account MFA is not enabled
deny[msg] if {
    input.resource_type == "AWS::Account"
    not input.root_mfa_enabled
    msg := sprintf(
        "VIOLATION: Root account must have MFA enabled. Control: ISO 27001:2022 A.5.17 (Authentication Information)",
        []
    )
}

# Deny if SageMaker notebook lacks authentication
deny[msg] if {
    input.resource_type == "AWS::SageMaker::NotebookInstance"
    input.direct_internet_access == "Enabled"
    not input.authentication_mode
    msg := sprintf(
        "VIOLATION: SageMaker notebook '%s' with internet access must enforce authentication. Control: ISO 27001:2022 A.5.17 (Authentication Information)",
        [input.notebook_name]
    )
}

# Deny if API endpoint lacks authentication
deny[msg] if {
    input.resource_type == "AWS::SageMaker::Endpoint"
    not input.requires_authentication
    msg := sprintf(
        "VIOLATION: SageMaker endpoint '%s' must require authentication. Control: ISO 27001:2022 A.5.17 (Authentication Information), ISO 42001:2023 6.1.3",
        [input.endpoint_name]
    )
}

# Deny if password policy is weak
deny[msg] if {
    input.resource_type == "AWS::IAM::AccountPasswordPolicy"
    input.minimum_password_length < 14
    msg := sprintf(
        "VIOLATION: Password policy must require minimum 14 characters. Control: ISO 27001:2022 A.5.17 (Authentication Information)",
        []
    )
}

# Deny if password policy lacks complexity
deny[msg] if {
    input.resource_type == "AWS::IAM::AccountPasswordPolicy"
    not input.require_symbols
    msg := sprintf(
        "VIOLATION: Password policy must require symbols. Control: ISO 27001:2022 A.5.17 (Authentication Information)",
        []
    )
}

# Warn if passwordless authentication is not enabled
warn[msg] if {
    input.resource_type == "AWS::IAM::User"
    input.has_console_access
    not input.supports_passwordless
    msg := sprintf(
        "WARNING: Consider enabling passwordless authentication for user '%s'. Control: ISO 27001:2022 A.5.17 (Authentication Information)",
        [input.user_name]
    )
}

# Allow if no violations
allow if {
    count(deny) == 0
}

# Severity classification
severity[result] if {
    count(deny) > 0
    result := {
        "level": "HIGH",
        "violations": count(deny),
        "controls_affected": [
            "ISO 27001:2022 A.5.17 (Authentication Information)",
            "ISO 27701:2025 6.2.1",
            "ISO 42001:2023 6.1.3"
        ]
    }
}
