#!/bin/bash

# Note: for HS8200 with loader 6.00!
#
# CAUTION:
# 
# This script reflashes the kernel by also reflashing the
# partitions 8, 7 and 1 (requirement of loader 6.00).
# Partition 1 is flashed as the squashfs dummy only, leaving
# the enigma2 part of it untouched.
CURDIR=$1
TUFSBOXDIR=$2
OUTDIR=$3
TMPKERNELDIR=$4
RESELLERID=$5

#echo "CURDIR       = $CURDIR"
#echo "TUFSBOXDIR   = $TUFSBOXDIR"
#echo "OUTDIR       = $OUTDIR"
#echo "TMPKERNELDIR = $TMPKERNELDIR"
#echo "RESELLERID   = $RESELLERID"

MKSQUASHFS=$CURDIR/../common/mksquashfs3.3
FUP=$CURDIR/fup

OUTFILE=$OUTDIR/HS8200_L600_kernel_flash_R$RESELLERID.ird

if [ ! -e $OUTDIR ]; then
  mkdir $OUTDIR
fi

if [ -e $OUTFILE ]; then
  rm -f $OUTFILE
fi

# Note: for HS8200 with loader 6.00!
#
echo "-----------------------------------------------------------------------------"
echo "Prepare kernel file..."
cp $TMPKERNELDIR/uImage $CURDIR/uImage
# Note: padding the kernel to set start offset of type 8 (root) does not work;
# bootloader always uses the actual kernel size (at offset 0x0c?).
# CAUTION for a known problem: a kernel with a size that is an exact multiple
# 0x20000 bytes cannot be flashed, due to a bug in the loader.
# This condition is tested for in this script later on.
echo "-----------------------------------------------------------------------------"
echo "Checking kernel size..."
SIZEK=`stat $CURDIR/uImage -t --format %s`
SIZEKD=`printf "%d" $SIZEK`
SIZEKH=`printf "%08X" $SIZEK`
if [[ $SIZEKD < "1048577" ]]; then
  echo -e "\033[01;31m"
  echo "Kernel is smaller than 1 Mbyte." > /dev/stderr
  echo "Are you sure this is correct?" > /dev/stderr
  echo -e "\033[00m"
  echo "Exiting..."
  exit
fi
if [[ $SIZEKD > "3276799" ]]; then
  echo -e "\033[01;31m"
  echo "KERNEL TOO BIG: 0x$SIZEKH instead of max. 0x0031FFFF bytes" > /dev/stderr
  echo -e "\033[00m"
  echo "Exiting..."
  exit
else
  echo "KERNEL size is: $SIZEKD (0x$SIZEKH, max. 0x0031FFFF) bytes"
fi

# Note: root size is adjusted so that the type 7 partition is always flashed at 0x3A0000.
# This in turn will leave the real root starting at 0x3E0000 (0x3C0000 + squashfs dummy) untouched.
TMPDUMDIR=$CURDIR/tmp/DUMMY
if [ ! -e $TMPDUMDIR ]; then
  mkdir $TMPDUMDIR
fi
# Determine size
if [[ $SIZEKD < "3276800" ]] && [[ $SIZEKD > "3145728" ]]; then
  FAKESIZE="196385"
else
  FAKESIZE="999" #used to flag illegal kernel size
fi
if [[ $SIZEKD < "3145728" ]] && [[ $SIZEKD > "3014656" ]]; then
  FAKESIZE="196385"
fi
if [[ $SIZEKD < "3014656" ]] && [[ $SIZEKD > "2883584" ]]; then
  FAKESIZE="327455"
fi
if [[ $SIZEKD < "2883584" ]] && [[ $SIZEKD > "2752512" ]]; then
  FAKESIZE="458527"
fi
if [[ $SIZEKD < "2752512" ]] && [[ $SIZEKD > "2621440" ]]; then
  FAKESIZE="589599"
fi
if [[ $SIZEKD < "2621440" ]] && [[ $SIZEKD > "2490368" ]]; then
  FAKESIZE="720670"
fi
if [[ $SIZEKD < "2490368" ]] && [[ $SIZEKD > "2359296" ]]; then
  FAKESIZE="851741"
fi
if [[ $SIZEKD < "2359296" ]] && [[ $SIZEKD > "2228224" ]]; then
  FAKESIZE="982810"
fi
if [[ $SIZEKD < "2228224" ]] && [[ $SIZEKD > "2097152" ]]; then
  FAKESIZE="1113881"
fi
if [[ $SIZEKD < "2097152" ]] && [[ $SIZEKD > "1966080" ]]; then
  FAKESIZE="1244953"
fi
if [[ $SIZEKD < "1966080" ]] && [[ $SIZEKD > "1835008" ]]; then
  FAKESIZE="1376025"
fi
if [[ $SIZEKD < "1835008" ]] && [[ $SIZEKD > "1703936" ]]; then
  FAKESIZE="1507097"
fi
if [[ $SIZEKD < "1703936" ]] && [[ $SIZEKD > "1572864" ]]; then
  FAKESIZE="1638169"
fi
if [[ $SIZEKD < "1572864" ]] && [[ $SIZEKD > "1441792" ]]; then
  FAKESIZE="1769241"
fi
if [[ $SIZEKD < "1441792" ]] && [[ $SIZEKD > "1310720" ]]; then
  FAKESIZE="1900314"
fi
if [[ $SIZEKD < "1310720" ]] && [[ $SIZEKD > "1179650" ]]; then
  FAKESIZE="2031386"
fi
if [[ $SIZEKD < "1179648" ]] && [[ $SIZEKD > "1048576" ]]; then
  FAKESIZE="2162458"
fi
if [[ "$FAKESIZE" == "999" ]]; then
  echo -e "\033[01;31m"
  echo "This kernel cannot be flashed, due to its size being" > /dev/stderr
  echo "an exact multiple of 0x20000. This is a limitation of" > /dev/stderr
  echo "bootloader 6.00." > /dev/stderr
  echo "Rebuild the kernel by changing the configuration." > /dev/stderr
  echo -e "\033[00m"
  echo "Exiting..."
  exit
fi

echo "-----------------------------------------------------------------------------"
echo "Create dummy root squashfs 3.3 partition..."
# Create a dummy squashfs 3.3 partition for root, type 8 (Fake_ROOT)
echo "dd if=./seedfile of=./tmp/DUMMY/dummy bs=1 skip=0 count=$FAKESIZE"
dd if=$CURDIR/seedfile of=$TMPDUMDIR/dummy bs=1 skip=0 count=$FAKESIZE > /dev/null
echo "MKSQUASHFS $TMPDUMDIR ./mtd_fakeroot.bin -nopad -le"
$MKSQUASHFS $TMPDUMDIR $CURDIR/mtd_fakeroot.bin -nopad -le > /dev/null
#sign partition
$FUP -s $CURDIR/mtd_fakeroot.bin > /dev/null

echo "-----------------------------------------------------------------------------"
echo "Create dummy dev squashfs 3.3 partition..."
# Create a dummy squash partition for dev, type 7 (Fake_DEV)
echo "#!/bin/bash" > $TMPDUMDIR/dummy
echo "exit" >> $TMPDUMDIR/dummy
chmod 755 $TMPDUMDIR/dummy > /dev/null
echo "MKSQUASHFS $TMPDUMDIR ./mtd_fakedev.bin -nopad -le"
$MKSQUASHFS $TMPDUMDIR $CURDIR/mtd_fakedev.bin -nopad -le > /dev/null
#sign partition
$FUP -s $CURDIR/mtd_fakedev.bin > /dev/null

# Create a Fortis flash file
echo "-----------------------------------------------------------------------------"
echo "File size OK, creating IRD file..."
echo "FUP -c $OUTFILE -v  -6 ./uImage -8 ./mtd_fakeroot.bin.signed -7 ./mtd_fakedev.bin.signed -1 ./mtd_fakedev.bin.signed"
$FUP -c $OUTFILE -v  -6 $CURDIR/uImage -8 $CURDIR/mtd_fakeroot.bin.signed -7 $CURDIR/mtd_fakedev.bin.signed -1 $CURDIR/mtd_fakedev.bin.signed
# Set reseller ID
$FUP -r $OUTFILE $RESELLERID

echo "-----------------------------------------------------------------------------"
echo ""
echo "Preparation of kernel flash file completed."
rm -f $CURDIR/uImage
rm -f $CURDIR/mtd_fakeroot.bin
rm -f $CURDIR/mtd_fakeroot.bin.signed
rm -f $CURDIR/mtd_fakedev.bin
rm -f $CURDIR/mtd_fakedev.bin.signed

#zip $OUTFILE.zip $OUTFILE
