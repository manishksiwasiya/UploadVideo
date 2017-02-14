//
//  YouTubeGetUploads.m
//  YouTube Direct Lite for iOS
//
//  Created by Ibrahim Ulukaya on 10/29/13.
//  Copyright (c) 2013 Google. All rights reserved.
//

#import "YouTubeGetUploads.h"
#import "VideoData.h"

// Thumbnail image size.
static const CGFloat kCropDimension = 70;

@implementation YouTubeGetUploads


- (void)getYouTubeUploadsWithService:(GTLRYouTubeService *)service {
    // Construct query
    GTLRYouTubeQuery_ChannelsList *channelsListQuery = [GTLRYouTubeQuery_ChannelsList queryWithPart:@"contentDetails"];
    
    channelsListQuery.mine = YES;
    
    // This callback uses the block syntax
    
    [service executeQuery:channelsListQuery
     
        completionHandler:^(GTLRServiceTicket *ticket, GTLRYouTube_ChannelListResponse
                            
                            *response, NSError *error) {
            
            if (error) {
                [self.delegate getYouTubeUploads:self didFinishWithResults:nil];
                return;
            }
            
            NSLog(@"Finished API call");
            
            if ([[response items] count] > 0) {
                
                GTLRYouTube_Channel *channel = response[0];
                
                NSString *uploadsPlaylistId = channel.contentDetails.relatedPlaylists.uploads;
                
                GTLRYouTubeQuery_PlaylistsList *playlistItemsListQuery = [GTLRYouTubeQuery_PlaylistsList queryWithPart:@"contentDetails"];
                
                playlistItemsListQuery.maxResults = 20l;
                playlistItemsListQuery.identifier = uploadsPlaylistId;
                
                // This callback uses the block syntax
                
                [service executeQuery:playlistItemsListQuery
                 
                    completionHandler:^(GTLRServiceTicket *ticket, GTLRYouTube_PlaylistItemListResponse
                                        
                                        *response, NSError *error) {
                        
                        if (error) {
                            [self.delegate getYouTubeUploads:self didFinishWithResults:nil];
                            return;
                        }
                        
                        NSLog(@"Finished API call");
                        
                        NSMutableArray *videoIds = [NSMutableArray arrayWithCapacity:response.items.count];
                        
                        for (GTLRYouTube_PlaylistItem *playlistItem in response.items) {
                            
                            [videoIds addObject:playlistItem.contentDetails.videoId];
                            
                        }
                        
                        GTLRYouTubeQuery_VideosList *videosListQuery = [GTLRYouTubeQuery_VideosList queryWithPart:@"id,contentDetails,snippet,status,statistics"];
                        
                        videosListQuery.identifier = [videoIds componentsJoinedByString: @","];
                        
                        [service executeQuery:videosListQuery
                         
                            completionHandler:^(GTLRServiceTicket *ticket, GTLRYouTube_VideoListResponse
                                                
                                                *response, NSError *error) {
                                if (error) {
                                    [self.delegate getYouTubeUploads:self didFinishWithResults:nil];
                                    return;
                                }
                                
                                NSLog(@"Finished API call");
                                NSMutableArray *videos = [NSMutableArray arrayWithCapacity:response.items.count];
                                VideoData *vData;
                                
                                for (GTLRYouTube_Video *video in response.items){
                                    if ([@"public" isEqualToString:video.status.privacyStatus]){
                                        vData = [VideoData alloc];
                                        vData.video = video;
                                        [videos addObject:vData];
                                    }
                                }
                                
                                // Schedule an async job to fetch the image data for each result and
                                // resize the large image in to a smaller thumbnail.
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                                    NSMutableArray *removeThese = [NSMutableArray array];
                                    
                                    for (VideoData *vData in videos) {
                                        // Fetch synchronously the full sized image.
                                        NSURL *url = [NSURL URLWithString:vData.getThumbUri];
                                        NSData *imageData = [NSData dataWithContentsOfURL:url];
                                        UIImage *image = [UIImage imageWithData:imageData];
                                        if (!image) {
                                            [removeThese addObject:vData];
                                            continue;
                                        }
                                        vData.fullImage = image;
                                        // Create a thumbnail from the fullsized image.
                                        UIGraphicsBeginImageContext(CGSizeMake(kCropDimension,
                                                                               kCropDimension));
                                        [image drawInRect:
                                         CGRectMake(0, 0, kCropDimension, kCropDimension)];
                                        vData.thumbnail = UIGraphicsGetImageFromCurrentImageContext();
                                        UIGraphicsEndImageContext();
                                    }
                                    
                                    // Remove images that has no image data.
                                    [videos removeObjectsInArray:removeThese];
                                    
                                    // Once all the images have been fetched and cached, call
                                    // our delegate on the main thread.
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [self.delegate getYouTubeUploads:self
                                                        didFinishWithResults:videos];
                                    });
                                });
                                
                            }];
                    }];
            }
            }];
}

@end
