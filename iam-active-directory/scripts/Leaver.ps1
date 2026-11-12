<#
.SYNOPSIS
    Leaver: offboards a user and keeps an audit trail.
.DESCRIPTION
    Disables the account, saves current group memberships to a file,
    removes all group memberships, records date and ticket number,
    moves the account to the Disabled Users OU, and verifies.
.EXAMPLE
    .\Leaver.ps1 -User jwilson -Ticket HR-1042
#>
param(
    [Parameter(Mandatory)][string]$User,
    [Parameter(Mandatory)][string]$Ticket,
    [string]$BaseOU    = "OU=Corp,DC=lab,DC=local",
    [string]$AuditPath = "C:\Lab"
)

$date       = Get-Date -Format "yyyy-MM-dd"
$disabledOU = "OU=Disabled Users,$BaseOU"

# 0. Create an OU for disabled accounts (only the first time)
if (-not (Get-ADOrganizationalUnit -Filter "Name -eq 'Disabled Users'")) {
    New-ADOrganizationalUnit -Name "Disabled Users" -Path $BaseOU
}
# 1. Disable the account (most urgent step)
Disable-ADAccount $User
# 2. Save current groups for the audit trail
$groups = (Get-ADUser $User -Properties MemberOf).MemberOf
$groups | Out-File (Join-Path $AuditPath "${User}_groups_$date.txt")
# 3. Remove all group memberships
foreach ($g in $groups) { Remove-ADGroupMember $g -Members $User -Confirm:$false }
# 4. Document the reason
Set-ADUser $User -Description "Terminated $date - ticket $Ticket"
# 5. Move to the Disabled Users OU
Move-ADObject (Get-ADUser $User).DistinguishedName -TargetPath $disabledOU
# 6. Verify
Get-ADUser $User -Properties Enabled, Description, MemberOf |
    Select-Object Name, Enabled, Description, DistinguishedName, MemberOf
