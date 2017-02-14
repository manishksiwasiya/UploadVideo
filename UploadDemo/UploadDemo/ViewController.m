//
//  ViewController.m
//  UploadDemo
//
//  Created by Manish Kumar on 13/02/17.
//  Copyright © 2017 Manish Kumar. All rights reserved.
//

#import "ViewController.h"
#import "GTMOAuth2KeychainCompatibility.h"
#import "OIDAuthorizationRequest.h"
#import "Utils.h"
#import "AppDelegate.h"

#import <AppAuth/AppAuth.h>
#import <GTMAppAuth/GTMAppAuth.h>
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _uploadVideo = [[YouTubeUploadVideo alloc] init];
    _uploadVideo.delegate = self;
    NSString *myUrlSTR = [[NSBundle mainBundle] pathForResource:@"compose_demo" ofType:@"mov"];
    _videoUrl = [NSURL URLWithString:myUrlSTR];
    
    // Initialize the youtube service & load existing credentials from the keychain if available
    self.youtubeService = [[GTLRYouTubeService alloc] init];
    self.youtubeService.authorizer = [GTMOAuth2KeychainCompatibility authForGoogleFromKeychainForName:kKeychainItemName clientID:kClientID clientSecret:kClientSecret];
}

// Helper to check if user is authorized
- (BOOL)isAuthorized {
    return [((GTMAppAuthFetcherAuthorization *)self.youtubeService.authorizer) canAuthorize];
}

// Creates the auth controller for authorizing access to YouTube.
- (GTMAppAuthFetcherAuthorization *)createAuthController
{
    NSURL *redirectURI = [NSURL URLWithString:kRedirectURI];
    
    OIDServiceConfiguration *configuration = [GTMAppAuthFetcherAuthorization configurationForGoogle];
    
//    // builds authentication request
//    OIDAuthorizationRequest *request =
//    [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
//                                                  clientId:kClientID
//                                              clientSecret:kClientSecret
//                                                    scopes:@[kGTLRAuthScopeYouTube]
//                                               redirectURL:redirectURI
//                                              responseType:OIDResponseTypeCode
//                                      additionalParameters:nil];
    
    // builds authentication request
    OIDAuthorizationRequest *request =
    [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                                                  clientId:kClientID
                                                    scopes:@[kGTLRAuthScopeYouTube]
                                               redirectURL:redirectURI
                                              responseType:OIDResponseTypeCode
                                      additionalParameters:nil];
    
//    OIDAuthorizationUICoordinatorIOS *cordinator = [[OIDAuthorizationUICoordinatorIOS alloc] initWithPresentingViewController:self];
    
    // performs authentication request
     AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    appDelegate.currentAuthorizationFlow =
    [OIDAuthState authStateByPresentingAuthorizationRequest:request
                                   presentingViewController:self
                                                   callback:^(OIDAuthState *_Nullable authState,
                                                              NSError *_Nullable error) {
                                                       if (authState) {
                                                           // Creates the GTMAppAuthFetcherAuthorization from the OIDAuthState.
                                                           GTMAppAuthFetcherAuthorization *authorization =
                                                           [[GTMAppAuthFetcherAuthorization alloc] initWithAuthState:authState];
                                                           
                                                           self.authorization = authorization;
                                                           NSLog(@"Got authorization tokens. Access token: %@",
                                                                 authState.lastTokenResponse.accessToken);
                                                           self.youtubeService.authorizer = authorization;
                                                       } else {
                                                           NSLog(@"Authorization error: %@", [error localizedDescription]);
                                                           self.authorization = nil;
                                                       }
                                                   }];
   
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)btnAuthorizeClicked:(id)sender {
    if (![self isAuthorized]) {
        
        [self createAuthController];
    }
}

- (IBAction)uploadYTDL:(id)sender {
    NSData *fileData = [NSData dataWithContentsOfFile:_videoUrl.absoluteString];
    NSString *title = @"MY first upload";
    NSString *description = @"This is a demo video uploaded by ME.";
    
    if ([title isEqualToString:@""]) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"'Direct Lite Uploaded File ('EEEE MMMM d, YYYY h:mm a, zzz')"];
        title = [dateFormat stringFromDate:[NSDate date]];
    }
    if ([description isEqualToString:@""]) {
        description = @"Uploaded from YouTube Direct Lite iOS";
    }
    
    [self.uploadVideo uploadYouTubeVideoWithService:_youtubeService
                                           fileData:fileData
                                              title:title
                                        description:description];
}

#pragma mark - uploadYouTubeVideo

- (void)uploadYouTubeVideo:(YouTubeUploadVideo *)uploadVideo
      didFinishWithResults:(GTLRYouTube_Video *)video {
    NSLog(@"Video Uploaded: %@", video.identifier);
    [Utils showAlert:@"Video Uploaded" message:video.identifier];
}

@end
