# Enable PREEMPT_RT patches for Raspberry Pi 5 with kernel 6.12.25
# Based on https://forums.raspberrypi.com/viewtopic.php?t=371851
#
# Kernel: 6.12.25 (Raspberry Pi)
# RT Patch: 6.12.49-rt13 (kernel.org)
# Version gap: +24 versions (may require manual conflict resolution)

# Force kernel version to 6.12.25
LINUX_VERSION = "6.12.25"

# RT patch configuration for kernel 6.12
RT_KERNEL_VERSION ?= "6.12"
RT_PATCH_MINOR ?= "49"
RT_PATCH_NUM ?= "13"

# Only add RT patches if preempt-rt feature is enabled
SRC_URI += "${@bb.utils.contains('MACHINE_FEATURES', 'preempt-rt', \
    'https://mirrors.edge.kernel.org/pub/linux/kernel/projects/rt/${RT_KERNEL_VERSION}/patch-${RT_KERNEL_VERSION}.${RT_PATCH_MINOR}-rt${RT_PATCH_NUM}.patch.gz;name=rtpatch', \
    '', d)}"

# Checksums for RT patch
SRC_URI[rtpatch.md5sum] = ""
SRC_URI[rtpatch.sha256sum] = "c17ab18e5c89ee5bdd7a418d5e0d97d50dc639c533a7c4d20eecd74fbd430f72"

# Apply RT patch after unpack
do_unpack:append() {
    if bb.utils.contains('MACHINE_FEATURES', 'preempt-rt', True, False, d):
        import subprocess
        import os
        
        # Find RT patch in workdir
        workdir = d.getVar('WORKDIR')
        patch_files = [f for f in os.listdir(workdir) if 'rt' in f and f.endswith('.patch.gz')]
        
        if patch_files:
            rt_patch = os.path.join(workdir, patch_files[0])
            kernel_src = d.getVar('S')
            
            bb.note("Applying PREEMPT_RT patch: %s" % rt_patch)
            
            # Decompress and apply patch
            import gzip
            import shutil
            
            # Decompress
            with gzip.open(rt_patch, 'rb') as f_in:
                with open(rt_patch.replace('.gz', ''), 'wb') as f_out:
                    shutil.copyfileobj(f_in, f_out)
            
            # Apply patch
            patch_file = rt_patch.replace('.gz', '')
            bb.note("Patching kernel at: %s" % kernel_src)
            result = subprocess.run(['patch', '-p1', '-d', kernel_src, '-i', patch_file], 
                                   capture_output=True, text=True, check=False)
            
            if result.returncode != 0:
                bb.warn("RT patch application returned errors:")
                bb.warn(result.stdout)
                bb.warn(result.stderr)
}

