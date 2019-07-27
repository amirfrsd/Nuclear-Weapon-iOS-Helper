//
//  HasteFM.m
//  Profile
//
//  Created by Apple on 7/21/19.
//  Copyright © 2019 Amir Farsad. All rights reserved.
//

#import "HasteFM.h"
#import "ZipZap.h"
#import <UIKit/UIKit.h>
@implementation HasteFM
+ (NSArray *)listIPAFilesInDocumentsDirectory {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSFileManager *hasteFM;
    NSString *entry;
    NSString *documentsDir;
    NSDirectoryEnumerator *enumerator;
    BOOL isDirectory;
    hasteFM = [NSFileManager defaultManager];
    documentsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    [hasteFM changeCurrentDirectoryPath:documentsDir];
    enumerator = [hasteFM enumeratorAtPath:documentsDir];
    while ((entry = [enumerator nextObject]) != nil) {
        if ([hasteFM fileExistsAtPath:entry isDirectory:&isDirectory] && isDirectory)
            NSLog(@"It's a directory, i'm gonna skip :D");
        else
            if ([entry hasSuffix:@"ipa"])
                [array addObject:entry];
    }
    return [array mutableCopy];
}

+ (NSDictionary *)extractDataFromIPAFileInPath:(NSString *)path {
    NSDictionary *tempDict = [[NSDictionary alloc] init];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSURL *writePath = [NSURL fileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"/tmp/"]];
    ZZArchive *archive = [ZZArchive archiveWithURL:[NSURL fileURLWithPath:path] error:nil];
    for (ZZArchiveEntry* entry in archive.entries) {
        NSURL* targetPath = [writePath URLByAppendingPathComponent:entry.fileName];
        if (entry.fileMode & S_IFDIR)
            [fileManager createDirectoryAtURL:targetPath
                  withIntermediateDirectories:YES
                                   attributes:nil
                                        error:nil];
        else {
            [fileManager createDirectoryAtURL:
             [targetPath URLByDeletingLastPathComponent]
                  withIntermediateDirectories:YES
                                   attributes:nil
                                        error:nil];
            [[entry newDataWithError:nil] writeToURL:targetPath
                                          atomically:NO];
        }
    }
    NSURL *payloadPath = [writePath URLByAppendingPathComponent:@"/Payload"];
    NSArray *dirContents = [fileManager contentsOfDirectoryAtURL:payloadPath
      includingPropertiesForKeys:@[]
                         options:NSDirectoryEnumerationSkipsHiddenFiles
                           error:nil];
    NSURL *appFileName = [dirContents firstObject];
    NSURL *infoFilePath = [NSURL fileURLWithPath:[[NSString stringWithFormat:@"/%@Info.plist",appFileName] stringByReplacingOccurrencesOfString:@"file:///" withString:@""]];
    NSURL *provisioningProfileFilePath = [NSURL fileURLWithPath:[[NSString stringWithFormat:@"/%@embedded.mobileprovision",appFileName] stringByReplacingOccurrencesOfString:@"file:///" withString:@""]];
    NSMutableDictionary *infoPlistDic = [[NSMutableDictionary alloc] initWithContentsOfFile:infoFilePath.path];
    NSData *provisioningData = [NSData dataWithContentsOfFile:provisioningProfileFilePath.path];
    NSString *newStr = [[NSString alloc] initWithData:provisioningData encoding:NSASCIIStringEncoding];
    NSString *stringOne = @"<?xml";
    NSString *stringTwo = @"</plist>";
    NSString *urlProcessor = newStr;
    NSString* scanString = @"";
    if (urlProcessor.length > 0) {
        NSScanner* scanner = [[NSScanner alloc] initWithString:urlProcessor];
        @try {
            [scanner scanUpToString:stringOne intoString:nil];
            scanner.scanLocation += [stringOne length];
            [scanner scanUpToString:stringTwo intoString:&scanString];
        }
        @finally {
            scanString = [NSString stringWithFormat:@"<?xml %@</plist>",scanString];
        }
    }
    NSData *data = [scanString dataUsingEncoding:NSUTF8StringEncoding];
    NSPropertyListFormat format;
    NSDictionary *profileDict = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainersAndLeaves format:&format error:nil];
    NSString *appName = [NSString stringWithFormat:@"%@ (%@)", [infoPlistDic valueForKey:@"CFBundleName"], [infoPlistDic valueForKey:@"CFBundleShortVersionString"]];
    NSString *certName = [profileDict valueForKey:@"TeamName"];
    NSString *expireDate = [profileDict valueForKey:@"ExpirationDate"];
    UIImage *image = [UIImage imageWithContentsOfFile:[NSURL fileURLWithPath:[[NSString stringWithFormat:@"/%@AppIcon60x60@3x.png",appFileName] stringByReplacingOccurrencesOfString:@"file:///" withString:@""]].path];
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *imgBase64String = [imageData base64EncodedStringWithOptions:0];
    tempDict = @{@"image":imgBase64String, @"name": appName, @"cert": certName, @"expire": expireDate,@"filepath":appFileName};
    [fileManager removeItemAtURL:writePath error:nil];
    return tempDict;
}
@end
