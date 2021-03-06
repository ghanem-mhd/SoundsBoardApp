# SoundsBoard

Soundboard is an iOS app and widget for creating custom sounds board. Sounds can be recorded directly from the app or created from audio and video files including Youtube videos.

<p align="center">
    <img alt="SoundsBoard" src="https://github.com/ghanem-mhd/SoundsBoard/blob/master/Screenshots/preview.png">
</p>


## Features
- Sounds can be added from:
  - Recroder within the app.
  - Audio/video files.
  - Youtube videos.
- Vidoes will be converted autoamticlly.
- Name and thumbnail for each sound.
- Trim length of the sound.
- Shortcut to allow Siri to play any sound within the app.
- Widget to easily play favorite sounds.

## Getting Started
### Requirements
- iOS 12.0+
- Xcode 11.0
- CocoaPods 1.10.1+

### Installation
1. Make sure you have [CocoaPods](http://cocoapods.org) installed. You can install it with the following command: `gem install cocoapods`
2. Clone this repository.
3. Go to the project's directory and run `pod install` to install the third party dependencies.
4. Open 'SoundsBoard.xcworkspace' via Xcode.
5. In case you changed the app group name. Head to this [file](https://github.com/ghanem-mhd/SoundsBoardApp/blob/master/SBKit/utilities/Constants.swift) and change the appGroupID constant.

## Dependencies
- [AudioKit](https://github.com/AudioKit/AudioKit): Swift audio synthesis, processing, & analysis platform for iOS, macOS and tvOS.
- [SnapKit](https://github.com/SnapKit/SnapKit): A Swift Autolayout DSL for iOS & OS X.
- [SwiftySound](https://github.com/adamcichy/SwiftySound): A simple library that lets you play sounds with a single line of code.
- [WARangeSlider](https://github.com/warchimede/RangeSlider): A simple range slider made in Swift.
- [SDDownloadManager](https://github.com/SagarSDagdu/SDDownloadManager): A simple, robust and elegant download manager supporting simultaneous downloads.
- [NVActivityIndicatorView](https://github.com/ninjaprox/NVActivityIndicatorView): A collection of awesome loading animations.

## Project modules
The project is consists of the following modules:
- SoundsBoard: The main app.
- SBShare: The share extension to allow adding new content to the app.
- SBWidget: The widget to play the favorite sounds.
- SBKit: Extention to share code between the first three modules.
