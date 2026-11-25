# Founder Governance and Approval Policy

**Document status:** Draft for Founder / CEO review

## 1. Authority

The Founder / CEO is the sole confirmed human member and final human approval authority in the current operating model.

Virtual AI role definitions are not human officers, employees, directors, legal representatives or independent agents.

## 2. Work That Virtual Roles May Prepare

Within an approved scope, a Virtual AI role may:

- Research and analyze
- Draft requirements, plans and reports
- Propose architecture and designs
- Prepare code and documentation
- Run approved tests using synthetic or authorized data
- Identify risks, defects and dependencies
- Recommend next steps

## 3. Actions Requiring Explicit Founder / CEO Approval

- Hiring, termination, compensation or contractual commitments
- Signing or accepting agreements
- Legal representations or binding legal positions
- Spending, purchasing, banking or payments
- Production deployments and releases
- Production database writes, migrations or destructive changes
- Creation or use of production credentials and secrets
- Granting access to sensitive data or systems
- External publication, customer commitments or official company statements
- Activation of Virtual AI roles with live permissions

## 4. Separation of Duties

- A role must not approve its own work.
- A proposer cannot be the sole approver of a high-impact change.
- QA evidence must be separate from the developer's claim of completion.
- Release readiness is a recommendation; release authorization remains with the Founder / CEO.
- If the Founder / CEO is unavailable, the default is to pause gated actions, not to infer approval.

## 5. Security and Privacy

- Deny access by default.
- Use least privilege and task-specific access.
- Do not expose passwords, tokens, private keys, bank credentials, patient records, identity documents or other sensitive personal data to Virtual AI roles unless a separate approved, secure and lawful process explicitly permits it.
- Prefer synthetic or de-identified test data.
- Record access grants, changes, approvals and material actions.
- Support expiry and revocation of access.

## 6. Approval Evidence

An approval record should identify:

- The exact action or deliverable approved
- Scope, environment and affected systems
- Relevant version, commit or document reference
- Risks and rollback / recovery approach
- Approver identity and timestamp
- Any conditions or expiry
- Verification evidence after execution

A general “go ahead” is limited to the safe work described in the immediate context. It does not override explicit production, financial, legal, security or destructive-action approval gates.

## 7. External Professional Review

Virtual AI outputs are drafts or recommendations. Qualified human professionals must provide required legal, accounting, tax, regulatory, security certification or other professional sign-off.
