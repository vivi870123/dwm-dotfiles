#!/usr/bin/env sh

# Simple ncmpcpp notification script by Gerome Matilla;
# gerome.matilla07@gmail.com
#	Depends:
#		- mpc, mpd, ncmpcpp, imagemagick, ffmpeg or perl-image-exiftool

# Exit if on tty
# Uhh... we don't need a notification while on tty
if [[ tty == "/dev/tty"* ]]; then
	exit 1
fi

music_dir="$(xdg-user-dir MUSIC)"
ncmpcpp_tmp_dir="/tmp/ncmpcpp_tmp/${USER}"
ncmpcpp_tmp_dir_cover="${ncmpcpp_tmp_dir}/ncmpcpp_cover.jpg"
ncmpcpp_tmp_dir_song="${ncmpcpp_tmp_dir}/current-song"

mpd_current_music_title="$(mpc -f %title% current | tr -d '"')"
mpd_current_music_artist="$(mpc -f %artist% current | tr -d '"')"

# Create ncmpcpp temporary directory
function create_tmp_dir() {
	if [[ ! -d "$ncmpcpp_tmp_dir" ]]; then
		mkdir -p "$ncmpcpp_tmp_dir"
	fi
}

create_tmp_dir

# Check if metadata is missing the song title and artist
function check_missing_metadata() {
	if [[ -z "$mpd_current_music_title" ]]; then
		file_name="$(mpc -f %file% current | tr -d '"')"
		file_name=${file_name::-4}
		mpd_current_music_title="${file_name}"
	fi
	if [[ -z "$mpd_current_music_artist" ]]; then
		mpd_current_music_artist="unknown artist"
	fi
}

check_missing_metadata

function delete_cover_art() {
	if [[ -e "$ncmpcpp_tmp_dir_cover" ]]; then
		rm "$ncmpcpp_tmp_dir_cover" >/dev/null 2>&1
        fi
      }

# Delete the previous album art,
# so we can distinguish if the current music file has one
delete_cover_art

# Extract album cover
function extract_cover_art() {
  # Use exiftool
  if [[ ! -z "$(command -v exiftool)" ]]; then
    current_song="${music_dir}/$(mpc -p 6600 --format "%file%" current)"
    picture_tag="-Picture"

    if [[ "$current_song" == *".m4a" ]]; then
      picture_tag="-CoverArt"
    fi

                # Extract album cover using perl-image-exiftool
                exiftool -b "$picture_tag" "$current_song" >"$ncmpcpp_tmp_dir_cover"
              else
                # Extract image using ffmpeg
                cp "${music_dir}/$(mpc --format %file% current)" "$ncmpcpp_tmp_dir_song"

                ffmpeg \
                  -hide_banner \
                  -loglevel 0 \
                  -y \
                  -i "$ncmpcpp_tmp_dir_song" \
                  -vf scale=300:-1 \
                  "$ncmpcpp_tmp_dir_cover" >/dev/null 2>&1
  fi
}

extract_cover_art

# Check if image is valid or existing
function check_cover_art_validity() {
  img_data=$(identify "$ncmpcpp_tmp_dir_cover" 2>&1)
  if [[ "$img_data" == *"insufficient"* ]] || [[ ! -e "$ncmpcpp_tmp_dir_cover" ]]; then
    ncmpcpp_tmp_dir_cover="${HOME}/.config/ncmpcpp/vinyl.svg"
  fi
}

check_cover_art_validity

# Create a notification for DE/WM without a native notification system
function notify_fallback() {
  # Check if dunst is installed
  if [[ ! -z "$(command -v dunst)" ]]; then
    dunstify --urgency 'normal' --appname "ncmpcpp" \
      --replace 3 --icon "$ncmpcpp_tmp_dir_cover" \
      "$mpd_current_music_title" "$mpd_current_music_artist"
        else
          notify-send --urgency "normal" --app-name "ncmpcpp" \
            --icon "$ncmpcpp_tmp_dir_cover" \
            "$mpd_current_music_title" "$mpd_current_music_artist"
  fi
}

notify_fallback
