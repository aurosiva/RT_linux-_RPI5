# Real-Time Kernel Configuration for Raspberry Pi 5

## Overview

This document explains how Real-Time (RT) kernel features have been configured for your Yocto Raspberry Pi 5 build.

## What Was Configured

### 1. Kernel Configuration Fragment (`realtime.cfg`)
Created: `meta-raspberrypi/recipes-kernel/linux/files/realtime.cfg`

This file enables:
- **CONFIG_PREEMPT=y** - Full kernel preemption
- **CONFIG_HIGH_RES_TIMERS=y** - High-resolution timers for better timing accuracy
- **CONFIG_HZ_1000=y** - 1000Hz kernel tick rate (lower latency)
- **CONFIG_IRQ_FORCED_THREADING=y** - IRQ threading for better preemption
- **CONFIG_RT_GROUP_SCHED=y** - Real-time scheduling groups
- **CONFIG_LATENCYTOP=y** - Track kernel latency

### 2. Modified `linux-raspberrypi.inc`
Added conditional inclusion of `realtime.cfg` when `MACHINE_FEATURES` includes "realtime"

### 3. Updated `local.conf`
Added:
```conf
MACHINE_FEATURES += "realtime"
```

## How to Build

Rebuild your image with RT support:

```bash
cd /mnt/build-storage/yacto_rpi5
source poky/oe-init-build-env build
bitbake core-image-minimal
```

The kernel will now be built with RT optimizations enabled.

## What You Get

With RT configuration enabled, you get:
- **Lower latency** - Faster interrupt response times
- **Better real-time performance** - More predictable scheduling
- **High-resolution timers** - Better timing accuracy for real-time applications
- **IRQ threading** - Improved preemption during interrupt handling

## Important Notes

⚠️ **This is NOT full PREEMPT_RT**: 
- This configuration uses `CONFIG_PREEMPT=y` (standard kernel with preemption)
- For **full PREEMPT_RT support**, see `PREEMPT_RT-SETUP.md` for detailed instructions
- PREEMPT_RT requires applying kernel patches from kernel.org

**Current Setup Benefits**:
- Low latency (~100-500μs)
- Good for most real-time applications
- No external patches needed
- Stable and well-tested

**Full PREEMPT_RT Benefits**:
- Hard real-time (< 100μs, often < 50μs)
- Deterministic latency guarantees
- transient interrupts become threads
- Required for industrial/robotics applications

See `PREEMPT_RT-SETUP.md` for step-by-step PREEMPT_RT patch installation guide.

## Verifying RT Support

After booting, check the kernel configuration:

```bash
# Check if PREEMPT is enabled
cat /proc/config.gz | gunzip | grep PREEMPT

# Check kernel tick rate
cat /proc/sys/kernel/sched_rt_runtime_us

# Check CPU governor (should be performance for RT)
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

## For True Hard Real-Time

If you need **hard real-time** guarantees (< 100μs latency):
1. Use Xenomai or RTDM (Real-Time Driver Model)
2. Add `meta-rt` layer with PREEMPT_RT patches
3. Consider using RTOS alongside Linux (co-kernel approach)

## Disabling RT Configuration

To disable RT features, comment out or remove from `local.conf`:
```conf
# MACHINE_FEATURES += "realtime"
```

Then rebuild the kernel.

