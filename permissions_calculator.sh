#!/bin/bash

#Colours
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
greenColour="\e[0;32m\033[1m"
yellowColour="\e[0;33m\033[1m"
blueColour="\e[0;34m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function ctrlC() {
    echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
}

trap ctrlC INT

# Start Script
#Functions
function helpPanel() {
    echo -e "Permission Help\n"
    echo -e "\t-s) write a simbolic permission and convert to octal permission"
    echo -e "\t\tExample:   rwxr-xr-- (this comvert to 754)"
    echo -e "\t\tExample 2: rwS--s--t (this comvert to 7611)\n"
    echo -e "\t-o) write a octal permission and convert to simbolic permission"
    echo -e "\t\tExample:   652 (this comvert to rw-r-x-w-)"
    echo -e "\t\tExample 2: 2732 (this comvert to rwx-ws-w-)"
}

function simbolicPermissions() { #convert simbolic to octal permissions
    tput civis
    permission="$1"
    num_characters=$(echo -n "$permission" | wc -m)
    #echo $num_characters
   
    #Verification of characters
    if [ $num_characters -eq 9 ]; then
        #p = permission
        #variable=${String:init:length}
        user_p=${permission:0:3}
        group_p=${permission:3:3}
        others_p=${permission:6:3}

        declare -i verify=0

        #verification of every parts
        for p in {0..2}; do
            #verify user permission
            if [ $p -eq 0 ]; then
                if ! [ ${user_p:0:1} == "-" ] && ! [ ${user_p:0:1} == "r" ]; then
                    #echo "el valor primero de user_p es erroneo: ${user_p:0:1}"
                    let verify+=1
                fi
                if ! [ ${user_p:1:1} == "-" ] && ! [ ${user_p:1:1} == "w" ]; then
                    #echo "el valor segundo de user_p es erroneo: ${user_p:1:1}"
                    let verify+=1
                fi
                if ! [ ${user_p:2:1} == "-" ] && ! [ ${user_p:2:1} == "x" ] && ! [ ${user_p:2:1} == "S" ] && ! [ ${user_p:2:1} == "s" ]; then
                    #echo "el valor segundo de user_p es erroneo: ${user_p:2:1}"
                    let verify+=1
                fi
                
            #verify group permission
            elif [ $p -eq 1 ]; then
                if ! [ ${group_p:0:1} == "-" ] && ! [ ${group_p:0:1} == "r" ]; then
                    #echo "el valor primero de group_p es erroneo: ${group_p:0:1}"
                    let verify+=1
                fi
                if ! [ ${group_p:1:1} == "-" ] && ! [ ${group_p:1:1} == "w" ]; then
                    #echo "el valor segundo de group_p es erroneo: ${group_p:1:1}"
                    let verify+=1
                fi
                if ! [ ${group_p:2:1} == "-" ] && ! [ ${group_p:2:1} == "x" ] && ! [ ${group_p:2:1} == "S" ] && ! [ ${group_p:2:1} == "s" ]; then
                    #echo "el valor segundo de group_p es erroneo: ${group_p:2:1}"
                    let verify+=1
                fi

            #verify others permission
            else
                if ! [ ${others_p:0:1} == "-" ] && ! [ ${others_p:0:1} == "r" ]; then
                    #echo "el valor primero de others_p es erroneo: ${others_p:0:1}"
                    let verify+=1
                fi
                if ! [ ${others_p:1:1} == "-" ] && ! [ ${others_p:1:1} == "w" ]; then
                    #echo "el valor segundo de others_p es erroneo: ${others_p:1:1}"
                    let verify+=1
                fi
                if ! [ ${others_p:2:1} == "-" ] && ! [ ${others_p:2:1} == "x" ] && ! [ ${others_p:2:1} == "T" ] && ! [ ${others_p:2:1} == "t" ]; then
                    #echo "el valor segundo de others_p es erroneo: ${others_p:2:1}"
                    let verify+=1
                fi
            fi
        done

        if [ $verify -ge 1 ]; then
            echo -e "${redColour}[!] The permission is spelled incorrectly${endColour}"
            tput cnorm; exit 1
        fi
    else
        echo -e "${redColour}[!] Incorrect permission - Must be 9 characters${endColour}"
        tput cnorm; exit 1
    fi
    
    #Calculate of permission number
    #echo "continuation of funcion after of verification loop"
    user_sum=0
    group_sum=0
    others_sum=0
    special_sum=0
    result=""

    #Sum of user permissions
    if [ ${user_p:0:1} == "r" ]; then
        let user_sum+=4
    fi
    
    if [ ${user_p:1:1} == "w" ]; then
        let user_sum+=2
    fi
    
    if [ ${user_p:2:1} == "x" ]; then
        let user_sum+=1
    elif [ ${user_p:2:1} == "S" ]; then
        let special_sum+=4
    elif [ ${user_p:2:1} == "s" ]; then
        let user_sum+=1
        let special_sum+=4
    fi

    #Sum of group permissions
    if [ ${group_p:0:1} == "r" ]; then
        let group_sum+=4
    fi
    
    if [ ${group_p:1:1} == "w" ]; then
        let group_sum+=2
    fi
    
    if [ ${group_p:2:1} == "x" ]; then
        let group_sum+=1
    elif [ ${group_p:2:1} == "S" ]; then
        let special_sum+=2
    elif [ ${group_p:2:1} == "s" ]; then
        let group_sum+=1
        let special_sum+=2
    fi

    #Sum of others permissions
    if [ ${others_p:0:1} == "r" ]; then
        let others_sum+=4
    fi
    
    if [ ${others_p:1:1} == "w" ]; then
        let others_sum+=2
    fi
    
    if [ ${others_p:2:1} == "x" ]; then
        let others_sum+=1
    elif [ ${others_p:2:1} == "T" ]; then
        let special_sum+=2
    elif [ ${others_p:2:1} == "t" ]; then
        let others_sum+=1
        let special_sum+=1
    fi

    #Set final result
    if [ $special_sum -eq 0 ]; then
        result="$user_sum$group_sum$others_sum"
    else
        result="$special_sum$user_sum$group_sum$others_sum"
    fi

    echo -e "${greenColour}[+]${endColour} The permission \e[1m$permission\e[0m in octal is \e[1m$result\e[0m"

    tput cnorm
}

function octalPermissions() { #convert octal to simbolic permission
    tput civis
    permission=$1
    num_characters=$(echo -n "$permission" | wc -m)
    
    #Verify number digits
    if [ $num_characters -lt 3 ] || [ $num_characters -gt 4 ]; then
        echo -e "${redColour}[!] Number of Digits wrong - 3 or 4 numbers less or equal to 7${endColour}"
        tput cnorm; exit 1
    fi
    #verify value of numbers
    if [[ ! "$permission" =~ ^[0-7]+$ ]]; then
        echo -e "${redColour}[!] The numbers range from 0 to 7${endColour}"
        tput cnorm; exit 1
    fi

    #Convertion octal to simbolic
    result=""
    
    #Calculation without special permissions
    if [ $num_characters -eq 3 ]; then
        for p in {0..2}; do
            if [ ${permission:$p:1} -eq 0 ]; then
                result=$result"---"
            elif [ ${permission:$p:1} -eq 1 ]; then
                result=$result"--x"
            elif [ ${permission:$p:1} -eq 2 ]; then
                result=$result"-w-"
            elif [ ${permission:$p:1} -eq 3 ]; then
                result=$result"-wx"
            elif [ ${permission:$p:1} -eq 4 ]; then
                result=$result"r--"
            elif [ ${permission:$p:1} -eq 5 ]; then
                result=$result"r-x"
            elif [ ${permission:$p:1} -eq 6 ]; then
                result=$result"rw-"
            elif [ ${permission:$p:1} -eq 7 ]; then
                result=$result"rwx"
            fi
        done
    #Calculation with special permissions
    else
        for p in {1..3}; do
            if [ ${permission:$p:1} -eq 0 ]; then
                result=$result"---"
            elif [ ${permission:$p:1} -eq 1 ]; then
                result=$result"--x"
            elif [ ${permission:$p:1} -eq 2 ]; then
                result=$result"-w-"
            elif [ ${permission:$p:1} -eq 3 ]; then
                result=$result"-wx"
            elif [ ${permission:$p:1} -eq 4 ]; then
                result=$result"r--"
            elif [ ${permission:$p:1} -eq 5 ]; then
                result=$result"r-x"
            elif [ ${permission:$p:1} -eq 6 ]; then
                result=$result"rw-"
            elif [ ${permission:$p:1} -eq 7 ]; then
                result=$result"rwx"
            fi
        done
        #calculate special permissions
        if [ ${permission:0:1} -eq 1 ] || [ ${permission:0:1} -eq 3 ] || [ ${permission:0:1} -eq 5 ] || [ ${permission:0:1} -eq 7 ]; then #1 3 5 7
            if [ ${result:8:1} == "x" ]; then
                result="${result:0:8}t"
            else
                result="${result:0:8}T"
            fi
        fi
        if [ ${permission:0:1} -eq 2 ] || [ ${permission:0:1} -eq 3 ] || [ ${permission:0:1} -eq 6 ] || [ ${permission:0:1} -eq 7 ]; then #2 3 6 7
            if [ ${result:5:1} == "x" ]; then
                result="${result:0:5}s${result:6}"
            else
                result="${result:0:5}S${result:6}"
            fi
        fi
        if [ ${permission:0:1} -eq 4 ] || [ ${permission:0:1} -eq 5 ] || [ ${permission:0:1} -eq 6 ] || [ ${permission:0:1} -eq 7 ]; then #4 5 6 7
            if [ ${result:2:1} == "x" ]; then
                result="${result:0:2}s${result:3}"
            else
                result="${result:0:2}S${result:3}"
            fi
        fi
    fi

    echo -e "${greenColour}[+]${endColour} The permission \e[1m$permission\e[0m in simbolic is \e[1m$result\e[0m"

    tput cnorm
}

#Variables
declare -i parameter_counter=0

while getopts "s:o:h" arg; do #s=simbolic o=octal h=help
    case $arg in
        s) simbolic_p=$OPTARG; let parameter_counter+=1;;
        o) octal_p=$OPTARG; let parameter_counter+=2;;
        h) let parameter_counter+=3;;
    esac
done

if [ $parameter_counter -eq 1 ]; then
    simbolicPermissions $simbolic_p
elif [ $parameter_counter -eq 2 ]; then
    octalPermissions $octal_p
elif [ $parameter_counter -eq 3 ]; then
    helpPanel
else
    echo -e "${yellowColour}[-] -h for help panel${endColour}"
fi
