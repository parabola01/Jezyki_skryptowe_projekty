#!/bin/bash
#Aleksandra Jaroszek grupa 2

script_dir=$(dirname "$0")

# Default game options
max_attempts=6
words=("cat" "dog" "house" "car" "book" "university" "applied" "computer" "science")

difficulty=0
words_file=""
result_file="$script_dir/results.txt"
stats_file="$script_dir/stats.txt"
stats=false

help() {
    echo "Hangman Game Script"
    echo "Usage: bash bash.sh [-d difficulty] [-f words_file] [-s] [-r result_file_name]"
    echo ""
    echo "Options:"
    echo "-d : Set the difficulty level (1 - Easy, 2 - Medium, 3 - Hard)"
    echo "-f : Specify a file containing custom words separated by spaces"
    echo "-s : Display game statistics after playing"
    echo "-r : Specify the name of the result file to record game outcomes (default: results.txt)"
    echo "-h : Display this help message"
    echo ""
    echo "Requirements:"
    echo " - Bash shell"
    echo " - Unix-like environment"
    echo ""
    echo "Word File Format:"
    echo " - The word file should contain a list of words separated by spaces"
    echo " - Only letters are allowed in the words (no numbers, symbols, or spaces)"
    echo ""
    echo "File Management:"
    echo " - If the result file or statistics file is not provided, the program will create them in the directory where the script is located"
    echo " - The result file will store the outcomes of each game (number of tries needed to win and word guessed)"
    echo " - The statistics file will store the overall statistics of games played"
    echo ""
    echo "Example usage:"
    echo "./hangman.sh -d 2 -f custom_words.txt -r my_results.txt -s"
    echo ""
    echo "If no options are provided, the game will be played with default settings."
    echo "Enjoy the game!"
}


while getopts ":d:f:r:sh" opt; do
  case $opt in
    d) if ! [[ "$OPTARG" =~ ^[1-3]$ ]]; then
                echo "Option -d requires a number from 1 to 3."
                exit 1
        else
            difficulty="$OPTARG"
        fi
        ;;
    f) words_file="$script_dir/$OPTARG"
        if [[ ! -f "$words_file" ]]; then
           echo "File '$words_file' not found."
           exit 1
        fi;;
    r) result_file="$script_dir/$OPTARG.txt";;
    s) stats=true
    echo "stats: $stats";;
    h) help; exit;;
    \?) echo "Invalid option: -$OPTARG. Use -h for help."; exit 1;;
  esac
done
shift $((OPTIND -1))

draw_hangman() {
    case $1 in
        6) echo "  ________"
           echo "  |      |"
           echo "  |      O"
           echo "  |     /|\\"
           echo "  |     / \\"
           echo " _|_";;
        5) echo "  ________"
           echo "  |      |"
           echo "  |      O"
           echo "  |     /|\\"
           echo "  |     /"
           echo " _|_";;
        4) echo "  ________"
           echo "  |      |"
           echo "  |      O"
           echo "  |     /|\\"
           echo "  |"
           echo " _|_";;
        3) echo "  ________"
           echo "  |      |"
           echo "  |      O"
           echo "  |     /|"
           echo "  |"
           echo " _|_";;
        2) echo "  ________"
           echo "  |      |"
           echo "  |      O"
           echo "  |      |"
           echo "  |"
           echo " _|_";;
        1) echo "  ________"
           echo "  |      |"
           echo "  |      O"
           echo "  |"
           echo "  |"
           echo " _|_";;
        0) echo "  ________"
           echo "  |      |"
           echo "  |"
           echo "  |"
           echo "  |"
           echo " _|_";;
    esac
}

validate_input() {
    local input=$1
    if [[ ! $input =~ ^[a-zA-Z]$ ]]; then
        echo "Invalid input! Please enter a single letter from the English alphabet."
        return 1
    fi
}

if [[ -n $words_file ]]; then
    if ! words=($(< "$words_file")); then
        echo "Unable to load words from file."
        exit 1
    fi
fi

for word in "${words[@]}"; do
    if [[ ! $word =~ ^[a-zA-Z]+$ ]]; then
        echo "Invalid word in file: $word. Words should contain only letters and be separated by space."
        exit 1
    fi
done

if (( difficulty != 0 )); then
    case $difficulty in
        1) min_length=1; max_length=3;;
        2) min_length=4; max_length=6;;
        3) min_length=7; max_length=100;;
    esac

    filtered_words=()
    for word in "${words[@]}"; do
        if (( ${#word} >= min_length )) && (( ${#word} <= max_length )); then
            filtered_words+=("$word")
        fi
    done

    # Random word selection
    if [ ${#filtered_words[@]} -gt 0 ]; then
        random_index=$((RANDOM % ${#filtered_words[@]}))
        word=${filtered_words[random_index]}
    else
        echo "No word found for the specified difficulty level. Choosing a random word."
        sleep 6
        random_index=$((RANDOM % ${#words[@]}))
        word=${words[random_index]}
    fi
else
    random_index=$((RANDOM % ${#words[@]}))
    word=${words[random_index]}
fi

word_length=${#word}

attempts=0
guessed_letters=()

display_array=()
for ((i=0; i<$word_length; i++)); do
    display_array+=("_")
done

while true; do
    remaining_attempts=$((max_attempts - attempts))

    clear

    draw_hangman $attempts

    display_word=""
    for letter in "${display_array[@]}"; do
        display_word+=" $letter"
    done

    echo "Word: $display_word"
    echo "Guessed letters: ${guessed_letters[@]}"
    echo "Remaining attempts: $remaining_attempts/$max_attempts"
    echo ""

    if [[ ! "${display_array[*]}" =~ "_" ]]; then
        echo "Congratulations! You won in $attempts attempts! The word was: $word"
        echo "Result: won in $attempts attempts. The word was: $word" >> "$result_file"
        echo "won $attempts" >> "$stats_file"
        break
    elif ((remaining_attempts <= 0)); then
        echo "You lost! The word was: $word"
        echo "Result: lost. The word was: $word" >> "$result_file"
        echo "lost" >> "$stats_file"
        break
    fi

    read -p "Enter a letter: " guess

    if ! validate_input "$guess"; then
        sleep 3
        continue
    fi

    if [[ "${guessed_letters[*]}" =~ $guess ]]; then
        echo "You already guessed '$guess'. Try another letter."
        sleep 3
        continue
    fi

    guessed_letters+=("$guess")

    if [[ $word == *$guess* ]]; then
        for ((i=0; i<$word_length; i++)); do
            if [[ "${word:$i:1}" == "$guess" ]]; then
                display_array[$i]=$guess
            fi
        done
    else
        ((attempts++))
    fi
done

if [[ -n $stats ]]; then
    if [[ -f "$stats_file" ]]; then
        wins=$(grep -c "won" "$stats_file")
        losses=$(grep -c "lost" "$stats_file")
        total_games=$((wins + losses))
        if ((total_games > 0)); then
            total_attempts=$(grep "won" "$stats_file" | awk '{sum += $2} END {print sum}')
            average_attempts=$(echo "scale=2; $total_attempts / $wins" | bc)
        else
            average_attempts=0
        fi
        echo "Total games played: $total_games"
        echo "Wins: $wins"
        echo "Losses: $losses"
        echo "Average attempts needed to win: $average_attempts"
    else
        echo "No games played yet."
    fi
fi