## SMART SSH
smart_ssh(){
local port=$1
local ip=$2
local gate=$3
local bwname=$4
local remotehome=$5
local mountpoint=$6
if [[ -z "$5" ]] ; then
  if ssh -o ConnectTimeout=1 fmarini@$ip -YC 2>/dev/null; then
    :
  else
    if nc -z localhost $port &>/dev/null
    then
      ssh fmarini@localhost -p $port -YC
    else
      bw-cp $bwname
      (ssh -fN -L $port:$ip:22 fmarini@$gate; ssh fmarini@localhost -p $port -YC;)
    fi
  fi
else
  if mountpoint $mountpoint &>/dev/null ; then
    if ssh -o ConnectTimeout=1 fmarini@$ip -YC 2>/dev/null; then
      :
    else
      ssh fmarini@localhost -p $port -YC;
    fi
  else
    if sshfs -o ConnectTimeout=1 fmarini@$ip:$remotehome $mountpoint &>/dev/null ; then
      ssh fmarini@$ip -YC
    else
      if nc -z localhost $port &>/dev/null
      then
        sshfs fmarini@localhost:$remotehome $mountpoint -p $port
        ssh fmarini@localhost -p $port -YC
      else
        bw-cp $bwname
        ssh -fN -L $port:$ip:22 fmarini@$gate
        sshfs fmarini@localhost:$remotehome $mountpoint -p $port
        ssh fmarini@localhost -p $port -YC
      fi
    fi
  fi
fi
}

# BITWARDEN
bw-cp () {
local name=$1
local char_num=($(echo -n $name | wc -m));
local items=$(bw list items --search $name | jq '.[] | select(.name | match("'$name'"; "i"))');
local items_num=$(echo -E $items | jq -s '. | length');
if [[ $items_num -eq 1 ]]
then
    local passq=$(echo -E $items | jq '.login.password' | sed "s/\"/'/g");
elif [[ $items_num -gt 1 ]]
then
    local passq=$(echo -E $items | jq '. | select(.name | length=='$char_num')' | jq '.login.password' | sed "s/\"/'/g" );
else
    echo "Nothing found..."
fi
local pass=$(echo $passq | xargs) ;
(echo -n $pass | xclip -se c;) }

bw-cu () {
local name=$1
local passq=$(bw list items --search $name | jq '.[0].name');
local num_out=$(bw list items --search $name | jq '.[] | select(.name | match("'$name'"; "i"))' | jq -s '. | length');
local pass=$(echo $passq | xargs) ;
(echo -n $pass | xclip -se c;) }

bw-ls-s () { bw list items --search $1 | jq -r '.[]?.name'; }

# SSH - SCREEN
lxele02-make () {
local target=${1:-bit}
local file=${2-screen-cmd.log}
local cd_to_path="cd $PWD"
local tail_file="$PWD/$file"
local preamble='export PATH=/home/fmarini/.local/bin:$PATH; source /home/eda/xilinx/Vivado/2021.1/settings64.sh'
local cmd="make $target 2>&1 | tee $file"
local command1_pre="$preamble; $cd_to_path; $cmd"
local command1="zsh -c \"$command1_pre\""
local command2="sleep 2;tail -f $tail_file"
ssh fmarini@localhost -p8020 "screen -dm $command1;$command2"
}

lxele02-resume-screen(){
local file=${1-screen-cmd.log}
local tail_file="$PWD/$file"
local command1="tail -f $tail_file"
ssh fmarini@localhost -p8020 "$command1"
}

lxele02-wipe-screens(){
local cmd="screen -ls | grep Detached | cut -d. -f1 | awk '{print $1}' | xargs kill"
ssh fmarini@localhost -p8020 "$cmd"
}
