#!/bin/bash

if [ "$1" == "build" ]; then

    name=lazy-points
    version=$(git describe --abbrev=0 --tags)
    filename=$name-$version.pk3

    rm -f $filename

    zip $filename    \
        zscript/*.zs \
        *.md  \
        *.txt \
        *.zs  \
    echo pk3 written to $filename
    exit
fi

clear
touch high_scores.txt

while true; do
    skip_score=0
    # show high scores
    echo "#######################################################"
    echo "   --] 1990's Trivia Night - DooM - High Scores [--"
    echo "#######################################################"
    echo -e "\n\t\tRank:\tScore:\tName:\n"
    sort -k1,1nr high_scores.txt | awk 'BEGIN {OFS="\t"} {print "\t", NR, $0}'
    echo ""
    echo "#######################################################"
    echo ""

    name=""
    while [ -z "$name" ]; do
        echo    "            Welcome new challenger!"
        echo    "               Enter your name: "
        echo -n "               "
        read name
    done

    # sanitize name
    name=$(echo "$name" | tr -cd '[:print:]' | cut -c1-30)
    echo "Hi $name, loading DooM... good luck!"
    out_file=/tmp/doom.out
    rm -f $out_file
    rm -f gzdoom.ini
    cp gzdoom_main.ini gzdoom.ini
    iwad='/home/georgem/games/doom/Collection/doom.wad'
    stdbuf -o0 -- gzdoom \
        -file lazy-points-0.4.pk3 \
        -iwad $iwad \
        -warp 1 1 \
        -config ./gzdoom.ini \
        -nostartup >$out_file 2>&1&
    gzdoom_pid=$!
    if [ ! -f $outfile ]; then
        sleep 0.1
    fi


    while true; do

        if ! kill -0 "$gzdoom_pid" 2>/dev/null; then
            clear
            break
        fi

        if grep -q "Final score:" $out_file; then
            kill $gzdoom_pid
            wait $gzdoom_pid >/dev/null 2>&1
            clear
            if [ $skip_score -eq 0 ]; then
                score=$(cat $out_file | grep "Final score:" | tail -n1 | awk '{print $NF}')
                echo -e "$score\t$name" >> high_scores.txt
                echo "*************************************"
                echo "    $name, your final score: $score"
                echo "*************************************"
                echo ""
            fi
            break
        fi

        if grep -Eq "Degreelessness|Very Happy Ammo Added|No Clipping Mode" $out_file; then
            skip_score=1
            kill $gzdoom_pid
            wait $gzdoom_pid >/dev/null 2>&1
            clear
            echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            echo "            Well, well, well... A cheater eh?"
            echo "       Congratulations on remembering the cheat codes,"
            echo "             but your run has been terminated!"
            echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            break
        fi

        map_string="$(grep -E 'E[1234]M.+ - .+' $out_file | tail -n1)"
        map_id=$(echo "$map_string" | awk -F' - ' '{print $1}')
        map_name=$(echo "$map_string" | awk -F' - ' '{print $2}')
        if [ -n "$map_name" ] && [ "$map_name" != "Hangar" ]; then
            skip_score=1
            kill $gzdoom_pid
            wait $gzdoom_pid >/dev/null 2>&1
            clear
            echo "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
            echo "     Sorry, we're playing map E1M1 only for this challenge."
            echo "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
            break
        fi

        sleep 1

    done
done

