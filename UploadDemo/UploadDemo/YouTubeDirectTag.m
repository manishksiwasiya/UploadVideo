//
//  YouTubeDirectTag.m
//  YouTube Direct Lite for iOS
//
//  Created by Ibrahim Ulukaya on 10/29/13.
//  Copyright (c) 2013 Google. All rights reserved.
//

#import "YouTubeDirectTag.h"
#import "VideoData.h"
#import "UploadController.h"
#import "Utils.h"

// Thumbnail image size.
static const CGFloat kCropDimension = 44;

@implementation YouTubeDirectTag


- (void)directTagWithService:(GTLRYouTubeService *)service videoData:(VideoData*)videoData {
    //GTLRYouTube_Video
        GTLRYouTube_Video *updateVideo = [GTLRYouTube_Video alloc];
        GTLRYouTube_VideoSnippet *snippet = [videoData addTags:[NSArray arrayWithObjects:DEFAULT_KEYWORD,[UploadController generateKeywordFromPlaylistId:UPLOAD_PLAYLIST],   nil]];
        updateVideo.snippet = snippet;
        updateVideo.identifier = videoData.getYouTubeId;
        
        GTLRYouTubeQuery_VideosUpdate *videosUpdateQuery = [GTLRYouTubeQuery_VideosUpdate queryWithObject:updateVideo part:@"snippet"];
        [service executeQuery:videosUpdateQuery
         
                    completionHandler:^(GTLRServiceTicket *ticket, GTLRYouTube_Video
                                        
                                        *response, NSError *error) {
                        if (error == nil)
                        {
                            NSLog(@"Tags updated");
                            [Utils showAlert:@"YouTube" message:@"Video uploaded!"];
                            [self.delegate directTag:self didFinishWithResults:response];
                            return;
                        }
                        else
                        {
                            NSLog(@"An error occurred: %@", error);
                            [Utils showAlert:@"YouTube" message:@"Sorry, an error occurred!"];
                            [self.delegate directTag:self didFinishWithResults:nil];
                            return;
                        }

                        
                    }];
        
    }

@end
