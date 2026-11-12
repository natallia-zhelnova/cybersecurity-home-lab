# IAM Home Lab: Active Directory & Joiner-Mover-Leaver Automation

A home lab where I built a Windows Server 2022 domain controller from scratch, designed an OU and group structure based on role-based access control (RBAC), and automated the full identity lifecycle — **Joiner, Mover, Leaver** — with PowerShell.

## Skills demonstrated

| Area | What I did |
|---|---|
| Active Directory | Promoted a server to domain controller, created the `lab.local` forest with integrated DNS |
| Directory design | OU structure by department, security groups with a naming convention (`GRP-*`) |
| RBAC / least privilege | Access granted through role groups, never to individual users |
| Identity lifecycle (JML) | Bulk onboarding from CSV, role change with access removal, offboarding with audit trail |
| PowerShell automation | `Import-Csv`, `New-ADUser` with splatting, `Add/Remove-ADGroupMember`, `Move-ADObject`, `Disable-ADAccount` |
| Access verification | Group membership checks that caught a real access gap; attribute data-quality report |
| Troubleshooting | Disk space, hypervisor conflict, boot failure recovery, static IP configuration |

## Lab architecture

| Component | Details |
|---|---|
| Host | Windows 10, VirtualBox 7.x |
| Domain controller | `DC01`, Windows Server 2022 Standard Evaluation (Desktop Experience), 6 GB RAM, 4 vCPU |
| Domain | `lab.local` (NetBIOS `LAB`), forest/domain functional level Windows Server 2016 |
| Network | Adapter 1: NAT (internet) · Adapter 2: Host-only, static IP `192.168.56.10/24`, DNS `127.0.0.1` |
| Roles | AD DS, DNS, Global Catalog |

```
lab.local
└── Corp
    ├── IT              John Smith, David Kim
    ├── HR              Anna Lee
    ├── Finance         Maria Garcia, Michael Chen, Emily Davis, Sarah Brown (moved from HR)
    ├── Groups          GRP-IT-Staff, GRP-HR-Staff, GRP-Finance-Staff, GRP-All-Employees
    └── Disabled Users  James Wilson (leaver)
```

## What I built

### 1. Domain controller
- Installed Windows Server 2022 in VirtualBox, set a static IP and DNS pointing to itself (AD depends on DNS: clients find DCs through SRV records).
- Installed the AD DS role and promoted the server to the first DC of a new forest, `lab.local`.
- Verified with `whoami` → `lab\administrator`.

### 2. OU and group design
- Created an OU per department under `Corp` instead of using the default `Users` container (containers can't have Group Policy linked or rights delegated cleanly).
- Created **global security groups** per department plus `GRP-All-Employees`.
- Created users manually in ADUC with *User must change password at next logon* and added them to role groups.

### 3. Joiner — bulk onboarding from CSV
[`scripts/New-HireOnboarding.ps1`](scripts/New-HireOnboarding.ps1) reads [`scripts/new_hires.csv`](scripts/new_hires.csv) and, for each row:
- creates the account in the department OU with department and title attributes,
- sets a temporary password that must be changed at first logon,
- adds the user to the department group and `GRP-All-Employees`.

Result: 5 accounts created and placed correctly in one run; `GRP-All-Employees` grew from 3 to 8 members.

### 4. Mover — role change without privilege creep
[`scripts/Mover.ps1`](scripts/Mover.ps1) moved Sarah Brown from HR to Finance:
move to the new OU → **remove the old group** → add the new group → update department and title → verify.
Verification confirmed she was no longer in `GRP-HR-Staff`. Removing old access is the step that prevents privilege creep.

### 5. Leaver — offboarding with an audit trail
[`scripts/Leaver.ps1`](scripts/Leaver.ps1) offboarded James Wilson:
1. Disabled the account (most urgent step).
2. Saved the current group list to a file for audit.
3. Removed all group memberships.
4. Recorded date and ticket number in the account description.
5. Moved the account to the `Disabled Users` OU.
6. Verified: `Enabled: False`, no group memberships.

Accounts are disabled, not deleted: deletion is irreversible and removes the history auditors need. Deletion would follow the retention policy (typically 30–90 days).

### 6. Access verification
[`scripts/Verify-Access.ps1`](scripts/Verify-Access.ps1) reports group membership and user attributes. Two real findings during the lab:
- **Missing role groups:** a user's group membership added through the GUI had not been saved. `Get-ADUser -Properties MemberOf` returned nothing; fixed with `Add-ADGroupMember` and re-verified.
- **Data quality:** three manually created accounts had empty Department and Title fields, which would break reports and attribute-based (dynamic) groups. Fixed with `Set-ADUser`.

## Troubleshooting and lessons learned
See [`docs/troubleshooting.md`](docs/troubleshooting.md). Highlights:
- **VERR_DISK_FULL** during install → moved VMs to a second drive and freed ~130 GB on the host.
- **VM failed to boot** after a forced reset during updates → repaired from install media; took a snapshot before every major step from then on.
- **VM freezes** → VirtualBox was running on top of Hyper-V (green turtle icon). Wrote two scripts to switch the hypervisor off for lab work and back on for Docker.
- **Static IP not applied via `sconfig`** → configured through the adapter settings and verified with `ipconfig`.

**Main lesson:** read the actual error, verify every change, and always keep a rollback point.

## Screenshots
See [`screenshots/`](screenshots/).

## Next steps
- Microsoft Entra ID: MFA, Conditional Access, SSO, PIM, access reviews
- Forward AD security events (logons, group changes) to Splunk for detection

---
*All names are fictional. Passwords are not stored in this repository; scripts prompt for the temporary password at runtime.*
