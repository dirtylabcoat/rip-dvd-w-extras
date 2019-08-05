#!/bin/bash
# Requires lsdvd, HandBrakeCLI
# TODO: output-dir from param, subs, audio, preset-profile from param

DVD_DEVICE=/dev/sr0
NUM_OF_TRACKS=$(lsdvd $DVD_DEVICE 2>/dev/null|grep -c "^Title:")
MAIN_TRACK=$(lsdvd $DVD_DEVICE 2>/dev/null|grep "Longest track"|sed 's/^Longest track: \(.*\)$/\1/g')
TITLE="ripped-dvd"
PRESET="HQ 720p30 Surround"
BASE_DIR=.
DEST_DIR=$BASE_DIR/$TITLE
EXTRAS_DIR=$DEST_DIR/extras
mkdir -p $EXTRAS_DIR

# Rip main track
echo "Ripping main track ($MAIN_TRACK)..."
HandBrakeCLI -Z "$PRESET" -t $MAIN_TRACK -i $DVD_DEVICE -o $DEST_DIR/main.mp4

# Rip extras
CNT=1
for T in $(seq 1 $NUM_OF_TRACKS); do
    PADDED_T=$(printf "%02d" $T)
    PADDED_CNT=$(printf "%02d" $CNT)
    if [ "$PADDED_T" != "$MAIN_TRACK" ]; then
        echo "Not main, ripping track $PADDED_T to extras directory..."
        HandBrakeCLI -Z "$PRESET" -t $T -i $DVD_DEVICE -o $EXTRAS_DIR/$PADDED_CNT.mp4
        let CNT=CNT+1
    fi
done

