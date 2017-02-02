//
// Created by Leland Richardson on 12/27/15.
// Copyright (c) 2015 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MAMapKit/MAMapKit.h>
#import <UIKit/UIKit.h>
#import <React/RCTConvert+MapKit.h>
//#import "RCTConvert+MapKit.h"
#import <React/RCTComponent.h>
#import "AMapCoordinate.h"
#import "AMap.h"
#import <React/RCTView.h>
//#import "RCTView.h"


@interface AMapPolyline: MAAnnotationView <MAOverlay>

@property (nonatomic, weak) AMap *map;

@property (nonatomic, strong) MAPolyline *polyline;
@property (nonatomic, strong) MAPolylineRenderer *renderer;

@property (nonatomic, strong) NSArray<AMapCoordinate *> *coordinates;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, assign) CGFloat strokeWidth;
@property (nonatomic, assign) CGFloat miterLimit;
@property (nonatomic, assign) CGLineCap lineCap;
@property (nonatomic, assign) CGLineJoin lineJoin;
@property (nonatomic, assign) CGFloat lineDashPhase;
@property (nonatomic, strong) NSArray <NSNumber *> *lineDashPattern;

#pragma mark MAOverlay protocol

@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property(nonatomic, readonly) MAMapRect boundingMapRect;
- (BOOL)intersectsMapRect:(MAMapRect)mapRect;
- (BOOL)canReplaceMapContent;

@end
