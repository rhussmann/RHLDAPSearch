//
//  iPhoneLDAPTestAppDelegate.h
//  iPhoneLDAPTest
//
//  Created by Ricky Hussmann on 7/29/09.
//  Copyright Ricky Hussmann 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface iPhoneLDAPTestAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
}

-(IBAction)searchAgain:(id)sender;

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

