# Threat Intelligence Policy
# Enforces threat intelligence requirements for AI/ML systems
# ISO 27001:2022 A.5.7 (Threat Intelligence), ISO 42001:2023 9.2.2

package security.threat_intelligence

import future.keywords.if
import future.keywords.in

# Default deny
default allow = false

# Deny if Security Hub is not enabled
deny[msg] if {
    input.resource_type == "AWS::Account"
    not input.security_hub_enabled
    msg := sprintf(
        "VIOLATION: AWS Security Hub must be enabled for threat intelligence aggregation. Control: ISO 27001:2022 A.5.7 (Threat Intelligence)",
        []
    )
}

# Deny if GuardDuty is not enabled
deny[msg] if {
    input.resource_type == "AWS::Account"
    not input.guardduty_enabled
    msg := sprintf(
        "VIOLATION: AWS GuardDuty must be enabled for ML workload threat detection. Control: ISO 27001:2022 A.5.7 (Threat Intelligence), ISO 42001:2023 9.2.2",
        []
    )
}

# Deny if GuardDuty ML Protection is not enabled
deny[msg] if {
    input.resource_type == "AWS::GuardDuty::Detector"
    input.guardduty_enabled
    not input.ml_protection_enabled
    msg := sprintf(
        "VIOLATION: GuardDuty ML Protection must be enabled for AI/ML threat detection. Control: ISO 27001:2022 A.5.7 (Threat Intelligence)",
        []
    )
}

# Deny SageMaker resources without threat monitoring
deny[msg] if {
    input.resource_type in ["AWS::SageMaker::NotebookInstance", "AWS::SageMaker::Endpoint"]
    not input.cloudwatch_logs_enabled
    msg := sprintf(
        "VIOLATION: SageMaker resource '%s' must have CloudWatch Logs enabled for threat detection. Control: ISO 27001:2022 A.5.7 (Threat Intelligence)",
        [input.resource_name]
    )
}

# Warn if threat intelligence feeds are not configured
warn[msg] if {
    input.resource_type == "AWS::SecurityHub::Hub"
    count(input.threat_intel_feeds) == 0
    msg := sprintf(
        "WARNING: No external threat intelligence feeds configured. Consider integrating threat feeds. Control: ISO 27001:2022 A.5.7 (Threat Intelligence)",
        []
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
            "ISO 27001:2022 A.5.7 (Threat Intelligence)",
            "ISO 42001:2023 9.2.2"
        ]
    }
}
