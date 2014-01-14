//
//  EQViewController.m
//  Equalizer
//
//  Created by Max Nedorezov on 1/12/14.
//  Copyright (c) 2014 Max Nedorezov. All rights reserved.
//

#import "EQViewController.h"

@interface EQViewController ()

@end

@implementation EQViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.audioManager = [Novocaine audioManager];
    self.audioManager.forceOutputToSpeaker = YES;

    MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    mediaPicker.delegate = self;
    mediaPicker.allowsPickingMultipleItems = NO;
    [self presentViewController:mediaPicker animated:YES completion:nil];
}

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    [self dismissViewControllerAnimated:YES completion:nil];

    MPMediaItem *mediaItem = [mediaItemCollection representativeItem];
    NSURL *songURL = [mediaItem valueForProperty:MPMediaItemPropertyAssetURL];

    if (songURL != nil) {
        self.fileReader = [[AudioFileReader alloc]
                           initWithAudioFileURL:songURL
                           samplingRate:self.audioManager.samplingRate
                           numChannels:self.audioManager.numOutputChannels];

        [self.fileReader play];

        __weak EQViewController *wself = self;

        [self.audioManager setOutputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels) {
            [wself.fileReader retrieveFreshAudio:data numFrames:numFrames numChannels:numChannels];
        }];

        [self.audioManager play];
    }
}

@end
