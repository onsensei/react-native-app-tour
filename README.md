<p align="center">
  <a href="https://www.npmjs.com/package/onsensei-react-native-app-tour"><img src="http://img.shields.io/npm/v/onsensei-react-native-app-tour.svg?style=flat" /></a>
  <a href="https://github.com/onsensei/onsensei-react-native-app-tour/pulls"><img alt="PRs Welcome" src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg" /></a>
  <a href="https://github.com/onsensei/onsensei-react-native-app-tour#License"><img src="https://img.shields.io/npm/l/onsensei-react-native-app-tour.svg?style=flat" /></a>
</p>

# onsensei-react-native-app-tour

This library is a React Native bridge around native libraries. It allows show/guide beautiful tours:

| **Android: [KeepSafe/TapTargetView](https://github.com/KeepSafe/TapTargetView)**             |
| ----------------- |
| <img src="https://github.com/KeepSafe/TapTargetView/raw/master/.github/video.gif" width="300" height="600" />                  |


| **iOS: [aromajoin/material-showcase-ios](https://github.com/aromajoin/material-showcase-ios)**             |
| ----------------- |
| <img src="https://github.com/aromajoin/material-showcase-ios/raw/master/art/material-showcase.gif" width="300" height="600" />

## Getting started

`$ npm install onsensei-react-native-app-tour --save`

`$ react-native link onsensei-react-native-app-tour`

- **Android**
  - in ./android/app/src/build.gradle
    ```
    android {
      compileSdkVersion 25
      buildToolsVersion "25.0.2"
      .
      .
      .
    }
    ```
- **iOS**
    - Add [aromajoin/material-showcase-ios](https://github.com/aromajoin/material-showcase-ios) in Embedded Binaries & Linked Frameworks and Libraries. You can find this library from below path:
    - Please find below screenshot reference for the same 
    - <img src="./Example/assets/linking1.png" />
    - <img src="./Example/assets/linking2.png" />


## Usage
```javascript
import {AppTour, AppTourSequence, AppTourView} from 'onsensei-react-native-app-tour';
```

**Props**
  - title #String
  - description #String
  - titleTextSize #String(0 - 100)
  - descriptionTextSize #String(0 - 100)
  - titleTextColor #hexCodeRGB
  - targetHolderColor #hexCodeRGB
  - descriptionTextColor #hexCodeRGB
  - outerCircleColor #hexCodeRGB
  - outerCircleAlpha #String(0.00 - 1.00)
  - targetRadius #String(0 - 100)
  - transparentTarget #Bool
  - buttonText #String
  - buttonTextColor #hexCodeRGB
  - buttonBGColor #hexCodeRGB
  - buttonRadius #String(0 - 100)
  - buttonVisable #Bool
  - buttonTextSize #String(0 - 100)

## Credits
- Android: [KeepSafe/TapTargetView](https://github.com/KeepSafe/TapTargetView)
- iOS: [aromajoin/material-showcase-ios](https://github.com/aromajoin/material-showcase-ios)
- RN: [prscX/react-native-app-tour](https://github.com/prscX/react-native-app-tour)
