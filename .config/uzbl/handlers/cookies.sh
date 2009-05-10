#!/bin/zsh

file=$XDG_CONFIG_HOME/uzbl/cookies
cookie_file=$XDG_DATA_HOME/uzbl/cookies

which zenity &>/dev/null || exit 2

action=$8 # GET/PUT
host=$9
shift
path=$9
shift
cookie=$9

field_domain=$host
field_path=$path
field_name=
field_value=
field_exp='end_session'


# FOR NOW LETS KEEP IT SIMPLE AND JUST ALWAYS PUT AND ALWAYS GET
function parse_cookie () {
	IFS=$';'
	first_pair=1
	for pair in $cookie
	do
		if [ "$first_pair" == 1 ]
		then
			field_name=${i%%=*}
			field_value=${i#*=}
			first_pair=0
		else
			read -r pair <<< "$pair" #strip leading/trailing wite space
			key=${i%%=*}
			val=${i#*=}
			[ "$key" == expires ] && field_exp=`date -u -d "$val" +'%s'`
			# TODO: domain
			[ "$key" == path ] && field_path=$val
		fi
	done
	unset IFS
}

# match cookies in cookies.txt againsh hostname and path
function get_cookie () {
	path_esc=${path//\//\\/}
	cookie=`awk "/^[^\t]*$host\t[^\t]*\t$path_esc/" cookie_file 2>/dev/null | tail -n 1`
	[ -n "$cookie" ]
}

[ $action == PUT ] && parse_cookie && echo -e "$field_domain\tFALSE\t$field_path\tFALSE\t$field_exp\t$field_name\t$field_value" >> $cookie_file
[ $action == GET ] && get_cookie && echo "$cookie"

exit


# TODO: implement this later.
# $1 = section (TRUSTED or DENY)
# $2 =url
function match () {
	sed -n "/$1/,/^\$/p" $file 2>/dev/null | grep -q "^$host"
}

function fetch_cookie () {
	cookie=`cat $cookie_file/$host.cookie`
}

function store_cookie () {
	echo $cookie > $cookie_file/$host.cookie
}

if match TRUSTED $host
then
	[ $action == PUT ] && store_cookie $host
	[ $action == GET ] && fetch_cookie && echo "$cookie"
elif ! match DENY $host
then
	[ $action == PUT ] &&                 cookie=`zenity --entry --title 'Uzbl Cookie handler' --text "Accept this cookie from $host ?" --entry-text="$cookie"` && store_cookie $host
	[ $action == GET ] && fetch_cookie && cookie=`zenity --entry --title 'Uzbl Cookie handler' --text "Submit this cookie to $host ?"   --entry-text="$cookie"` && echo $cookie
fi
exit 0
