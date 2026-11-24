PRAGMA foreign_keys = ON;

-- Provision virtual member identities and role assignments.
-- All members start as pending; this does not claim live operational activation.
INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-gm', 'General Manager (GM)', 'virtual.gm@members.invalid', 'virtual', 'dept-executive-leadership', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-gm', 'member-virtual-gm', 'role-gm', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-coo', 'Chief Operating Officer (COO)', 'virtual.coo@members.invalid', 'virtual', 'dept-executive-leadership', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-coo', 'member-virtual-coo', 'role-coo', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-cto', 'Chief Technology Officer (CTO)', 'virtual.cto@members.invalid', 'virtual', 'dept-executive-leadership', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-cto', 'member-virtual-cto', 'role-cto', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-cfo', 'Chief Financial Officer (CFO)', 'virtual.cfo@members.invalid', 'virtual', 'dept-executive-leadership', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-cfo', 'member-virtual-cfo', 'role-cfo', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-hr-manager', 'HR Manager', 'virtual.hr-manager@members.invalid', 'virtual', 'dept-human-resources-administration', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-hr-manager', 'member-virtual-hr-manager', 'role-hr-manager', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-recruitment-coordinator', 'Recruitment & Organization Coordinator', 'virtual.recruitment-coordinator@members.invalid', 'virtual', 'dept-human-resources-administration', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-recruitment-coordinator', 'member-virtual-recruitment-coordinator', 'role-recruitment-coordinator', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-head-pmo', 'Head of PMO / Project Manager', 'virtual.head-pmo@members.invalid', 'virtual', 'dept-project-management-business-analysis', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-head-pmo', 'member-virtual-head-pmo', 'role-head-pmo', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-business-analyst', 'Business Analyst', 'virtual.business-analyst@members.invalid', 'virtual', 'dept-project-management-business-analysis', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-business-analyst', 'member-virtual-business-analyst', 'role-business-analyst', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-project-coordinator', 'Project Coordinator', 'virtual.project-coordinator@members.invalid', 'virtual', 'dept-project-management-business-analysis', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-project-coordinator', 'member-virtual-project-coordinator', 'role-project-coordinator', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-solution-architect', 'Solution Architect', 'virtual.solution-architect@members.invalid', 'virtual', 'dept-technology-engineering', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-solution-architect', 'member-virtual-solution-architect', 'role-solution-architect', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-lead-developer', 'Lead Developer / Engineering Lead', 'virtual.lead-developer@members.invalid', 'virtual', 'dept-technology-engineering', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-lead-developer', 'member-virtual-lead-developer', 'role-lead-developer', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-backend-developer-01', 'Backend Developer 01', 'virtual.backend-developer-01@members.invalid', 'virtual', 'dept-technology-engineering', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-backend-developer-01', 'member-virtual-backend-developer-01', 'role-backend-developer-01', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-backend-developer-02', 'Backend Developer 02', 'virtual.backend-developer-02@members.invalid', 'virtual', 'dept-technology-engineering', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-backend-developer-02', 'member-virtual-backend-developer-02', 'role-backend-developer-02', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-frontend-developer-01', 'Frontend Developer 01', 'virtual.frontend-developer-01@members.invalid', 'virtual', 'dept-technology-engineering', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-frontend-developer-01', 'member-virtual-frontend-developer-01', 'role-frontend-developer-01', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-frontend-developer-02', 'Frontend Developer 02', 'virtual.frontend-developer-02@members.invalid', 'virtual', 'dept-technology-engineering', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-frontend-developer-02', 'member-virtual-frontend-developer-02', 'role-frontend-developer-02', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-mobile-developer', 'Mobile Application Developer', 'virtual.mobile-developer@members.invalid', 'virtual', 'dept-technology-engineering', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-mobile-developer', 'member-virtual-mobile-developer', 'role-mobile-developer', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-database-engineer', 'Database Engineer', 'virtual.database-engineer@members.invalid', 'virtual', 'dept-technology-engineering', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-database-engineer', 'member-virtual-database-engineer', 'role-database-engineer', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-devops-engineer', 'DevOps Engineer', 'virtual.devops-engineer@members.invalid', 'virtual', 'dept-technology-engineering', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-devops-engineer', 'member-virtual-devops-engineer', 'role-devops-engineer', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-cloud-engineer', 'Cloud Engineer', 'virtual.cloud-engineer@members.invalid', 'virtual', 'dept-technology-engineering', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-cloud-engineer', 'member-virtual-cloud-engineer', 'role-cloud-engineer', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-ui-ux-designer', 'UI/UX Designer', 'virtual.ui-ux-designer@members.invalid', 'virtual', 'dept-technology-engineering', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-ui-ux-designer', 'member-virtual-ui-ux-designer', 'role-ui-ux-designer', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-head-ict', 'Head of ICT / Network Engineer', 'virtual.head-ict@members.invalid', 'virtual', 'dept-ict-infrastructure', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-head-ict', 'member-virtual-head-ict', 'role-head-ict', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-systems-engineer', 'Systems & Infrastructure Engineer', 'virtual.systems-engineer@members.invalid', 'virtual', 'dept-ict-infrastructure', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-systems-engineer', 'member-virtual-systems-engineer', 'role-systems-engineer', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-head-product', 'Head of Product', 'virtual.head-product@members.invalid', 'virtual', 'dept-product-management', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-head-product', 'member-virtual-head-product', 'role-head-product', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-product-analyst', 'Product Analyst', 'virtual.product-analyst@members.invalid', 'virtual', 'dept-product-management', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-product-analyst', 'member-virtual-product-analyst', 'role-product-analyst', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-qa-manager', 'Head of QA / QA Manager', 'virtual.qa-manager@members.invalid', 'virtual', 'dept-quality-assurance-testing', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-qa-manager', 'member-virtual-qa-manager', 'role-qa-manager', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-qa-engineer-01', 'QA Engineer 01', 'virtual.qa-engineer-01@members.invalid', 'virtual', 'dept-quality-assurance-testing', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-qa-engineer-01', 'member-virtual-qa-engineer-01', 'role-qa-engineer-01', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-qa-engineer-02', 'QA Engineer 02', 'virtual.qa-engineer-02@members.invalid', 'virtual', 'dept-quality-assurance-testing', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-qa-engineer-02', 'member-virtual-qa-engineer-02', 'role-qa-engineer-02', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-uat-functional', 'UAT 01 — Functional Testing', 'virtual.uat-functional@members.invalid', 'virtual', 'dept-quality-assurance-testing', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-uat-functional', 'member-virtual-uat-functional', 'role-uat-functional', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-uat-integration', 'UAT 02 — Integration Testing', 'virtual.uat-integration@members.invalid', 'virtual', 'dept-quality-assurance-testing', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-uat-integration', 'member-virtual-uat-integration', 'role-uat-integration', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-uat-regression', 'UAT 03 — Regression & Acceptance', 'virtual.uat-regression@members.invalid', 'virtual', 'dept-quality-assurance-testing', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-uat-regression', 'member-virtual-uat-regression', 'role-uat-regression', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-head-security', 'Head of Cybersecurity / Security Engineer', 'virtual.head-security@members.invalid', 'virtual', 'dept-cybersecurity-governance', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-head-security', 'member-virtual-head-security', 'role-head-security', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-security-privacy-analyst', 'Security & Privacy Analyst', 'virtual.security-privacy-analyst@members.invalid', 'virtual', 'dept-cybersecurity-governance', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-security-privacy-analyst', 'member-virtual-security-privacy-analyst', 'role-security-privacy-analyst', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-risk-compliance', 'Risk & Compliance Coordinator', 'virtual.risk-compliance@members.invalid', 'virtual', 'dept-cybersecurity-governance', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-risk-compliance', 'member-virtual-risk-compliance', 'role-risk-compliance', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-legal-advisor', 'Virtual AI Legal Advisor', 'virtual.legal-advisor@members.invalid', 'virtual', 'dept-legal-compliance', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-legal-advisor', 'member-virtual-legal-advisor', 'role-legal-advisor', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-release-manager', 'Release Manager', 'virtual.release-manager@members.invalid', 'virtual', 'dept-release-service-operations', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-release-manager', 'member-virtual-release-manager', 'role-release-manager', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-operations-coordinator', 'Operations Coordinator', 'virtual.operations-coordinator@members.invalid', 'virtual', 'dept-release-service-operations', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-operations-coordinator', 'member-virtual-operations-coordinator', 'role-operations-coordinator', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-support-manager', 'Support Manager', 'virtual.support-manager@members.invalid', 'virtual', 'dept-release-service-operations', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-support-manager', 'member-virtual-support-manager', 'role-support-manager', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-application-support', 'Application Support Specialist', 'virtual.application-support@members.invalid', 'virtual', 'dept-release-service-operations', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-application-support', 'member-virtual-application-support', 'role-application-support', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-customer-support', 'Customer Support Specialist', 'virtual.customer-support@members.invalid', 'virtual', 'dept-release-service-operations', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-customer-support', 'member-virtual-customer-support', 'role-customer-support', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-technical-writer', 'Technical Writer / Documentation Officer', 'virtual.technical-writer@members.invalid', 'virtual', 'dept-documentation-knowledge-management', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-technical-writer', 'member-virtual-technical-writer', 'role-technical-writer', 'company', NULL, NULL);

INSERT OR IGNORE INTO people (id, display_name, email, person_type, department_id, status)
VALUES ('member-virtual-knowledge-coordinator', 'Knowledge Base Coordinator', 'virtual.knowledge-coordinator@members.invalid', 'virtual', 'dept-documentation-knowledge-management', 'pending');

INSERT OR IGNORE INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by)
VALUES ('assignment-virtual-knowledge-coordinator', 'member-virtual-knowledge-coordinator', 'role-knowledge-coordinator', 'company', NULL, NULL);

-- Explicitly keep the Legal Advisor pending until CMD deployment and onboarding checks.
UPDATE people SET status = 'pending'
WHERE id = 'member-virtual-ai-legal-advisor';

CREATE TABLE IF NOT EXISTS virtual_role_onboarding (
  id TEXT PRIMARY KEY,
  role_id TEXT NOT NULL REFERENCES roles(id),
  checkpoint TEXT NOT NULL CHECK (checkpoint IN (
    'role_profile','ceo_batch_authorization','capability_assessment',
    'permission_review','workflow_validation','operational_activation'
  )),
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending','completed','blocked','not_applicable')),
  evidence_note TEXT,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(role_id, checkpoint)
);

-- CEO has authorized the company-wide virtual team onboarding batch.
-- This is not a claim that individual assessments or technical activation are complete.
INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-gm-profile', 'role-gm', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-gm-ceo-authorization', 'role-gm', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-gm-capability_assessment', 'role-gm', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-gm-permission_review', 'role-gm', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-gm-workflow_validation', 'role-gm', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-gm-operational_activation', 'role-gm', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-coo-profile', 'role-coo', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-coo-ceo-authorization', 'role-coo', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-coo-capability_assessment', 'role-coo', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-coo-permission_review', 'role-coo', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-coo-workflow_validation', 'role-coo', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-coo-operational_activation', 'role-coo', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-cto-profile', 'role-cto', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-cto-ceo-authorization', 'role-cto', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-cto-capability_assessment', 'role-cto', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-cto-permission_review', 'role-cto', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-cto-workflow_validation', 'role-cto', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-cto-operational_activation', 'role-cto', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-cfo-profile', 'role-cfo', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-cfo-ceo-authorization', 'role-cfo', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-cfo-capability_assessment', 'role-cfo', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-cfo-permission_review', 'role-cfo', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-cfo-workflow_validation', 'role-cfo', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-cfo-operational_activation', 'role-cfo', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-hr-manager-profile', 'role-hr-manager', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-hr-manager-ceo-authorization', 'role-hr-manager', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-hr-manager-capability_assessment', 'role-hr-manager', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-hr-manager-permission_review', 'role-hr-manager', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-hr-manager-workflow_validation', 'role-hr-manager', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-hr-manager-operational_activation', 'role-hr-manager', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-recruitment-coordinator-profile', 'role-recruitment-coordinator', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-recruitment-coordinator-ceo-authorization', 'role-recruitment-coordinator', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-recruitment-coordinator-capability_assessment', 'role-recruitment-coordinator', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-recruitment-coordinator-permission_review', 'role-recruitment-coordinator', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-recruitment-coordinator-workflow_validation', 'role-recruitment-coordinator', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-recruitment-coordinator-operational_activation', 'role-recruitment-coordinator', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-head-pmo-profile', 'role-head-pmo', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-head-pmo-ceo-authorization', 'role-head-pmo', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-head-pmo-capability_assessment', 'role-head-pmo', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-head-pmo-permission_review', 'role-head-pmo', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-head-pmo-workflow_validation', 'role-head-pmo', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-head-pmo-operational_activation', 'role-head-pmo', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-business-analyst-profile', 'role-business-analyst', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-business-analyst-ceo-authorization', 'role-business-analyst', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-business-analyst-capability_assessment', 'role-business-analyst', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-business-analyst-permission_review', 'role-business-analyst', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-business-analyst-workflow_validation', 'role-business-analyst', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-business-analyst-operational_activation', 'role-business-analyst', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-project-coordinator-profile', 'role-project-coordinator', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-project-coordinator-ceo-authorization', 'role-project-coordinator', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-project-coordinator-capability_assessment', 'role-project-coordinator', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-project-coordinator-permission_review', 'role-project-coordinator', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-project-coordinator-workflow_validation', 'role-project-coordinator', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-project-coordinator-operational_activation', 'role-project-coordinator', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-solution-architect-profile', 'role-solution-architect', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-solution-architect-ceo-authorization', 'role-solution-architect', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-solution-architect-capability_assessment', 'role-solution-architect', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-solution-architect-permission_review', 'role-solution-architect', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-solution-architect-workflow_validation', 'role-solution-architect', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-solution-architect-operational_activation', 'role-solution-architect', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-lead-developer-profile', 'role-lead-developer', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-lead-developer-ceo-authorization', 'role-lead-developer', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-lead-developer-capability_assessment', 'role-lead-developer', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-lead-developer-permission_review', 'role-lead-developer', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-lead-developer-workflow_validation', 'role-lead-developer', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-lead-developer-operational_activation', 'role-lead-developer', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-backend-developer-01-profile', 'role-backend-developer-01', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-backend-developer-01-ceo-authorization', 'role-backend-developer-01', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-backend-developer-01-capability_assessment', 'role-backend-developer-01', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-backend-developer-01-permission_review', 'role-backend-developer-01', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-backend-developer-01-workflow_validation', 'role-backend-developer-01', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-backend-developer-01-operational_activation', 'role-backend-developer-01', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-backend-developer-02-profile', 'role-backend-developer-02', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-backend-developer-02-ceo-authorization', 'role-backend-developer-02', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-backend-developer-02-capability_assessment', 'role-backend-developer-02', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-backend-developer-02-permission_review', 'role-backend-developer-02', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-backend-developer-02-workflow_validation', 'role-backend-developer-02', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-backend-developer-02-operational_activation', 'role-backend-developer-02', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-frontend-developer-01-profile', 'role-frontend-developer-01', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-frontend-developer-01-ceo-authorization', 'role-frontend-developer-01', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-frontend-developer-01-capability_assessment', 'role-frontend-developer-01', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-frontend-developer-01-permission_review', 'role-frontend-developer-01', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-frontend-developer-01-workflow_validation', 'role-frontend-developer-01', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-frontend-developer-01-operational_activation', 'role-frontend-developer-01', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-frontend-developer-02-profile', 'role-frontend-developer-02', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-frontend-developer-02-ceo-authorization', 'role-frontend-developer-02', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-frontend-developer-02-capability_assessment', 'role-frontend-developer-02', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-frontend-developer-02-permission_review', 'role-frontend-developer-02', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-frontend-developer-02-workflow_validation', 'role-frontend-developer-02', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-frontend-developer-02-operational_activation', 'role-frontend-developer-02', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-mobile-developer-profile', 'role-mobile-developer', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-mobile-developer-ceo-authorization', 'role-mobile-developer', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-mobile-developer-capability_assessment', 'role-mobile-developer', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-mobile-developer-permission_review', 'role-mobile-developer', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-mobile-developer-workflow_validation', 'role-mobile-developer', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-mobile-developer-operational_activation', 'role-mobile-developer', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-database-engineer-profile', 'role-database-engineer', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-database-engineer-ceo-authorization', 'role-database-engineer', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-database-engineer-capability_assessment', 'role-database-engineer', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-database-engineer-permission_review', 'role-database-engineer', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-database-engineer-workflow_validation', 'role-database-engineer', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-database-engineer-operational_activation', 'role-database-engineer', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-devops-engineer-profile', 'role-devops-engineer', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-devops-engineer-ceo-authorization', 'role-devops-engineer', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-devops-engineer-capability_assessment', 'role-devops-engineer', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-devops-engineer-permission_review', 'role-devops-engineer', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-devops-engineer-workflow_validation', 'role-devops-engineer', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-devops-engineer-operational_activation', 'role-devops-engineer', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-cloud-engineer-profile', 'role-cloud-engineer', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-cloud-engineer-ceo-authorization', 'role-cloud-engineer', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-cloud-engineer-capability_assessment', 'role-cloud-engineer', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-cloud-engineer-permission_review', 'role-cloud-engineer', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-cloud-engineer-workflow_validation', 'role-cloud-engineer', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-cloud-engineer-operational_activation', 'role-cloud-engineer', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-ui-ux-designer-profile', 'role-ui-ux-designer', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-ui-ux-designer-ceo-authorization', 'role-ui-ux-designer', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-ui-ux-designer-capability_assessment', 'role-ui-ux-designer', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-ui-ux-designer-permission_review', 'role-ui-ux-designer', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-ui-ux-designer-workflow_validation', 'role-ui-ux-designer', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-ui-ux-designer-operational_activation', 'role-ui-ux-designer', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-head-ict-profile', 'role-head-ict', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-head-ict-ceo-authorization', 'role-head-ict', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-head-ict-capability_assessment', 'role-head-ict', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-head-ict-permission_review', 'role-head-ict', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-head-ict-workflow_validation', 'role-head-ict', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-head-ict-operational_activation', 'role-head-ict', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-systems-engineer-profile', 'role-systems-engineer', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-systems-engineer-ceo-authorization', 'role-systems-engineer', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-systems-engineer-capability_assessment', 'role-systems-engineer', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-systems-engineer-permission_review', 'role-systems-engineer', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-systems-engineer-workflow_validation', 'role-systems-engineer', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-systems-engineer-operational_activation', 'role-systems-engineer', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-head-product-profile', 'role-head-product', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-head-product-ceo-authorization', 'role-head-product', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-head-product-capability_assessment', 'role-head-product', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-head-product-permission_review', 'role-head-product', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-head-product-workflow_validation', 'role-head-product', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-head-product-operational_activation', 'role-head-product', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-product-analyst-profile', 'role-product-analyst', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-product-analyst-ceo-authorization', 'role-product-analyst', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-product-analyst-capability_assessment', 'role-product-analyst', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-product-analyst-permission_review', 'role-product-analyst', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-product-analyst-workflow_validation', 'role-product-analyst', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-product-analyst-operational_activation', 'role-product-analyst', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-qa-manager-profile', 'role-qa-manager', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-qa-manager-ceo-authorization', 'role-qa-manager', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-qa-manager-capability_assessment', 'role-qa-manager', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-qa-manager-permission_review', 'role-qa-manager', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-qa-manager-workflow_validation', 'role-qa-manager', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-qa-manager-operational_activation', 'role-qa-manager', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-qa-engineer-01-profile', 'role-qa-engineer-01', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-qa-engineer-01-ceo-authorization', 'role-qa-engineer-01', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-qa-engineer-01-capability_assessment', 'role-qa-engineer-01', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-qa-engineer-01-permission_review', 'role-qa-engineer-01', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-qa-engineer-01-workflow_validation', 'role-qa-engineer-01', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-qa-engineer-01-operational_activation', 'role-qa-engineer-01', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-qa-engineer-02-profile', 'role-qa-engineer-02', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-qa-engineer-02-ceo-authorization', 'role-qa-engineer-02', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-qa-engineer-02-capability_assessment', 'role-qa-engineer-02', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-qa-engineer-02-permission_review', 'role-qa-engineer-02', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-qa-engineer-02-workflow_validation', 'role-qa-engineer-02', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-qa-engineer-02-operational_activation', 'role-qa-engineer-02', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-uat-functional-profile', 'role-uat-functional', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-uat-functional-ceo-authorization', 'role-uat-functional', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-uat-functional-capability_assessment', 'role-uat-functional', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-uat-functional-permission_review', 'role-uat-functional', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-uat-functional-workflow_validation', 'role-uat-functional', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-uat-functional-operational_activation', 'role-uat-functional', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-uat-integration-profile', 'role-uat-integration', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-uat-integration-ceo-authorization', 'role-uat-integration', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-uat-integration-capability_assessment', 'role-uat-integration', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-uat-integration-permission_review', 'role-uat-integration', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-uat-integration-workflow_validation', 'role-uat-integration', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-uat-integration-operational_activation', 'role-uat-integration', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-uat-regression-profile', 'role-uat-regression', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-uat-regression-ceo-authorization', 'role-uat-regression', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-uat-regression-capability_assessment', 'role-uat-regression', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-uat-regression-permission_review', 'role-uat-regression', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-uat-regression-workflow_validation', 'role-uat-regression', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-uat-regression-operational_activation', 'role-uat-regression', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-head-security-profile', 'role-head-security', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-head-security-ceo-authorization', 'role-head-security', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-head-security-capability_assessment', 'role-head-security', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-head-security-permission_review', 'role-head-security', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-head-security-workflow_validation', 'role-head-security', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-head-security-operational_activation', 'role-head-security', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-security-privacy-analyst-profile', 'role-security-privacy-analyst', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-security-privacy-analyst-ceo-authorization', 'role-security-privacy-analyst', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-security-privacy-analyst-capability_assessment', 'role-security-privacy-analyst', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-security-privacy-analyst-permission_review', 'role-security-privacy-analyst', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-security-privacy-analyst-workflow_validation', 'role-security-privacy-analyst', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-security-privacy-analyst-operational_activation', 'role-security-privacy-analyst', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-risk-compliance-profile', 'role-risk-compliance', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-risk-compliance-ceo-authorization', 'role-risk-compliance', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-risk-compliance-capability_assessment', 'role-risk-compliance', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-risk-compliance-permission_review', 'role-risk-compliance', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-risk-compliance-workflow_validation', 'role-risk-compliance', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-risk-compliance-operational_activation', 'role-risk-compliance', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-legal-advisor-profile', 'role-legal-advisor', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-legal-advisor-ceo-authorization', 'role-legal-advisor', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-legal-advisor-capability_assessment', 'role-legal-advisor', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-legal-advisor-permission_review', 'role-legal-advisor', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-legal-advisor-workflow_validation', 'role-legal-advisor', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-legal-advisor-operational_activation', 'role-legal-advisor', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-release-manager-profile', 'role-release-manager', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-release-manager-ceo-authorization', 'role-release-manager', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-release-manager-capability_assessment', 'role-release-manager', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-release-manager-permission_review', 'role-release-manager', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-release-manager-workflow_validation', 'role-release-manager', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-release-manager-operational_activation', 'role-release-manager', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-operations-coordinator-profile', 'role-operations-coordinator', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-operations-coordinator-ceo-authorization', 'role-operations-coordinator', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-operations-coordinator-capability_assessment', 'role-operations-coordinator', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-operations-coordinator-permission_review', 'role-operations-coordinator', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-operations-coordinator-workflow_validation', 'role-operations-coordinator', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-operations-coordinator-operational_activation', 'role-operations-coordinator', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-support-manager-profile', 'role-support-manager', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-support-manager-ceo-authorization', 'role-support-manager', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-support-manager-capability_assessment', 'role-support-manager', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-support-manager-permission_review', 'role-support-manager', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-support-manager-workflow_validation', 'role-support-manager', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-support-manager-operational_activation', 'role-support-manager', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-application-support-profile', 'role-application-support', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-application-support-ceo-authorization', 'role-application-support', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-application-support-capability_assessment', 'role-application-support', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-application-support-permission_review', 'role-application-support', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-application-support-workflow_validation', 'role-application-support', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-application-support-operational_activation', 'role-application-support', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-customer-support-profile', 'role-customer-support', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-customer-support-ceo-authorization', 'role-customer-support', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-customer-support-capability_assessment', 'role-customer-support', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-customer-support-permission_review', 'role-customer-support', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-customer-support-workflow_validation', 'role-customer-support', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-customer-support-operational_activation', 'role-customer-support', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-technical-writer-profile', 'role-technical-writer', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-technical-writer-ceo-authorization', 'role-technical-writer', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-technical-writer-capability_assessment', 'role-technical-writer', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-technical-writer-permission_review', 'role-technical-writer', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-technical-writer-workflow_validation', 'role-technical-writer', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-technical-writer-operational_activation', 'role-technical-writer', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-knowledge-coordinator-profile', 'role-knowledge-coordinator', 'role_profile', 'completed', 'Role profile and responsibility defined in HR organization register.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-knowledge-coordinator-ceo-authorization', 'role-knowledge-coordinator', 'ceo_batch_authorization', 'completed', 'CEO authorized proceeding with the company-wide virtual AI member onboarding batch in chat.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-knowledge-coordinator-capability_assessment', 'role-knowledge-coordinator', 'capability_assessment', 'pending', 'Role-specific capability assessment has not yet been individually completed and evidenced.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-knowledge-coordinator-permission_review', 'role-knowledge-coordinator', 'permission_review', 'pending', 'Least-privilege permissions must be reviewed before system access is granted.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-knowledge-coordinator-workflow_validation', 'role-knowledge-coordinator', 'workflow_validation', 'pending', 'Role workflow and deliverables must be tested before operational activation.');

INSERT OR IGNORE INTO virtual_role_onboarding (id, role_id, checkpoint, status, evidence_note)
VALUES ('onboard-knowledge-coordinator-operational_activation', 'role-knowledge-coordinator', 'operational_activation', 'pending', 'Not active in a live CMD environment until deployment and acceptance checks pass.');

