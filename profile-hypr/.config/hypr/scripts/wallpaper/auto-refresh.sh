# This script will randomly go through the files of a directory, setting it
# up as the wallpaper at regular intervals
#
# NOTE: this script uses bash (not POSIX shell) for the RANDOM variable

wallust_refresh=$HOME/.config/hypr/scripts/wallpaper/refresh.sh

focused_monitor=$(hyprctl monitors | awk '/^Monitor/{name=$2} /focused: yes/{print name}')

if [[ $# -lt 1 ]] || [[ ! -d $1   ]]; then
	echo "Usage:
	$0 <dir containing images>"
	exit 1
fi

# Edit below to control the images transition
SWWW_TRANSITION_STEP=200
SWWW_TRANSITION_FPS=60
SWWW_TRANSITION_TYPE=grow
SWWW_TRANSITION_POS=0.8,0.9
# SWWW_TRANSITION_ANGLE=30

# This controls (in seconds) when to switch to the next image
INTERVAL=1800

while true; do
	find "$1" \
		| while read -r img; do
			echo "$((RANDOM % 1000)):$img"
		done \
		| sort -n | cut -d':' -f2- \
		| while read -r img; do
      swww img -o $focused_monitor --transition-type $SWWW_TRANSITION_TYPE --transition-pos $SWWW_TRANSITION_POS  --transition-step $SWWW_TRANSITION_STEP --transition-fps $SWWW_TRANSITION_FPS "$img" 
      echo "executing wallust_refresh"
			$wallust_refresh
      echo "sleeping for $INTERVAL seconds..."
			sleep $INTERVAL
			
		done
done
