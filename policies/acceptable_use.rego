# Acceptable Use Policy
# Enforces acceptable use policies for AI data and resources
# ISO 27001:2022 A.5.10 (Acceptable Use), ISO 27701:2025 6.4.1, ISO 42001:2023 6.2.1

package data.acceptable_use

import future.keywords.if
import future.keywords.in

# Default deny
default allow = false

# Deny if S3 bucket lacks acceptable use classification
deny[msg] if {
    input.resource_type == "AWS::S3::Bucket"
    not input.tags.AcceptableUse
    input.tags.DataClassification in ["PII", "SENSITIVE", "CONFIDENTIAL"]
    msg := sprintf(
        "VIOLATION: S3 bucket '%s' with sensitive data must have AcceptableUse tag. Control: ISO 27001:2022 A.5.10 (Acceptable Use), ISO 27701:2025 6.4.1",
        [input.bucket_name]
    )
}

# Deny if training data lacks acceptable use documentation
deny[msg] if {
    input.resource_type == "AWS::SageMaker::TrainingJob"
    not input.acceptable_use_documented
    input.data_classification in ["PII", "SENSITIVE"]
    msg := sprintf(
        "VIOLATION: Training job '%s' using sensitive data must document acceptable use. Control: ISO 27001:2022 A.5.10 (Acceptable Use), ISO 42001:2023 6.2.1",
        [input.training_job_name]
    )
}

# Deny if model lacks acceptable use constraints
deny[msg] if {
    input.resource_type == "AWS::SageMaker::Model"
    not input.tags.AcceptableUse
    not input.model_card.acceptable_use
    msg := sprintf(
        "VIOLATION: Model '%s' must define acceptable use constraints in tags or model card. Control: ISO 27001:2022 A.5.10 (Acceptable Use), ISO 42001:2023 6.2.1",
        [input.model_name]
    )
}

# Deny if endpoint lacks usage restrictions
deny[msg] if {
    input.resource_type == "AWS::SageMaker::Endpoint"
    input.publicly_accessible
    not input.usage_restrictions_documented
    msg := sprintf(
        "VIOLATION: Publicly accessible endpoint '%s' must document usage restrictions. Control: ISO 27001:2022 A.5.10 (Acceptable Use)",
        [input.endpoint_name]
    )
}

# Warn if no acceptable use policy is referenced
warn[msg] if {
    input.resource_type in ["AWS::SageMaker::NotebookInstance", "AWS::SageMaker::Model"]
    not input.tags.AcceptableUsePolicy
    msg := sprintf(
        "WARNING: Resource '%s' should reference an acceptable use policy. Control: ISO 27001:2022 A.5.10 (Acceptable Use)",
        [input.resource_name]
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
            "ISO 27001:2022 A.5.10 (Acceptable Use)",
            "ISO 27701:2025 6.4.1",
            "ISO 42001:2023 6.2.1"
        ]
    }
}
