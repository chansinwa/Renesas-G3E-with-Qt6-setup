# **Quick Start Summary**

This guide sets up the RZ/G3E BSP with Qt6 for building images and SDKs, then cross-compiles projects for the target device. Key prerequisites: Ubuntu (20.04 or 22.04), sufficient hardware (16GB RAM, 200GB+ disk), downloaded BSP/Qt6 packages. **Important: Avoid apt update/upgrade to prevent breaking dependencies.**

1. **Hardware Setup**: Connect power, debug port (Tera Term), write .wic to microSD, boot board per handbook.  
2. **Prepare Workspace**: Create \~/rzg3e\_bsp\_v1.0.0, place/unzip BSP/Qt6/graphics/codec files, init build env with TEMPLATECONF=... source poky/oe-init-build-env build.  
3. **Add Layers**: Use bitbake-layers add-layer for Qt6, graphics, codecs (disable Chromium to avoid failures).  
4. **Configure local.conf**: Add MACHINE, thread limits if needed, optional Qt examples.  
5. **Build Image**: MACHINE=smarc-rzg3e bitbake core-image-qt (may take days; disable QtWebEngine if fails).  
6. **Build/Install SDK**: bitbake core-image-qt \-c populate\_sdk, install to custom path, source environment.  
7. **Cross-Compile Project**: In project dir, create build/, check permissions, run cmake .. with toolchain/Qt paths (or use custom\_toolchain.cmake), then make.  
8. **Deploy**: Transfer binary to device, test.

For details, failures, and options, see full sections below. Refer to official docs for troubleshooting.

# **Initial Setting**

1. Connect 15V+ power supply  
2. Connect type-B for the debug port, open Tera Term for command control  
3. Use Win32DiskImager to write the .wic file into a microSD card.  
4. Transfer the necessary files to the board from the microSD card  
5. Turn on the SW Mode to download mode, and insert the SD card into the board  
6. According to the quick start handbook [RZ/G3E Linux Start-up Guide Rev.1.00](https://www.renesas.com/en/document/gde/rzg3e-linux-start-guide-rev100?srsltid=AfmBOop0RjDW_kmWdue3NO2O-s3Nazz7UhFV3Z940LXueBte4pwAPVOt), to type commands  
7. connect to an HDMI screen  
8. power on the board and reset

**\*\*Before we start, the first important thing you need to remember \- DO NOT apt upgrade and apt update\*\***

# **Qt6 BSP Image set up** 

Official documentation here: [Qt6 Start-up Guide (for RZ/G3E Board Support Package v1.0.0)](https://www.renesas.com/en/document/rln/qt6-start-guide-rzg3e-board-support-package-v100?language=en&r=25574498). Also, there’s a clearer and simplified version (worth reading, especially the parts highlighted in red) recorded by intern Ronnie (a Linux expert): [Custom linux imaging documentation.docx](https://defondetech-my.sharepoint.com/:w:/r/personal/tnlow_defondetech_com/_layouts/15/Doc.aspx?sourcedoc=%7BE07BF572-9E0D-4A4C-B09F-779210DC9F9C%7D&file=Custom%20linux%20imaging%20documentation.docx&fromShare=true&action=default&mobileredirect=true)

Here's my setup process record after finishing pre-build image setup. Note: This was initially for personal review, not as an instruction guide, so it includes extra details and may feel lengthy. Bear with it for the insights.

1. Download the required files ([RZ/G3E Board Support Package | Renesas](https://www.renesas.com/en/software-tool/rzg3e-board-support-package#download)) to the host PC

![][image1]  
also download Qt6 BSP RTK0EF0224Z00001ZJ\_v4.0.0.1 ([RZ MPU Qt Package | Renesas](https://www.renesas.com/en/software-tool/rz-mpu-qt-package))

2. Ubuntu 22.04  
   1. 16GB RAM, 200GB Disk, 8-core CPU  
   2. set up shared folder/clipboard  
   3. make a working directory: \~/rzg3e\_bsp\_v1.0.0

   (Update: we have switched to our git server with Ubuntu 20.04, which has more disk space, sufficient to bitbake a full image. Although the git server Ubuntu is not 22.04, it’s still workable. The only one thing need topay attention is that you might need to manually point the toolchain to the suitable Qt host path and CMake path since 20.04 does not natively support Qt6. There will be more details to introduce these relevant steps later.)

3.  Ensure these files are in \~/rzg3e\_bsp\_v1.0.0 (should cp from the host PC(downloaded before) to the Linux machine):  
         \- RTK0EF0045Z0040AZJ-v1.0.0.zip (base BSP) – already there.  
         \- RTK0EF0224Z00001ZJ\_v4.0.0.1.zip (Qt6 package) – add this.  
         \- Optional: RTK0EF0045Z14001ZJ-v4.2.0.2\_rzg\_EN.zip (graphics).  
         \- Optional: RTK0EF0207Z00001ZJ-v4.4.0.0\_rzg3e\_EN.zip (codec)  
   ~~\- Optional: RTK0EF0193Z00002ZJ\_v4.0.0.0.zip(chromium)~~   
     
4.  Then run, from \~/rzg3e\_bsp\_v1.0.0:  
     1\. Unpack Qt6 recipes for building :
```bash
 unzip ./RTK0EF0224Z00001ZJ\_v4.0.0.1.zip 
 tar zxvf ./RTK0EF0224Z00001ZJ\_v4.0.0.1/rzg\_bsp\_qt6.8.3\_v4.0.0.1.tar.gz 
```

     2\. (Optional) Unpack graphics/codec layers:

```bash
 unzip ./RTK0EF0045Z14001ZJ-v4.2.0.2\_rzg\_EN.zip 
 tar zxvf ./RTK0EF0045Z14001ZJ-v4.2.0.2\_rzg\_EN/meta-rz-features\_graphics\_v4.2.0.2.tar.gz 
 unzip ./RTK0EF0207Z00001ZJ-v4.4.0.0\_rzg3e\_EN.zip 
 tar zxvf ./RTK0EF0207Z00001ZJ-v4.4.0.0_rzg3e_EN/meta-rz-features_codec_v4.4.0.0.tar.gz
 ~~unzip ./RTK0EF0193Z00002ZJ\_v4.0.0.0.zip tar zxvf ./RTK0EF0193Z00002ZJ\_v4.0.0.0/rzg\_bsp\_chromium132\_v4.0.0.0.tar.gz~~ 
```
   After that, you should see meta-qt6 and meta-rz-qt6 alongside poky/meta-renesas.

   Then proceed with: 
```bash
 TEMPLATECONF=$PWD/meta-renesas/meta-rz-distro/conf/templates/rz-conf/ source poky/oe-init-build-env build 
```
   (remember to run this command each time before bitbaking an image or sdk etc)


5. Add required layers  
   From \~/rzg3e\_bsp\_v1.0.0/build:
```bash
 bitbake-layers add-layer ../meta-qt6 
 bitbake-layers add-layer ../meta-rz-qt6 
 bitbake-layers add-layer ../meta-rz-features/meta-rz-graphics 
 bitbake-layers add-layer ../meta-rz-features/meta-rz-codecs 
 bitbake-layers add-layer ../meta-clang 
 bitbake-layers add-layer ../meta-lts-mixins 
 \# bitbake-layers add-layer ../meta-browser/meta-chromium 
 bitbake-layers add-layer ../meta-openembedded/meta-networking 
 \# bitbake-layers add-layer ../meta-browser-hwdecode 
```
   

\# Commented out due to build failure.

*Note(added by 11/02/2026): disable the Chromium layers, make sure only build the core-image-qt first instead of combining everything. After many experiments, adding chromium browser layers when building the image always led to failure without exception.*

6. (Optional, cuz this is for chromium)Add the below lines to “\~/rzg3e\_bsp\_v1.0.0/build/conf/local.conf”.  
   
```bash
 IMAGE\_INSTALL:append \= " chromium-ozone-wayland " 
 IMAGE\_INSTALL:append \= " ntp " 
 IMAGE\_INSTALL:append \= " ttf-sazanami-gothic ttf-sazanami-mincho " 
 IMAGE\_INSTALL:append \= " adwaita-icon-theme-cursors " 
```
   

   

7.  (Optional) Add Qt examples: edit conf/local.conf and append: 

| IMAGE\_INSTALL: append \= " packagegroup-qt6-examples " |
| :---- |

   

   

8. Append MACHINE \= “smarc-rzg3e” to conf/local.conf (the default MACHINE ??= “qemux86-64” remains, but we’ll override it in commands)  
     
9. (Update: This issue doesn't occur on the git server with more disk space)  
   Issue: If OOM occurs during building (in step 8), limits threads by adding to the bottom of build/conf/local.conf:  
   1. BB\_NUMBER\_THREADS \= “4”  
   2. PARALLEL\_MAKE \= “-j4”

10. Build the Qt image:

| \~/rzg3e\_bsp\_v1.0.0/build$ MACHINE=smarc-rzg3e bitbake core-image-qt |
| :---- |

11. *Update(11/02/2026): if disk space is sufficient, and without adding Chromium, can ignore these steps(11-13) of disable qtwebengine. The commands below with @Ubuntu22 are for the local VM before.*  
    QtWebEngine failed multiple times, so I have disabled it due to no web requirements now.  
    sitachan@Ubuntu22:\~/rzg3e\_bsp\_v1.0.0/build$ mkdir \-p \~/rzg3e\_bsp\_v1.0.0/meta-rz-qt6/recipes-qt/qt6  
    sitachan@Ubuntu22:\~/rzg3e\_bsp\_v1.0.0/build$ nano \~/rzg3e\_bsp\_v1.0.0/meta-rz-qt6/recipes-qt/qt6/qtwebengine\_%.bbappend  
      
    add:  
    PACKAGECONFIG \= ""  
    save and exit  
      
    sitachan@Ubuntu22:\~/rzg3e\_bsp\_v1.0.0/build$ bitbake \-c cleansstate qtwebengine  
      
    then rebuild again:  
    sitachan@Ubuntu22:\~/rzg3e\_bsp\_v1.0.0/build$ MACHINE=smarc-rzg3e bitbake core-image-qt  
      
12. disable the qtwebengine\_git.bbappend  
    mv \~/rzg3e\_bsp\_v1.0.0/meta-rz-qt6/recipes-qt6/qt6/qtwebengine\_git.bbappend \\  
     \~/rzg3e\_bsp\_v1.0.0/meta-rz-qt6/recipes-qt6/qt6/qtwebengine\_git.bbappend.disabled  
      
13. Remove the skips from conf/local.conf:

     BBMASK \+= "meta-qt6/recipes-qt/qt6/qtwebengine"  
     IMAGE\_INSTALL:remove \= "qtwebengine qtwebengine-qmlplugins qtwebengine-dev"

14. Rebuild(if bitbake failed):

| MACHINE=smarc-rzg3e bitbake core-image-qt |
| :---- |

Dont worry, it wont restart from zero. cuz it stores all packages installed/installing to the cache/ when you doing bitbake, it may save a lot of time when rebitbake. (But the condition is that you haven't deleted the cache/) 

The image bitbake process is quite long, it takes over 3 days for my case.

—--------------------------------------------------------------------------------------------------------

# **G3E SDK install && cross compile program**

Reaching this step means your core-image-qt has built successfully. And fortunately, the SDK building is faster than the image since your image cache helps you save a lot of time. 

(using sita\_work directory as example)

## SDK install

(*Note: all sdk installation steps can be found in the official documentation, this detailed document will be useful: [RZ/G3E Linux Start-up Guide Rev.1.00](https://www.renesas.com/en/document/gde/rzg3e-linux-start-guide-rev100?srsltid=AfmBOop0RjDW_kmWdue3NO2O-s3Nazz7UhFV3Z940LXueBte4pwAPVOt)*)  
I just retrieved part of the relevant information here based on my current progress.

Building core-image-qt sdk:

| $ cd \~/rzg3e\_bsp\_v1.0.0/build $ MACHINE=smarc-rzg3e bitbake core-image-qt \-c populate\_sdk |
| :---- |

The resulting SDK installer will be in “build/tmp/deploy/sdk/”.  
To run the installer, execute the following command to your customized path(for me, I extracted the sdk to the \<rzg3e\_bsp\_v1.0.0/gitadmin/workspace/sdks/rzg3e\_qt6/\>):

| $ sudo sh rz-vlp-glibc-x86\_64-core-image-qt-cortexa55-smarc-rzg3e-toolchain-5.0.8.sh |
| :---- |

Result should be like:  
![][image2]

Checking the path to ensure it’s correct for the cmake  
After building sdk, cd to the project directory, sudo mkdir build/. And source the SDK environment.

source the SDK environment like this:

| source \~/rzg3e\_bsp\_v1.0.0/workspace/sdks/rzg3e\_qt6/environment-setup-cortexa55-poky-linux |
| :---- |

or

| . /home/gitadmin/rzg3e\_bsp\_v1.0.0/workspace/sdks/rzg3e\_qt6/environment-setup-cortexa55-poky-linux |
| :---- |

—-----------------------------------------------------------------------------------------

(Optional if all setup are correct, but recommend to check first before cmake)check the info below if needed:

| echo $OECORE\_TARGET\_SYSROOT |
| :---- |

\# Should be \~/rzg3e\_bsp\_v1.0.0/workspace/sdks/rzg3e\_qt6/sysroots/cortexa55-poky-linux

| echo $OECORE\_NATIVE\_SYSROOT |
| :---- |

\# Should be \~/rzg3e\_bsp\_v1.0.0/workspace/sdks/rzg3e\_qt6/sysroots/x86\_64-pokysdk-linux (host tools here)

| echo $CXX |
| :---- |

 \# Should be aarch64-poky-linux-g++ or similar

| echo $CMAKE\_TOOLCHAIN\_FILE |
| :---- |

\# Should point to OEToolchainConfig.cmake in $OECORE\_NATIVE\_SYSROOT/usr/share/cmake/

My output is here:  
![][image3]

—----------------------------------------------------------------------------------------------------------------------

## Start to cross compile project via cmake and make executable binary file for target device (g3e aarch64)

### Check the permission

| ls \-al // Ensure read/write access, especially for build/ |
| :---- |

Otherwise, if there is no permission for the target user (e.g. my case will be gitadmin, not root):

| sudo chown \-R gitadmin:gitadmin build |
| :---- |

Give gitadmin the project build/ directory permission

### Start cmake

~~(ignore this failed cmd)(make .. \-DQT\_HOST\_PATH\_CMAKE\_DIR=/home/gitadmin/rzg3e\_bsp\_v1.0.0/workspace/sdks/rzg3e\_qt6/sysroots/x86\_64-pokysdk-linux/usr/lib/cmake)~~

Method 1: type \-DQT……manually (easier but need to type each time)  
just run:

| cmake .. \-DCMAKE\_TOOLCHAIN\_FILE=$CMAKE\_TOOLCHAIN\_FILE \-DQt6\_DIR=$OECORE\_TARGET\_SYSROOT/usr/lib/cmake/Qt6 \-DQT\_HOST\_PATH=$OECORE\_NATIVE\_SYSROOT/usr |
| :---- |

Output should be like this:![][image4]

After cmake is successful, you need to make an executable file

| make \-j2 |
| :---- |

use \-j2 due to only 2 cores for our poor git server, you may check yours with lscpu

Method 2: make a custom\_toolchain.cmake file instead of typing \-DQT…. each time(only setup once, and for future run, just type cmake..)  
In project directory, create a custom\_toolchain.cmake file:

```bash
 gitadmin@DEIL-HK-GIT01:\~/rzg3e\_bsp\_v1.0.0/sita\_work/Qt\_Wega\_HMI$ sudo touch custom\_toolchain.cmake 
 gitadmin@DEIL-HK-GIT01:\~/rzg3e\_bsp\_v1.0.0/sita\_work/Qt\_Wega\_HMI$ sudo vim custom\_toolchain.cmake 
```

add to this toolchain cmake file:

```bash
 \# Wrap SDK toolchain 
 include($ENV{CMAKE\_TOOLCHAIN\_FILE}) 
 \# Qt6 paths (these get cached) 
 set(Qt6\_DIR $ENV{OECORE\_TARGET\_SYSROOT}/usr/lib/cmake/Qt6) 
 set(QT\_HOST\_PATH $ENV{OECORE\_NATIVE\_SYSROOT}/usr) 
```

don’t forget to save :wq

Then go to the project build directory(make sure it is clean)

| cmake .. \-DCMAKE\_TOOLCHAIN\_FILE=../custom\_toolchain.cmake |
| :---- |

(Note: if you accidentally remove the whole build/ folder, you can remake a new build/, but don’t forget to check the permissions\! A better way to avoid to set the permission again is just remove the files/folders inside the build/ rather than a whole build directory)

For the future rerun, can just type this command in this project build/

| cmake .. |
| :---- |

—---------------------------------------------------------------------------------------------------------

## Some Failed Experiments Records 

(Not recommended to follow, just for your reference)

Modify the sysroot toolchain file to include the cmake path  
find . \-name “OEToolchainConfig.cmake”  
the toolchain file shall located at: sita\_work/rzg3e\_bsp\_v1.0.0/build/tmp/sysroots-components/x86\_64/cmake-native/usr/share/cmake/OEToolchainConfig.cmake

(remember to use sudo vim, otherwise cannot save)  
![][image5]  
add  
set(QT\_HOST\_PATH "/home/gitadmin/rzg3e\_bsp\_v1.0.0/workspace/sdks/rzg3e\_qt6/sysroots/x86\_64-pokysdk-linux/usr/lib/cmake/")

(12/02/2026 Noted: this step directly changed the default sysroot toolchain,)

—---------------------------------------------------------------------

# **Others:**

## 20260120

for the virtual machine Linux system, gitadmin@172.16.4.167

Already mounted (done by Ronnie) once logged in  
can check by mount | grep sdb  
Or sudo fdisk \-l, the sdb is the virtual space (2TB)  
The program to mount the gitadmin can be checked by: cat /etc/fstab  
\*\* Important \*\* DO NOT apt upgrade and apt update

## 20260122

 (Update: Failed experiments. Some linker problems occurred when directly copy/paste, so some paths pointing to hklow\_work are already added to the layers/setup that won't change even if modified to sita\_work manually.)  
Copied hklow\_work to sita\_work, the folder owner changed, need to modify the permission, otherwise, cannot build the sdk:  
sudo chown \-R gitadmin:gitadmin build  
password: P@55w0rd2024

rm \-rf tmp //the TMPDIR has changed the location due to this new copied folder

MACHINE=smarc-rzg3e bitbake core-image-qt \-c populate\_sdk

## Release VirtualBox disk space – Failed

[https://serverfault.com/questions/779106/how-to-decrease-virtual-size-capacity-of-a-virtualbox-vdi-file](https://serverfault.com/questions/779106/how-to-decrease-virtual-size-capacity-of-a-virtualbox-vdi-file)

1. rm \-rf /rzg3e\_bsp\_v1.0.0/build  
2. Open GParted Live iso → resize/remove dev/sda3 partition disk space  
3. navigate to the VM Box folder to compact the ubuntu vdi file:   
   (base) PS C:\\Program Files\\Oracle\\VirtualBox\> ./VboxManage.exe modifymedium disk "C:\\Users\\swchan\\VirtualBox VMs\\Ubuntu22.04.5\\Ubuntu22.04.5.vdi" \--compact  
4. make a new Virtual Disk with desired space  
5. Move content from old disk to inside the new disk:  
   (base) PS C:\\Program Files\\Oracle\\VirtualBox\> .\\VboxManage clonemedium disk "C:\\Users\\swchan\\VirtualBox VMs\\Ubuntu22.04.5\\Ubuntu22.04.5.vdi" "C:\\Users\\swchan\\VirtualBox VMs\\Ubunru22.04.5 amd\\Ubunru22.04.5 amd.vdi" \--existing  
   
