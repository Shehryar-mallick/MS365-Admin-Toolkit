# Get-HWID.ps1
# Exports Autopilot HWID to a CSV, then copies it to a destination drive/folder.

param(
    [string]$OutputFile = "C:\HWID.csv",
    [string]$CopyTo     = "D:\"
)

# Use TLS 1.2 (helps on older images)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Ensure NuGet provider exists
if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
    Install-PackageProvider -Name NuGet -Force
}

# Trust PSGallery (avoid prompts)
try {
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted -ErrorAction Stop
} catch {
    # ignore if policy already set / restricted
}

# Install the script if missing
if (-not (Get-Command Get-WindowsAutopilotInfo -ErrorAction SilentlyContinue)) {
    Install-Script -Name Get-WindowsAutopilotInfo -Force
}

# Generate HWID CSV
Get-WindowsAutopilotInfo -OutputFile $OutputFile

# Copy it
Copy-Item -Path $OutputFile -Destination $CopyTo -Force

Write-Host "Done. HWID saved to $OutputFile and copied to $CopyTo"
