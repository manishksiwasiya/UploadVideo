//
//  ViewController.h
//  UploadDemo
//
//  Created by Manish Kumar on 13/02/17.
//  Copyright © 2017 Manish Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLRYouTube.h"
#import "YouTubeUploadVideo.h"

@class OIDAuthState;
@class GTMAppAuthFetcherAuthorization;
@class OIDServiceConfiguration;

@interface ViewController : UIViewController <YouTubeUploadVideoDelegate>

@property (nonatomic, retain) GTLRYouTubeService *youtubeService;

@property(nonatomic) GTMAppAuthFetcherAuthorization *authorization;

@property(nonatomic, strong) YouTubeUploadVideo *uploadVideo;

@property(nonatomic, strong) NSURL *videoUrl;

- (IBAction)btnAuthorizeClicked:(id)sender;

@end

