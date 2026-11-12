<#
.SYNOPSIS
    Access verification: who is in each role group, and which users
    have missing attributes or no role groups.
.EXAMPLE
    .\Verify-Access.ps1
#>
param([string]$BaseOU = "OU=Corp,DC=lab,DC=local")

# Members of every GRP-* group
Get-ADGroup -Filter "Name -like 'GRP-*'" | ForEach-Object {
    [pscustomobject]@{
        Group   = $_.Name
        Members = (Get-ADGroupMember $_ | Select-Object -Expand SamAccountName) -join ", "
    }
} | Format-Table -AutoSize

# Users with empty Department/Title or no role groups
Get-ADUser -Filter "Enabled -eq 'True'" -SearchBase $BaseOU -Properties Department, Title, MemberOf |
    Where-Object { -not $_.Department -or -not $_.Title -or -not $_.MemberOf } |
    Select-Object SamAccountName, Department, Title, @{n='Groups';e={$_.MemberOf.Count}}
