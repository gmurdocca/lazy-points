#!/bin/bash

version=1.1
name=lazy-points
filename=$name-$version.pk3
time_limit=180
finish_bonus=500

draw_logo() {
    echo '                 =================     ===============     ===============   ========  ========'
    echo '                 ||. . ._____. . .|| ||. . ._____. . .|| ||. . ._____. . .|| || . . .\/ . . .||'
    echo '                 || . .||   ||. . || || . .||   ||. . || || . .||   ||. . || ||. . . . . . . ||'
    echo '                 ||. . ||   || . .|| ||. . ||   || . .|| ||. . ||   || . .|| || . | . . . . .||'
    echo '                 || . .||   ||. _-|| ||-_ .||   ||. . || || . .||   ||. _-|| ||-_.|\ . . . . ||'
    echo '                 ||. . ||   ||-^  || ||  `-||   || . .|| ||. . ||   ||-^  || ||  `|\_ . .|. .||'
    echo '                 || . _||   ||    || ||    ||   ||_ . || || . _||   ||    || ||   |\ `-_/| . ||'
    echo '                 ||_-^ ||  .|/    || ||    \|.  || `-_|| ||_-^ ||  .|/    || ||   | \  / |-_.||'
    echo '                 ||    ||_-^      || ||      `-_||    || ||    ||_-^      || ||   | \  / |  `||'
    echo '                 ||    `^         || ||         `^    || ||    `^         || ||   | \  / |   ||'
    echo '                 ||            .===^ `===.         .===^.`===.         .===^ /==. |  \/  |   ||'
    echo '                 ||         .==^   \_|-_ `===. .===^   _|_   `===. .===^ _-|/   `==  \/  |   ||'
    echo '                 ||      .==^    _-^    `-_  `=^    _-^   `-_    `=^  _-^   `-_  /|  \/  |   ||'
    echo '                 ||   .==^    _-^          ^-__\._-^         ^-_./__-^         `^ |. /|  |   ||'
    echo '                 ||.==^    _-^                                                     `^ |  /==.||'
    echo "                 ==^    _-^         -=] TPS Nothing But 90s Trivia Night [=-           \\/   \`=="
    echo '                 \   _-^                                                                `-_   /'
    echo '                 `^^        -=-=-=-=  T O P   1 0   H I G H    S C O R E S  =-=-=-=-      ``^^'

}

if [ "$1" == "build" ]; then


    rm -f $filename

    zip $filename    \
        zscript/*.zs \
        *.md  \
        *.txt \
        *.zs
    echo pk3 written to $filename
    exit
fi

clear
touch high_scores.txt

while true; do
    skip_score=0
    # show high scores
    draw_logo
    echo -e "\n                                      Rank:\tScore:\tName:\n"
    sort -k1,1nr high_scores.txt | awk '{print NR, $0}' | head -n10 | while read l; do
        rank=$(echo $l | awk '{print $1}')
        score=$(echo $l | awk '{print $2}')
        name=$(echo $l | awk '{for (i=3; i<=NF; i++) printf $i (i==NF?RS:OFS)}')
        echo -e "                                      $rank \t$score\t$name"
    done
    echo ""
    echo    "                               Max time limit per game: $(($time_limit / 60)) minutes"
    echo -n "                               Enter your name to play: "
    read name
    if [ -z "$name" ]; then
        exec $0
    fi


    # sanitize name
    name=$(echo "$name" | tr -cd '[:print:]' | cut -c1-30)
    echo "                                    Hi $name, loading DooM... good luck!"
    out_file=/tmp/doom.out
    rm -f $out_file
    rm -f gzdoom.ini
    cp gzdoom_main.ini gzdoom.ini
    iwad='./doom.wad'

    start_time=$(date +%s)
    stdbuf -o0 -- gzdoom \
        -file $filename \
        -iwad $iwad \
        -warp 1 1 \
        -config ./gzdoom.ini \
        -nostartup >$out_file 2>&1 &
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
                # add finish_bonus since they fionished the map
                score=$(( $score + $finish_bonus ))
                echo -e "$score\t$name" >> high_scores.txt
                echo "                       *****************************************************************"
                echo "                             $name, congratulations for completing the level!"
                echo "                                         Your final score was $score"
                echo "                       *****************************************************************"
                echo ""
            fi
            break
        fi



        if grep -Eq "Degreelessness|Very Happy Ammo Added|No Clipping Mode|Power-up Toggled" $out_file; then
            skip_score=1
            kill $gzdoom_pid
            wait $gzdoom_pid >/dev/null 2>&1
            clear
            echo "                          XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
            echo "                                       Well, well, well... A cheater eh?"
            echo "                                  Congratulations on remembering the cheat codes,"
            echo "                                        but your run has been terminated!"
            echo "                          XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
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
            echo "                          =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
            echo "                               Sorry, we're playing map E1M1 only for this challenge."
            echo "                          =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="

            break
        fi

        # detect death and reset
        if grep -Eq 'Player was|Player killed|Player mutated' $out_file; then
            score=$(cat $out_file | grep "Current score:" | tail -n1 | awk '{print $NF}')
            if [ $score -gt 0 ]; then
                # only update score file if the score was > 0
                echo -e "$score\t$name" >> high_scores.txt
            fi
            kill $gzdoom_pid
            wait $gzdoom_pid >/dev/null 2>&1
            clear
            echo "                          =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
            echo "                                        You died! Your final score was $score..."
            echo "                          =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
            break
        fi

        # detect death and reset
        current_timestamp=$(date +%s)
        duration=$(($current_timestamp - $start_time))
        if [ $duration -gt $time_limit ]; then
            score=$(cat $out_file | grep "Current score:" | tail -n1 | awk '{print $NF}')
            if [ $score -gt 0 ]; then
                # only update score file if the score was > 0
                echo -e "$score\t$name" >> high_scores.txt
            fi
            kill $gzdoom_pid
            wait $gzdoom_pid >/dev/null 2>&1
            clear
            echo "                          =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
            echo "                               You ran out of time! Your final score was $score..."
            echo "                          =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
            break
        fi

        sleep 1

    done
done
