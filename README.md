# Renesas-G3E-with-Qt6-setup
Renesas RZ/G3E Qt6 Setup Guide. Includes full BSP/SDK/cross-compilation docs.

# RZ/G3E & G2L Qt6 Setup

**Quick reference repo** for Renesas RZ/G3E (and G2L) with Qt 6.8.3.

Contains:
- ~~Pre-built Qt HMI binaries for both boards~~
- Short setup summary
- Full detailed guide in `Renesas_G3E_Setup_withQt6.md`

---
<del>
# Copy binary to target board
scp binaries/oven-hmi-g3e toot@<board-ip>:/usr/bin/

# On the board
chmod +x /usr/bin/oven-hmi-g3e
./oven-hmi-g3e

Same for oven-hmi-g2l and coffee-hmi-g2l on RZ/G2L
</del>