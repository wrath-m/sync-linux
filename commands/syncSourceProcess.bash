#!/bin/bash

# name logic:
# sync --> watched files and folders, to be synced
# source --> source is the destination where the updated files are saved, the git source, from where the other machines will get their updates

declare -A files
#files['$HOME/watchedFolder|$HOME/destinationFolder']='file1.xml|file2.jpg'
#files['$HOME/watchedFolder2|$HOME/destinationFolder2']='subfolder/file1.js|subfolder2/file2.html'
#files['$HOME/watchedFolder3|$HOME/destinationFolder3']='*'
#excludeFiles=('$HOME/watchedFolder3/subfolder1/file1.xml' '$HOME/watchedFolder3/subfolder2/another-file.xml' '$HOME/watchedFolder3/subfolder3')
#excludeFolders=('$HOME/watchedFolder3/subfolder1/' '$HOME/watchedFolder3/subfolder2/')

files['$HOME/.config/sublime-text-3/Packages|$HOME/syncCore/portable/sublime_text_3/.config/Packages']='*'
files['$HOME/.config/sublime-text-3/Installed Packages|$HOME/syncCore/portable/sublime_text_3/.config/Installed Packages']='*'
files['$HOME/sync/portable/postman|$HOME/syncCore/portable/postman']='*'
files['$HOME/sync/files|$HOME/syncCore/files']='*'
excludeFiles=('$HOME/.config/sublime-text-3/Packages/User/Package Control.last-run' '$HOME/.config/sublime-text-3/Packages/User/Package Control.ca-list' '$HOME/.config/sublime-text-3/Packages/User/Package Control.ca-bundle' '$HOME/.config/sublime-text-3/Packages/User/Package Control.system-ca-bundle')
excludeFolders=('$HOME/.config/sublime-text-3/Packages/User/Package Control.cache/' '$HOME/.config/sublime-text-3/Packages/User/Package Control.ca-certs/')

# execution starts from here --------------------------------------------------------

bash $HOME/syncCore/commands/updateSyncSource.bash

function validateAction {
    if [[ "$file" = *.swp || "$file" = *.swpx ]]; then
        return 1
    fi
    for exclusion in "${excludeFiles[@]}"; do
        exclusion=$(eval echo $exclusion)
        if [[ "$syncFolder/$file" = $exclusion ]]; then
            return 1
        fi
    done
    for exclusion in "${excludeFolders[@]}"; do
        exclusion=$(eval echo $exclusion)
        if [[ "$syncFolder/$file" = ${exclusion}* ]]; then
            return 1
        fi
    done

    if [[ $filter = '*' ]]; then
        runAction=0
    else
        filter=$(echo $filter | tr '|' "\n")
        while read fileInFilter; do
            if [[ "$file" = $fileInFilter ]]; then
                runAction=0
            fi
        done <<< "$filter"
    fi
}


function pushChanges {
    pkill -f "sleep 5 && bash $HOME/syncCore/commands/pushChanges.bash"
    bash -c "sleep 5 && bash $HOME/syncCore/commands/pushChanges.bash" &
}

function createModifyAction {
    syncFolder=$1
    sourceFolder=$2
    filter=$3
    #filepath=$4
    file=${4:(${#syncFolder} + 1)}
    runAction=1
    validateAction

    if [[ $runAction -eq 0 ]]; then
        echo "synchronizing from $syncFolder/$file to $sourceFolder/$file"
        mkdir -p "$(dirname "$sourceFolder/$file")"
        cp "$syncFolder/$file" "$sourceFolder/$file"
        pushChanges
    fi
}
function deleteAction {
    syncFolder=$1
    sourceFolder=$2
    filter=$3
    #filepath=$4
    file=${4:(${#syncFolder} + 1)}
    runAction=1

    validateAction

    if [[ $runAction -eq 0 ]]; then
        rm "$sourceFolder/$file"
        pushChanges
    fi
}
function deleteFolderAction {
    syncFolder=$1
    sourceFolder=$2
    filter=$3
    #filepath=$4
    file=${4:(${#syncFolder} + 1)}
    runAction=1

    validateAction

    if [[ $runAction -eq 0 ]]; then
        rm -rf "$sourceFolder/$file"
        pushChanges
    fi
}

declare -A getSourceFolderBySyncFolder
declare -A getFilterBySyncFolder
for sourceTargetInput in "${!files[@]}"; do
    syncFolder=$(eval echo $(echo $sourceTargetInput | cut -f1 -d'|'))
    if [[ -z ${watchFolders+x} ]]; then
        watchFolders="$syncFolder"
    else
        watchFolders="$watchFolders $syncFolder"
    fi
    if [[ -z ${syncFolders+x} ]]; then
        syncFolders=("$syncFolder")
    else
        syncFolders=("${syncFolders[@]}" "$syncFolder")
    fi
    mkdir -p "$syncFolder"
    getSourceFolderBySyncFolder[$syncFolder]=$(eval echo $(echo $sourceTargetInput | cut -f2 -d'|'))
    getFilterBySyncFolder[$syncFolder]=${files[$sourceTargetInput]}
done

for syncFolder in "${syncFolders[@]}"; do
    inotifywait -rm "$syncFolder" -e CREATE,CLOSE_WRITE,MOVED_TO,DELETE,MOVED_FROM --format "%w%f|%e"| while read eventInfo; do
        filepath=$(eval echo $(echo $eventInfo | cut -f1 -d'|'))
        event=$(eval echo $(echo $eventInfo | cut -f2 -d'|'))
        sourceFolder="${getSourceFolderBySyncFolder[$syncFolder]}"
        filter="${getFilterBySyncFolder[$syncFolder]}"
        # echo "$filepath"
        # echo "$event"
        # echo "$sourceFolder"
        # echo "$filter"
        if [[ $event = 'CREATE' || $event = 'CLOSE_WRITE,CLOSE' || $event = 'MOVED_TO' ]]; then
            sleep 0
            createModifyAction "$syncFolder" "$sourceFolder" "$filter" "$filepath"
        elif [[ $event = 'DELETE' || $event = 'MOVED_FROM' ]]; then
            deleteAction "$syncFolder" "$sourceFolder" "$filter" "$filepath"
        elif [[ $event = 'DELETE,ISDIR' || $event = 'MOVED_FROM,ISDIR' ]]; then
            deleteFolderAction "$syncFolder" "$sourceFolder" "$filter" "$filepath"
        fi
    done &
done

function finish {
    pkill -f "syncSourceProcess.bash"
}
trap finish exit 0
sleep infinity
