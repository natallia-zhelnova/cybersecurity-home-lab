<#
.SYNOPSIS
    Mover: moves a user to a new department without privilege creep.
.DESCRIPTION
    Moves the account to the new department OU, removes the old department
    group, adds the new one, updates Department and Title, and verifies.
.EXAMPLE
    .\Mover.ps1 -User sbrown -OldDept HR -NewDept Finance -NewTitle "Payroll Specialist"
#>
param(
    [Parameter(Mandatory)][string]$User,
    [Parameter(Mandatory)][string]$OldDept,
    [Parameter(Mandatory)][string]$NewDept,
    [Parameter(Mandatory)][string]$NewTitle,
    [string]$BaseOU = "OU=Corp,DC=lab,DC=local"
)

# 1. Move to the new department OU
Move-ADObject (Get-ADUser $User).DistinguishedName -TargetPath "OU=$NewDept,$BaseOU"
# 2. Remove old access (prevents privilege creep)
Remove-ADGroupMember "GRP-$OldDept-Staff" -Members $User -Confirm:$false
# 3. Grant new access
Add-ADGroupMember "GRP-$NewDept-Staff" -Members $User
# 4. Update attributes
Set-ADUser $User -Department $NewDept -Title $NewTitle
# 5. Verify
Get-ADUser $User -Properties Department, Title, MemberOf |
    Select-Object Name, Department, Title, DistinguishedName, MemberOf
