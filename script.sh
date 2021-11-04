ALBUM_ID=$1

get_album_items_with_curl() {
	USER_AGENT='Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:94.0) Gecko/20100101 Firefox/94.0'
	ACCEPT='application/json, text/javascript, */*'
	ACCEPT_LANGUAGE='en-US,en;q=0.5'
	CONTENT_TYPE='application/x-www-form-urlencoded; charset=UTF-8'
	X_REQUESTED_WITH='XMLHttpRequest'	
	ORIGIN='https://ibb.co'
	dataRawACTION="get-album-contents&albumid=${ALBUM_ID}"


	curl 'https://ibb.co/json' --silent -X POST -H "User-Agent: ${USER_AGENT}" -H "Accept: ${ACCEPT}" -H "Accept-Language: ${ACCEPT_LANGUAGE}" --compressed -H "Content-Type: ${CONTENT_TYPE}" -H "X-Requested-With: ${X_REQUESTED_WITH}" -H "Origin: ${ORIGIN}" --data-raw "action=${dataRawACTION}"
}

main() {
	echo "Getting album info"
	jsonResponse=$(get_album_items_with_curl)
	# jsonResponse=$(cat 'myfile.txt')

	numberOfAlbumItems=$(echo "$jsonResponse" | jq -r ".album.image_count")

	echo "Album contains '${numberOfAlbumItems}' items."


	for (( i=0;i<${numberOfAlbumItems}; i++)); do
		current_url=$(echo "$jsonResponse" | jq -r ".contents[${i}].url")

		filename=$(basename ${current_url})
		if ! [ -f ${filename} ]; then
			echo "Saving '${filename}'"
			curl ${current_url} --silent -o ${filename}
		else
			echo "'${filename}' exists. Skipping"
		fi
	done

	echo "Ok. Downloaded album '${ALBUM_ID}'"
}

USAGE="\n\tbash script.sh <album_id>\n"
if [[ -z ${ALBUM_ID} ]]; then
	echo "Album ID can't be empty."
	echo -e ${USAGE}
	exit 1

elif ! command -v curl &> /dev/null; then
	echo 'I require "curl". Please install'
	exit 1

elif ! command -v jq &> /dev/null; then
	echo 'I require "jq". Please install'
	exit 1

else
	ANSWER=true
	directory_name="ibb.co-${ALBUM_ID}"

	if [[ -d ${directory_name} ]]; then
		echo "directory ${directory_name} exists."
		while true; do
		    read -p "run script anyway? [Y/n]: " yn
		    case $yn in
		        [Yy]) break ;;  
		        [Nn]) ANSWER=false; break ;;
		        "") break ;;
		    esac 
		done
	else
		mkdir ${directory_name}
	fi

	if $ANSWER; then
	    (cd ${directory_name}; main)
	else
	    echo "not running"
	fi
	exit 0
fi
