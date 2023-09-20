if [ "$CONFIGURATION" == "Debug-eventodemo" ] || [ "$CONFIGURATION" == "Release-eventodemo" ]; then
  cp Runner/eventodemo/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-epicseries" ] || [ "$CONFIGURATION" == "Release-epicseries" ]; then
  cp Runner/epicseries/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-motatapu" ] || [ "$CONFIGURATION" == "Release-motatapu" ]; then
  cp Runner/motatapu/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-noosatri" ] || [ "$CONFIGURATION" == "Release-noosatri" ]; then
  cp Runner/noosatri/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-mootri" ] || [ "$CONFIGURATION" == "Release-mootri" ]; then
  cp Runner/mootri/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-uta" ] || [ "$CONFIGURATION" == "Release-uta" ]; then
  cp Runner/uta/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-rtb" ] || [ "$CONFIGURATION" == "Release-rtb" ]; then
  cp Runner/rtb/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-auckland" ] || [ "$CONFIGURATION" == "Release-auckland" ]; then
  cp Runner/auckland/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-whaka100" ] || [ "$CONFIGURATION" == "Release-whaka100" ]; then
  cp Runner/whaka100/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-ironman" ] || [ "$CONFIGURATION" == "Release-ironman" ]; then
  cp Runner/ironman/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-runaway" ] || [ "$CONFIGURATION" == "Release-runaway" ]; then
  cp Runner/runaway/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-challenge" ] || [ "$CONFIGURATION" == "Release-challenge" ]; then
  cp Runner/challenge/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-coasttocoast" ] || [ "$CONFIGURATION" == "Release-coasttocoast" ]; then
  cp Runner/coasttocoast/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-chmarathon" ] || [ "$CONFIGURATION" == "Release-chmarathon" ]; then
  cp Runner/chmarathon/GoogleService-Info.plist Runner/GoogleService-Info.plist
fi

