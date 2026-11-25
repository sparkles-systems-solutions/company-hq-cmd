#!/usr/bin/env python3
"""Replay CMD SQL migrations in disposable SQLite and verify core safety invariants."""
from pathlib import Path
import sqlite3
import sys

ROOT = Path(__file__).resolve().parents[1]
MIGRATIONS = [
    ROOT / "migrations/0001_initial.sql",
    ROOT / "migrations/0002_virtual_legal_advisor.sql",
    ROOT / "migrations/0003_virtual_ai_role_catalogue.sql",
    ROOT / "migrations/0004_virtual_ai_member_onboarding.sql",
    ROOT / "migrations/0005_authorization_schema.sql",
]

def expect_integrity_error(db, sql, params=()):
    try:
        db.execute(sql, params)
    except sqlite3.IntegrityError:
        return
    raise AssertionError("Expected SQLite integrity constraint/trigger rejection")

def main():
    db = sqlite3.connect(":memory:")
    db.execute("PRAGMA foreign_keys = ON")
    for path in MIGRATIONS:
        print(f"Applying {path.name}")
        db.executescript(path.read_text(encoding="utf-8"))

    db.commit()
    assert db.execute("PRAGMA foreign_keys").fetchone()[0] == 1
    fk_errors = db.execute("PRAGMA foreign_key_check").fetchall()
    assert not fk_errors, f"Foreign key violations: {fk_errors}"

    counts = {
        "departments": db.execute("SELECT COUNT(*) FROM departments").fetchone()[0],
        "roles": db.execute("SELECT COUNT(*) FROM roles").fetchone()[0],
        "virtual_people": db.execute("SELECT COUNT(*) FROM people WHERE person_type='virtual'").fetchone()[0],
        "role_assignments": db.execute("SELECT COUNT(*) FROM role_assignments").fetchone()[0],
        "permission_catalogue": db.execute("SELECT COUNT(*) FROM permission_catalogue").fetchone()[0],
        "role_permission_rules": db.execute("SELECT COUNT(*) FROM role_permission_rules").fetchone()[0],
        "role_scope_grants": db.execute("SELECT COUNT(*) FROM role_scope_grants").fetchone()[0],
        "auth_users": db.execute("SELECT COUNT(*) FROM auth_users").fetchone()[0],
        "auth_sessions": db.execute("SELECT COUNT(*) FROM auth_sessions").fetchone()[0],
        "share_tokens": db.execute("SELECT COUNT(*) FROM dashboard_share_tokens").fetchone()[0],
        "approval_controls": db.execute("SELECT COUNT(*) FROM approval_controls").fetchone()[0],
    }
    assert counts["roles"] == 41, counts
    assert counts["virtual_people"] == 41, counts
    assert counts["role_assignments"] == 41, counts
    assert counts["permission_catalogue"] == 60, counts
    for key in ("role_permission_rules", "role_scope_grants", "auth_users", "auth_sessions", "share_tokens", "approval_controls"):
        assert counts[key] == 0, f"Expected no seeded {key}: {counts}"

    # Create a synthetic active CEO identity only inside this disposable test database.
    db.execute(
        "INSERT INTO people (id,display_name,email,person_type,department_id,status) VALUES (?,?,?,?,?,?)",
        ("test-ceo", "Test CEO", "test-ceo@example.invalid", "human", "dept-executive", "active"),
    )
    expect_integrity_error(
        db,
        "INSERT INTO auth_users (id,person_id,auth_provider,provider_subject,account_status) VALUES (?,?,?,?,?)",
        ("bad-virtual-login", "member-virtual-gm", "email_otp", "virtual-gm", "active"),
    )
    db.execute(
        "INSERT INTO auth_users (id,person_id,auth_provider,provider_subject,account_status) VALUES (?,?,?,?,?)",
        ("test-ceo-auth", "test-ceo", "email_otp", "test-ceo-subject", "active"),
    )

    # Virtual role definitions cannot receive approve/execute allow rules.
    for action in ("approve", "execute"):
        expect_integrity_error(
            db,
            "INSERT INTO role_permission_rules (id,role_id,module_key,action_key,effect) VALUES (?,?,?,?,?)",
            (f"bad-{action}", "role-gm", "EXEC", action, "allow"),
        )

    # Pending virtual roster entries cannot receive active scope grants.
    expect_integrity_error(
        db,
        """INSERT INTO role_scope_grants
           (id,role_assignment_id,module_key,scope_type,scope_id,grant_status,granted_by,granted_at)
           VALUES (?,?,?,?,?,?,?,CURRENT_TIMESTAMP)""",
        ("bad-pending-grant", "assignment-virtual-gm", "EXEC", "company", None, "active", "test-ceo"),
    )
    db.execute(
        """INSERT INTO role_scope_grants
           (id,role_assignment_id,module_key,scope_type,scope_id,grant_status)
           VALUES ('pending-grant-update','assignment-virtual-gm','EXEC','company',NULL,'pending')"""
    )
    expect_integrity_error(
        db,
        "UPDATE role_scope_grants SET grant_status='active', granted_by='test-ceo', granted_at=CURRENT_TIMESTAMP WHERE id='pending-grant-update'",
    )

    # Migration 0004 deliberately resets every virtual member to pending.
    # Simulate a CEO-approved status transition only inside this disposable database,
    # then verify the active grant path and restore pending before the test ends.
    db.execute(
        "UPDATE people SET status='active' WHERE id='member-virtual-ai-legal-advisor' AND person_type='virtual'"
    )
    db.execute(
        """INSERT INTO role_scope_grants
           (id,role_assignment_id,module_key,scope_type,scope_id,grant_status,granted_by,granted_at)
           VALUES (?,?,?,?,?,?,?,CURRENT_TIMESTAMP)""",
        ("test-legal-scope", "assignment-virtual-ai-legal-advisor", "DOC", "company", None, "active", "test-ceo"),
    )
    db.execute("DELETE FROM role_scope_grants WHERE id='test-legal-scope'")
    db.execute(
        "UPDATE people SET status='pending' WHERE id='member-virtual-ai-legal-advisor' AND person_type='virtual'"
    )

    # A control record must be created unconsumed and tied to an approved human decision.
    db.execute(
        """INSERT INTO approvals
           (id,subject_type,subject_id,approval_type,requested_by,approver_id,decision,rationale,decided_at)
           VALUES ('test-approval','test','resource-1','test','test-ceo','test-ceo','approved','disposable test',CURRENT_TIMESTAMP)"""
    )
    expect_integrity_error(
        db,
        """INSERT INTO approval_controls
           (id,approval_id,permission_key,resource_type,resource_id,environment,payload_sha256,
            approved_by,expires_at,consumed_at,consumed_by)
           VALUES ('bad-preconsumed','test-approval','EXEC.approve','test','resource-1','test',
                   'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
                   'test-ceo',datetime('now','+10 minutes'),CURRENT_TIMESTAMP,'test-ceo')""",
    )
    db.execute(
        """INSERT INTO approval_controls
           (id,approval_id,permission_key,resource_type,resource_id,environment,payload_sha256,
            approved_by,expires_at)
           VALUES ('test-control','test-approval','EXEC.approve','test','resource-1','test',
                   'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
                   'test-ceo',datetime('now','+10 minutes'))"""
    )
    db.execute(
        "UPDATE approval_controls SET consumed_at=CURRENT_TIMESTAMP, consumed_by='test-ceo' WHERE id='test-control'"
    )
    expect_integrity_error(
        db,
        "UPDATE approval_controls SET consumed_at=CURRENT_TIMESTAMP, consumed_by='test-ceo' WHERE id='test-control'",
    )

    # Share tokens must be created by an active human and remain within the 7-day cap.
    db.execute(
        """INSERT INTO dashboard_share_tokens
           (id,token_hash,dashboard_key,allowed_fields_json,filters_json,created_by,expires_at)
           VALUES ('test-share','hash-test','exec-overview','["status"]','{}','test-ceo',datetime('now','+1 day'))"""
    )
    db.execute("DELETE FROM dashboard_share_tokens WHERE id='test-share'")

    db.commit()
    fk_errors = db.execute("PRAGMA foreign_key_check").fetchall()
    assert not fk_errors, f"Foreign key violations after safety tests: {fk_errors}"
    print("Migration replay: PASS")
    print("Safety invariant tests: PASS")
    print("Counts:", counts)
    print("Note: disposable SQLite schema validation only; Cloudflare D1 runtime integration is still required.")

if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(f"VALIDATION FAILED: {exc}", file=sys.stderr)
        raise
