# RT Kernel Verification - Quick Reference Card

## 🚀 Quick Boot Verification

### 1. Login to System
```bash
# Username: sramamo3
# Password: 12345
```

### 2. Check Kernel Version
```bash
uname -r
# ✅ Expected: 6.12.25-rt13-v8-16k
```

### 3. Verify RT Configuration
```bash
zcat /proc/config.gz | grep CONFIG_PREEMPT_RT
# ✅ Expected: CONFIG_PREEMPT_RT=y
```

### 4. Check RT Runtime Settings
```bash
cat /proc/sys/kernel/sched_rt_runtime_us
# ✅ Expected: 950000
```

### 5. Test RT Scheduling
```bash
sudo chrt -f 99 sleep 1 &
ps -eo pid,class,rtprio,ni,comm | grep sleep
# ✅ Expected: Shows FF (FIFO) class with priority 99
```

---

## 🧪 Performance Testing

### Latency Test
```bash
# Install RT tools
sudo apt update && sudo apt install rt-tests

# Run latency test
sudo cyclictest -t 4 -p 80 -n -i 10000 -l 10000
# ✅ Expected: Max latency < 100μs
```

### RT Scheduling Test
```bash
# Create RT tasks
sudo chrt -f 50 taskset -c 0 yes > /dev/null &
sudo chrt -f 51 taskset -c 1 yes > /dev/null &

# Verify scheduling
ps -eo pid,class,rtprio,ni,comm | grep yes
# ✅ Expected: Shows RT tasks with FF class
```

---

## 🔍 Detailed Verification

### Complete RT Check Script
```bash
#!/bin/bash
echo "=== RT Kernel Verification ==="
echo "Kernel: $(uname -r)"
echo "RT Config: $(zcat /proc/config.gz | grep CONFIG_PREEMPT_RT)"
echo "RT Runtime: $(cat /proc/sys/kernel/sched_rt_runtime_us)"
echo "RT Period: $(cat /proc/sys/kernel/sched_rt_period_us)"
echo "RT Mutexes: $(zcat /proc/config.gz | grep CONFIG_RT_MUTEXES)"
echo "RT Group Sched: $(zcat /proc/config.gz | grep CONFIG_RT_GROUP_SCHED)"
```

### Expected Results Summary
- **Kernel**: 6.12.25-rt13-v8-16k
- **RT Config**: CONFIG_PREEMPT_RT=y
- **RT Runtime**: 950000 μs
- **RT Period**: 1000000 μs
- **RT Mutexes**: CONFIG_RT_MUTEXES=y
- **RT Group Sched**: CONFIG_RT_GROUP_SCHED=y

---

## 🚨 Troubleshooting

### If RT Features Missing
```bash
# Check kernel messages
dmesg | grep -i "preempt\|rt"

# Verify RT patch was applied
grep -i "rt" /proc/version

# Check available scheduling policies
chrt --help
```

### Performance Issues
```bash
# Check CPU frequency
cat /proc/cpuinfo | grep MHz

# Monitor system load
htop

# Check for RT throttling
cat /proc/sys/kernel/sched_rt_runtime_us
```

---

## 📊 Success Indicators

### ✅ RT Kernel Working
- Kernel version contains `rt13`
- CONFIG_PREEMPT_RT=y in config
- RT scheduling classes available
- Sub-100μs latency in cyclictest
- RT mutexes enabled

### ❌ RT Kernel Not Working
- Kernel version without `rt` suffix
- CONFIG_PREEMPT_RT not set
- No RT scheduling classes
- High latency (>1000μs)
- Standard kernel features only

---

*Quick Reference - RT Kernel 6.12.25-rt13*
