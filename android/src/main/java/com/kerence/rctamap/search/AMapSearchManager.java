package com.kerence.rctamap.search;

import com.amap.api.services.core.LatLonPoint;
import com.amap.api.services.geocoder.GeocodeQuery;
import com.amap.api.services.geocoder.GeocodeSearch;
import com.amap.api.services.geocoder.RegeocodeQuery;
import com.amap.api.services.help.InputtipsQuery;
import com.amap.api.services.route.BusRouteResult;
import com.amap.api.services.route.DrivePath;
import com.amap.api.services.route.DriveRouteResult;
import com.amap.api.services.route.DriveStep;
import com.amap.api.services.route.RouteSearch;
import com.amap.api.services.route.WalkRouteResult;
import com.amap.api.services.weather.WeatherSearchQuery;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;


/**
 * Created by marshal on 16/6/6.
 */
public class AMapSearchManager extends ReactContextBaseJavaModule {
    private ReactContext reactContext;

    public AMapSearchManager(ReactApplicationContext rContext) {
        super(rContext);
        reactContext = rContext;
    }

    @Override
    public String getName() {
        return "AMapSearchManager";
    }

    @ReactMethod
    public void inputTipsSearch(String requestId, String keys, String city) {
        InputtipsQuery inputtipsQuery = new InputtipsQuery(keys, city);
        MyInputtips request = new MyInputtips(reactContext, requestId);

        request.inputTips.setQuery(inputtipsQuery);
        request.inputTips.requestInputtipsAsyn();
    }

    @ReactMethod
    public void weatherSearch(String requestId, String city, Boolean isLive) {
        WeatherSearchQuery query = new WeatherSearchQuery(city,
                isLive ? WeatherSearchQuery.WEATHER_TYPE_LIVE : WeatherSearchQuery.WEATHER_TYPE_FORECAST);
        MyWeatherSearch request = new MyWeatherSearch(reactContext, requestId);

        request.weatherSearch.setQuery(query);
        request.weatherSearch.searchWeatherAsyn();
    }

    protected WritableArray getPolyLine(DriveStep step) {
        WritableArray array = Arguments.createArray();
        for (LatLonPoint point : step.getPolyline()) {
            WritableMap pointMap = Arguments.createMap();
            pointMap.putDouble("latitude", point.getLatitude());
            pointMap.putDouble("longitude", point.getLongitude());
            array.pushMap(pointMap);
        }
        return array;
    }

    protected WritableMap getDrivePath(DrivePath path) {
        WritableMap map = Arguments.createMap();
        map.putDouble("distance", path.getDistance());
        map.putString("strategy", path.getStrategy());
        map.putDouble("tollDistance", path.getTollDistance());
        map.putInt("totalTrafficLight", path.getTotalTrafficlights());
        map.putInt("duration", (int) path.getDuration());

        WritableArray array = Arguments.createArray();
        for (DriveStep step : path.getSteps()) {
            WritableMap stepMap = Arguments.createMap();
            stepMap.putString("action", step.getAction());
            stepMap.putInt("duration", (int) step.getDuration());
            stepMap.putString("assistantAction", step.getAssistantAction());
            stepMap.putString("instruction", step.getInstruction());
            stepMap.putString("orientation", step.getOrientation());
            stepMap.putString("road", step.getRoad());
            stepMap.putArray("polyline", getPolyLine(step));
            array.pushMap(stepMap);
        }
        map.putArray("steps", array);
        return map;
    }

    public WritableArray getResultFromDriveRouteResult(DriveRouteResult drr) {
        if (drr == null || drr.getPaths() == null || drr.getPaths().size() == 0) {
            return null;
        }
        WritableArray arr = Arguments.createArray();
        for (DrivePath p : drr.getPaths()) {
            arr.pushMap(getDrivePath(p));
        }
        return arr;
    }

    @ReactMethod
    public void routeDrivingSearch(double fromLat, double fromLng, double toLat, double toLng, final Callback normalCallback, final Callback errCallback) {
        RouteSearch rs = new RouteSearch(reactContext);
        rs.setRouteSearchListener(new RouteSearch.OnRouteSearchListener() {
            @Override
            public void onBusRouteSearched(BusRouteResult busRouteResult, int i) {
            }

            @Override
            public void onDriveRouteSearched(DriveRouteResult result, int rCode) {
                WritableMap map = Arguments.createMap();
                map.putInt("errorCode", rCode);
                map.putArray("paths", getResultFromDriveRouteResult(result));
                normalCallback.invoke(map);
//                if (rCode == 1000) {
//                    if (result != null && result.getPaths() != null
//                            && result.getPaths().size() > 0) {
//                        WritableArray r = getResultFromDriveRouteResult(result);
//                        normalCallback.invoke(r);
////                        DrivePath drivePath = result.getPaths().get(0);
//                    } else {
//                        errCallback.invoke("无法找到路径");
//                    }
//                } else if (rCode == 27) {
//                    errCallback.invoke("搜索失败，请检查网络连接");
//                } else if (rCode == 32) {
//                    errCallback.invoke("搜索失败，KEY错误");
//                } else {
//                    errCallback.invoke("搜索失败，发生未知错误" + rCode);
//                }
            }

            @Override
            public void onWalkRouteSearched(WalkRouteResult walkRouteResult, int i) {
            }
        });
        final RouteSearch.FromAndTo fromAndTo = new RouteSearch.FromAndTo(
                new LatLonPoint(fromLat, fromLng), new LatLonPoint(toLat, toLng));
        RouteSearch.DriveRouteQuery query = new RouteSearch.DriveRouteQuery(fromAndTo, RouteSearch.DrivingDefault,
                null, null, "");
        // 第一个参数表示路径规划的起点和终点，第二个参数表示驾车模式，第三个参数表示途经点，第四个参数表示避让区域，第五个参数表示避让道路
        rs.calculateDriveRouteAsyn(query);// 异步路径规划驾车模式查询
    }

    @ReactMethod
    public void geocodeSearch(String requestId, String address, String city) {
        MyGeocodeSearch request = new MyGeocodeSearch(reactContext, requestId);
        GeocodeQuery query = new GeocodeQuery(address, city);

        request.geocodeSearch.getFromLocationNameAsyn(query);
    }

    @ReactMethod
    public void regeocodeSearch(String requestId, ReadableMap latlon, Float radius) {
        MyGeocodeSearch request = new MyGeocodeSearch(reactContext, requestId);
        LatLonPoint point = new LatLonPoint(latlon.getDouble("latitude"), latlon.getDouble("longitude"));
        RegeocodeQuery query = new RegeocodeQuery(point, radius != null ? radius : 1000, GeocodeSearch.AMAP);

        request.geocodeSearch.getFromLocationAsyn(query);
    }
}
