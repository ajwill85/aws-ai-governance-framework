# ISO Control Mapping: 27001, 27701, and 42001
## AWS AI Governance Framework - Control Overlap Analysis (UPDATED)

**Project**: AWS AI Governance Framework with Policy-as-Code  
**Author**: AJ Williams  
**Date**: October 2025 (Updated October 16, 2025)  
**Purpose**: Identify and prioritize overlapping controls across ISO 27001:2022, 27701:2025, and 42001:2023

**Version**: 2.0 - Updated for ISO 27001:2022 (3rd edition)

---

## Executive Summary

This document maps overlapping controls across three critical ISO standards for AI governance and privacy:
- **ISO/IEC 27001:2022** - Information Security Management (93 controls, 4 themes)
- **ISO/IEC 27701:2025** - Privacy Information Management (extension of 27001)
- **ISO/IEC 42001:2023** - AI Management System

**Key Update**: This version reflects the **ISO 27001:2022 (3rd edition)** control structure, which significantly changed from the 2013 version. The 2022 edition reorganized 114 controls into 93 controls across 4 themes instead of 14 domains.

The phased approach prioritizes controls with maximum overlap (all 3 standards) in Phase 1, progressing to standard-specific controls in later phases.

---

## Phase 1: Triple-Overlap Controls (All 3 Standards)
**Priority**: CRITICAL | **Timeline**: Days 1-30

These controls appear across all three standards and form the foundation of the AI governance framework.

### 1. Access Control & Identity Management

| Control Area | ISO 27001:2022 | ISO 27701:2025 | ISO 42001:2023 | Implementation |
|--------------|----------------|----------------|----------------|----------------|
| **Access Control** | **A.5.15** | 6.2.1, 6.3.1 | 5.2, 6.1.3 | AWS IAM policies, SageMaker role validation |
| **Identity Management** | **A.5.16** | 6.2.1 | 6.1.3 | IAM Identity Center, federated access |
| **Authentication** | **A.5.17** | 6.2.1 | 6.1.3 | MFA enforcement, passwordless auth |
| **Access Rights** | **A.5.18** | 6.2.2, 6.2.3 | 6.1.3, 6.1.4 | Least privilege enforcement, quarterly reviews |

**Technical Implementation**:
- OPA policies enforcing least privilege for SageMaker roles
- Lambda function for automated IAM role analysis
- CloudTrail monitoring for privileged access to AI systems
- IAM Access Analyzer for continuous access validation

**2022 Update**: Consolidated and clarified access control requirements. A.5.16 (Identity management) and A.5.17 (Authentication) are new explicit controls.

---

### 2. Data Governance & Classification

| Control Area | ISO 27001:2022 | ISO 27701:2025 | ISO 42001:2023 | Implementation |
|--------------|----------------|----------------|----------------|----------------|
| **Acceptable Use** | **A.5.10** | 6.4.1 | 6.2.1 | Acceptable use policies for AI data |
| **Information Classification** | **A.5.12** | 6.4.1, 6.5.1 | 6.2.1 | S3 bucket tagging, Glue Data Catalog |
| **Data Minimization** | **A.5.34** | 6.4.2 | 6.2.2 | Policy checks on training data scope |
| **Data Retention** | **A.5.34** | 6.4.3, 6.5.3 | 6.2.3 | S3 lifecycle policies, automated deletion |
| **Data Quality** | **A.8.24** | 6.4.4 | **6.2.4, 7.7** | Data validation in ML pipelines |
| **Data for AI Systems** | - | - | **7.6** | Training data governance |
| **Data Governance** | - | - | **7.8** | End-to-end data lineage |

**Technical Implementation**:
- Automated data classification using AWS Macie
- OPA policies enforcing data minimization principles
- S3 lifecycle rules based on data classification
- Data quality checks in SageMaker Processing jobs
- SageMaker Feature Store for data governance

**2022 Update**: A.5.10 (Acceptable use) and A.5.12 (Classification) are now separate controls. Added explicit ISO 42001 data governance controls.

---

### 3. Risk Management

| Control Area | ISO 27001:2022 | ISO 27701:2025 | ISO 42001:2023 | Implementation |
|--------------|----------------|----------------|----------------|----------------|
| **Risk Assessment** | **Clause 6.1.2** | Clause 5.2 | **6.1.1, 6.1.2** | AI system risk scoring framework |
| **Risk Treatment** | **Clause 6.1.3** | Clause 5.3 | **6.1.5** | Automated control recommendations |
| **Risk Monitoring** | **Clause 9.1** | Clause 9.1 | **6.1.6, 9.1** | CloudWatch dashboards, EventBridge |
| **AI Impact Assessment** | **Clause 6.1.2** | Clause 5.2 | **6.6** | AI-specific impact assessments |

**Technical Implementation**:
- Python risk assessment engine for AI models
- Risk scoring based on data sensitivity + model complexity + AI-specific risks
- Automated alerts for high-risk deployments
- **SageMaker Clarify for bias and explainability assessments**
- **Amazon A2I for human review workflows**

**2022 Update**: Added ISO 42001 Clause 6.6 (Impact assessment for AI systems) - a critical control that was missing in the original mapping.

---

### 4. Security Controls for AI/ML Systems

| Control Area | ISO 27001:2022 | ISO 27701:2025 | ISO 42001:2023 | Implementation |
|--------------|----------------|----------------|----------------|----------------|
| **Cryptography** | **A.8.24** | 6.6.1 | 6.3.1 | KMS encryption for data/models |
| **Networks Security** | **A.8.20, A.8.21** | 6.6.2 | 6.3.2 | VPC isolation for SageMaker |
| **Secure Configuration** | **A.8.9** | 6.6.3 | 6.3.3 | Hardened SageMaker configurations |
| **Logging** | **A.8.15** | 6.6.3, 6.7.1 | 6.3.3, 9.2 | CloudTrail, CloudWatch Logs |
| **Monitoring** | **A.8.16** | 6.7.1 | 9.2, 9.2.2 | CloudWatch, SageMaker Model Monitor |
| **Vulnerability Management** | **A.8.8** | 6.6.4 | 6.3.4 | Container scanning, dependency checks |
| **Secure Coding** | **A.8.28** | - | 6.3.4 | SAST/DAST for ML code |
| **Web Filtering** | **A.8.23** | - | - | VPC endpoint policies, AWS WAF |

**Technical Implementation**:
- OPA policies requiring encryption at rest/transit
- Security group validation for SageMaker endpoints
- Automated vulnerability scanning for ML containers (ECR scanning)
- Centralized logging to CloudWatch Logs
- **SageMaker Model Monitor for continuous monitoring**
- **AWS Security Hub for centralized security findings**

**2022 Update**: A.8.15 (Logging) and A.8.16 (Monitoring) are now separate controls. Added A.8.28 (Secure coding) and A.8.23 (Web filtering) as new 2022 controls.

---

### 5. Documentation & Transparency

| Control Area | ISO 27001:2022 | ISO 27701:2025 | ISO 42001:2023 | Implementation |
|--------------|----------------|----------------|----------------|----------------|
| **Documented Procedures** | **A.5.37** | 6.8.1 | 7.2, 7.4 | Model cards, data lineage tracking |
| **Change Management** | **A.8.32** | 6.8.2 | 7.5 | GitOps for model versioning |
| **Audit Logging** | **A.8.15** | 6.7.1, 6.7.2 | 9.2.1 | Immutable logs in CloudWatch |
| **Transparency** | - | - | **7.9** | Model explainability documentation |
| **Explainability** | - | 6.13.2 | **7.10** | SageMaker Clarify integration |

**Technical Implementation**:
- Automated model card generation
- SageMaker Model Registry for versioning
- S3 versioning for training data
- CloudTrail for complete audit trail
- **SageMaker Clarify for explainability reports**
- **Model lineage tracking in SageMaker**

**2022 Update**: Added explicit transparency and explainability requirements from ISO 42001.

---

### 6. Incident Management

| Control Area | ISO 27001:2022 | ISO 27701:2025 | ISO 42001:2023 | Implementation |
|--------------|----------------|----------------|----------------|----------------|
| **Incident Response** | **A.5.24, A.5.25** | 6.9.1 | 8.1, 8.2 | Automated incident detection |
| **Breach Notification** | **A.5.26** | 6.9.2 | 8.3 | SNS notifications, runbooks |
| **Learning from Incidents** | **A.5.27** | - | 8.4 | Post-incident reviews |

**Technical Implementation**:
- EventBridge rules for anomaly detection
- Lambda functions for automated response
- SNS/PagerDuty integration for alerts
- **GuardDuty for ML-specific threat detection**
- **Automated incident response playbooks**

**2022 Update**: A.5.27 (Learning from information security incidents) is a new control in 2022.

---

### 7. Threat Intelligence (NEW in 2022)

| Control Area | ISO 27001:2022 | ISO 27701:2025 | ISO 42001:2023 | Implementation |
|--------------|----------------|----------------|----------------|----------------|
| **Threat Intelligence** | **A.5.7** | - | 9.2.2 | Security Hub, GuardDuty integration |

**Technical Implementation**:
- AWS Security Hub for threat intelligence aggregation
- GuardDuty for ML workload protection
- Integration with external threat feeds
- **ML-specific threat intelligence (adversarial attacks, model theft)**

**2022 Update**: A.5.7 is a new control in ISO 27001:2022 focusing on threat intelligence.

---

## Phase 2: Double-Overlap Controls (2 of 3 Standards)
**Priority**: HIGH | **Timeline**: Days 31-60

### 2A. ISO 27001 + 27701 (Privacy & Security)

| Control Area | ISO 27001:2022 | ISO 27701:2025 | Implementation |
|--------------|----------------|----------------|----------------|
| **Privacy by Design** | **A.5.34** | 6.10.1-6.10.3 | Privacy-enhancing technologies (PETs) |
| **Data Subject Rights** | **A.5.34** | 6.11.1-6.11.5 | Automated data deletion workflows |
| **Third-Party Management** | **A.5.19-A.5.23** | 6.12.1-6.12.3 | Vendor risk assessments |
| **Information Security Policies** | **A.5.1** | 6.1.1 | Comprehensive policy framework |
| **Roles and Responsibilities** | **A.5.2** | 6.1.2 | RACI matrix for AI governance |

**Technical Implementation**:
- Differential privacy for analytics
- Data anonymization pipelines
- Third-party API security scanning
- **AWS Lake Formation for fine-grained access control**
- **Automated data subject request handling**

---

### 2B. ISO 27001 + 42001 (Security & AI)

| Control Area | ISO 27001:2022 | ISO 42001:2023 | Implementation |
|--------------|----------------|----------------|----------------|
| **Model Security** | **A.8.24** | 6.4.1-6.4.3 | Model encryption, adversarial testing |
| **Training Environment Security** | **A.8.1-A.8.3** | 6.5.1 | Isolated training environments |
| **Continuous Monitoring** | **A.8.16** | 9.2.2 | Model drift detection |
| **Deletion of Information** | **A.8.10** | 6.2.3 | Secure model and data deletion |
| **Data Masking** | **A.8.11** | 7.6 | PII masking in training data |

**Technical Implementation**:
- SageMaker Model Monitor for drift
- Adversarial robustness testing
- Secure training job configurations
- **VPC isolation for training jobs**
- **Encrypted model artifacts in S3**

**2022 Update**: A.8.10 (Deletion of information) and A.8.11 (Data masking) are new controls in 2022.

---

### 2C. ISO 27701 + 42001 (Privacy & AI)

| Control Area | ISO 27701:2025 | ISO 42001:2023 | Implementation |
|--------------|----------------|----------------|----------------|
| **Automated Decision-Making** | 6.13.1 | 7.6, 7.7 | Bias detection in training data |
| **Explainability** | 6.13.2 | 7.10 | SageMaker Clarify integration |
| **Human Oversight** | 6.13.3 | 7.9, 7.11 | Human-in-the-loop workflows |
| **Fairness Testing** | - | 7.6, 7.7 | Automated fairness metrics |
| **AI Ethics** | - | 7.11-7.13 | Ethics review board |

**Technical Implementation**:
- Automated bias metrics calculation
- SageMaker Clarify for explainability
- Step Functions for approval workflows
- **Amazon A2I for human review**
- **Fairness testing in CI/CD pipeline**

---

## Phase 3: Single-Standard Controls
**Priority**: MEDIUM | **Timeline**: Days 61-90

### 3A. ISO 27001:2022 Only

| Control Area | Control | Implementation |
|--------------|---------|----------------|
| **Physical Security** | A.7.1-A.7.14 | AWS data center compliance |
| **Business Continuity** | A.5.29-A.5.30 | Multi-region DR strategy |
| **Supplier Security** | A.5.19-A.5.23 | Vendor risk assessments |
| **Capacity Management** | A.8.6 | Auto-scaling for SageMaker |
| **Configuration Management** | A.8.9 | AWS Config for compliance |
| **Information Backup** | A.8.13 | Automated S3 backups |
| **Redundancy** | A.8.14 | Multi-AZ deployments |

---

### 3B. ISO 27701:2025 Only

| Control Area | Control | Implementation |
|--------------|---------|----------------|
| **Privacy Notices** | 6.14.1-6.14.3 | Automated privacy notice generation |
| **Consent Management** | 6.15.1-6.15.2 | Consent tracking system |
| **Cross-Border Transfers** | 6.16.1-6.16.3 | Data residency controls |
| **Records of Processing** | 6.17.1 | Automated processing records |

---

### 3C. ISO 42001:2023 Only

| Control Area | Control | Implementation |
|--------------|---------|----------------|
| **AI Ethics Framework** | 7.11-7.13 | Ethics review board, principles |
| **Stakeholder Engagement** | 5.3 | Stakeholder consultation process |
| **AI System Lifecycle** | 6.7.1-6.7.5 | MLOps pipeline with governance |
| **Continual Learning** | 7.14 | Model retraining workflows |
| **AI System Retirement** | 6.7.5 | Decommissioning procedures |

---

## Control Implementation Priority Matrix

```
┌─────────────────────────────────────────────────────────────────────┐
│  OVERLAP LEVEL  │  # CONTROLS  │  PHASE  │  DAYS  │  EFFORT │  NEW  │
├─────────────────────────────────────────────────────────────────────┤
│  Triple (3/3)   │     30       │    1    │  1-30  │  60%    │  +5   │
│  Double (2/3)   │     22       │    2    │ 31-60  │  30%    │  +4   │
│  Single (1/3)   │     15       │    3    │ 61-90  │  10%    │  +3   │
└─────────────────────────────────────────────────────────────────────┘

Total: 67 controls (was 55 in original mapping)
```

---

## Technical Architecture Summary

### Core Components
1. **Policy Engine**: Open Policy Agent (OPA) for policy-as-code
2. **Scanning Engine**: Python + boto3 for AWS resource analysis
3. **Automation Layer**: Lambda + EventBridge for continuous monitoring
4. **Reporting Layer**: CloudWatch Dashboards + S3 for evidence collection
5. **Integration Layer**: APIs for Jira, Slack, and audit tools
6. **ML Governance**: SageMaker Model Registry, Clarify, Model Monitor

### AWS Services Used

#### AI/ML Services
- **SageMaker**: Training, hosting, monitoring, explainability
- **Bedrock**: Foundation model governance
- **Comprehend**: NLP compliance checks
- **A2I**: Human review workflows

#### Security Services
- **IAM**: Access control, identity management
- **KMS**: Encryption key management
- **Security Hub**: Centralized security findings
- **Macie**: Data classification and protection
- **GuardDuty**: Threat detection for ML workloads
- **Inspector**: Vulnerability scanning

#### Governance Services
- **Config**: Configuration compliance
- **CloudTrail**: Audit logging
- **Organizations**: Multi-account governance
- **Control Tower**: Guardrails and compliance

#### Data Services
- **S3**: Data storage with encryption and lifecycle
- **Glue**: Data catalog and ETL
- **Lake Formation**: Fine-grained access control
- **Athena**: Compliance reporting queries

#### Automation Services
- **Lambda**: Serverless automation
- **EventBridge**: Event-driven workflows
- **Step Functions**: Orchestration and approval workflows
- **Systems Manager**: Configuration management

---

## Control Evidence Mapping

### For Audit Purposes

| Control Category | Evidence Type | AWS Service | Automation |
|-----------------|---------------|-------------|------------|
| **Access Control** | IAM policies, access logs | IAM, CloudTrail | AWS Config rules |
| **Encryption** | KMS key policies, encryption status | KMS, S3, SageMaker | Config rules, Lambda |
| **Logging** | Log retention, integrity | CloudTrail, CloudWatch | S3 lifecycle, Lambda |
| **Monitoring** | Dashboards, alerts | CloudWatch, Security Hub | EventBridge rules |
| **Risk Assessment** | Risk reports, impact assessments | SageMaker Clarify | Automated reporting |
| **Incident Response** | Incident logs, response times | Security Hub, SNS | Lambda functions |
| **Data Governance** | Data lineage, classification | Glue, Macie, SageMaker | Automated tagging |
| **Model Governance** | Model cards, versions, metrics | SageMaker Registry | CI/CD pipeline |

---

## Success Metrics

### Phase 1 (Days 1-30)
- ✅ 30 triple-overlap controls implemented (up from 25)
- ✅ 100% of SageMaker resources scanned
- ✅ Automated policy enforcement active
- ✅ Compliance dashboard operational
- ✅ AI impact assessments integrated

### Phase 2 (Days 31-60)
- ✅ 22 double-overlap controls implemented (up from 18)
- ✅ Privacy-enhancing technologies deployed
- ✅ Bias detection integrated
- ✅ Third-party risk assessments automated
- ✅ Model explainability operational

### Phase 3 (Days 61-90)
- ✅ 15 single-standard controls implemented (up from 12)
- ✅ Full audit trail capability
- ✅ Incident response playbooks tested
- ✅ Complete documentation published
- ✅ AI ethics framework established

---

## Key Changes from Version 1.0

### ISO 27001:2022 Updates
1. ✅ Updated all Annex A control references to 2022 numbering
2. ✅ Added new 2022 controls (A.5.7, A.5.16, A.5.17, A.8.11, A.8.23, A.8.28)
3. ✅ Separated A.8.15 (Logging) and A.8.16 (Monitoring) as distinct controls
4. ✅ Updated control descriptions to match 2022 terminology

### ISO 42001:2023 Enhancements
1. ✅ Added Clause 6.6 (Impact assessment for AI systems) - critical missing control
2. ✅ Expanded data governance controls (7.6, 7.7, 7.8)
3. ✅ Added transparency and explainability controls (7.9, 7.10)
4. ✅ Included AI ethics and lifecycle management controls

### ISO 27701:2025 Clarifications
1. ✅ Clarified "Automated decision-making" vs "Fairness & Bias"
2. ✅ Updated to 2025 edition references
3. ✅ Added explicit privacy-by-design controls

### Overall Improvements
1. ✅ Increased total controls from 55 to 67
2. ✅ Added control evidence mapping for audits
3. ✅ Enhanced AWS service mappings
4. ✅ Added ML-specific governance tools (Clarify, Model Monitor, A2I)

---

## References

- ISO/IEC 27001:2022 (3rd edition) - Information security, cybersecurity and privacy protection
- ISO/IEC 27001:2022/Amd 1:2024 - Amendment 1
- ISO/IEC 27701:2025 - Privacy information management systems
- ISO/IEC 42001:2023 - Artificial intelligence management system
- AWS Well-Architected Framework - Security Pillar
- AWS Well-Architected Framework - Machine Learning Lens
- NIST AI Risk Management Framework (AI RMF)
- EU AI Act compliance considerations

---

**Document Version**: 2.0  
**Last Updated**: October 16, 2025  
**Previous Version**: 1.0 (October 2025)  
**Next Review**: Phase 1 Completion (Day 30)  
**Changes**: Updated for ISO 27001:2022, added ISO 42001 Clause 6.6, enhanced AWS mappings
