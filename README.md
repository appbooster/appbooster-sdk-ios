# appbooster-sdk-ios

Mobile framework for Appbooster platform.

## Installation

#### CocoaPods:

```
pod 'AppboosterSDK'
```

#### Swift Package Manager:

1. Select File > Swift Packages > Add Package Dependency. Enter https://github.com/appbooster/appbooster-sdk-ios.git in the "Enter Package Repository URL" dialog.
2. In the next page, specify the version resolving rule as "Up to Next Major" with "0.1.0" as its earliest version.
3. After Xcode checking out the source and resolving the version, you can choose the "AppboosterSDK" library and add it to your app target.

#### Manual:

Download ZIP and copy folder **AppboosterSDK** to your app.

## Usage

```
import AppboosterSDK
```

### Initialization:

```
let ab = AppboosterSDK(sdkToken: "<YOUR_SDK_TOKEN>",
                       appId: "<YOUR_APP_ID>",
                       deviceId: "<YOUR_DEVICE_ID>", // optional, UUID generated by default
                       usingShake: false, // true by default for debug mode, turn it off if you are already using shake motion in your app for other purposes
                       defaults: [
                         "<TEST_1_KEY>": "<TEST_1_DEFAULT_VALUE>",
                         "<TEST_2_KEY>": "<TEST_2_DEFAULT_VALUE>"
                       ])
```

### How to fetch known tests values that associated with your device?

```
ab.fetch(completion: { error in })
```

### How to get the value for a specific test?

```
let value: String? = ab["<TEST_KEY>"]
```

or

```
let value: String? = ab.value("<TEST_KEY>")
```

In case of problems with no internet connection or another, the values obtained in the previous session will be used, or if they are missing, the default values specified during initialization will be used.

### How to get user tests for analytics?   

``` 
let experiments = ab.experiments(addAppboosterPrefix: true)

// i.e. set Amplitude user properties
Amplitude.instance().setUserProperties(experiments);
```

where `addAppboosterPrefix: Bool` used to add *[Appbooster]* prefix to experiments' keys.

You can disable the sending of events to analytics if debug mode is turn on.

```
if AppboosterDebugMode.isOn {
  // hold sending events
}
```

### How to debug?

Before debug make sure that debug-mode for your App is turned-on on [settings page](https://platform.appbooster.com/ab/settings)

  ![](https://imgproxy.appbooster.com/9ACImnEbmsO822dynjTjcC_B8aXzbbpPQsOgop2PlBs//aHR0cHM6Ly9hcHBib29zdGVyLWNsb3VkLnMzLmV1LWNlbnRyYWwtMS5hbWF6b25hd3MuY29tLzk0N2M5NzdmLTAwY2EtNDA1Yi04OGQ4LTAzOTM4ZjY4OTAzYi5wbmc.png)

```
ab.showDebug = true // false by default, to print all debugging info in the console
ab.log = { text in } // to define your own log handler
let duration = ab.lastOperationDuration // the duration of the last operation in seconds
```

In debug mode you can see all actual tests and check how the user will see each option of the test.
To show the debug menu you just need to turn it on in your personal cabinet and call
```
AppboosterDebugMode.showMenu(from: <yourViewController>)
```
or you can inherit some of your `UIViewController`'s from `AppboosterShakeToDebugController` and just make shake motion on your iPhone or simulator.



==================================================

You can see the example of usage in the attached project.
