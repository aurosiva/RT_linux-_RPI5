# PREEMPT_RT Implementation Summary

## Changes Made

### 1. Updated `linux-raspberrypi_6.6.bbappend`
**File**: `meta-raspberrypi/recipes-kernel/linux/linux-raspberrypi_6.6.bbappend`

**Changes**:
- Added automatic RT patch download from kernel.org
- Configured patch version variables (RT_KERNEL_VERSION, RT_PATCH_MINOR, RT_PATCH_NUM)
- Implemented `do_unpack_append()` function to automatically apply RT patches
- Conditional loading only when `MACHINE_FEATURES` includes "preempt-rt"

**Key Features**:
- Downloads patches from: `https://mirrors.edge.kernel.org/pub/linux/kernel/projects/rt/6.6/`
- Automatically decompresses `.patch.gz` files
- Applies patches with `patch -p1` command
- Only activates when RT feature is enabled

### 2. Updated `realtime.cfg`
**File**: `meta-raspberrypi/recipes-kernel/linux/files/realtime.cfg`

**Changes**:
- Added commented PREEMPT_RT specific options
- Kept existing CONFIG_PREEMPT settings
- Added notes for RT-specific configurations

### 3. Updated `local.conf`
**File**: `build/conf/local.conf`

**Changes**:
- Added documentation on how to enable PREEMPT_RT
- Kept existing `MACHINE_FEATURES += "realtime"` for standard preemption
- Added instructions for enabling full RT support

### 4. Created Helper Script
**File**: `enable-rt-kernel.sh`

**Features**:
- Check available RT patches from kernel.org
- Enable/disable PREEMPT_RT support
- Show current RT configuration status
- Automate clean and rebuild process

## How to Use

### Step 1: Check Available RT Patches
```bash
cd /mnt/build-storage/yacto_rpi5
./enable-rt-kernel.sh check
```

This will show available RT patches for kernel 6.6

### Step 2: Update Patch Version
Edit `meta-raspberrypi/recipes-kernel/linux/linux-raspberrypi_6.6.bbappend`:
```conf
RT_PATCH_MINOR ?= "32"  # Change to latest available version
RT_PATCH_NUM ?= "32"    # Change to match RT version
```

### Step 3: Enable RT Support
```bash
./enable-rt-kernel.sh enable
```

This adds `MACHINE_FEATURES += "preempt-rt"` to `local.conf`

### Step 4: Rebuild Kernel and Image
```bash
./enable-rt-kernel.sh rebuild
```

Or manually:
```bash
source poky/oe-init-build-env build
bitbake virtual/kernel -c cleanall
bitbake core-image-minimal
```

### Step 5: Check Status
```bash
./enable-rt-kernel.sh status
```

## Important Notes

### Patch Version Matching
⚠️ **Critical**: RT patches must match your kernel version exactly or be close to it.

Your kernel version: **6.6.63**

You need an RT patch for 6.6.63 or compatible version (like 6.6.60-rt32).

### Available Patch Locations
- Main: https://mirrors.edge.kernel.org/pub/linux/kernel/projects/rt/6.6/
- Check for patches matching version 6.6.X

### Testing Without Full RT
Current setup already has `CONFIG_PREEMPT=y` enabled, which provides:
- Low latency (~100-500μs)
- Good for most real-time applications
- No patches needed

### Switching Between Modes

**Standard Preemption (Current)**:
```conf
MACHINE_FEATURES += "realtime"
```

**Full PREEMPT_RT**:
```conf
MACHINE_FEATURES += "realtime preempt-rt"
```

## Troubleshooting

### Patch Download Fails
- Check internet connection
- Verify patch URL is correct
- Check if patch version exists at kernel.org

### Patch Apply Fails
- Patch version mismatch
- Kernel source changed
- Try closer patch version

### Build Errors
- Check disk space (RT builds are larger)
- Review logs: `build/tmp/log/`
- Verify all dependencies installed

## Verification

After booting with RT kernel:

```bash
# Check kernel version (should show -rt suffix)
uname -r

# Check PREEMPT_RT enabled
zcat /proc/config.gz | grep PREEMPT_RT

# Test latency
cyclictest -t1 -p 99 -i 1000 -l 10000
```

## Files Modified

1. ✓ `meta-raspberrypi/recipes-kernel/linux/linux-raspberrypi_6.6.bbappend`
2. ✓ `meta-raspberrypi/recipes-kernel/linux/files/realtime.cfg`
3. ✓ `build/conf/local.conf`
4. ✓ `enable-rt-kernel.sh` (new)
5. ✓ Backup files created for safety

## Next Steps

1. **Find compatible RT patch**: Use `./enable-rt-kernel.sh check`
2. **Update patch version**: Edit bbappend file
3. **Enable RT**: Run `./enable-rt-kernel.sh enable`
4. **Rebuild**: Run `./enable-rt-kernel.sh rebuild`
5. **Flash SD card**: Use your existing flash process
6. **Test**: Boot and verify RT support

## References

- [Raspberry Pi Forum Discussion](https://forums.raspberrypi.com/viewtopic.php?t=371851)
- [Kernel.org RT Patches](https://mirrors.edge.kernel.org/pub/linux/kernel/projects/rt/)
- RT-KERNEL-SETUP.md (soft real-time guide)
- PREEMPT_RT-SETUP.md (detailed RT patch guide)

