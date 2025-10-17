# Data Masking Policy
# Enforces data masking requirements for sensitive data
# ISO 27001:2022 A.8.11 (Data Masking), ISO 42001:2023 7.6

package data.masking

import future.keywords.if
import future.keywords.in

# Default deny
default allow = false

# Deny if PII data is not masked in non-production environments
deny[msg] if {
    input.resource_type == "AWS::SageMaker::TrainingJob"
    input.environment in ["dev", "test", "staging"]
    input.data_classification == "PII"
    not input.data_masking_enabled
    msg := sprintf(
        "VIOLATION: Training job '%s' in %s environment must mask PII data. Control: ISO 27001:2022 A.8.11 (Data Masking), ISO 42001:2023 7.6",
        [input.training_job_name, input.environment]
    )
}

# Deny if S3 bucket with PII lacks masking configuration
deny[msg] if {
    input.resource_type == "AWS::S3::Bucket"
    input.tags.DataClassification == "PII"
    input.tags.Environment != "production"
    not input.macie_data_masking_enabled
    msg := sprintf(
        "VIOLATION: S3 bucket '%s' with PII must have data masking enabled. Control: ISO 27001:2022 A.8.11 (Data Masking)",
        [input.bucket_name]
    )
}

# Deny if notebook instance can access unmasked PII
deny[msg] if {
    input.resource_type == "AWS::SageMaker::NotebookInstance"
    input.has_pii_access
    not input.data_masking_enforced
    msg := sprintf(
        "VIOLATION: Notebook instance '%s' with PII access must enforce data masking. Control: ISO 27001:2022 A.8.11 (Data Masking)",
        [input.notebook_name]
    )
}

# Deny if CloudWatch logs contain unmasked sensitive data
deny[msg] if {
    input.resource_type == "AWS::CloudWatch::LogGroup"
    input.contains_pii
    not input.log_masking_enabled
    msg := sprintf(
        "VIOLATION: Log group '%s' containing PII must have log masking enabled. Control: ISO 27001:2022 A.8.11 (Data Masking)",
        [input.log_group_name]
    )
}

# Deny if Glue ETL job doesn't mask PII
deny[msg] if {
    input.resource_type == "AWS::Glue::Job"
    input.processes_pii
    not input.pii_masking_transformation
    msg := sprintf(
        "VIOLATION: Glue job '%s' processing PII must include masking transformation. Control: ISO 27001:2022 A.8.11 (Data Masking), ISO 42001:2023 7.6",
        [input.job_name]
    )
}

# Deny if model training uses unmasked PII without justification
deny[msg] if {
    input.resource_type == "AWS::SageMaker::TrainingJob"
    input.data_classification == "PII"
    not input.data_masking_enabled
    not input.unmasked_pii_justification
    msg := sprintf(
        "VIOLATION: Training job '%s' using unmasked PII must document justification. Control: ISO 27001:2022 A.8.11 (Data Masking), ISO 42001:2023 7.6",
        [input.training_job_name]
    )
}

# Warn if data masking strategy is not documented
warn[msg] if {
    input.resource_type in ["AWS::SageMaker::Model", "AWS::SageMaker::Endpoint"]
    input.handles_pii
    not input.masking_strategy_documented
    msg := sprintf(
        "WARNING: Resource '%s' handling PII should document masking strategy. Control: ISO 27001:2022 A.8.11 (Data Masking)",
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
        "level": "HIGH",
        "violations": count(deny),
        "controls_affected": [
            "ISO 27001:2022 A.8.11 (Data Masking)",
            "ISO 42001:2023 7.6"
        ]
    }
}
