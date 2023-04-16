#!/bin/bash

# disables bloat packages on TCL TVs
# tested with TCL E17_65E17US

packages_to_uninstall=(
  "com.tcl.MultiScreenInteraction_TV|Controls TV from mobile (T-Cast), a function which is rarely used by its native API." \
  "com.tcl.bi|Bi is a couple of sticker-like resources that end up running in the background unused." \
  "com.google.android.tvrecommendations|Quick notification shortcut when a flash drive is plugged in. Useful for the default laucher. Relatively useless," \
  "com.google.android.leanbacklauncher.recommendations|Part of the default launcher, responsible for displaying recommendations from TCL/Google partners. Not useful." \
  "com.tcl.pvr.pvrplayer|TCL MediaPlayer." \
  "com.tcl.imageplayer|TCL PicturePlayer." \
  "com.tcl.videoplayer|TCL VideoPlayer." \
  "com.tcl.audioplayer|TCL AudioPlayer." \
  "com.tcl.inputmethod.international|TCL input app." \
  "com.tcl.xian.StartandroidService|TCL Unknown service." \
  "com.google.android.inputmethod.pinyin|Android phonetic input method." \
  "com.tcl.appmarket2|Responsible for keeping TCL partner dumps running, as well as doing heavy telemetry. Performs functions in the default non-vital launcher." \
  "com.tcl.eletronicpolicy|TCL Electronic Policy ??"
)

packages_to_disable=(
  "com.tcl.appmarket2|Responsible for keeping TCL partner dumps running, as well as doing heavy telemetry. Performs functions in the default non-vital launcher." \
  "com.tcl.ui_mediaCenter|TCL Media Center. Poorly made and useless." \
  "com.tcl.notereminder|System messenger, responsible for annoying you when the internet connection drops, and the like." \
  "com.tcl.partnercustomizer|Packed by TCL, useless, is a contractual obligation of TCL with its partners, forces and privileges content from partners." \
  "com.tcl.partnercustomizer.resource|Built by TCL. Background engine that restores partner content if you have removed them." \
  "com.tcl.rc.ota|Remote control firmware update, unused. *SAFE TO DISABLE." \
  "com.tcl.factory.view|Secret developer menu, runs telemetry." \
  "com.tcl.esticker|Displays TCL content." \
  "com.tcl.tvweishi|TVGuard not used bloatware."\
  "com.tcl.MultiScreenInteraction_TV|Controls TV from mobile (T-Cast), a function which is rarely used by its native API." \
  "com.tcl.smartalexa|Alexa voice assistant." \
  "com.google.android.tvrecommendations|Quick notification shortcut when a flash drive is plugged in. Useful for the default laucher. Relatively useless," \
  "com.google.android.leanbacklauncher.recommendations|Part of the default launcher, responsible for displaying recommendations from TCL/Google partners. Not useful," \
  "tv.wuaki.apptv|Rakuten TV|??"\
  "com.iqt.iqqijni.tv.gp.pro|IQQI - Chinese Pro - Chinese Keyboard|??"\
  "com.android.statementservice|System garbage to agree with spying." \
  "com.google.android.syncadapters.calendar|CalendarAPI, relatively useless." \
  "com.google.android.partnersetup|API for google telemetry for their partners." \
  "com.google.android.syncadapters.contacts|API for contacts, useless on a TV." \
  "com.google.android.backuptransport|Google API, part of core services, provides background data transport." \
  "com.android.katniss|Google voice control. If you don't use the control's voice control." \
  "com.android.printspooler|service for network printing, useless on a TV." \
  "com.android.providers.contacts|Built into the native Android system, it controls and displays contacts (people) via API. Useless on a TV," \
  "com.google.android.feedback|Google telemetry." \
  "com.google.android.tv.bugreportsender|Google telemetry. *RECOMMENDED TO BE DISABLED." \
  "com.google.android.youtube.tv|Youtube native, displays ads and is not customizable. Recommended to replace it with SmartYoutube." \
  "com.google.android.tvrecommendations|Quick notification shortcut when a flash drive is plugged in. Useful for the default laucher. Relatively useless," \
  "com.google.android.tv.remote.service|Updates the firmware of the control, runs services in the background. To date no update has been made available. Relatively useless," \
  "com.google.android.music|Packaged by Google with similar function as Spotify, Deezer. Not useful, *SECURE DISABLED*." \
  "com.google.android.videos|Embedded by Google with similar function to Netflix, Amazon Videos, focused on movie rentals. Useless," \
  "com.google.android.play.games|Boosted by Google, some native games make use of APIs to save data, achievements, scores to the cloud. Relatively useless," \
  "android.autoinstalls.config.tcl.device|Function that pushes "recommended" automatic configuration." \
  "com.android.statementservice|System garbage to agree with spying."
)

# Connect to TV
connect_tv(){
    read -p  "[?] Enter the IP address of your TV and press [Enter] to continue: " IP

	ping -c 1 ${IP} >/dev/null
        if [ "$?" -eq "0" ]; then
        # Tests if the TV is turned on with debug mode active
        echo ""
        echo -e "[+] Connecting to your TV..."
        adb connect ${IP} >/dev/null
        if [ "$?" -eq "0" ]; then
            echo -e "[+] Successfully connected to the TV!"
            echo ""
            check_tv
        else
            echo -e "[x] Error! Connection failed, Check your IP address"
            connect_tv
        fi
    else
        echo -e "[x] Error! Connection failed, Check your IP address"
        connect_tv
    fi
}

check_tv(){
    adb devices -l | grep ${IP} | grep device:tcl >/dev/null
    if [ "$?" -eq "0" ]; then
        echo -e "[+] TV is TCL"
        echo ""
        package_cleanup
    else
        echo -e "[x] Error - TV not TCL"
        read -p "[?] Would you like to continue  [Y/N]" yn
        case $yn in 
            [yY] ) package_cleanup;;
            [nN] ) echo "[+] Exiting";
                exit;;
            *)
                echo "[!] Invalid Option"
                echo ""
                check_tv
                ;;
        esac
    fi
}

package_cleanup(){
echo "[+] Remove Packages"
for package in "${packages_to_uninstall[@]}"
do
  package_name="$(echo "$package" | cut -f1 -d"|")"
  package_desc="$(echo "$package" | cut -f2 -d"|")"
  adb shell pm list packages -e | grep ${package_name} >/dev/null
  if [ "$?" -eq "0" ]; then
    uninstall_output=$(adb shell pm uninstall -k --user 0 ${package_name} 2>/dev/null)
    if [[ ${uninstall_output} == *"Success"* ]]; then
        echo "  [+] Removed: ${package_name}"
        echo "      ${package_desc}"
    else
        echo "  [x] Not removed: ${package_name}"
        echo "      ${package_desc}"
    fi
  else
    echo "  [!] Not Found: ${package_name}"
  fi
done

echo ""
echo "[+] Disable Packages"
for package in "${packages_to_disable[@]}"
do
  package_name="$(echo "$package" | cut -f1 -d"|")"
  package_desc="$(echo "$package" | cut -f2 -d"|")"
  adb shell pm list packages -e | grep ${package_name} >/dev/null
  if [ "$?" -eq "0" ]; then
    disable_user_output=$(adb shell pm disable-user --user 0 ${package_name} 2>/dev/null)
    if [[ ${disable_user_output} == *"Exception"* ]]; then
        echo "  [!] Exception: ${package_name}"
        echo "      ${package_desc}"
    else
        echo "  [+] Disabled: ${package_name}"
        echo "      ${package_desc}"
    fi
  else
    echo "  [!] Not found or already disabled: ${package_name}"
  fi
done
}
clear
echo "
TCL Debloat
---------------------
"
connect_tv
