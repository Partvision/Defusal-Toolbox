Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# App categories and individual apps
$categories = @{
    "Browsers" = @(
        "Firefox", "Firefox ESR", "Brave", "Ungoogled Chromium", 
        "Chromium", "LibreWolf", "Mullvad Browser", "Tor Browser", 
        "Vivaldi", "Opera GX"
    )
    "Dev" = @(
        "Git", "Git LFS", "GitHub Desktop", "Node.js LTS", 
        "Python 3.13", "Rust", "Go", "Java 17 JDK", 
        "Docker Desktop", "PowerShell 7", "Windows Terminal"
    )
    "Utilities" = @(
        "7-Zip", "NanaZip", "Everything", "WizTree", 
        "ShareX", "Rufus", "Ventoy", "Notepad++", 
        "VS Code", "VLC", "MPC-HC", "Sumatra PDF", 
        "OBS Studio", "Steam", "Discord"
    )
    "Runtime" = @(
        "Visual C++ Redist", ".NET 8 Runtime", "DirectX", 
        "OpenAL", "Edge WebView2"
    )
    "Tweaks" = @(
        "Run System Tweaks"
    )
}

# Map display names to winget IDs
$appToPackageId = @{
    "Firefox" = "Mozilla.Firefox"
    "Firefox ESR" = "Mozilla.Firefox.ESR"
    "Brave" = "Brave.Brave"
    "Ungoogled Chromium" = "eloston.ungoogled-chromium"
    "Chromium" = "Hibbiki.Chromium"
    "LibreWolf" = "LibreWolf.LibreWolf"
    "Mullvad Browser" = "MullvadVPN.MullvadBrowser"
    "Tor Browser" = "TorProject.TorBrowser"
    "Vivaldi" = "VivaldiTechnologies.Vivaldi"
    "Opera GX" = "Opera.OperaGX"
    
    "Git" = "Git.Git"
    "Git LFS" = "GitHub.GitLFS"
    "GitHub Desktop" = "GitHub.GitHubDesktop"
    "Node.js LTS" = "OpenJS.NodeJS.LTS"
    "Python 3.13" = "Python.Python.3.13"
    "Rust" = "Rustlang.Rustup"
    "Go" = "GoLang.Go"
    "Java 17 JDK" = "EclipseAdoptium.Temurin.17.JDK"
    "Docker Desktop" = "Docker.DockerDesktop"
    "PowerShell 7" = "Microsoft.PowerShell"
    "Windows Terminal" = "Microsoft.WindowsTerminal"
    
    "7-Zip" = "7zip.7zip"
    "NanaZip" = "M2Team.NanaZip"
    "Everything" = "voidtools.Everything"
    "WizTree" = "AntibodySoftware.WizTree"
    "ShareX" = "ShareX.ShareX"
    "Rufus" = "Rufus.Rufus"
    "Ventoy" = "Ventoy.Ventoy"
    "Notepad++" = "Notepad++.Notepad++"
    "VS Code" = "Microsoft.VisualStudioCode"
    "VLC" = "VideoLAN.VLC"
    "MPC-HC" = "clsid2.mpc-hc"
    "Sumatra PDF" = "SumatraPDF.SumatraPDF"
    "OBS Studio" = "OBSProject.OBSStudio"
    "Steam" = "Valve.Steam"
    "Discord" = "Discord.Discord"
    
    "Visual C++ Redist" = "Microsoft.VCRedist.2015+.x64"
    ".NET 8 Runtime" = "Microsoft.DotNet.DesktopRuntime.8"
    "DirectX" = "Microsoft.DirectX"
    "OpenAL" = "OpenAL.OpenAL"
    "Edge WebView2" = "Microsoft.EdgeWebView2Runtime"
    
    "Run System Tweaks" = "TWEAKS_PLACEHOLDER"
}

# Create form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Defusal Toolbox - App Installer"
$form.Size = New-Object System.Drawing.Size(800, 600)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$form.ForeColor = [System.Drawing.Color]::White

# Create TabControl
$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Location = New-Object System.Drawing.Point(10, 10)
$tabControl.Size = New-Object System.Drawing.Size(760, 490)
$tabControl.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
$tabControl.ForeColor = [System.Drawing.Color]::White
$form.Controls.Add($tabControl)

# Store checkboxes
$allCheckboxes = @{}

# Create tabs for each category
foreach ($category in $categories.Keys | Sort-Object) {
    $tabPage = New-Object System.Windows.Forms.TabPage
    $tabPage.Text = $category
    $tabPage.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
    $tabPage.ForeColor = [System.Drawing.Color]::White
    $tabControl.TabPages.Add($tabPage)
    
    # Select All checkbox for category
    $selectAllCb = New-Object System.Windows.Forms.CheckBox
    $selectAllCb.Text = "Select All $category"
    $selectAllCb.Location = New-Object System.Drawing.Point(20, 10)
    $selectAllCb.Size = New-Object System.Drawing.Size(300, 20)
    $selectAllCb.ForeColor = [System.Drawing.Color]::FromArgb(100, 200, 255)
    $selectAllCb.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $tabPage.Controls.Add($selectAllCb)
    
    # Individual app checkboxes
    $y = 40
    $x = 20
    $column = 0
    
    foreach ($app in $categories[$category]) {
        $cb = New-Object System.Windows.Forms.CheckBox
        $cb.Text = $app
        $cb.Location = New-Object System.Drawing.Point($x, $y)
        $cb.Size = New-Object System.Drawing.Size(340, 25)
        $cb.ForeColor = [System.Drawing.Color]::White
        $cb.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $tabPage.Controls.Add($cb)
        
        # Store checkbox reference
        $key = "$category|$app"
        $allCheckboxes[$key] = $cb
        
        # Update Select All when individual checkbox changes
        $cb.Add_CheckedChanged({
            $parent = $this.Parent
            $selectAll = $parent.Controls[0]
            $allChecked = $true
            foreach ($control in $parent.Controls) {
                if ($control -is [System.Windows.Forms.CheckBox] -and $control -ne $selectAll) {
                    if (-not $control.Checked) {
                        $allChecked = $false
                        break
                    }
                }
            }
            $selectAll.Checked = $allChecked
        })
        
        $y += 30
        
        # Create second column if needed
        if ($y -gt 400 -and $column -eq 0) {
            $y = 40
            $x = 380
            $column = 1
        }
    }
    
    # Select All functionality
    $selectAllCb.Add_CheckedChanged({
        $parent = $this.Parent
        foreach ($control in $parent.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control -ne $this) {
                $control.Checked = $this.Checked
            }
        }
    })
}

# Bottom panel for buttons
$bottomPanel = New-Object System.Windows.Forms.Panel
$bottomPanel.Location = New-Object System.Drawing.Point(10, 510)
$bottomPanel.Size = New-Object System.Drawing.Size(760, 50)
$bottomPanel.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$form.Controls.Add($bottomPanel)

# Select All button
$selectAllBtn = New-Object System.Windows.Forms.Button
$selectAllBtn.Text = "Select All Apps"
$selectAllBtn.Location = New-Object System.Drawing.Point(10, 10)
$selectAllBtn.Size = New-Object System.Drawing.Size(120, 35)
$selectAllBtn.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
$selectAllBtn.ForeColor = [System.Drawing.Color]::White
$selectAllBtn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$selectAllBtn.Add_Click({
    foreach ($cb in $allCheckboxes.Values) {
        $cb.Checked = $true
    }
})
$bottomPanel.Controls.Add($selectAllBtn)

# Deselect All button
$deselectAllBtn = New-Object System.Windows.Forms.Button
$deselectAllBtn.Text = "Deselect All"
$deselectAllBtn.Location = New-Object System.Drawing.Point(140, 10)
$deselectAllBtn.Size = New-Object System.Drawing.Size(120, 35)
$deselectAllBtn.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
$deselectAllBtn.ForeColor = [System.Drawing.Color]::White
$deselectAllBtn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$deselectAllBtn.Add_Click({
    foreach ($cb in $allCheckboxes.Values) {
        $cb.Checked = $false
    }
})
$bottomPanel.Controls.Add($deselectAllBtn)

# Status label
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object System.Drawing.Point(270, 15)
$statusLabel.Size = New-Object System.Drawing.Size(300, 25)
$statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(100, 200, 100)
$statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$statusLabel.Text = "Select apps to install"
$bottomPanel.Controls.Add($statusLabel)

# Install button
$installBtn = New-Object System.Windows.Forms.Button
$installBtn.Text = "Install Selected"
$installBtn.Location = New-Object System.Drawing.Point(630, 10)
$installBtn.Size = New-Object System.Drawing.Size(120, 35)
$installBtn.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
$installBtn.ForeColor = [System.Drawing.Color]::White
$installBtn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$installBtn.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$installBtn.Add_Click({
    $selectedApps = @()
    $count = 0
    
    foreach ($key in $allCheckboxes.Keys) {
        if ($allCheckboxes[$key].Checked) {
            $parts = $key -split '\|'
            $category = $parts[0]
            $appName = $parts[1]
            
            # Get package ID
            if ($appToPackageId.ContainsKey($appName)) {
                $packageId = $appToPackageId[$appName]
                if ($packageId -eq "TWEAKS_PLACEHOLDER") {
                    $selectedApps += "Tweaks"
                } else {
                    $selectedApps += "$packageId|$appName"
                }
                $count++
            }
        }
    }
    
    if ($count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("No apps selected!", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }
    
    # Save to selected.txt
    $selectedApps | Set-Content "$PSScriptRoot\selected.txt"
    
    $statusLabel.Text = "$count app(s) selected for installation"
    $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(100, 255, 100)
    
    Start-Sleep -Milliseconds 500
    $form.Close()
})
$bottomPanel.Controls.Add($installBtn)

# Show form
[void]$form.ShowDialog()
