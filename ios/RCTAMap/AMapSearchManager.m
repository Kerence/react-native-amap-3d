//
//  AMapSearchManager.m
//  RCTAMap
//
//  Created by yuanmarshal on 16/6/1.
//  Copyright © 2016年 dianowba. All rights reserved.
//

#import "AMapSearchManager.h"
#import <React/RCTBridge.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTViewManager.h>
#import <AMapFoundationKit/AMapURLSearchType.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <objc/runtime.h>

#import "AMapSearchObject+RequestId.h"

@implementation AMapSearchManager
{
    AMapSearchAPI *_search;
}

-(instancetype)init
{
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;
    return self;
}

RCT_EXPORT_MODULE();

- (NSDictionary *)constantsToExport
{
    return @{ @"DrivingStrategy": @{
                      @"Fastest":                           @(AMapDrivingStrategyFastest), //速度最快
                      @"MinFare":                           @(AMapDrivingStrategyMinFare), //避免收费
                      @"Shortest":                          @(AMapDrivingStrategyShortest), //距离最短
                      @"NoHighways":                        @(AMapDrivingStrategyNoHighways), //不走高速
                      @"AvoidCongestion":                   @(AMapDrivingStrategyAvoidCongestion) , //躲避拥堵
                      @"AvoidHighwaysAndFare":              @(AMapDrivingStrategyAvoidHighwaysAndFare), //不走高速且避免收费
                      @"AvoidHighwaysAndCongestion":        @(AMapDrivingStrategyAvoidHighwaysAndCongestion), //不走高速且躲避拥堵
                      @"AvoidFareAndCongestion":            @(AMapDrivingStrategyAvoidFareAndCongestion), //躲避收费和拥堵
                      @"AvoidHighwaysAndFareAndCongestion": @(AMapDrivingStrategyAvoidHighwaysAndFareAndCongestion) //不走高速躲避收费和拥堵
                      }};
}

@synthesize bridge = _bridge;

//RCT_EXPORT_METHOD(poiSearchByKeywords:(NSString *)requestId options:(NSDictionary *)options)
//{
//    AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc]init];
//    request.keywords = options[@"keywords"];
//    request.city = options[@"city"];
//    request.cityLimit = options[@"cityLimit"];
//    request.types = options[@"types"];
//    request.page = options[@"page"];
//    request.offset = options[@"offset"];
//    
//    [_search AMapPOIKeywordsSearch:request];
//}
//
//RCT_EXPORT_METHOD(poiAroundSearch:(NSString *)requestId options:(NSDictionary *)options)
//{
//    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc]init];
//    request.keywords = options[@"keywords"];
//    request.radius = options[@"radius"];
//    NSDictionary *location = options[@"location"];
//    CGFloat lat = location[@"latitude"];
//    request.location = [AMapGeoPoint locationWithLatitude:location[@"latitude"] longitude:(CGFloat)location[@"longitude"]]
//    
//    request.types = options[@"types"];
//    request.page = options[@"page"];
//    request.offset = options[@"offset"];
//
//    
//    [_search AMapPOIAroundSearch:request];
//}




RCT_EXPORT_METHOD(inputTipsSearch:(NSString *)requestId keys:(NSString *) keys city:(NSString *)city)
{
    AMapInputTipsSearchRequest *_tipsRequest = [[AMapInputTipsSearchRequest alloc] init];

    _tipsRequest.keywords = keys;
    _tipsRequest.city = city;
    _tipsRequest.requestId = requestId;
    [_search AMapInputTipsSearch:_tipsRequest];
}

RCT_EXPORT_METHOD(weatherSearch:(NSString *)requestId city:(NSString *)city isLive:(BOOL) isLive)
{
    AMapWeatherSearchRequest *request = [[AMapWeatherSearchRequest alloc] init];
    request.city = city;
    request.type = isLive? AMapWeatherTypeLive: AMapWeatherTypeForecast;
    request.requestId = requestId;
    [_search AMapWeatherSearch:request];
}

RCT_EXPORT_METHOD(geocodeSearch:(NSString *)requestId address:(NSString *)address city:(NSString *)city)
{
    AMapGeocodeSearchRequest *request = [[AMapGeocodeSearchRequest alloc]init];
    request.address = address;
    request.city = city;
    request.requestId = requestId;
    [_search AMapGeocodeSearch:request];
}

RCT_EXPORT_METHOD(regeocodeSearch:(NSString *)requestId location:(AMapGeoPoint *)location radius:(NSInteger)radius)
{
    AMapReGeocodeSearchRequest *request = [[AMapReGeocodeSearchRequest alloc]init];
    request.location = location;
    request.radius = radius? radius: 1000;
    request.requireExtension = NO;
    request.requestId = requestId;
    [_search AMapReGoecodeSearch:request];
}

RCT_EXPORT_METHOD(walkingRouteSearch:(NSString *)requestId fromOrigin:(AMapGeoPoint *)origin to:(AMapGeoPoint *)destination with:(NSInteger)strategy)
{
    AMapWalkingRouteSearchRequest *request = [[AMapWalkingRouteSearchRequest alloc]init];
    request.requestId = requestId;
    request.origin = origin;
    request.destination = destination;
    
    [_search AMapWalkingRouteSearch:request];
    
}


//实现输入提示的回调函数
-(void)onInputTipsSearchDone:(AMapInputTipsSearchRequest*)request response:(AMapInputTipsSearchResponse *)response
{
    //通过AMapInputTipsSearchResponse对象处理搜索结果
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    if (response.tips.count != 0) {
        for (AMapTip *p in response.tips)
        {
            NSDictionary *n = [self amapTipToJson: p];
            [arr addObject:n];
        }
    }
  
    [self.bridge.eventDispatcher sendAppEventWithName:@"ReceiveAMapSearchResult" body:@{
                                                                                     @"requestId":request.requestId, @"data":arr}];
}


-(NSDictionary *)amapTipToJson:(AMapTip *)tip
{
    return @{@"name":tip.name,
             @"location":@{@"latitude":@(tip.location.latitude), @"longitude":@(tip.location.longitude)},
             @"district":tip.district
             };
}

//实现天气查询的回调函数
- (void)onWeatherSearchDone:(AMapWeatherSearchRequest *)request response:(AMapWeatherSearchResponse *)response
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    //如果是实时天气
    if(request.type == AMapWeatherTypeLive)
    {
        if (response.lives.count != 0) {
            for (AMapLocalWeatherLive *live in response.lives) {
                [arr addObject:[self dictionaryWithPropertiesOfObject:live]];
            }
        }
    }
    //如果是预报天气
    else if(response.forecasts.count != 0)
    {
        for (AMapLocalWeatherForecast *forecast in response.forecasts) {
            [arr addObject:[self amapLocalWeatherForecastToJson:forecast]];
        }
    }
    
    [self.bridge.eventDispatcher sendAppEventWithName:@"ReceiveAMapSearchResult" body:@{
                                                                                        @"requestId":request.requestId, @"data":arr}];
}


-(NSDictionary *)amapLocalWeatherForecastToJson:(AMapLocalWeatherForecast *) forecast
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (AMapLocalDayWeatherForecast *cast in forecast.casts) {
        [arr addObject:[self dictionaryWithPropertiesOfObject:cast]];
    }
    
    return @{@"adcode": forecast.adcode,
             @"province": forecast.province,
             @"city": forecast.city,
             @"reportTime": forecast.reportTime,
             @"casts": arr
             };
}

//接受处理地理编码
-(void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response
{
    //通过AMapGeocodeSearchResponse对象处理搜索结果
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    if(response.geocodes.count != 0)
    {
        for (AMapGeocode *gc in response.geocodes)
        {
            NSDictionary *n = @{@"formattedAddress": gc.formattedAddress,
                                @"province": gc.province,
                                @"city": gc.city,
                                @"cityCode": gc.citycode,
                                @"district": gc.district,
                                @"township": gc.township,
                                @"neighborhood": gc.neighborhood,
                                @"building": gc.building,
                                @"adcode": gc.adcode,
                                @"location": @{@"latitude": @(gc.location.latitude), @"longitude": @(gc.location.longitude)},
                                @"level": gc.level
                                };
            [arr addObject:n];
        }
    }
    
    [self.bridge.eventDispatcher sendAppEventWithName:@"ReceiveAMapSearchResult" body:@{
                                                                                        @"requestId":request.requestId, @"data":arr}];
}

//接收处理 逆地址编码
-(void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    if(response.regeocode != nil)
    {
        //通过AMapReGeocodeSearchResponse对象处理搜索结果
        NSDictionary *n = @{
                            @"formattedAddress":response.regeocode.formattedAddress,
                            @"province": response.regeocode.addressComponent.province,
                            @"city": response.regeocode.addressComponent.city,
                            @"cityCode": response.regeocode.addressComponent.citycode,
                            @"township": response.regeocode.addressComponent.township,
                            @"neighborhood": response.regeocode.addressComponent.neighborhood,
                            @"building": response.regeocode.addressComponent.building,
                            @"district": response.regeocode.addressComponent.district
                            };
        [arr addObject:n];
    }
    
    [self.bridge.eventDispatcher sendAppEventWithName:@"ReceiveAMapSearchResult" body:@{
                                                                                        @"requestId":request.requestId, @"data":arr}];
}

//实现路径搜索的回调函数
- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response
{
    if(response.route != nil)
    {
        
    }
    
    if ([request isKindOfClass:[AMapWalkingRouteSearchRequest class]]) {
        
    }else if ([request isKindOfClass:[AMapTransitRouteSearchRequest class]]) {
        
    }else if ([request isKindOfClass:[AMapDrivingRouteSearchRequest class]]) {
        
    }
    
    //通过AMapNavigationSearchResponse对象处理搜索结果
    [self.bridge.eventDispatcher sendAppEventWithName:@"ReceiveAMapSearchResult" body:@{
                                                                                        @"requestId":request.requestId, @"data":@[]}];
}


-(void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    AMapSearchObject *search = (AMapSearchObject *)request;
    [self.bridge.eventDispatcher sendAppEventWithName:@"ReceiveAMapSearchResult" body:@{
                                                                                        @"requestId":search.requestId, @"error":@{
                                                                                                @"domain": error.domain,
                                                                                                @"userInfo": error.userInfo
                                                                                                }}];
}

- (NSDictionary *) dictionaryWithPropertiesOfObject:(id)obj
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([obj class], &count);
    
    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
//        if ([[obj valueForKey:key] class] == [AMapGeoPoint class] ) {
//            @todo//
//        }
        [dict setObject:[obj valueForKey:key] forKey:key];
    }
    
    free(properties);
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end
