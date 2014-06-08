//
//  StaffViewController.m
//  UTARadioIphone
//
//  Created by James Fielder on 6/2/14.
//  Copyright (c) 2014 com.mobi. All rights reserved.
//

#import "StaffViewController.h"
#import "AudioPlayerSingleton.h"

#define RADIO_STAFF_URL @"http://omega.uta.edu/~jwcarter/utaradio/radiostaff.csv"

@interface StaffViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation StaffViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"Radio Staff";
}

-(void)viewDidLayoutSubviews{
    //NSString *staffListStr = @"first line\n second line \n third line\n";
    //self.textView.textAlignment = NSTextAlignmentCenter;
    //[self.textView setText:staffListStr];
     [self retrieveRadioStaff];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)retrieveRadioStaff{
    NSString *infoUrl = RADIO_STAFF_URL;
    NSURL  *url = [NSURL URLWithString:infoUrl];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    
    NSString *staffStr = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
   
    NSMutableArray *data = [[staffStr componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]] mutableCopy];

    [self updateViewWithStaff:data];
}

- (void) updateViewWithStaff: (NSMutableArray *)staffList{
    NSString *textViewStr = @"";
    for(int i = 1; i < staffList.count; i++){
        NSArray *brokenStr = [staffList[i] componentsSeparatedByString:@","];
        if(brokenStr.count == 3){
            NSString *newStr = [@"" stringByAppendingFormat:@"%@: %@ %@"
            ,brokenStr[2], brokenStr[0], brokenStr[1]];
            
            textViewStr = [textViewStr stringByAppendingString: [newStr stringByAppendingString:@"\n\n"]];
        
        }
    }
    
    [self.textView setText:textViewStr];
}
@end
