PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS departments (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0,1)),
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS roles (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  access_level TEXT NOT NULL DEFAULT 'standard'
    CHECK (access_level IN ('standard','sensitive','privileged')),
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS people (
  id TEXT PRIMARY KEY,
  display_name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  person_type TEXT NOT NULL DEFAULT 'human'
    CHECK (person_type IN ('human','virtual')),
  department_id TEXT REFERENCES departments(id),
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending','active','suspended','inactive')),
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS role_assignments (
  id TEXT PRIMARY KEY,
  person_id TEXT NOT NULL REFERENCES people(id),
  role_id TEXT NOT NULL REFERENCES roles(id),
  scope_type TEXT NOT NULL DEFAULT 'company',
  scope_id TEXT,
  assigned_by TEXT REFERENCES people(id),
  assigned_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expires_at TEXT,
  UNIQUE(person_id, role_id, scope_type, scope_id)
);

CREATE TABLE IF NOT EXISTS projects (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  code TEXT NOT NULL UNIQUE,
  description TEXT,
  repository_url TEXT,
  status TEXT NOT NULL DEFAULT 'planned'
    CHECK (status IN ('planned','active','on_hold','at_risk','completed','cancelled')),
  priority TEXT NOT NULL DEFAULT 'medium'
    CHECK (priority IN ('low','medium','high','critical')),
  owner_id TEXT REFERENCES people(id),
  start_date TEXT,
  target_date TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS milestones (
  id TEXT PRIMARY KEY,
  project_id TEXT NOT NULL REFERENCES projects(id),
  title TEXT NOT NULL,
  due_date TEXT,
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending','in_progress','blocked','completed')),
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS tasks (
  id TEXT PRIMARY KEY,
  project_id TEXT NOT NULL REFERENCES projects(id),
  milestone_id TEXT REFERENCES milestones(id),
  title TEXT NOT NULL,
  description TEXT,
  owner_id TEXT REFERENCES people(id),
  status TEXT NOT NULL DEFAULT 'backlog'
    CHECK (status IN ('backlog','ready','in_progress','blocked','review','done','cancelled')),
  priority TEXT NOT NULL DEFAULT 'medium'
    CHECK (priority IN ('low','medium','high','critical')),
  due_date TEXT,
  acceptance_criteria TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS task_dependencies (
  task_id TEXT NOT NULL REFERENCES tasks(id),
  depends_on_task_id TEXT NOT NULL REFERENCES tasks(id),
  PRIMARY KEY(task_id, depends_on_task_id),
  CHECK(task_id <> depends_on_task_id)
);

CREATE TABLE IF NOT EXISTS risks (
  id TEXT PRIMARY KEY,
  project_id TEXT NOT NULL REFERENCES projects(id),
  title TEXT NOT NULL,
  impact TEXT NOT NULL CHECK (impact IN ('low','medium','high','critical')),
  likelihood TEXT NOT NULL CHECK (likelihood IN ('low','medium','high')),
  mitigation TEXT,
  owner_id TEXT REFERENCES people(id),
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open','mitigating','accepted','closed')),
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS test_cases (
  id TEXT PRIMARY KEY,
  project_id TEXT NOT NULL REFERENCES projects(id),
  title TEXT NOT NULL,
  test_type TEXT NOT NULL CHECK (test_type IN ('functional','integration','regression','security','uat','performance')),
  expected_result TEXT,
  actual_result TEXT,
  status TEXT NOT NULL DEFAULT 'not_run'
    CHECK (status IN ('not_run','passed','failed','blocked')),
  tester_id TEXT REFERENCES people(id),
  executed_at TEXT
);

CREATE TABLE IF NOT EXISTS defects (
  id TEXT PRIMARY KEY,
  project_id TEXT NOT NULL REFERENCES projects(id),
  test_case_id TEXT REFERENCES test_cases(id),
  title TEXT NOT NULL,
  severity TEXT NOT NULL CHECK (severity IN ('low','medium','high','critical')),
  status TEXT NOT NULL DEFAULT 'open'
    CHECK (status IN ('open','in_progress','fixed','verified','closed','reopened')),
  assigned_to TEXT REFERENCES people(id),
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS approvals (
  id TEXT PRIMARY KEY,
  subject_type TEXT NOT NULL,
  subject_id TEXT NOT NULL,
  approval_type TEXT NOT NULL,
  requested_by TEXT NOT NULL REFERENCES people(id),
  approver_id TEXT REFERENCES people(id),
  decision TEXT NOT NULL DEFAULT 'pending'
    CHECK (decision IN ('pending','approved','rejected','withdrawn')),
  rationale TEXT,
  requested_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  decided_at TEXT
);

CREATE TABLE IF NOT EXISTS audit_logs (
  id TEXT PRIMARY KEY,
  actor_id TEXT REFERENCES people(id),
  action TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id TEXT,
  request_id TEXT,
  metadata_json TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS budget_requests (
  id TEXT PRIMARY KEY,
  project_id TEXT REFERENCES projects(id),
  requested_by TEXT NOT NULL REFERENCES people(id),
  amount_minor INTEGER NOT NULL CHECK (amount_minor >= 0),
  currency TEXT NOT NULL DEFAULT 'LKR',
  purpose TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending','approved','rejected','cancelled')),
  approval_id TEXT REFERENCES approvals(id),
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_projects_status ON projects(status);
CREATE INDEX IF NOT EXISTS idx_tasks_project_status ON tasks(project_id, status);
CREATE INDEX IF NOT EXISTS idx_tasks_owner ON tasks(owner_id);
CREATE INDEX IF NOT EXISTS idx_approvals_decision ON approvals(decision);
CREATE INDEX IF NOT EXISTS idx_audit_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_defects_project_status ON defects(project_id, status);
