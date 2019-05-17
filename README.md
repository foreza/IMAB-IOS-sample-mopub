# mopub-sharknark
This is a sample application to test the MoPub IOS SDK integration with AerServ plugin

This path is typically used with MoPub and a custom native network like AerServ / InMobi.
Typically, what happens is that the application publisher integrates the MoPub SDK directly first.
From there, they might integrate and implement other SDKs and do internal 'mediation' within the core SDK (MoPub in this case) and the core AdServer (Also Mopub).
This allows for better fill rate across the board, which is important for revenue for all parties involved in the chain. 

## Mopub IOS SDK:

Mopub is open source:
https://github.com/mopub/mopub-ios-sdk 
https://developers.mopub.com/docs/ios/getting-started/


## AerServ Plugin:

The SDK Package for IOS/Android comes with a 'Network Support' folder that contains all the plugin files required for integration.
The .framework file would be dragged / dropped into the XCode project and then referenced in the build process to 'complete' the plugin procedure. 

https://support.aerserv.com/hc/en-us/articles/203458530-Integrate-AerServ-as-a-Custom-Network-on-MoPub-


## Notes:

WORK IN PROGRESS
