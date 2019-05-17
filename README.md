# IMAB - IOS Example (with MoPub SDK) mopub-sharknark

This is a sample application to test the MoPub IOS SDK integration with the InMobi IMAB plugin.

This path is typically used by publishers whom are using MoPub today for primary SDK mediation.
What happens is that the publisher integrates the MoPub SDK directly first and requests a bid from InMobi before loading the Mopub ad waterfall. 
This allows for better fill rate across the board.

## Mopub IOS SDK:

Mopub is open source:
https://github.com/mopub/mopub-ios-sdk 
https://developers.mopub.com/docs/ios/getting-started/


## IMAB Plugin:

The SDK Package for IOS/Android comes with a 'Network Support' folder that contains all the plugin files required for integration.
The .framework file would be dragged / dropped into the XCode project and then referenced in the build process to 'complete' the plugin procedure. 

https://d2hzra53t5a9gw.cloudfront.net/documentation/documentation.html?platform=ios&plugin=mopub


## Notes:

You will need to include your own version of the InMobi SDK, InMobi AB plugin, and MoPub SDK. These are not versioned.

