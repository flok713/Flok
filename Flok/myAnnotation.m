//
//  myAnnotation.m
//  MapView
//
//  Created by dev27 on 5/30/13.
//  Copyright (c) 2013 codigator. All rights reserved.
//

#import "myAnnotation.h"

@implementation myAnnotation
//3
-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title Description:(NSString *)description{
    
  if (self = [super init]) {
      self.coordinate =coordinate;
      self.title = title;
      self.description1=description;
  }
  return self;
    
}

@end
