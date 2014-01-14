//
//  EQViewController.h
//  Equalizer
//
//  Created by Max Nedorezov on 1/12/14.
//  Copyright (c) 2014 Max Nedorezov. All rights reserved.
//

#import "Novocaine.h"
#import "AudioFileReader.h"

@interface EQViewController : UIViewController <MPMediaPickerControllerDelegate>

@property (nonatomic, strong) Novocaine *audioManager;
@property (nonatomic, strong) AudioFileReader *fileReader;

@end
