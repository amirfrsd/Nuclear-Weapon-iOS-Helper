//
//  HasteFM.h
//  Profile
//
//  Created by Apple on 7/21/19.
//  Copyright © 2019 Amir Farsad. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HasteFM : NSObject
+ (NSArray *)listIPAFilesInDocumentsDirectory;
+ (NSDictionary *)extractDataFromIPAFileInPath:(NSString *)path;
@end

NS_ASSUME_NONNULL_END
