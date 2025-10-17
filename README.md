# AWS AI Governance Framework with Policy-as-Code

A comprehensive security and compliance framework for AWS AI/ML systems, implementing automated controls across ISO 27001:2022, ISO 27701:2025, and ISO 42001:2023 standards.

## 🎯 Project Overview

This framework provides automated policy enforcement, security scanning, and compliance monitoring for AWS SageMaker and related AI/ML services. It demonstrates practical implementation of AI governance principles using policy-as-code and infrastructure automation.

**Portfolio Project by AJ Williams** | [ajwill.ai](https://www.ajwill.ai)

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│              AWS AI/ML Environment                          │
│  SageMaker | Bedrock | Comprehend | S3 | IAM               │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│         Policy-as-Code Enforcement (OPA)                    │
│  • Access Control  • Data Governance  • Security            │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│         Python Scanners & Automation                        │
│  • SageMaker  • IAM  • S3  • Risk Scoring                  │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│         Reporting & Compliance Evidence                     │
│  • JSON Reports  • HTML Dashboards  • Audit Trails         │
└─────────────────────────────────────────────────────────────┘
```

## ✨ Features

### Policy-as-Code (OPA/Rego)
- ✅ SageMaker encryption enforcement (A.8.24)
- ✅ Network isolation validation (A.8.20/A.8.21)
- ✅ IAM least privilege checks (A.5.15-A.5.18)
- ✅ Data classification requirements (A.5.12)
- ✅ Threat intelligence integration (A.5.7) - NEW 2022
- ✅ Authentication enforcement (A.5.17) - NEW 2022
- ✅ Data masking for PII (A.8.11) - NEW 2022
- ✅ Secure coding validation (A.8.28) - NEW 2022
- ✅ AI impact assessments (ISO 42001 Clause 6.6)

### Python Security Scanners
- ✅ SageMaker resource scanner
- ✅ IAM role analyzer
- ✅ S3 bucket governance checker
- ✅ Unified reporting engine

### Compliance Coverage
- ✅ **ISO 27001:2022** - Information Security Management (30 controls)
- ✅ **ISO 27701:2025** - Privacy Information Management (22 controls)
- ✅ **ISO 42001:2023** - AI Management System (15 controls)
- ✅ **Total**: 67 controls across 3 frameworks

## 🚀 Quick Start

### Prerequisites

```bash
# AWS CLI configured with credentials
aws configure

# Python 3.11+
python --version

# Install dependencies
pip install -r requirements.txt

# Install OPA (optional, for policy testing)
brew install opa  # macOS
```

### Run Security Scan

```bash
# Run unified scan across all resources
python scan_all.py --region us-east-1

# Run individual scanners
python -m scanners.sagemaker_scanner --region us-east-1
python -m scanners.iam_scanner
python -m scanners.s3_scanner --region us-east-1
```

### Test OPA Policies

```bash
# Test SageMaker encryption policy
opa test policies/ -v

# Evaluate policy against sample data
opa eval -d policies/ -i test_data/sample_notebook.json "data.sagemaker.encryption.deny"
```

## 📁 Project Structure

```
grc_ai_privacy/
├── policies/                      # OPA policy definitions
│   ├── sagemaker_encryption.rego  # Encryption controls (A.8.24)
│   ├── sagemaker_network.rego     # Network security (A.8.20/A.8.21)
│   ├── iam_least_privilege.rego   # Access controls (A.5.15-A.5.18)
│   ├── data_classification.rego   # Data governance (A.5.12)
│   ├── threat_intelligence.rego   # Threat intelligence (A.5.7) - NEW 2022
│   ├── acceptable_use.rego        # Acceptable use (A.5.10) - NEW 2022
│   ├── authentication.rego        # Authentication (A.5.17) - NEW 2022
│   ├── incident_learning.rego     # Learning from incidents (A.5.27) - NEW 2022
│   ├── data_masking.rego          # Data masking (A.8.11) - NEW 2022
│   ├── secure_coding.rego         # Secure coding (A.8.28) - NEW 2022
│   └── ai_impact_assessment.rego  # AI impact assessment (ISO 42001 6.6)
│
├── scanners/                      # Python security scanners
│   ├── sagemaker_scanner.py       # SageMaker resource scanner
│   ├── iam_scanner.py             # IAM role analyzer
│   ├── s3_scanner.py              # S3 bucket checker
│   └── __init__.py
│
├── scan_all.py                    # Unified scanner CLI
├── requirements.txt               # Python dependencies
├── test_syntax.py                 # Syntax validation tests
├── test_structure.py              # Structure validation tests
├── .gitignore                     # Git ignore file
│
├── docs/                          # Documentation
│   ├── ISO_CONTROL_MAPPING.md     # Control overlap analysis
│   ├── 90_DAY_IMPLEMENTATION_PLAN.md  # Implementation timeline
│   └── PROJECT_README.md          # Detailed project docs
│
└── README.md                      # This file
```

## 📊 Sample Output

### Console Output
```
[*] Starting SageMaker security scan in us-east-1
[*] Scanning notebook instances...
[*] Scanning training jobs...
[*] Scanning models...
[*] Scanning endpoints...
[+] Scan complete. Found 12 violations.

============================================================
SAGEMAKER SECURITY SCAN SUMMARY
============================================================
Region: us-east-1
Total Findings: 12

Severity Breakdown:
  CRITICAL: 2
  HIGH:     5
  MEDIUM:   3
  LOW:      2
============================================================
```

### JSON Report
```json
{
  "scan_timestamp": "2025-10-12T20:30:00Z",
  "total_findings": 12,
  "severity_breakdown": {
    "CRITICAL": 2,
    "HIGH": 5,
    "MEDIUM": 3,
    "LOW": 2
  },
  "findings": [
    {
      "resource_type": "AWS::SageMaker::NotebookInstance",
      "resource_name": "ml-notebook-dev",
      "severity": "HIGH",
      "issue": "Notebook instance does not have KMS encryption enabled",
      "control": "ISO 27001:2022 A.8.24 (Cryptography), ISO 27701:2025 6.6.1",
      "remediation": "Enable KMS encryption for the notebook instance"
    }
  ]
}
```

## 🔍 OPA Policy Examples

### SageMaker Encryption Policy
```rego
package sagemaker.encryption

deny[msg] if {
    input.resource_type == "AWS::SageMaker::NotebookInstance"
    not input.kms_key_id
    msg := sprintf(
        "VIOLATION: SageMaker notebook '%s' must have KMS encryption enabled",
        [input.notebook_name]
    )
}
```

### IAM Least Privilege Policy
```rego
package iam.least_privilege

deny[msg] if {
    input.resource_type == "AWS::IAM::Role"
    statement := input.policy_document.Statement[_]
    statement.Action[_] == "*"
    msg := "VIOLATION: Wildcard actions not allowed"
}
```

## 🎓 Skills Demonstrated

### Technical Skills
- **Cloud Security**: AWS IAM, KMS, VPC, Security Hub
- **Policy-as-Code**: Open Policy Agent (OPA), Rego language
- **Python**: boto3, dataclasses, type hints, CLI tools
- **AI/ML Governance**: SageMaker security, model monitoring
- **Data Privacy**: PII detection, data classification, retention

### GRC Frameworks
- **ISO 27001:2022** (3rd edition) - Information Security Management
- **ISO 27701:2025** - Privacy Information Management
- **ISO 42001:2023** - AI Management System
- **NIST AI RMF** - AI Risk Management Framework

### AWS Services
- SageMaker (notebooks, training, models, endpoints)
- IAM (roles, policies, access analysis)
- S3 (encryption, lifecycle, public access)
- KMS (encryption key management)
- CloudTrail (audit logging)

## 📈 Implementation Roadmap

### Phase 1: Foundation (Days 1-30)
- ✅ Core OPA policies for encryption, access control, data governance
- ✅ Python scanners for SageMaker, IAM, S3
- ✅ Automated reporting and evidence collection
- ✅ 30 triple-overlap controls implemented (ISO 27001:2022 updated)

### Phase 2: Advanced Controls (Days 31-60)
- 🔄 Privacy-enhancing technologies (PETs)
- 🔄 Bias detection and fairness metrics
- 🔄 Model monitoring and drift detection
- 🔄 22 double-overlap controls implemented

### Phase 3: Optimization (Days 61-90)
- 📋 Business continuity procedures
- 📋 AI ethics framework
- 📋 Complete documentation and training
- 📋 15 single-standard controls implemented

See [90_DAY_IMPLEMENTATION_PLAN.md](docs/90_DAY_IMPLEMENTATION_PLAN.md) for detailed timeline.

## 🧪 Testing

### Quick Validation (No AWS Required)

```bash
# Validate Python syntax
python3 test_syntax.py

# Validate code structure
python3 test_structure.py
```

### Full Testing (Requires Dependencies)

```bash
# Install dependencies first
pip install -r requirements.txt

# Run Python unit tests (when implemented)
pytest tests/ -v --cov=scanners

# Test OPA policies (requires OPA binary)
opa test policies/ -v

# Run security checks
bandit -r scanners/
safety check
```

## 📚 Documentation

- **[ISO Control Mapping](docs/ISO_CONTROL_MAPPING.md)** - Detailed control overlap analysis
- **[90-Day Implementation Plan](docs/90_DAY_IMPLEMENTATION_PLAN.md)** - Phased deployment timeline
- **[Project README](docs/PROJECT_README.md)** - Comprehensive project documentation

## 🎯 Use Cases

### For Security Teams
- Automated compliance monitoring for AI/ML systems
- Continuous security posture assessment
- Audit-ready evidence collection

### For Data Science Teams
- Pre-deployment security checks
- Model governance and risk scoring
- Privacy-preserving ML workflows

### For GRC Teams
- Multi-framework compliance (ISO 27001/27701/42001)
- Automated control testing
- Executive risk reporting

## 🔐 Security Best Practices

This framework implements:
- ✅ Encryption at rest and in transit
- ✅ Least privilege access control
- ✅ Network isolation for sensitive workloads
- ✅ Data classification and retention policies
- ✅ Audit logging and monitoring
- ✅ Privacy-by-design principles

## 🤝 Contributing

This is a portfolio project demonstrating GRC engineering capabilities. For questions or collaboration:

- **Portfolio**: [ajwill.ai](https://www.ajwill.ai)
- **Email**: [Contact via portfolio]
- **LinkedIn**: [Connect via portfolio]

## 📄 License

© 2025 AJ Williams. Portfolio demonstration project.

## 🙏 Acknowledgments

- AWS Well-Architected Framework - Security Pillar
- Open Policy Agent Community
- ISO Standards Organization (ISO 27001, 27701, 42001)
- NIST AI Risk Management Framework
- Cloud Security Alliance - AI Security Working Group

---

**Built with** ❤️ **for AI Governance and Privacy**

*Demonstrating practical implementation of security, privacy, and AI governance controls for AWS environments.*

---

## 📚 Additional Documentation

Comprehensive documentation has been organized in the `context_files/` directory:

- **Deployment Guides**: `context_files/deployment/`
- **Project Documentation**: `context_files/project_docs/`
- **Security & Cost Analysis**: `context_files/security_analysis/`

See `context_files/README.md` for a complete index.
