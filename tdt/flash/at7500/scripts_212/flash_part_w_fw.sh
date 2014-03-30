#!/bin/bash

CURDIR=$1
TUFSBOXDIR=$2
OUTDIR=$3
TMPKERNELDIR=$4
TMPFWDIR=$5
TMPROOTDIR=$6

echo "CURDIR       = $CURDIR"
echo "TUFSBOXDIR   = $TUFSBOXDIR"
echo "OUTDIR       = $OUTDIR"
echo "TMPKERNELDIR = $TMPKERNELDIR"
echo "TMPFWDIR     = $TMPFWDIR"
echo "TMPROOTDIR   = $TMPROOTDIR"

MKFSJFFS2=$TUFSBOXDIR/host/bin/mkfs.jffs2
SUMTOOL=$TUFSBOXDIR/host/bin/sumtool
PAD=$CURDIR/../common/pad
FUP=$CURDIR/fup

OUTFILE=$OUTDIR/update_w_fw.ird

if [ ! -e $OUTDIR ]; then
  mkdir $OUTDIR
fi

if [ -e $OUTFILE ]; then
  rm -f $OUTFILE
fi

cp $TMPKERNELDIR/uImage $CURDIR/uImage

# Create a jffs2 partition for fw's
echo "MKFSJFFS2 -qUfv -p0x6E0000 -e0x20000 -r $TMPFWDIR -o $CURDIR/mtd_fw.bin"
$MKFSJFFS2 -qUfv -p0x6E0000 -e0x20000 -r $TMPFWDIR -o $CURDIR/mtd_fw.bin > /dev/null
echo "SUMTOOL -v -p -e 0x20000 -i $CURDIR/mtd_fw.bin -o $CURDIR/mtd_fw.sum.bin"
$SUMTOOL -v -p -e 0x20000 -i $CURDIR/mtd_fw.bin -o $CURDIR/mtd_fw.sum.bin > /dev/null
echo "PAD 0x6E0000 $CURDIR/mtd_fw.sum.bin $CURDIR/mtd_fw.sum.pad.bin"
$PAD 0x6E0000 $CURDIR/mtd_fw.sum.bin $CURDIR/mtd_fw.sum.pad.bin

cat $CURDIR/dummy.squash.signed.padded > $CURDIR/mtd_fw.sum.pad.signed.bin
cat $CURDIR/mtd_fw.sum.pad.bin >> $CURDIR/mtd_fw.sum.pad.signed.bin

# Create a jffs2 partition for root
echo "MKFSJFFS2 -qUfv -p0x3C20000 -e0x20000 -r $TMPROOTDIR -o $CURDIR/mtd_root.bin"
$MKFSJFFS2 -qUfv -p0x3C20000 -e0x20000 -r $TMPROOTDIR -o $CURDIR/mtd_root.bin > /dev/null
echo "SUMTOOL -v -p -e 0x20000 -i $CURDIR/mtd_root.bin -o $CURDIR/mtd_root.sum.bin"
$SUMTOOL -v -p -e 0x20000 -i $CURDIR/mtd_root.bin -o $CURDIR/mtd_root.sum.bin > /dev/null
echo "PAD 0x3C20000 $CURDIR/mtd_root.sum.bin $CURDIR/mtd_root.sum.pad.bin"
$PAD 0x3C20000 $CURDIR/mtd_root.sum.bin $CURDIR/mtd_root.sum.pad.bin

# Split the rootfs
#
#root 0x00BD0000
#echo "dd if=$CURDIR/mtd_root.sum.pad.bin of=$CURDIR/mtd_root.sum.pad.r.bin bs=1 skip=0 count=0x00BD0000"
#dd if=$CURDIR/mtd_root.sum.pad.bin of=$CURDIR/mtd_root.sum.pad.r.bin bs=1 skip=0 count=12386304
echo "dd if=$CURDIR/mtd_root.sum.pad.bin of=$CURDIR/mtd_root.sum.pad.r.bin bs=0x10000 skip=0 count=0x00BD"
dd if=$CURDIR/mtd_root.sum.pad.bin of=$CURDIR/mtd_root.sum.pad.r.bin bs=65536 skip=0 count=189
cat $CURDIR/dummy.squash.signed.padded > $CURDIR/mtd_root.sum.pad.r.signed.bin
cat $CURDIR/mtd_root.sum.pad.r.bin >> $CURDIR/mtd_root.sum.pad.r.signed.bin
echo "dd if=$CURDIR/mtd_root.sum.pad.bin of=$CURDIR/mtd_root.sum.pad.d.bin bs=0x10000 skip=0x00BD count=0x002D"
dd if=$CURDIR/mtd_root.sum.pad.bin of=$CURDIR/mtd_root.sum.pad.d.bin bs=65536 skip=189 count=45
cat $CURDIR/dummy.squash.signed.padded > $CURDIR/mtd_root.sum.pad.d.signed.bin
cat $CURDIR/mtd_root.sum.pad.d.bin >> $CURDIR/mtd_root.sum.pad.d.signed.bin
echo "dd if=$CURDIR/mtd_root.sum.pad.bin of=$CURDIR/mtd_root.sum.pad.c0.bin bs=0x10000 skip=0x0118 count=0x0004"
dd if=$CURDIR/mtd_root.sum.pad.bin of=$CURDIR/mtd_root.sum.pad.c0.bin bs=65536 skip=234 count=4
echo "dd if=$CURDIR/mtd_root.sum.pad.bin of=$CURDIR/mtd_root.sum.pad.c4.bin bs=0x10000 skip=0x011C count=0x0004"
dd if=$CURDIR/mtd_root.sum.pad.bin of=$CURDIR/mtd_root.sum.pad.c4.bin bs=65536 skip=238 count=4
echo "dd if=$CURDIR/mtd_root.sum.pad.bin of=$CURDIR/mtd_root.sum.pad.c8.bin bs=0x10000 skip=0x0120 count=0x0002"
dd if=$CURDIR/mtd_root.sum.pad.bin of=$CURDIR/mtd_root.sum.pad.c8.bin bs=65536 skip=242 count=2
echo "dd if=$CURDIR/mtd_root.sum.pad.bin of=$CURDIR/mtd_root.sum.pad.ca.bin bs=0x10000 skip=0x0122 count=0x0002"
dd if=$CURDIR/mtd_root.sum.pad.bin of=$CURDIR/mtd_root.sum.pad.ca.bin bs=65536 skip=244 count=2
echo "dd if=$CURDIR/mtd_root.sum.pad.bin of=$CURDIR/mtd_root.sum.pad.u.bin bs=0x10000 skip=0x0124 count=0x0236"
dd if=$CURDIR/mtd_root.sum.pad.bin of=$CURDIR/mtd_root.sum.pad.u.bin bs=65536 skip=246 count=566

$FUP -c $OUTFILE -k $CURDIR/uImage -a $CURDIR/mtd_fw.sum.pad.signed.bin -r $CURDIR/mtd_root.sum.pad.r.signed.bin -d $CURDIR/mtd_root.sum.pad.d.signed.bin -c0 $CURDIR/mtd_root.sum.pad.c0.bin -c4 $CURDIR/mtd_root.sum.pad.c4.bin -c8 $CURDIR/mtd_root.sum.pad.c8.bin -ca $CURDIR/mtd_root.sum.pad.ca.bin -u $CURDIR/mtd_root.sum.pad.u.bin


rm -f $CURDIR/uImage
rm -f $CURDIR/mtd_fw.bin
rm -f $CURDIR/mtd_root.bin
rm -f $CURDIR/mtd_fw.sum.bin
rm -f $CURDIR/mtd_root.sum.bin
rm -f $CURDIR/mtd_fw.sum.pad.bin
rm -f $CURDIR/mtd_root.sum.pad.bin
rm -f $CURDIR/mtd_root.sum.pad.c0.bin
rm -f $CURDIR/mtd_root.sum.pad.c4.bin
rm -f $CURDIR/mtd_root.sum.pad.c8.bin
rm -f $CURDIR/mtd_root.sum.pad.ca.bin
rm -f $CURDIR/mtd_root.sum.pad.d.bin
rm -f $CURDIR/mtd_root.sum.pad.r.bin
rm -f $CURDIR/mtd_root.sum.pad.u.bin
rm -f $CURDIR/mtd_fw.sum.pad.signed.bin
rm -f $CURDIR/mtd_root.sum.pad.d.signed.bin
rm -f $CURDIR/mtd_root.sum.pad.r.signed.bin

zip $OUTFILE.zip $OUTFILE
