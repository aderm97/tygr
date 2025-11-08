# Enabling Virtualization for Docker

Docker requires hardware virtualization to be enabled. If you're getting "virtualization not enabled" errors, follow this guide.

## Quick Check

Run the diagnostic script:
```bash
./scripts/check-virtualization.sh
```

## Common Issue: Virtualization Disabled in BIOS

This is the most common problem. Virtualization is supported by your CPU but disabled in BIOS/UEFI settings.

### How to Enable Virtualization in BIOS

#### Step 1: Reboot and Enter BIOS

1. Restart your computer
2. Press the BIOS key during startup (before OS loads):
   - **Dell**: F2 or F12
   - **HP**: F10 or Esc
   - **Lenovo**: F1 or F2
   - **ASUS**: F2 or Del
   - **Acer**: F2 or Del
   - **MSI**: Del
   - **Generic**: F2, F10, F12, Del, or Esc

**Tip**: The key is usually shown briefly on screen during boot ("Press F2 for Setup")

#### Step 2: Find the Virtualization Setting

The exact location varies by manufacturer. Look in these sections:

**Intel CPUs** - Look for one of these names:
- Intel Virtualization Technology
- Intel VT-x
- Vanderpool Technology
- VT-x Technology
- Virtualization Extensions

**AMD CPUs** - Look for one of these names:
- AMD-V
- SVM Mode
- Secure Virtual Machine
- AMD Virtualization

**Common BIOS Locations:**
```
Advanced
  ├── CPU Configuration
  │   └── Intel Virtualization Technology [Disabled] → Enable
  ├── System Configuration
  │   └── Virtualization Technology [Disabled] → Enable
  └── Processor Configuration

Security
  └── Virtualization

Chipset
  └── North Bridge
      └── Intel VT for Directed I/O [Disabled] → Enable
```

#### Step 3: Enable and Save

1. Change the setting from **Disabled** to **Enabled**
2. Save changes (usually F10)
3. Confirm and exit
4. System will reboot

#### Step 4: Verify

After reboot, run the check script:
```bash
./scripts/check-virtualization.sh
```

You should see:
```
✓ CPU supports virtualization
✓ /dev/kvm exists - virtualization is enabled
```

---

## Issue: Running in a Virtual Machine

If you're running this inside a VM (VMware, VirtualBox, etc.), you need **nested virtualization**.

### VMware Workstation/Player

1. Shut down the VM
2. Edit VM settings
3. Go to: Hardware → Processors
4. Check: **Virtualize Intel VT-x/EPT or AMD-V/RVI**
5. Click OK and start VM

Or via command line:
```bash
# Find your VM's .vmx file and add:
vhv.enable = "TRUE"
```

### VirtualBox

```bash
# Shut down VM first
VBoxManage modifyvm <vm-name> --nested-hw-virt on

# Or enable in GUI:
# Settings → System → Processor → Enable Nested VT-x/AMD-V
```

### KVM/QEMU/virt-manager

Edit VM XML configuration:
```xml
<cpu mode='host-passthrough' check='none'>
  <feature policy='require' name='vmx'/>  <!-- For Intel -->
  <!-- OR -->
  <feature policy='require' name='svm'/>  <!-- For AMD -->
</cpu>
```

Or via virt-manager:
1. Open VM details
2. Go to CPUs section
3. Set CPU model to: **host-passthrough**

---

## Issue: KVM Kernel Modules Not Loaded

If virtualization is enabled but KVM modules aren't loaded:

### Intel CPUs
```bash
sudo modprobe kvm
sudo modprobe kvm_intel

# Load automatically on boot
echo 'kvm_intel' | sudo tee -a /etc/modules
```

### AMD CPUs
```bash
sudo modprobe kvm
sudo modprobe kvm_amd

# Load automatically on boot
echo 'kvm_amd' | sudo tee -a /etc/modules
```

### Verify Modules
```bash
lsmod | grep kvm

# Should show:
# kvm_intel (or kvm_amd)
# kvm
```

---

## Alternative: Docker Without Virtualization

If you **cannot** enable virtualization, you have limited options:

### Option 1: Use Docker in WSL2 (Windows only)
If on Windows, WSL2 can run Docker with Hyper-V instead of KVM.

### Option 2: Use Podman (Rootless containers)
Podman doesn't require virtualization for basic containers:
```bash
sudo apt-get install podman
```

**Note**: Some TYGR features requiring full system emulation may not work.

### Option 3: Use Docker on a Different Machine
- Use a cloud VM (AWS, DigitalOps, etc.)
- Use a physical machine with virtualization
- Use a different computer

---

## Troubleshooting Commands

```bash
# Check CPU virtualization flags
grep -E '(vmx|svm)' /proc/cpuinfo

# Intel CPUs should show: vmx
# AMD CPUs should show: svm

# Check if KVM device exists
ls -la /dev/kvm

# Check if running in VM
systemd-detect-virt

# Check KVM modules
lsmod | grep kvm

# Install diagnostic tools
sudo apt-get install cpu-checker qemu-kvm

# Run diagnostic
sudo kvm-ok

# Should show: "KVM acceleration can be used"
```

---

## Manufacturer-Specific BIOS Guides

### Dell
- Key: F2 or F12
- Path: `Virtualization Support → Enable Intel Virtualization Technology`

### HP
- Key: F10 or Esc
- Path: `Security → System Security → Virtualization Technology → Enabled`

### Lenovo
- Key: F1 or F2
- Path: `Config → CPU → Intel Virtualization Technology → Enabled`

### ASUS
- Key: F2 or Del
- Path: `Advanced → CPU Configuration → Intel Virtualization Technology → Enabled`

### Acer
- Key: F2 or Del
- Path: `Main → Intel Virtualization Technology → Enabled`

### MSI
- Key: Del
- Path: `OC → CPU Features → Intel Virtualization Tech → Enabled`

---

## Still Having Issues?

1. **Check Windows Features (if dual-booting)**:
   - Windows Hyper-V can lock virtualization
   - Disable Hyper-V, WSL, or Windows Hypervisor Platform in Windows Features

2. **Update BIOS/UEFI**:
   - Some older BIOS versions have buggy virtualization support
   - Check manufacturer website for updates

3. **Check Secure Boot**:
   - Some systems have conflicts with Secure Boot
   - Try disabling Secure Boot temporarily

4. **Ask for Help**:
   - Email: hi@tygrsecurity.com
   - Include output of: `./scripts/check-virtualization.sh`

---

## Summary

**Most Common Fix**: Enable virtualization in BIOS
1. Reboot → Press F2/F10/Del
2. Find "Intel VT-x" or "AMD-V" setting
3. Change to Enabled
4. Save (F10) and reboot

After enabling, Docker should work! 🐳
