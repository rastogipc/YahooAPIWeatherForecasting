//
//  YQL.h
//  yql-ios
//
//  Created by Guilherme Chapiewski on 10/19/12.
//  Copyright (c) 2012 Guilherme Chapiewski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YQL : NSObject

- (NSURL *)prepareUrlForQuery:(NSString *)statement;
- (NSDictionary *)getResultForResponseDict:(NSDictionary *)results;

@end
