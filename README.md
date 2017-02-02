# react-native-amap-3d
React Native AMap3d component for iOS + Android

### react-native-amap-3d is a wrapper of AMap 3d's Libraries inspired by react-native-maps and it's usable in Android and iOS
this library utilized https://github.com/dwd-fe/react-native-amap and port to the 3d version of amap which have better visual effect than that of 2d

###Demo

![demo-gif](https://github.com/Kerence/react-native-amap-3d/blob/master/ios_amap_3d.gif)
![demo-gif](https://github.com/Kerence/react-native-amap-3d/blob/master/amap-3d-android.gif)

### Installation

`npm install react-native-amap-3d --save`

### iOS
Only test on react-native 0.40
* `Add Files to "xxx"` on `Libaries` folder, and select `RCTAMap.xcodeproj`
* In `Link Binary With Libraries`, add `libRCTAMap.a`
* In `Link Binary With Libraries`, add `MAMapKit.framework` and `AMapSearchKit.framework`
* In `Framework Search Paths`, add `$(PROJECT_DIR)/../node_modules/react-native-amap-3d/ios`
* `Add Files to "xxx"` on your project, and select `AMap.bundle`
* In `Link Binary With Libraries`, add other libs, see [here](http://lbs.amap.com/api/ios-sdk/guide/create-project/manual-configuration/#t3)
* Make sure `NSAllowsArbitraryLoads` in `Info.plist` is `true`
* Make sure `LSApplicationQueriesSchemes` has `iosamap`
* In `Info.plist`, Add `Privacy - Location Usage Description`=`NSLocationWhenInUseUsageDescription`(for foreground usage) 
  or `NSLocationAlwaysUsageDescription`(for background usage). see [here](http://lbs.amap.com/api/ios-sdk/guide/draw-on-map/draw-location-marker/)

### Android
* `android/setting.gradle`:
```
include ':react-native-amap-3d'
project(':react-native-amap-3d').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-amap-3d/android')
```
* `android/app/build.gradle`:
```
    compile project(":react-native-amap-3d")
```
* `MainApplication.java`:
```
import com.kerence.rctamap.AMapPackage;
      
      return Arrays.<ReactPackage>asList(
          ...
          , new AMapPackage()
          ...
```
* `AndroidManifest.xml`:
```
    <!-- Geolocation -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" /><!--用于访问GPS定位-->
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" /><!--用于进行网络定位-->
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" /><!--用于访问wifi网络信息，wifi信息会用于进行网络定位-->
    <uses-permission android:name="android.permission.CHANGE_WIFI_STATE" /><!--这个权限用于获取wifi的获取权限，wifi信息会用来进行网络定位-->
    <uses-permission android:name="android.permission.READ_PHONE_STATE" />
    <uses-permission android:name="android.permission.ACCESS_LOCATION_EXTRA_COMMANDS" />
    <uses-permission android:name="android.permission.ACCESS_MOCK_LOCATION" />

    <application ...>
      <meta-data android:name="com.amap.api.v2.apikey" android:value="6f57512083ba84bc3353a42d533a48a1"></meta-data>

```

## Usage
```
import AMapView from 'react-native-amap-3d'

  render(){
    return (<View style={{flex: 1}}>
      <AMapView initialRegion={{latitude: 31.192199, longitude: 121.503628}} showsUserLocation/>
    </View>);
  }
```

ATTENTION: Make sure that the ancestor containers of AMapView is flexed, otherwise you will see an empty view!

### User Location
Dont use the `showsUserLocation` property for it has some bugs. 
Instead, use `geolocation` in iOS and [react-native-amap-location](https://github.com/xiaobuu/react-native-amap-location) in android.
Then render a new marker for the user location.
