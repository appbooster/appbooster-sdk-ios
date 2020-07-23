# appbooster-sdk-ios

Framework for A/B testing.

## Installation

CocoaPods:

```
pod 'AppboosterSDK'
```

## Usage

```
import AppboosterSDK
```

### Initialization:

```
let ab = AppboosterAB(serverUrl: "<YOUR_APPBOOSTERSDK_SERVER_URL>", // optional, e.g. "https://new.apitapi.com"
                   authToken: "<YOUR_APPBOOSTERSDK_AUTH_TOKEN>",
                   deviceToken: "<YOUR_DEVICE_TOKEN")
```

### How to fetch known tests values that associated with your device?

```
ab.fetch(knownKeys: ["<TEST_1_KEY>", "<TEST_2_KEY>"],
         timeoutInterval: 3.0, // optional
         completion: { error in })
```

### How to get the value for a specific test?

```
let value: String? = ab["<TEST_KEY>"]
```

or

```
let value: String? = ab.value("<TEST_KEY>")
```

or

```
let value: String = ab.value("<TEST_KEY>", or: "<DEFAULT_VALUE>")
```

### How to get user properties for analytics?

```
let userProperties = ab.userProperties
```

### How to debug?

```
ab.showDebug = true // false by default, to print all debugging info in the console
ab.log = { text in } // to define your own log handler
let duration = ab.lastOperationDuration // the duration of the last operation in seconds
```

==================================================

You can see the example of usage in the attached project.
