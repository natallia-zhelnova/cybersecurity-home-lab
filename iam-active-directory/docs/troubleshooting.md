# Troubleshooting log

Real problems I hit while building the lab, how I diagnosed them, and how I fixed them.

| # | Symptom | Diagnosis | Fix | Lesson |
|---|---|---|---|---|
| 1 | Setup showed "Choose what to keep" | `setup.exe` had been launched on the host OS, not inside the VM — continuing would have wiped the host | Cancelled; attached the ISO to the VM's optical drive instead | Check *where* an installer is running before clicking through |
| 2 | VM paused during install: `VERR_DISK_FULL` (`BLKCACHE_IOERR`) | Host C: drive full; VM disk was on C: | Recreated the VM on D:, set the default machine folder to D:, moved the Kali VM with VirtualBox **Move**; freed ~130 GB on C: by finding the largest files (WizTree) and removing old installers with PowerShell | Read the error ID; plan disk space before creating VMs |
| 3 | VM booted to `PXE-E06` — no bootable disk | Windows boot damaged by a forced reset during "Getting Windows ready" | Confirmed the virtual disk was still attached and had data (~14 GB), booted from install media, ran Startup Repair | Never reset during updates; take a snapshot before every major step |
| 4 | Static IP not applied via `sconfig` | The adapter kept a 169.254.x.x (APIPA) address after several attempts in sconfig | Set IP `192.168.56.10/24` and DNS `127.0.0.1` in adapter settings (`ncpa.cpl`), verified with `ipconfig` | Verify every network change |
| 5 | VM very slow, then froze; clock inside VM stopped | VirtualBox was running on top of Hyper-V (green turtle icon), enabled by Docker Desktop; 4 GB RAM was fully used | Raised VM to 6 GB RAM / 4 vCPU; created `Lab-mode` / `Docker-mode` scripts that switch `bcdedit /set hypervisorlaunchtype off/auto` | Check the hypervisor mode when nested virtualization behaves badly |
| 6 | VM hung after restoring "saved state" | Saved state of a Windows Server VM resumed into a frozen session | Powered off and cold-booted; shut down the VM normally instead of saving state | Prefer clean shutdowns for servers |
| 7 | User had no role groups although added in ADUC | `Get-ADUser -Properties MemberOf` returned nothing; group list showed 2 of 3 users | `Add-ADGroupMember`, then re-ran the checks | Verify access with a script, not by eye |
| 8 | Report showed empty Department/Title for 3 users | Users created manually in ADUC without those attributes | `Set-ADUser -Department -Title` | Data quality matters for reports and attribute-based groups |
