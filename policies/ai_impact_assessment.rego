# AI Impact Assessment Policy
# Enforces AI impact assessment requirements
# ISO 27001:2022 Clause 6.1.2, ISO 27701:2025 Clause 5.2, ISO 42001:2023 Clause 6.6

package ai.impact_assessment

import future.keywords.if
import future.keywords.in

# Default deny
default allow = false

# High-risk AI system categories
high_risk_categories := [
    "FACIAL_RECOGNITION",
    "BIOMETRIC_IDENTIFICATION",
    "CRITICAL_INFRASTRUCTURE",
    "EMPLOYMENT_DECISIONS",
    "CREDIT_SCORING",
    "LAW_ENFORCEMENT",
    "HEALTHCARE_DIAGNOSIS"
]

# Deny if high-risk AI system lacks impact assessment
deny[msg] if {
    input.resource_type == "AWS::SageMaker::Model"
    input.ai_category in high_risk_categories
    not input.impact_assessment_completed
    msg := sprintf(
        "VIOLATION: High-risk AI model '%s' (%s) must complete impact assessment. Control: ISO 42001:2023 Clause 6.6 (Impact Assessment for AI Systems)",
        [input.model_name, input.ai_category]
    )
}

# Deny if model processes PII without privacy impact assessment
deny[msg] if {
    input.resource_type == "AWS::SageMaker::Model"
    input.processes_pii
    not input.privacy_impact_assessment
    msg := sprintf(
        "VIOLATION: Model '%s' processing PII must complete privacy impact assessment. Control: ISO 27701:2025 Clause 5.2, ISO 42001:2023 Clause 6.6",
        [input.model_name]
    )
}

# Deny if AI system lacks bias assessment
deny[msg] if {
    input.resource_type == "AWS::SageMaker::Model"
    input.makes_decisions_about_people
    not input.bias_assessment_completed
    msg := sprintf(
        "VIOLATION: Model '%s' making decisions about people must complete bias assessment. Control: ISO 42001:2023 Clause 6.6",
        [input.model_name]
    )
}

# Deny if endpoint deployment lacks risk assessment
deny[msg] if {
    input.resource_type == "AWS::SageMaker::Endpoint"
    input.production_deployment
    not input.deployment_risk_assessment
    msg := sprintf(
        "VIOLATION: Production endpoint '%s' must complete deployment risk assessment. Control: ISO 27001:2022 Clause 6.1.2, ISO 42001:2023 Clause 6.6",
        [input.endpoint_name]
    )
}

# Deny if AI system lacks explainability assessment
deny[msg] if {
    input.resource_type == "AWS::SageMaker::Model"
    input.ai_category in high_risk_categories
    not input.explainability_assessment
    msg := sprintf(
        "VIOLATION: High-risk model '%s' must complete explainability assessment. Control: ISO 42001:2023 Clause 6.6",
        [input.model_name]
    )
}

# Deny if impact assessment is outdated
deny[msg] if {
    input.resource_type == "AWS::SageMaker::Model"
    input.impact_assessment_completed
    input.impact_assessment_age_days > 365
    msg := sprintf(
        "VIOLATION: Impact assessment for model '%s' is outdated (>365 days). Must be reviewed annually. Control: ISO 42001:2023 Clause 6.6",
        [input.model_name]
    )
}

# Deny if stakeholder consultation is not documented
deny[msg] if {
    input.resource_type == "AWS::SageMaker::Model"
    input.ai_category in high_risk_categories
    input.impact_assessment_completed
    not input.stakeholder_consultation_documented
    msg := sprintf(
        "VIOLATION: Impact assessment for high-risk model '%s' must document stakeholder consultation. Control: ISO 42001:2023 Clause 6.6",
        [input.model_name]
    )
}

# Deny if environmental impact is not assessed
deny[msg] if {
    input.resource_type == "AWS::SageMaker::TrainingJob"
    input.large_scale_training
    not input.environmental_impact_assessed
    msg := sprintf(
        "VIOLATION: Large-scale training job '%s' must assess environmental impact. Control: ISO 42001:2023 Clause 6.6",
        [input.training_job_name]
    )
}

# Warn if impact assessment lacks specific risk categories
warn[msg] if {
    input.resource_type == "AWS::SageMaker::Model"
    input.impact_assessment_completed
    not input.impact_assessment_includes_all_categories
    msg := sprintf(
        "WARNING: Impact assessment for model '%s' should cover all risk categories (bias, privacy, security, safety, environmental). Control: ISO 42001:2023 Clause 6.6",
        [input.model_name]
    )
}

# Warn if no monitoring plan after impact assessment
warn[msg] if {
    input.resource_type == "AWS::SageMaker::Model"
    input.impact_assessment_completed
    not input.ongoing_monitoring_plan
    msg := sprintf(
        "WARNING: Model '%s' should have ongoing monitoring plan based on impact assessment. Control: ISO 42001:2023 Clause 6.6",
        [input.model_name]
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
        "level": "CRITICAL",
        "violations": count(deny),
        "controls_affected": [
            "ISO 27001:2022 Clause 6.1.2 (Risk Assessment)",
            "ISO 27701:2025 Clause 5.2 (Privacy Impact Assessment)",
            "ISO 42001:2023 Clause 6.6 (Impact Assessment for AI Systems)"
        ]
    }
}
