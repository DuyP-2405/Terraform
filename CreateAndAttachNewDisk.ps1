param(
    [string]$resourceGroupName = "CyberWatch",
    [string]$vmName = "DevVM",
    [string]$diskName = "NewDataDisk",
    [string]$location = "Japan West",
    [int]$diskSizeGB = 128
)

# Step 1: Authenticate using Managed Identity
Write-Output "Authenticating to Azure using Managed Identity..."
try {
    Connect-AzAccount -Identity -ErrorAction Stop
    Write-Output "Authentication successful."
} catch {
    Write-Error "Failed to authenticate using Managed Identity. Error: $_"
    exit
}

# Step 2: Create a New Disk
Write-Output "Creating a new managed disk..."
try {
    $diskConfig = New-AzDiskConfig -Location $location -SkuName "Standard_LRS" -CreateOption Empty -DiskSizeGB $diskSizeGB
    $newDisk = New-AzDisk -ResourceGroupName $resourceGroupName -DiskName $diskName -Disk $diskConfig -ErrorAction Stop
    Write-Output "Disk created successfully with ID: $($newDisk.Id)"
} catch {
    Write-Error "Failed to create the disk. Error: $_"
    exit
}

# Step 3: Verify Disk Creation
Write-Output "Verifying if the disk exists..."
try {
    $disk = Get-AzDisk -ResourceGroupName $resourceGroupName -DiskName $diskName -ErrorAction Stop
    Write-Output "Disk exists: $($disk.Name)"
} catch {
    Write-Error "Disk not found. Error: $_"
    exit
}

# Step 4: Retrieve the Virtual Machine
Write-Output "Retrieving the virtual machine..."
try {
    $vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName -ErrorAction Stop
    Write-Output "VM retrieved successfully: $vmName"
} catch {
    Write-Error "Failed to retrieve the VM. Error: $_"
    exit
}

# Step 5: Attach the Disk to the VM
Write-Output "Attaching the new disk to the VM..."
try {
    $vm | Add-AzVMDataDisk -Name $diskName -CreateOption Attach -ManagedDiskId $newDisk.Id -Caching ReadWrite -Lun 1 -ErrorAction Stop
    Write-Output "Disk attached to the VM successfully."
} catch {
    Write-Error "Failed to attach the disk. Error: $_"
    exit
}

# Step 6: Update the VM
Write-Output "Updating the VM to apply changes..."
try {
    Update-AzVM -VM $vm -ResourceGroupName $resourceGroupName -ErrorAction Stop
    Write-Output "VM updated successfully. Disk is now attached."
} catch {
    Write-Error "Failed to update the VM. Error: $_"
    exit
}

Write-Output "Runbook completed successfully."