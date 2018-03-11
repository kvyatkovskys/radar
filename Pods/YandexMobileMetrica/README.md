# Yandex AppMetrica SDK

## License
License agreement on use of Yandex AppMetrica SDK is available at [EULA site][LICENSE]

## Documentation
Documentation could be found at [AppMetrica official site][DOCUMENTATION]

## Sample project
Sample project to use is available at [GitHub][GitHubSAMPLE]

## AppStore submit notice
Starting from version 1.6.0 Yandex AppMetrica became also a tracking instrument and
uses Apple idfa to attribute installs. Because of that during submitting your
application to the AppStore you will be prompted with three checkboxes to state
your intentions for idfa usage.
As Yandex AppMetrica uses idfa for attributing app installations you need to select **Attribute this app installation to a previously served
advertisement**.

## Changelog

### Version 2.9.6

* Improved performance and quality of statistics.

### Version 2.9.4
SDK archive: [**download**](https://storage.mds.yandex.net/get-appmetrica-mobile-sdk/117488/YandexMobileMetrica-2.9.4-ios-0ab49d70-c217-485d-98bd-2b16f2460cb5.zip)

* Fixed possible crashes on simulator.
* Improved performance and quality of statistics.

### Version 2.9.1
SDK archive: [**download**](https://storage.mds.yandex.net/get-appmetrica-mobile-sdk/48248/YandexMobileMetrica-2.9.1-ios-7e6844f1-c0eb-407d-8c6b-3f4a603befc1.zip)

* Added the ability to set referral url.

### Version 2.9.0
SDK archive: [**download**](https://storage.mds.yandex.net/get-appmetrica-mobile-sdk/48248/YandexMobileMetrica-2.9.0-ios-51230b69-82f2-4c7c-9207-047c7f9b7bee.zip)

* Improved performance and quality of statistics.
* Added the ability to send statistics using an API key that differs from the app's API key.

### Version 2.8.3
SDK archive: [**download**](https://storage.mds.yandex.net/get-appmetrica-mobile-sdk/128534/YandexMobileMetrica-2.8.3-ios-1a1760d0-385c-4f21-a1c5-802d63ee340f.zip)

* Fixed bitcode problems with Xcode 8.2.1

### Version 2.8.1
SDK archive: [**download**](https://storage.mds.yandex.net/get-appmetrica-mobile-sdk/48248/YandexMobileMetrica-2.8.1-ios-e63657db-01b9-4eb0-b8e3-bfdfa3b464e5.zip)

* Improved performance and quality of statistics.

### Version 2.8.0
SDK archive: [**download**](https://storage.mds.yandex.net/get-appmetrica-mobile-sdk/50347/YandexMobileMetrica-2.8.0-ios-c96e20e1-c1da-4c59-bc45-87aa1c86169d.zip)

* Fixed version/build number of application in crash reports.
* Fixed custom location setting.
* Improved performance and quality of statistics.

### Version 2.7.0
SDK archive: [**download**](https://storage.mds.yandex.net/get-appmetrica-mobile-sdk/48248/YandexMobileMetrica-2.7.0-ios-7058b11a-d987-4519-8c64-028c75b67eab.zip)

* Added method to distinguish application updates from new intallations.
* Supported deeplink tracking.

### Version 2.6.5
SDK archive: [**download**](https://storage.mds.yandex.net/get-appmetrica-mobile-sdk/50347/YandexMobileMetrica-2.6.5-ios-6c4350a9-024d-45f2-a9e7-253c72f413d0.zip)

* Fixed dynamic framework meta-information.

### Version 2.6.2
SDK archive: [**download**](https://storage.mds.yandex.net/get-appmetrica-mobile-sdk/50347/YandexMobileMetrica-2.6.2-ios-51ddba1a-89bd-4da8-b4ae-771d60a317f0.zip)

* Improved performance and quality of statistics.

### Version 2.6.1
SDK archive: [**download**](https://storage.mds.yandex.net/get-appmetrica-mobile-sdk/50347/YandexMobileMetrica-2.6.1-ios-64364d26-6106-4105-9f79-d18478e6e3b8.zip)

* Fixed iOS 6 support.

### Version 2.6.0
SDK archive: [**download**](https://storage.mds.yandex.net/get-appmetrica-mobile-sdk/50347/YandexMobileMetrica-2.6.0-ios-962cb138-d9c6-4d0f-8d1d-55fc98d81d1d.zip)

* Improved iOS 10 support.
* Improved Swift support.
* Added dynamic framework.

### Version 2.5.1
SDK archive: [**download**](https://storage.mds.yandex.net/get-appmetrica-mobile-sdk/117488/YandexMobileMetrica-2.5.1-ios-ec534922-a996-49c9-adef-96c781d33e07.zip)

* Framework archive moved to the Yandex cloud storage.
* Fixed [#41](https://github.com/yandexmobile/metrica-sdk-ios/issues/41).

### Version 2.5.0
* Improved performance and quality of statistics.

### Version 2.4.1

* Improved performance and quality of statistics.

### Version 2.4.0

* Supported referrer tracking method.
* Improved performance and quality of statistics.

### Version 2.3.1

* AppMetrica now also available as static framework.
* Removed explicit external dependencies.
* Improved error messages.
* Improved performance and quality of statistics.

### Version 2.3.0

* Added ability to activate AppMetrica with configuration.
* Added ability to track preloaded installs.
* Improved performance and quality of statistics.

### Version 2.1.1

* Added support for extensions.
* Added support for Bitcode.
* Improved error messages.

### Version 2.0.0

* The ApiKey format has been changed. The app ID in a new format is available in the AppMetrica web interface when the app editing mode is engaged.
* The method of initializing the library in the app has been renamed from [YMMYandexMetrica startWithAPIKey:(NSString *)apiKey]; to [YMMYandexMetrica activateWithApiKey:(NSString *)apiKey];.
* The session length has been changed. Now it is 10 seconds, by default.
* The library has been adapted for iOS 9.
* Improved quality of calculating statistics for app installations and devices identification for tracking.
* We have significantly improved performance and reduced the power consumption.
* The obsolete methods have been removed.

For more details see [official doc page](https://tech.yandex.com/metrica-mobile-sdk/doc/mobile-sdk-dg/concepts/ios-history-docpage/)

### Version 1.8.5

* Supported iOS 9

### Version 1.8.2

* Added ability to set crash environment

### Version 1.6.2

* Fixed crash reporting bugs

### Version 1.6.1

* Improved campaigns tracking accuracy

### Version 1.6.0
* Improved stability and performance
* Switched to reading [idfa] from AdSupport within library
* Added events with additional parameters
* Added free app install tracking support
* Renamed YMMCounter to YMMYandexMetrica
* Changed ApiKey type from integer to string
* Supported Xcode 6 and iOS 8
* Switched to min supported target iOS 6
* Improved location handling
* Switched to asynchronous error processing using blocks
* Optimised library start

### Version 1.2.3
 * Removed all references to idfa (AdSupport.framework) from library
 * Improved library stability


### Version 1.2
* Reduced size of library by half added to target app
* Optimised performance up to 30%
* Added arm64 and x86_64 slice to the library's binary
* Added arm64 crash handling
* Moved to protobuf-c
* Extracted FMDB as an external dependency
* Adjusted session length logic
* Added API for managing library logging
* Added jailbreak detection
* Improved library stability

### Version 1.0.1
* Removed private methods
* Extracted ProtobufObjC as an external dependency


[LICENSE]: https://yandex.com/legal/appmetrica_sdk_agreement/ "Yandex AppMetrica agreement"
[DOCUMENTATION]: https://tech.yandex.com/metrica-mobile-sdk/ "Yandex AppMetrica documentation"
[GitHubSAMPLE]: https://github.com/yandexmobile/metrica-sample-ios/
[idfa]: https://developer.apple.com/reference/adsupport/asidentifiermanager#//apple_ref/occ/instp/ASIdentifierManager/advertisingTrackingEnabled
