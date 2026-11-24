-- CMD Phase 4: additive authorization schema.
-- Schema/catalogue only: no users, sessions, role grants, share tokens, or approvals are seeded.
-- Do not apply to production until reviewed and tested against a disposable D1 database.

PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS permission_catalogue (
  permission_key TEXT PRIMARY KEY,
  module_key TEXT NOT NULL,
  action_key TEXT NOT NULL CHECK (action_key IN ('read','draft','propose','test','approve','execute')),
  description TEXT NOT NULL,
  is_sensitive INTEGER NOT NULL DEFAULT 0 CHECK (is_sensitive IN (0,1)),
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (module_key, action_key)
);

-- Catalogue only. Creating a catalogue entry does not grant it to any role.
INSERT OR IGNORE INTO permission_catalogue
  (permission_key, module_key, action_key, description, is_sensitive)
SELECT
  module_key || '.' || action_key,
  module_key,
  action_key,
  module_key || ' module ' || action_key || ' permission (policy catalogue only)',
  CASE WHEN action_key IN ('approve','execute') OR module_key IN ('FIN','SEC','SHARE') THEN 1 ELSE 0 END
FROM
  (SELECT 'EXEC' AS module_key UNION ALL SELECT 'HR' UNION ALL SELECT 'PMO'
   UNION ALL SELECT 'QA' UNION ALL SELECT 'FIN' UNION ALL SELECT 'OPS'
   UNION ALL SELECT 'SEC' UNION ALL SELECT 'DOC' UNION ALL SELECT 'REL'
   UNION ALL SELECT 'SHARE') AS modules
CROSS JOIN
  (SELECT 'read' AS action_key UNION ALL SELECT 'draft' UNION ALL SELECT 'propose'
   UNION ALL SELECT 'test' UNION ALL SELECT 'approve' UNION ALL SELECT 'execute') AS actions;

CREATE TABLE IF NOT EXISTS role_permission_rules (
  id TEXT PRIMARY KEY,
  role_id TEXT NOT NULL REFERENCES roles(id) ON DELETE RESTRICT,
  module_key TEXT NOT NULL,
  action_key TEXT NOT NULL,
  effect TEXT NOT NULL CHECK (effect IN ('allow','deny')),
  requires_scope INTEGER NOT NULL DEFAULT 1 CHECK (requires_scope IN (0,1)),
  policy_note TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (role_id, module_key, action_key),
  FOREIGN KEY (module_key, action_key)
    REFERENCES permission_catalogue(module_key, action_key) ON DELETE RESTRICT
);

-- Explicit record/project/department scope grants. Pending is the safe default.
CREATE TABLE IF NOT EXISTS role_scope_grants (
  id TEXT PRIMARY KEY,
  role_assignment_id TEXT NOT NULL REFERENCES role_assignments(id) ON DELETE RESTRICT,
  module_key TEXT NOT NULL,
  scope_type TEXT NOT NULL CHECK (scope_type IN ('company','department','project','record')),
  scope_id TEXT,
  grant_status TEXT NOT NULL DEFAULT 'pending'
    CHECK (grant_status IN ('pending','active','suspended','revoked','expired')),
  granted_by TEXT REFERENCES people(id) ON DELETE RESTRICT,
  granted_at TEXT,
  expires_at TEXT,
  revoked_at TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CHECK (
    (scope_type = 'company' AND scope_id IS NULL) OR
    (scope_type <> 'company' AND scope_id IS NOT NULL AND length(trim(scope_id)) > 0)
  ),
  CHECK (
    (grant_status = 'active' AND granted_at IS NOT NULL AND granted_by IS NOT NULL) OR
    (grant_status <> 'active')
  )
);

CREATE TABLE IF NOT EXISTS auth_users (
  id TEXT PRIMARY KEY,
  person_id TEXT NOT NULL UNIQUE REFERENCES people(id) ON DELETE RESTRICT,
  auth_provider TEXT NOT NULL CHECK (auth_provider IN ('email_otp','oidc','webauthn')),
  provider_subject TEXT NOT NULL,
  account_status TEXT NOT NULL DEFAULT 'pending'
    CHECK (account_status IN ('pending','active','locked','suspended','disabled')),
  mfa_required INTEGER NOT NULL DEFAULT 1 CHECK (mfa_required IN (0,1)),
  last_authenticated_at TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (auth_provider, provider_subject)
);

CREATE TABLE IF NOT EXISTS auth_sessions (
  id TEXT PRIMARY KEY,
  auth_user_id TEXT NOT NULL REFERENCES auth_users(id) ON DELETE CASCADE,
  session_token_hash TEXT NOT NULL UNIQUE,
  issued_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expires_at TEXT NOT NULL,
  last_seen_at TEXT,
  revoked_at TEXT,
  revoke_reason TEXT,
  mfa_verified_at TEXT,
  ip_address_hash TEXT,
  user_agent_summary TEXT,
  CHECK (expires_at > issued_at)
);

CREATE TABLE IF NOT EXISTS dashboard_share_tokens (
  id TEXT PRIMARY KEY,
  token_hash TEXT NOT NULL UNIQUE,
  dashboard_key TEXT NOT NULL,
  allowed_fields_json TEXT NOT NULL CHECK (json_valid(allowed_fields_json) AND json_type(allowed_fields_json) = 'array'),
  filters_json TEXT NOT NULL DEFAULT '{}' CHECK (json_valid(filters_json) AND json_type(filters_json) = 'object'),
  created_by TEXT NOT NULL REFERENCES people(id) ON DELETE RESTRICT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expires_at TEXT NOT NULL,
  revoked_at TEXT,
  revocation_reason TEXT,
  max_access_count INTEGER NOT NULL DEFAULT 100 CHECK (max_access_count BETWEEN 1 AND 10000),
  access_count INTEGER NOT NULL DEFAULT 0 CHECK (access_count >= 0),
  last_accessed_at TEXT,
  CHECK (expires_at > created_at),
  CHECK (expires_at <= datetime(created_at, '+7 days'))
);

-- A share link is created only by an active human member (the CEO in this company).
CREATE TRIGGER IF NOT EXISTS trg_share_token_human_creator_insert
BEFORE INSERT ON dashboard_share_tokens
FOR EACH ROW
WHEN NOT EXISTS (
  SELECT 1 FROM people
  WHERE id = NEW.created_by AND person_type = 'human' AND status = 'active'
)
BEGIN
  SELECT RAISE(ABORT, 'share token creator must be an active human');
END;

CREATE TABLE IF NOT EXISTS approval_controls (
  id TEXT PRIMARY KEY,
  approval_id TEXT NOT NULL UNIQUE REFERENCES approvals(id) ON DELETE RESTRICT,
  permission_key TEXT NOT NULL REFERENCES permission_catalogue(permission_key) ON DELETE RESTRICT,
  resource_type TEXT NOT NULL,
  resource_id TEXT NOT NULL,
  environment TEXT NOT NULL CHECK (environment IN ('development','test','staging','production')),
  payload_sha256 TEXT NOT NULL CHECK (length(payload_sha256) = 64),
  approved_by TEXT NOT NULL REFERENCES people(id) ON DELETE RESTRICT,
  approved_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expires_at TEXT NOT NULL,
  consumed_at TEXT,
  consumed_by TEXT REFERENCES people(id) ON DELETE RESTRICT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CHECK (expires_at > approved_at),
  CHECK ((consumed_at IS NULL AND consumed_by IS NULL) OR
         (consumed_at IS NOT NULL AND consumed_by IS NOT NULL))
);

-- A recorded approval must point to an approved legacy approval row and a human approver.
CREATE TRIGGER IF NOT EXISTS trg_approval_control_human_approver_insert
BEFORE INSERT ON approval_controls
FOR EACH ROW
WHEN NOT EXISTS (
  SELECT 1 FROM people
  WHERE id = NEW.approved_by AND person_type = 'human' AND status = 'active'
)
OR NOT EXISTS (
  SELECT 1 FROM approvals
  WHERE id = NEW.approval_id AND decision = 'approved' AND approver_id = NEW.approved_by
)
BEGIN
  SELECT RAISE(ABORT, 'approval control requires an approved decision by an active human');
END;

CREATE TRIGGER IF NOT EXISTS trg_approval_control_human_consumer_update
BEFORE UPDATE OF consumed_by ON approval_controls
FOR EACH ROW
WHEN NEW.consumed_by IS NOT NULL
AND NOT EXISTS (
  SELECT 1 FROM people
  WHERE id = NEW.consumed_by AND person_type = 'human' AND status = 'active'
)
BEGIN
  SELECT RAISE(ABORT, 'approval control consumer must be an active human');
END;

CREATE INDEX IF NOT EXISTS idx_permission_rules_role
  ON role_permission_rules(role_id, module_key, action_key, effect);
CREATE INDEX IF NOT EXISTS idx_scope_grants_assignment
  ON role_scope_grants(role_assignment_id, grant_status, module_key);
CREATE INDEX IF NOT EXISTS idx_scope_grants_expiry
  ON role_scope_grants(expires_at);
CREATE INDEX IF NOT EXISTS idx_auth_users_person_status
  ON auth_users(person_id, account_status);
CREATE INDEX IF NOT EXISTS idx_auth_sessions_user_expiry
  ON auth_sessions(auth_user_id, expires_at, revoked_at);
CREATE INDEX IF NOT EXISTS idx_share_tokens_expiry_revoked
  ON dashboard_share_tokens(expires_at, revoked_at);
CREATE INDEX IF NOT EXISTS idx_approval_controls_expiry_consumed
  ON approval_controls(expires_at, consumed_at);
