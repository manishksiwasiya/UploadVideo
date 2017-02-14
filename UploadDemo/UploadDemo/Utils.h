//
//  Utils.h
//  YouTube Direct Lite for iOS
//
//  Created by Ibrahim Ulukaya on 11/6/13.
//  Copyright (c) 2013 Google. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString *const DEFAULT_KEYWORD = @"ytdl";
static NSString *const UPLOAD_PLAYLIST = @"Replace me with the playlist ID you want to upload into";

static NSString *const kClientID = @"393641263035-p6gvq7jrfage1ufvfpnt22fb7frue364.apps.googleusercontent.com";
static NSString *const kClientSecret = nil;

static NSString *const kKeychainItemName = @"VideoUploadDemo";//@"YouTube Direct Lite";

static NSString *const kRedirectURI = @"com.googleusercontent.apps.393641263035-p6gvq7jrfage1ufvfpnt22fb7frue364:/oauthredirect";

/*! @brief The OIDC issuer from which the configuration will be discovered.
 */
static NSString *const kIssuer = @"https://accounts.google.com";

@interface Utils : NSObject

+ (UIAlertController *)showWaitIndicator:(NSString *)title;
+ (void)showAlert:(NSString *)title message:(NSString *)message;
+ (NSString *)humanReadableFromYouTubeTime:(NSString *)youTubeTimeFormat;

@end
