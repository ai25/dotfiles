wallust_refresh=$HOME/.config/hypr/scripts/wallpaper/refresh.sh
focused_monitor=$(hyprctl monitors | awk '/^Monitor/{name=$2} /focused: yes/{print name}')

if [[ $# -lt 1 ]] || [[ ! -d $1 ]]; then
  echo "Usage: $0 <dir containing images>"
  exit 1
fi

SWWW_TRANSITION_STEP=200
SWWW_TRANSITION_FPS=60
SWWW_TRANSITION_TYPE=grow
SWWW_TRANSITION_POS=0.8,0.9

img=$(find "$1" -type f | shuf -n 1)

swww img -o "$focused_monitor" \
  --transition-type "$SWWW_TRANSITION_TYPE" \
  --transition-pos "$SWWW_TRANSITION_POS" \
  --transition-step "$SWWW_TRANSITION_STEP" \
  --transition-fps "$SWWW_TRANSITION_FPS" \
  "$img"

echo "executing wallust_refresh"
$wallust_refresh
