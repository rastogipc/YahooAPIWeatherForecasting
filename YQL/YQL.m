//
//  YQL.m
//  yql-ios
//
//  Created by Guilherme Chapiewski on 10/19/12.
//  Copyright (c) 2012 Guilherme Chapiewski. All rights reserved.
//
//  Updated by Prakash Kumar Rastogi on 5 Sept 2018
//

#import "YQL.h"

#define QUERY_PREFIX @"https://query.yahooapis.com/v1/public/yql?q="
#define QUERY_SUFFIX @"&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback="
#define QUERY_SQL @"select * from weather.forecast where woeid in (SELECT woeid FROM geo.places WHERE text="

@implementation YQL

- (NSURL *) prepareUrlForQuery: (NSString *)locStatement {
    NSString *queryStmt = [NSString stringWithFormat:@"%@\"%@\")",QUERY_SQL,locStatement];
    NSString *query = [NSString stringWithFormat:@"%@%@%@", QUERY_PREFIX, [queryStmt stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], QUERY_SUFFIX];
    NSURL *queryUrl = [NSURL URLWithString:query];
    return queryUrl;
}

- (NSDictionary *)getResultForResponseDict:(NSDictionary *)results{
    NSDictionary *resultDict = nil;
    if (results && [results count] > 0){
        resultDict = [results valueForKeyPath:@"query.results"];
    }
    return resultDict;
}

@end
