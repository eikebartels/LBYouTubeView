//
//  LBYouTubePlayerController.m
//  LBYouTubeView
//
//  Created by Laurin Brandner on 29.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LBYouTubePlayerController.h"

@interface LBYouTubePlayerController () 

@property (nonatomic, strong) LBYouTubeExtractor* extractor;

-(void)_setupWithYouTubeURL:(NSURL*)URL quality:(LBYouTubeVideoQuality)quality;

-(void)_didSuccessfullyExtractYouTubeURL:(NSURL*)videoURL;
-(void)_failedExtractingYouTubeURLWithError:(NSError*)error;

@end
@implementation LBYouTubePlayerController

@synthesize delegate, extractor;

#pragma mark Initialization

-(id)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    }
    return self;
}

-(id)initWithYouTubeURL:(NSURL *)URL quality:(LBYouTubeVideoQuality)quality {
    NSMutableDictionary* parameters = [NSMutableDictionary new];
    for (NSString* parameter in [URL.query componentsSeparatedByString:@"&"]) {
        NSArray* pair = [parameter componentsSeparatedByString:@"="];
        if([pair count] == 2) {
            [parameters setObject:pair[1] forKey:pair[0]];
        }
    }
    
    return [self initWithYouTubeID:parameters[@"v"] quality:quality];
}

-(id)initWithYouTubeID:(NSString *)youTubeID quality:(LBYouTubeVideoQuality)quality {
    self = [super init];
    if (self) {
        [self _setupWithYouTubeURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@", youTubeID]] quality:quality];
    }
    return self;
}

-(void)_setupWithYouTubeURL:(NSURL *)URL quality:(LBYouTubeVideoQuality)quality {
    self.delegate = nil;
    
    self.extractor = [[LBYouTubeExtractor alloc] initWithURL:URL quality:quality];
    self.extractor.delegate = self;
    [self.extractor startExtracting];
}

- (void)playbackChange:(NSNotification*)notification{
    /*
     MPMoviePlaybackStateStopped,
     MPMoviePlaybackStatePlaying,
     MPMoviePlaybackStatePaused,
     MPMoviePlaybackStateInterrupted,
     MPMoviePlaybackStateSeekingForward,
     MPMoviePlaybackStateSeekingBackward
     */
    NSLog(@"playbackState: %i",self.playbackState);
    if (self.playbackState == MPMoviePlaybackStatePlaying) {
        if (self.inFullScreen) {
            [self setFullscreen:YES animated:YES];
        }
    }
    
    
}

#pragma mark -
#pragma mark Memory

-(void)dealloc {
    self.extractor.delegate = nil;
}

#pragma mark -
#pragma mark Delegate Calls
 
-(void)_didSuccessfullyExtractYouTubeURL:(NSURL *)videoURL {
    if ([self.delegate respondsToSelector:@selector(youTubePlayerViewController:didSuccessfullyExtractYouTubeURL:)]) {
        [self.delegate youTubePlayerViewController:self didSuccessfullyExtractYouTubeURL:videoURL];
    }
}

-(void)_failedExtractingYouTubeURLWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(youTubePlayerViewController:failedExtractingYouTubeURLWithError:)]) {
        [self.delegate youTubePlayerViewController:self failedExtractingYouTubeURLWithError:error];
    }
}

#pragma mark -
#pragma mark LBYouTubeExtractorDelegate

-(void)youTubeExtractor:(LBYouTubeExtractor *)extractor didSuccessfullyExtractYouTubeURL:(NSURL *)videoURL {
    [self _didSuccessfullyExtractYouTubeURL:videoURL];
    
    self.contentURL = videoURL;
    
    if (self.autoPlay)[self setShouldAutoplay:YES];
    if (self.inFullScreen){
        [self setFullscreen:YES animated:YES];
    }

    
    //[self play];
    //[self setFullscreen:YES animated:YES];
}

-(void)youTubeExtractor:(LBYouTubeExtractor *)extractor failedExtractingYouTubeURLWithError:(NSError *)error {
    [self _failedExtractingYouTubeURLWithError:error];
}

#pragma mark -

@end
