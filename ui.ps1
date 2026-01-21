Add-Type -AssemblyName System.Windows.Forms

$form = New-Object System.Windows.Forms.Form
$form.Text = "Windows Install Picker"
$form.Size = "400,350"

$items = @("Browsers","Dev","Utilities","Runtime","Tweaks")
$checks = @{}
$y = 20

foreach ($i in $items) {
    $cb = New-Object System.Windows.Forms.CheckBox
    $cb.Text = $i
    $cb.Location = "20,$y"
    $form.Controls.Add($cb)
    $checks[$i] = $cb
    $y += 30
}

$btn = New-Object System.Windows.Forms.Button
$btn.Text = "Install That Shit"
$btn.Location = "20,$y"
$btn.Add_Click({
    $out = @()
    foreach ($k in $checks.Keys) {
        if ($checks[$k].Checked) { $out += $k }
    }
    $out | Set-Content "$PSScriptRoot\selected.txt"
    $form.Close()
})

$form.Controls.Add($btn)
$form.ShowDialog()
