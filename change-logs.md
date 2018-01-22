# Change-logs

## 4. Jan 22, 2018
Stable release: v1_r3 
Synced changes from Smartpack kernel thanks to @sunilpaulmathew

## 3. Jan 18, 2018
Stable release: v1_r2
Removed o3 optimisations. Synced latest changes from LOS kernel git. Synced latest anykernel changes. Increased read ahead for internal + external storage to 512KB. Enabled kernel NTFS support. Merged a few perf fixes + improvements for IO schedulers. msm_adreno_tz will use lowest freq when no load (thanks to Lord Boeffla). 

## 2. Jan 15, 2018
Stable release: v1_r1
Removed CPU unclocking
Removed Faux sound for Franco sound control
Enable o3 optimisations
Removed userspace governor
Added extra safetynet workarounds 

## 1. Jan 13, 2018 
Stable release: v1
Removed UKSM, sound control, GPU underclock, adreno idler, Mako hotplug. Minor zzmoove tweaks. Remove test IO scheduler. Added ondemandplus, impulse and yankactive governors. Disabled crc for performance boost and exposed sysfs. 
