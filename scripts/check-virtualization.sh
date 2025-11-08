#!/bin/bash
# Virtualization Check and Troubleshooting Script

echo "=========================================="
echo "Checking Virtualization Support"
echo "=========================================="
echo ""

# Check CPU virtualization support
echo "1. Checking if CPU supports virtualization..."
if grep -E -q '(vmx|svm)' /proc/cpuinfo; then
    echo "   ✓ CPU supports virtualization"

    if grep -q vmx /proc/cpuinfo; then
        echo "   - Type: Intel VT-x (vmx)"
        VT_TYPE="Intel VT-x"
    elif grep -q svm /proc/cpuinfo; then
        echo "   - Type: AMD-V (svm)"
        VT_TYPE="AMD-V"
    fi

    CPU_SUPPORTS_VT=true
else
    echo "   ✗ CPU does NOT support virtualization"
    echo "   Your CPU is too old or doesn't support virtualization"
    CPU_SUPPORTS_VT=false
fi
echo ""

# Check if virtualization is enabled
echo "2. Checking if virtualization is enabled..."
if [ "$CPU_SUPPORTS_VT" = true ]; then
    # Check using kvm-ok if available
    if command -v kvm-ok &> /dev/null; then
        echo "   Running kvm-ok..."
        sudo kvm-ok
        KVM_OK=$?
    else
        # Manual check
        if [ -e /dev/kvm ]; then
            echo "   ✓ /dev/kvm exists - virtualization is enabled"
            VT_ENABLED=true
        else
            echo "   ✗ /dev/kvm does NOT exist - virtualization is disabled"
            VT_ENABLED=false
        fi
    fi
else
    echo "   Skipping (CPU doesn't support virtualization)"
fi
echo ""

# Check if running in a VM
echo "3. Checking if running inside a virtual machine..."
if systemd-detect-virt &> /dev/null; then
    VIRT_TYPE=$(systemd-detect-virt)
    if [ "$VIRT_TYPE" != "none" ]; then
        echo "   ⚠ Running inside a VM: $VIRT_TYPE"
        echo "   Note: Nested virtualization may not be supported"
        IN_VM=true
    else
        echo "   ✓ Running on physical hardware"
        IN_VM=false
    fi
else
    echo "   Unable to detect (systemd-detect-virt not available)"
    IN_VM=unknown
fi
echo ""

# Check kernel modules
echo "4. Checking virtualization kernel modules..."
if lsmod | grep -q kvm; then
    echo "   ✓ KVM module is loaded:"
    lsmod | grep kvm
    KVM_LOADED=true
else
    echo "   ✗ KVM module is NOT loaded"
    KVM_LOADED=false
fi
echo ""

# Provide recommendations
echo "=========================================="
echo "DIAGNOSIS & RECOMMENDATIONS"
echo "=========================================="
echo ""

if [ "$CPU_SUPPORTS_VT" = false ]; then
    echo "❌ PROBLEM: Your CPU doesn't support virtualization"
    echo ""
    echo "SOLUTIONS:"
    echo "  1. Use an older version of Docker (not recommended)"
    echo "  2. Upgrade to a newer CPU that supports virtualization"
    echo "  3. Use a different machine for Docker"
    echo ""

elif [ "$IN_VM" = true ]; then
    echo "⚠ PROBLEM: Running inside a VM without nested virtualization"
    echo ""
    echo "SOLUTIONS:"
    echo "  1. Enable nested virtualization on the host:"
    echo "     - VMware: Enable 'Virtualize Intel VT-x/EPT' in VM settings"
    echo "     - VirtualBox: VBoxManage modifyvm <vmname> --nested-hw-virt on"
    echo "     - KVM/QEMU: Add cpu mode='host-passthrough' to VM config"
    echo ""
    echo "  2. Run Docker on the host machine instead of VM"
    echo ""

elif [ "$VT_ENABLED" = false ]; then
    echo "❌ PROBLEM: Virtualization is supported but DISABLED in BIOS"
    echo ""
    echo "SOLUTION: Enable virtualization in BIOS/UEFI settings"
    echo ""
    echo "HOW TO ENABLE:"
    echo "  1. Reboot your computer"
    echo "  2. Press the BIOS key during startup:"
    echo "     - Common keys: F2, F10, F12, Del, Esc"
    echo "     - Check your PC manufacturer's documentation"
    echo ""
    echo "  3. Find the virtualization setting:"
    echo "     - Intel CPUs: Look for 'Intel VT-x', 'Intel Virtualization Technology', or 'Vanderpool'"
    echo "     - AMD CPUs: Look for 'AMD-V', 'SVM Mode', or 'Secure Virtual Machine'"
    echo ""
    echo "  4. Common BIOS locations:"
    echo "     - Advanced > CPU Configuration"
    echo "     - Security > Virtualization"
    echo "     - Advanced > System Configuration"
    echo "     - Chipset > North Bridge"
    echo ""
    echo "  5. Enable the setting and save changes (usually F10)"
    echo "  6. Reboot and run this script again"
    echo ""

elif [ "$KVM_LOADED" = false ]; then
    echo "⚠ PROBLEM: Virtualization enabled but kernel modules not loaded"
    echo ""
    echo "SOLUTION: Load KVM kernel modules"
    echo ""
    if [ "$VT_TYPE" = "Intel VT-x" ]; then
        echo "Run these commands:"
        echo "  sudo modprobe kvm"
        echo "  sudo modprobe kvm_intel"
    else
        echo "Run these commands:"
        echo "  sudo modprobe kvm"
        echo "  sudo modprobe kvm_amd"
    fi
    echo ""
    echo "To load automatically on boot:"
    if [ "$VT_TYPE" = "Intel VT-x" ]; then
        echo "  echo 'kvm_intel' | sudo tee -a /etc/modules"
    else
        echo "  echo 'kvm_amd' | sudo tee -a /etc/modules"
    fi
    echo ""

else
    echo "✓ Virtualization appears to be working!"
    echo ""
    echo "If Docker still doesn't work, the issue may be:"
    echo "  1. Docker installation problem - try reinstalling Docker"
    echo "  2. Permission issues - ensure user is in 'docker' group"
    echo "  3. Docker daemon not running - try: sudo dockerd &"
    echo ""
fi

echo "=========================================="
echo "SYSTEM INFORMATION"
echo "=========================================="
echo "CPU Model: $(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)"
echo "Kernel: $(uname -r)"
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '"')"
echo ""

# Offer to install cpu-checker
if ! command -v kvm-ok &> /dev/null; then
    echo "TIP: Install cpu-checker for better diagnostics:"
    echo "  sudo apt-get install -y cpu-checker"
    echo "  Then run: sudo kvm-ok"
    echo ""
fi
