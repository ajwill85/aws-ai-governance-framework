# Secure Coding Policy
# Enforces secure coding requirements for ML code and infrastructure
# ISO 27001:2022 A.8.28 (Secure Coding), ISO 42001:2023 6.3.4

package development.secure_coding

import future.keywords.if
import future.keywords.in

# Default deny
default allow = false

# Deny if ML code repository lacks security scanning
deny[msg] if {
    input.resource_type == "AWS::CodeCommit::Repository"
    input.contains_ml_code
    not input.security_scanning_enabled
    msg := sprintf(
        "VIOLATION: ML code repository '%s' must have security scanning enabled. Control: ISO 27001:2022 A.8.28 (Secure Coding), ISO 42001:2023 6.3.4",
        [input.repository_name]
    )
}

# Deny if SageMaker container lacks vulnerability scanning
deny[msg] if {
    input.resource_type == "AWS::ECR::Repository"
    input.used_for_sagemaker
    not input.scan_on_push
    msg := sprintf(
        "VIOLATION: ECR repository '%s' for SageMaker must scan on push. Control: ISO 27001:2022 A.8.28 (Secure Coding)",
        [input.repository_name]
    )
}

# Deny if training script lacks input validation
deny[msg] if {
    input.resource_type == "AWS::SageMaker::TrainingJob"
    input.custom_training_script
    not input.input_validation_implemented
    msg := sprintf(
        "VIOLATION: Training job '%s' with custom script must implement input validation. Control: ISO 27001:2022 A.8.28 (Secure Coding), ISO 42001:2023 6.3.4",
        [input.training_job_name]
    )
}

# Deny if Lambda function for ML lacks security review
deny[msg] if {
    input.resource_type == "AWS::Lambda::Function"
    input.ml_related
    not input.security_review_completed
    msg := sprintf(
        "VIOLATION: ML-related Lambda function '%s' must complete security review. Control: ISO 27001:2022 A.8.28 (Secure Coding)",
        [input.function_name]
    )
}

# Deny if dependencies have known vulnerabilities
deny[msg] if {
    input.resource_type == "AWS::SageMaker::NotebookInstance"
    count(input.vulnerable_dependencies) > 0
    msg := sprintf(
        "VIOLATION: Notebook instance '%s' has %d vulnerable dependencies. Control: ISO 27001:2022 A.8.28 (Secure Coding)",
        [input.notebook_name, count(input.vulnerable_dependencies)]
    )
}

# Deny if ML model code lacks SAST scanning
deny[msg] if {
    input.resource_type == "AWS::SageMaker::Model"
    input.custom_inference_code
    not input.sast_scan_completed
    msg := sprintf(
        "VIOLATION: Model '%s' with custom inference code must complete SAST scanning. Control: ISO 27001:2022 A.8.28 (Secure Coding), ISO 42001:2023 6.3.4",
        [input.model_name]
    )
}

# Deny if API endpoint lacks input sanitization
deny[msg] if {
    input.resource_type == "AWS::SageMaker::Endpoint"
    not input.input_sanitization_enabled
    msg := sprintf(
        "VIOLATION: Endpoint '%s' must implement input sanitization. Control: ISO 27001:2022 A.8.28 (Secure Coding)",
        [input.endpoint_name]
    )
}

# Deny if hardcoded credentials are detected
deny[msg] if {
    input.resource_type in ["AWS::SageMaker::NotebookInstance", "AWS::Lambda::Function"]
    input.hardcoded_credentials_detected
    msg := sprintf(
        "VIOLATION: Resource '%s' contains hardcoded credentials. Control: ISO 27001:2022 A.8.28 (Secure Coding)",
        [input.resource_name]
    )
}

# Warn if code review is not enforced
warn[msg] if {
    input.resource_type == "AWS::CodeCommit::Repository"
    input.contains_ml_code
    not input.code_review_required
    msg := sprintf(
        "WARNING: Repository '%s' should require code review for ML code. Control: ISO 27001:2022 A.8.28 (Secure Coding)",
        [input.repository_name]
    )
}

# Warn if DAST is not performed
warn[msg] if {
    input.resource_type == "AWS::SageMaker::Endpoint"
    not input.dast_testing_performed
    msg := sprintf(
        "WARNING: Endpoint '%s' should undergo DAST testing. Control: ISO 27001:2022 A.8.28 (Secure Coding)",
        [input.endpoint_name]
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
            "ISO 27001:2022 A.8.28 (Secure Coding)",
            "ISO 42001:2023 6.3.4"
        ]
    }
}
