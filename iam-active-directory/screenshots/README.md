# Screenshots

| File | What it shows |
|---|---|
| `01-server-manager-roles.png` | Server Manager with AD DS and DNS roles |
| `02-whoami-domain.png` | `whoami` → `lab\administrator` |
| `03-ou-structure.png` | ADUC: Corp → IT, HR, Finance, Groups, Disabled Users |
| `04-groups.png` | Groups OU with the four GRP-* security groups |
| `05-onboarding-script.png` | ISE: onboarding script (New-HireOnboarding.ps1) |
| `06-group-members.png` | `Get-ADGroupMember GRP-All-Employees` → 8 users |
| `07-mover-result.png` | Mover verification: Finance OU, GRP-HR-Staff removed |
| `08-leaver-result.png` | Leaver verification: Enabled False, no groups |
| `09-access-report.png` | Verify-Access.ps1 output: members of every GRP-* group |
| `10-lockout-policy-verify.png` | `gpupdate /force` and `Get-ADDefaultDomainPasswordPolicy` → threshold 5, 10 minutes |
| `11-lockout-test.png` | Six failed logons → `Search-ADAccount -LockedOut` shows the locked test user |
