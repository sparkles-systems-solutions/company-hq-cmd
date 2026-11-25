PRAGMA foreign_keys = ON;

INSERT OR IGNORE INTO departments (id, name, description)
VALUES (
  'dept-legal-compliance',
  'Legal & Compliance',
  'Virtual AI legal research, document drafting, contract risk review, and compliance support'
);

INSERT OR IGNORE INTO roles (id, name, description, access_level)
VALUES (
  'role-virtual-ai-legal-advisor',
  'Virtual AI Legal Advisor',
  'Virtual AI support role for legal research, contract drafting, compliance checklists, and escalation. Not a licensed legal practitioner.',
  'sensitive'
);

INSERT OR IGNORE INTO people (
  id, display_name, email, person_type, department_id, status
)
VALUES (
  'member-virtual-ai-legal-advisor',
  'Virtual AI Legal Advisor',
  'virtual-legal-advisor@members.invalid',
  'virtual',
  'dept-legal-compliance',
  'active'
);

INSERT OR IGNORE INTO role_assignments (
  id, person_id, role_id, scope_type, scope_id, assigned_by
)
VALUES (
  'assignment-virtual-ai-legal-advisor',
  'member-virtual-ai-legal-advisor',
  'role-virtual-ai-legal-advisor',
  'company',
  NULL,
  NULL
);
