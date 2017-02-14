//
//  YouTubeUploadVideo.m
//  YouTube Direct Lite for iOS
//
//  Created by Ibrahim Ulukaya on 10/29/13.
//  Copyright (c) 2013 Google. All rights reserved.
//

#import "YouTubeUploadVideo.h"
#import "VideoData.h"
#import "UploadController.h"
#import "Utils.h"

// Thumbnail image size.
static const CGFloat kCropDimension = 44;

@implementation YouTubeUploadVideo


- (void)uploadYouTubeVideoWithService:(GTLRYouTubeService *)service
                             fileData:(NSData*)fileData
                                title:(NSString *)title
                          description:(NSString *)description {
    
    GTLRYouTube_Video *video = [GTLRYouTube_Video object];
    GTLRYouTube_VideoSnippet *snippet = [GTLRYouTube_VideoSnippet alloc];
    GTLRYouTube_VideoStatus *status = [GTLRYouTube_VideoStatus alloc];
    status.privacyStatus = @"public";
    snippet.title = title;
    snippet.descriptionProperty = description;
    snippet.tags = [NSArray arrayWithObjects:DEFAULT_KEYWORD,[UploadController generateKeywordFromPlaylistId:UPLOAD_PLAYLIST], nil];
    video.snippet = snippet;
    video.status = status;
    
    GTLRUploadParameters *uploadParameters = [GTLRUploadParameters uploadParametersWithData:fileData MIMEType:@"video/*"];
    
    GTLRYouTubeQuery_VideosInsert *query = [GTLRYouTubeQuery_VideosInsert queryWithObject:video part:@"snippet,status" uploadParameters:uploadParameters];
    
    UIAlertController *waitIndicator = [Utils showWaitIndicator:@"Uploading to YouTube"];
    
    [service executeQuery:query
                completionHandler:^(GTLRServiceTicket *ticket,
                                    GTLRYouTube_Video *insertedVideo, NSError *error) {
                    //[waitIndicator dismissWithClickedButtonIndex:0 animated:YES];
                    if (error == nil)
                    {
                        NSLog(@"File ID: %@", insertedVideo.identifier);
                        [Utils showAlert:@"YouTube" message:@"Video uploaded!"];
                        [self.delegate uploadYouTubeVideo:self didFinishWithResults:insertedVideo];
                        return;
                    }
                    else
                    {
                        NSLog(@"An error occurred: %@", error);
                        [Utils showAlert:@"YouTube" message:@"Sorry, an error occurred!"];
                        [self.delegate uploadYouTubeVideo:self didFinishWithResults:nil];
                        return;
                    }
                }];
}

@end
