//
//  EQViewController.m
//  Equalizer
//
//  Created by Max Nedorezov on 1/12/14.
//  Copyright (c) 2014 Max Nedorezov. All rights reserved.
//

#import "EQViewController.h"
#import "NVDSP.h"
#import "NVPeakingEQFilter.h"
#import "NVSoundLevelMeter.h"

@interface EQViewController ()

@end

@implementation EQViewController {
    UISlider *slider[10];
    float centerFrequencies[10];
    float initialGain;
    NVPeakingEQFilter *PEQ[10];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.audioManager = [Novocaine audioManager];

    // define center frequencies of the bands
    centerFrequencies[0] = 32.0f;
    centerFrequencies[1] = 64.0f;
    centerFrequencies[2] = 128.0f;
    centerFrequencies[3] = 256.0f;
    centerFrequencies[4] = 512.0f;
    centerFrequencies[5] = 1000.0f;
    centerFrequencies[6] = 2000.0f;
    centerFrequencies[7] = 4000.0f;
    centerFrequencies[8] = 8000.0f;
    centerFrequencies[9] = 16000.0f;

    // define initial gain
    initialGain = 0.0f;

    for (int i = 0; i < 10; i++) {
        PEQ[i] = [[NVPeakingEQFilter alloc] initWithSamplingRate:self.audioManager.samplingRate];
        PEQ[i].Q = 2.0f;
        PEQ[i].centerFrequency = centerFrequencies[i];
        PEQ[i].G = initialGain;
    }

    MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    mediaPicker.delegate = self;
    mediaPicker.allowsPickingMultipleItems = NO;
    [self presentViewController:mediaPicker animated:YES completion:nil];

    [self layoutSliders];
}

- (void)layoutSliders
{
    for (int i = 0; i < 10; i++) {
        slider[i] = [[UISlider alloc] init];
        slider[i].value = 0;
        slider[i].minimumValue = -12.0f;
        slider[i].maximumValue = 12.0f;
        slider[i].tag = i;
        slider[i].transform =  CGAffineTransformMakeRotation(-M_PI/2);
        slider[i].frame = CGRectMake(320/10 * i, [UIScreen mainScreen].bounds.size.height/2 - [UIScreen mainScreen].bounds.size.height/2/2, 320/10, [UIScreen mainScreen].bounds.size.height/2);
        [slider[i] addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:slider[i]];
    }
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

            // apply the filter
            for (int i = 0; i < 10; i++) {
                [PEQ[i] filterData:data numFrames:numFrames numChannels:numChannels];
            }
        }];

        [self.audioManager play];
    }
}

- (void)sliderChanged:(id)sender
{
    UISlider *slider2 = sender;
    PEQ[slider2.tag].G = slider2.value;
}

@end
