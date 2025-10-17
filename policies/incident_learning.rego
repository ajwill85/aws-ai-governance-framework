# Incident Learning Policy
# Enforces learning from information security incidents
# ISO 27001:2022 A.5.27 (Learning from Information Security Incidents), ISO 42001:2023 8.4

package security.incident_learning

import future.keywords.if
import future.keywords.in

# Default deny
default allow = false

# Deny if incident response plan lacks post-incident review process
deny[msg] if {
    input.resource_type == "AWS::IncidentManager::ResponsePlan"
    not input.post_incident_analysis_enabled
    msg := sprintf(
        "VIOLATION: Incident response plan '%s' must include post-incident analysis. Control: ISO 27001:2022 A.5.27 (Learning from Information Security Incidents)",
        [input.plan_name]
    )
}

# Deny if CloudWatch alarms lack incident tracking
deny[msg] if {
    input.resource_type == "AWS::CloudWatch::Alarm"
    input.alarm_severity in ["CRITICAL", "HIGH"]
    not input.incident_tracking_enabled
    msg := sprintf(
        "VIOLATION: Critical alarm '%s' must have incident tracking enabled. Control: ISO 27001:2022 A.5.27 (Learning from Information Security Incidents)",
        [input.alarm_name]
    )
}

# Deny if Security Hub findings lack remediation tracking
deny[msg] if {
    input.resource_type == "AWS::SecurityHub::Finding"
    input.severity == "CRITICAL"
    not input.remediation_tracked
    msg := sprintf(
        "VIOLATION: Critical security finding must have remediation tracking. Control: ISO 27001:2022 A.5.27 (Learning from Information Security Incidents)",
        []
    )
}

# Deny if ML model incidents lack root cause analysis
deny[msg] if {
    input.resource_type == "AWS::SageMaker::ModelMonitor::Alert"
    input.alert_type in ["BIAS_DRIFT", "DATA_QUALITY_ISSUE", "MODEL_DRIFT"]
    not input.root_cause_analysis_required
    msg := sprintf(
        "VIOLATION: ML model alert for '%s' must trigger root cause analysis. Control: ISO 27001:2022 A.5.27 (Learning from Information Security Incidents), ISO 42001:2023 8.4",
        [input.model_name]
    )
}

# Deny if incident logs are not retained
deny[msg] if {
    input.resource_type == "AWS::CloudWatch::LogGroup"
    input.log_type == "incident"
    input.retention_days < 365
    msg := sprintf(
        "VIOLATION: Incident logs in '%s' must be retained for at least 365 days. Control: ISO 27001:2022 A.5.27 (Learning from Information Security Incidents)",
        [input.log_group_name]
    )
}

# Warn if no incident review meetings are scheduled
warn[msg] if {
    input.resource_type == "AWS::Account"
    not input.incident_review_schedule
    msg := sprintf(
        "WARNING: No regular incident review meetings scheduled. Control: ISO 27001:2022 A.5.27 (Learning from Information Security Incidents)",
        []
    )
}

# Warn if lessons learned are not documented
warn[msg] if {
    input.resource_type == "AWS::IncidentManager::Incident"
    input.status == "RESOLVED"
    not input.lessons_learned_documented
    msg := sprintf(
        "WARNING: Incident '%s' should document lessons learned. Control: ISO 27001:2022 A.5.27 (Learning from Information Security Incidents)",
        [input.incident_id]
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
        "level": "MEDIUM",
        "violations": count(deny),
        "controls_affected": [
            "ISO 27001:2022 A.5.27 (Learning from Information Security Incidents)",
            "ISO 42001:2023 8.4"
        ]
    }
}
