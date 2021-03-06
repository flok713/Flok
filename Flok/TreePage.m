//
//  TreePage.m
//  Flok
//
//  Created by NITS_Mac4 on 16/08/16.
//  Copyright © 2016 Ajeet. All rights reserved.
//

#import "TreePage.h"
#import "AppDelegate.h"
#import "TreeCell.h"
#import "CreateFlokPage.h"
#import "SettingPage.h"
#import "OtherUserFlok.h"
#import "FlikDetailsForRequestBase.h"
#import "WebImageOperations.h"
#import "OtherUserViewController.h"
#import "FindFriendsViewController.h"
#import "ChatViewController.h"
#import "MePage.h"
#import "EditFlokViewController.h"
#import "HashTagFeed.h"
#import "NewTreeCellTableViewCell.h"
#import "JoinedMemberViewController.h"
#import <EventKit/EventKit.h>
@interface TreePage ()
{
    NSUserDefaults *prefs;
    
    IBOutlet UIScrollView *scrlHeader;
    IBOutlet UIScrollView *scrlMain;
    IBOutlet UITableView *tblNew;
    IBOutlet UITableView *tblHot;
    IBOutlet UITableView *tblDistance;
    NSUInteger lastPage;
    NSString *coming_miles;
    TreeCell *teampCell;

}

@end

@implementation TreePage
@synthesize btnBubble;
#pragma mark- View life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    vwTransparent.hidden=YES;
    vwAlert.hidden=YES;
     isValueGet=NO;
     [self performSelector:@selector(getProfileInfo) withObject:self afterDelay:1.0 ];
    
   // self.view.backgroundColor=[UIColor clearColor];
    prefs=[NSUserDefaults standardUserDefaults];
    vwPost.hidden=YES;
    scrlHeader.contentSize=CGSizeMake(SCREEN_WIDTH, scrlHeader.frame.size.height);
    scrlHeader.showsHorizontalScrollIndicator=NO;
    scrlMain.contentSize=CGSizeMake(SCREEN_WIDTH*2, scrlMain.frame.size.height);
    scrlMain.pagingEnabled=YES;
    btnBubble.layer.cornerRadius=15;
    tblNew.frame=CGRectMake(SCREEN_WIDTH*0, tblNew.frame.origin.y, SCREEN_WIDTH, tblNew.frame.size.height);
    tblHot.frame=CGRectMake(SCREEN_WIDTH*1, tblHot.frame.origin.y, SCREEN_WIDTH, tblHot.frame.size.height);
   // tblDistance.frame=CGRectMake(SCREEN_WIDTH*2, tblDistance.frame.origin.y, SCREEN_WIDTH, tblDistance.frame.size.height);
    
   // mapView.delegate=self;
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    type=@"local";
    miles=coming_miles;
    
#ifdef __IPHONE_8_0
    if(IS_OS_8_OR_LATER)
    {
        
        [locationManager requestAlwaysAuthorization];
        [locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
       // [self zoomMyLocation];
        [locationManager startUpdatingLocation];
    }
    else
    {
        [locationManager startUpdatingLocation];
    }
#endif
    if ([CLLocationManager locationServicesEnabled])
    {
        locationManager.delegate = self;
        [locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
    
        
        //[self showCurrentLocation:nil];
        [locationManager startUpdatingLocation];
    }
    
#if TARGET_IPHONE_SIMULATOR
    NSLog(@"simulator");
    latitude=@"22.572600";//@"37.332331";//;
    longitude=@"88.363900";//@"-122.031219";/
    
#else
    
#endif
    
     type=@"local";
   //  miles=@"50";
    miles=[[NSUserDefaults standardUserDefaults] objectForKey:@"miles"];
    [self newflok:self];
    feed_state=1;
    
    refreshControl = [[UIRefreshControl alloc]init];
    refreshControlHot = [[UIRefreshControl alloc]init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    refreshControlHot.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [tblNew addSubview:refreshControl];
    [tblHot addSubview:refreshControlHot];
    [refreshControl addTarget:self action:@selector(pullToRefresh) forControlEvents:UIControlEventValueChanged];
    [refreshControlHot addTarget:self action:@selector(pullToRefresh) forControlEvents:UIControlEventValueChanged];
    
   

}
-(void)willAppearIn:(UINavigationController *)navigationController
{
   /* [self addCenterButtonWithImage:[UIImage imageNamed:@"acorn.png"] highlightImage:[UIImage imageNamed:@"acorn.png"]];*/
}
-(void)viewWillAppear:(BOOL)animated
{
    
     [btnBubble setFrame:CGRectMake(btnBubble.frame.origin.x,-60, btnBubble.frame.size.width, btnBubble.frame.size.height)];
    [super viewWillAppear:YES];
    vwLocService.hidden=YES;
    miles=[[NSUserDefaults standardUserDefaults] objectForKey:@"miles"];
    coming_miles=[[NSUserDefaults standardUserDefaults] objectForKey:@"miles"];
    
    if ([CLLocationManager locationServicesEnabled]){
        
        NSLog(@"Location Services Enabled");
        
        if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied){
            vwLocService.hidden=NO;
            tblNew.hidden=YES;
            tblHot.hidden=YES;
        }else{
            vwLocService.hidden=YES;
            tblNew.hidden=NO;
            tblHot.hidden=NO;
        }
    }else{
        vwLocService.hidden=NO;
        tblNew.hidden=YES;
        tblHot.hidden=YES;
    }
    
    if (isValueGet) {
        isNewUpdate=NO;
        if (feed_state==1) {
            [self newflok:self];
        }else if (feed_state==2) {
            [self hottestFlok:self];
        }else if (feed_state==3) {
            [self distanceFlok:self];
        }
    }
    
    self.tabBarController.delegate = self;
    [updateTimer invalidate];
    updateTimer=[NSTimer scheduledTimerWithTimeInterval:15.0
                                     target:self
                                   selector:@selector(checkNewUpdate)
                                   userInfo:nil
                                    repeats:YES];
    
}
-(void)viewDidDisappear:(BOOL)animated
{
    [updateTimer invalidate];
    //isValueGet=NO;
}
-(IBAction)enabledLocation:(id)sender{
   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}
-(IBAction)updateScreen:(id)sender{
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelay:0.1];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [btnBubble setFrame:CGRectMake(btnBubble.frame.origin.x,-60, btnBubble.frame.size.width, btnBubble.frame.size.height)];
    [UIView commitAnimations];
    [tblNew scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    [tblHot scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
     [self changeTabBarIconNormal];
    [tblNew reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    latitude=[NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
    longitude=[NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
    if ([CLLocationManager locationServicesEnabled]){
        
        //NSLog(@"Location Services Enabled");
        
        if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied){
            vwLocService.hidden=NO;
            tblNew.hidden=YES;
            tblHot.hidden=YES;
        }else{
            vwLocService.hidden=YES;
            tblNew.hidden=NO;
            tblHot.hidden=NO;
        }
    }else{
        vwLocService.hidden=NO;
        tblNew.hidden=YES;
        tblHot.hidden=YES;
    }
    
    if (!isValueGet) {
        
        if ([table_View length]==0){
            [self getFlokList];
            
        }
        else if ([table_View isEqualToString:@"tblNew"])
        {
            
           [self getFlokList];
            
        }else if ([table_View isEqualToString:@"tblHot"])
        {
            [self getHottestFlokList];
        }
        else if ([table_View isEqualToString:@"tblDistance"])
        {
            [self getFlokListWithDistance];
        }

        isValueGet=YES;
    }
    [locationManager stopUpdatingLocation];
}
-(void)pullToRefresh{
   // [self  changeTabBarIcon];
    isNewUpdate=NO;
    if (feed_state==1) {
        [self newflok:self];
    }else if (feed_state==2) {
        [self hottestFlok:self];
    }else if (feed_state==3) {
        [self distanceFlok:self];
    }
}
-(void)checkNewUpdate{
    isNewUpdate=YES;
    if (feed_state==1) {
        [self getFlokList];
    }
    /*else if (feed_state==2) {
        [self getHottestFlokList];
    }else if (feed_state==3) {
        [self getFlokListWithDistance];
    }*/
}
#pragma mark- call Flok list api

-(void)getFlokList{
   
    if ([miles length]==0) {
        miles=@"50";
    }
    NSString *strTime=[self getLocateDate];
    
    
    // miles=@"50";
    if([latitude length]!=0){
    userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    NSString *dataString=[NSString stringWithFormat:@"user_id=%@&lat=%@&lang=%@&type=%@&distance=%@&current_time=%@",userId,latitude,longitude,type,miles,strTime];
        [[Global sharedInstance] setDelegate:(id)self];
        [[Global sharedInstance] serviceCall:dataString servicename:@"flok/listFlok" serviceType:@"POST"];
    }
}


-(void)getHottestFlokList{
    if ([miles length]==0) {
        miles=@"50";
    }
     NSString *strTime=[self getLocateDate];
     if([latitude length]!=0){
    userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    NSString *dataString=[NSString stringWithFormat:@"user_id=%@&lat=%@&lang=%@&type=%@&distance=%@&current_time=%@",userId,latitude,longitude,type,miles,strTime];
    [[Global sharedInstance] setDelegate:(id)self];
    [[Global sharedInstance] serviceCall:dataString servicename:@"flok/hottest" serviceType:@"POST"];
     }
}

-(void)getFlokListWithDistance{
    if ([miles length]==0) {
        miles=@"50";
    }
     NSString *strTime=[self getLocateDate];
    if([latitude length]!=0){
    userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    NSString *dataString=[NSString stringWithFormat:@"user_id=%@&lat=%@&lang=%@&distance=%@&type=%@&current_time=%@",userId,latitude,longitude,miles,type,strTime];
    [[Global sharedInstance] setDelegate:(id)self];
    [[Global sharedInstance] serviceCall:dataString servicename:@"flok/listFlokByDistance" serviceType:@"POST"];
     }
}
-(void)getProfileInfo{
    
    NSString *dataString=[NSString stringWithFormat:@"id=%@",userId];
    [[Global sharedInstance] setDelegate:(id)self];
    [[Global sharedInstance] serviceCall:dataString servicename:@"users/userprofile" serviceType:@"POST"];
}

-(IBAction)showAddressOnMap:(UIButton*)sender{
    
    NSDictionary *DicFlok=[arrList objectAtIndex:sender.tag];
    CLLocationCoordinate2D coordinate ;
    coordinate.latitude=[[DicFlok valueForKey:@"lat"] floatValue];
    coordinate.longitude=[[DicFlok valueForKey:@"lang"] floatValue];
    
    //create MKMapItem out of coordinates
    MKPlacemark* placeMark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
    MKMapItem* destination =  [[MKMapItem alloc] initWithPlacemark:placeMark];
    if([destination respondsToSelector:@selector(openInMapsWithLaunchOptions:)])
    {
        [destination openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving}];
        
    } else{
        
        //using iOS 5 which has the Google Maps application
        
        NSString* url = [NSString stringWithFormat: @"http://maps.google.com/maps?saddr=Current+Location&daddr=%f,%f", coordinate.latitude, coordinate.longitude];
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
        
    }
}

- (IBAction)chatTap:(id)sender {
    
    UIButton *btn=(UIButton*)sender;
    [Global disableAfterClick:btn];
  
    if (![userId isEqualToString:[tempDic valueForKey:@"user_id"]]) {
        ChatViewController *vc=(ChatViewController*)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ChatViewController"];
        vc.dataDic=tempDic;
        vc.strFriendId=[tempDic valueForKey:@"user_id"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

-(IBAction)flokEdit:(UIButton *)sender{
    
    UIButton *btn=(UIButton*)sender;
    [Global disableAfterClick:btn];
    id superView1 = sender.superview;
    while (superView1 && ![superView1 isKindOfClass:[UITableViewCell class]]) {
        superView1 = [superView1 superview];
    }
    
    TreeCell *cell=(TreeCell*)superView1;
    NSIndexPath *indexPath;
    if (segmentedControl.selectedSegmentIndex == 0) {
        indexPath = [tblNew indexPathForCell:cell];
    }else{
        indexPath = [tblHot indexPathForCell:cell];
    }
    
        

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[arrList objectAtIndex:indexPath.row]];
    
    EditFlokViewController *vc=(EditFlokViewController*)[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"EditFlokViewController"];
    vc.flokId=[dict valueForKey:@"id"];
    [self.navigationController pushViewController:vc animated:YES];
    
}
-(IBAction)flokDelete:(UIButton *)sender{
    
    UIButton *btn=(UIButton*)sender;
    [Global disableAfterClick:btn];
    id superView1 = sender.superview;
    while (superView1 && ![superView1 isKindOfClass:[UITableViewCell class]]) {
        superView1 = [superView1 superview];
    }
    
    TreeCell *cell=(TreeCell*)superView1;
    if (segmentedControl.selectedSegmentIndex == 0) {
        tempIndexPath = [tblNew indexPathForCell:cell];
    }else{
        tempIndexPath = [tblHot indexPathForCell:cell];
    }
    tempDic = [[NSMutableDictionary alloc] initWithDictionary:[arrList objectAtIndex:tempIndexPath.row]];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                    message:@"Are you sure you want to delete?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Delete", nil];
    
    alert.tag=6;
    [alert show];
    
}
-(IBAction)flokDeleteApi:(id)sender{
    
    userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    NSString *dataString=[NSString stringWithFormat:@"user_id=%@&flok_id=%@",userId,[tempDic valueForKey:@"id"]];
    [[Global sharedInstance] setDelegate:(id)self];
    [[Global sharedInstance] serviceCall:dataString servicename:@"flok/deleteFlok" serviceType:@"POST"];
    
}
-(void)hideFlokAction{
    
    userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    NSString *dataString=[NSString stringWithFormat:@"user_id=%@&flok_id=%@",userId,[tempDic valueForKey:@"id"]];
    [[Global sharedInstance] setDelegate:(id)self];
    [[Global sharedInstance] serviceCall:dataString servicename:@"flok/deleteFlok" serviceType:@"POST"];
}
-(IBAction)userMoreOption:(id)sender{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select image" delegate:self cancelButtonTitle:@"Cancel"           destructiveButtonTitle:nil otherButtonTitles:@"Edit Flok", @"Delete", nil];
    actionSheet.tag=5;
    [actionSheet showInView:self.view];
    
}
-(IBAction)otherUserMoreOption:(id)sender{
    
    UIButton *btn=(UIButton*)sender;
    tempDic=[arrList objectAtIndex:btn.tag];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select image" delegate:self cancelButtonTitle:@"Cancel"           destructiveButtonTitle:nil otherButtonTitles:@"Message",@"Hide Flok",@"Report Flok", nil];
    actionSheet.tag=4;
    [actionSheet showInView:self.view];
    
}
-(IBAction)reportFlokAction:(id)sender{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                    message:@"Are you sure you want report this post?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Delete", nil];
    [alert setTag:5];
    [alert show];
    
    
    
}
-(IBAction)hideFlokAction:(id)sender{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                    message:@"Are you sure you want hide this post?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Delete", nil];
    [alert setTag:3];
    [alert show];
    
    
    
}
-(IBAction)setReminderAlert:(UIButton*)sender{
    
    vwTransparent.hidden=NO;
    vwAlert.hidden=NO;
    tempDic = [[NSMutableDictionary alloc] initWithDictionary:[arrList objectAtIndex:sender.tag]];
}
- (IBAction)cancelReminder:(id)sender {
    
    vwTransparent.hidden=YES;
    vwAlert.hidden=YES;
}
-(void)reportToAdmin{
    
    NSString *dataString=[NSString stringWithFormat:@"user_id=%@&post_id=%@&reason=",userId,[tempDic valueForKey:@"id"]];
    [[Global sharedInstance] setDelegate:(id)self];
    [[Global sharedInstance] serviceCall:dataString servicename:@"users/reportToAdminFolk" serviceType:@"POST"];
}
-(void)hideFlok{
    
    NSString *dataString=[NSString stringWithFormat:@"user_id=%@&post_id=%@&reason=",userId,[tempDic valueForKey:@"id"]];
    [[Global sharedInstance] setDelegate:(id)self];
    [[Global sharedInstance] serviceCall:dataString servicename:@"users/reportToAdminFolk" serviceType:@"POST"];
}
-(IBAction)saveEvent:(id)sender{
    
    vwTransparent.hidden=YES;
    vwAlert.hidden=YES;
    
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    if([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        // iOS 6 and later
        // This line asks user's permission to access his calendar
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
         {
             if (granted) // user user is ok with it
             {
                 EKEvent *event = [EKEvent eventWithEventStore:eventStore];
                 event.title  = @"Final Event Check";
                 event.allDay = YES;
                 
                 NSString *myString = [tempDic valueForKey:@"start_time"];
                 NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                 dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                 [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
                 
                 NSDate *yourDate = [dateFormatter dateFromString:myString];
                 event.startDate =yourDate;
                 event.endDate = [event.startDate dateByAddingTimeInterval:60*60];  //set 1 hour meeting
                 event.startDate = [[NSDate alloc] init];
                 event.location = [tempDic valueForKey:@"location"];
                 event.notes = [tempDic valueForKey:@"title"];
                 //event.allDay=NO;
                 
                 EKAlarm *alaram = [[EKAlarm alloc]init];
                 [alaram setAbsoluteDate:yourDate];
                 [event addAlarm:alaram];
                 
                 [event setCalendar:[eventStore defaultCalendarForNewEvents]];
                 NSError *err;
                 
                 [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
                 //for alert set the aleram and notify the user rest is taken care by calendar for u
                 
                 if(err){
                     NSLog(@"unable to save event to the calendar!: Error= %@", err);
                 }else{
                     NSLog(@"Success %@", err);
                 }
                 
             }
             else // if he does not allow
             {
                 [[[UIAlertView alloc]initWithTitle:nil message:@"" delegate:nil cancelButtonTitle:NSLocalizedString(@"plzAlowCalendar", nil)  otherButtonTitles: nil] show];
                 return;
             }
         }];
    }
}

#pragma mark- Method
- (IBAction)featherTap:(UIButton *)sender
{
    
    [Global disableAfterClick:sender];
    
    CreateFlokPage *vc=(CreateFlokPage*)[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"CreateFlokPage"];
    [self.navigationController pushViewController:vc animated:YES];
    
}
- (IBAction)settingTap:(UIButton *)sender {
    
    UIButton *btn=(UIButton*)sender;
    [Global disableAfterClick:btn];
    
    SettingPage *vc=(SettingPage*)[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"SettingPage"];
    [self.navigationController pushViewController:vc animated:YES];

}
-(IBAction)creatFlokAction:(id)sender{
    
   vwPost.hidden=YES;
    CreateFlokPage *vc=(CreateFlokPage*)[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"CreateFlokPage"];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)sendInviteMsg{
    
    NSString *dataString=[NSString stringWithFormat:@"AppSid=7zvVZ3z99lNth97njshMpckn9bJo0F&Recipient=918436773925&Body=Test msg"];
    [self serviceCall:dataString servicename:@"" serviceType:@"POST"];
}
-(IBAction)FindFriends:(id)sender{
    
    UIButton *btn=(UIButton*)sender;
    [Global disableAfterClick:btn];
    
    FindFriendsViewController *vc=[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"FindFriendsViewController"];
  //  vc.arrFind=[data valueForKey:@"all_users"];
   // vc.searchData=searchData;
    [self.navigationController pushViewController:vc animated:YES];
   /* UIViewController *vc=[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"SearchUsersViewController"];
    [self.navigationController pushViewController:vc animated:YES];*/
}
-(IBAction)searchAction:(id)sender{
    
    UIButton *btn=(UIButton*)sender;
    [Global disableAfterClick:btn];
    
    UIViewController *vc=[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"SearchFlokViewController"];
    //  vc.arrFind=[data valueForKey:@"all_users"];
    // vc.searchData=searchData;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)segmentSwitch:(id)sender {
    
    arrList=[[NSMutableArray alloc] init];
    isNewUpdate=NO;
    if (segmentedControl.selectedSegmentIndex == 0) {
        type=@"local";
        // miles=@"50";
       // miles=coming_miles;
        if (isValueGet) {
            
            if (feed_state==1) {
                [self newflok:self];
            }else if (feed_state==2) {
                [self hottestFlok:self];
            }else if (feed_state==3) {
                [self distanceFlok:self];
            }
        }
         //[tblNew reloadData];
        [scrlMain setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    else{
        type=@"social";
        //miles=@"15000";
        if (isValueGet) {
            
            if (feed_state==1) {
                [self newflok:self];
            }else if (feed_state==2) {
                [self hottestFlok:self];
            }else if (feed_state==3) {
                [self distanceFlok:self];
            }
        }
        //[tblHot reloadData];
        [scrlMain setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:YES];
    }
    
    [updateTimer invalidate];
    updateTimer=[NSTimer scheduledTimerWithTimeInterval:15.0
                                                 target:self
                                               selector:@selector(checkNewUpdate)
                                               userInfo:nil
                                                repeats:YES];
}
#pragma mark- Scroll delegate
- (IBAction)tabheaderTap:(UIButton *)btnTab
{
    
    [Global disableAfterClick:btnTab];
    
    [UIView animateWithDuration:0.5 animations:^{
        if (btnTab.tag==1)
        {
            [self getFlokList];
            [scrlHeader setContentOffset:CGPointMake(0, 0) animated:YES];
        }
        if (btnTab.tag==2)
        {
            
            [scrlHeader setContentOffset:CGPointMake(0, 0) animated:YES];
        }
        if (btnTab.tag==3)
        {
           
            [scrlHeader setContentOffset:CGPointMake(0, 0) animated:YES];
        }
        
        [scrlMain setContentOffset:CGPointMake(SCREEN_WIDTH*(btnTab.tag-1), 0) animated:YES];
        
    }];
    
}

-(IBAction)newflok:(id)sender{
    isNewUpdate=NO;
    table_View =@"tblNew";
   [self getFlokList];
   [self changeTabHeaderView:1];
    feed_state=1;
    
}

-(IBAction)hottestFlok:(id)sender{
    isNewUpdate=NO;
    table_View =@"tblHot";
    [self getHottestFlokList ];
    [self changeTabHeaderView:2];
    feed_state=2;
    
}

-(IBAction)distanceFlok:(id)sender{
    isNewUpdate=NO;
     table_View=@"tblDistance";
    [self changeTabHeaderView:3];
    [self getFlokListWithDistance ];
    feed_state=3;
}

#pragma mark- Scroll delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [UIView animateWithDuration:0.5 animations:^{
        
        if (scrollView==scrlMain)
        {
            CGFloat width=SCREEN_WIDTH;
            NSInteger page=(scrollView.contentOffset.x + (0.5f * width)) / width;
            
            if (page!=lastPage)
            {
                if (page==0)
                {
                    type=@"local";
                    //miles=@"50";
                    
                    if (feed_state==1) {
                        [self newflok:self];
                    }else if (feed_state==2) {
                        [self hottestFlok:self];
                    }else if (feed_state==3) {
                        [self distanceFlok:self];
                    }
                    segmentedControl.selectedSegmentIndex=0;
                    [scrlMain setContentOffset:CGPointMake(0, 0) animated:YES];
                   
                    
                }
                else if (page==1)
                {
                    type=@"social";
                    //miles=@"15000";
                    if (feed_state==1) {
                        [self newflok:self];
                    }else if (feed_state==2) {
                        [self hottestFlok:self];
                    }else if (feed_state==3) {
                        [self distanceFlok:self];
                    }
                     segmentedControl.selectedSegmentIndex=1;
                     [scrlMain setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:YES];
                    
                }
                else if (page==2)
                {
                    //[self getFlokListWithDistance ];
                    //[scrlHeader setContentOffset:CGPointMake(0, 0) animated:YES];
                }
                else
                {
                    //[scrlHeader setContentOffset:CGPointMake(0, 0) animated:YES];
                }
                lastPage=page;
              //  [self changeTabHeaderView:page+1];
            }
            
        }

    }];
    
}

-(void)changeTabHeaderView:(NSInteger)btnTag
{
    for (UIButton *btn in scrlHeader.subviews) {
        //there are 3 button for bottom border,tags are 1,2,3
        if (btn.tag==btnTag && [btn isKindOfClass:[UIButton class]]) {
            [btn setTitleColor:RGB(242, 67, 19) forState:UIControlStateNormal];
        }
        else if([btn isKindOfClass:[UIButton class]])
        {
            [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
    }
    
    for (UIImageView *img in scrlHeader.subviews) {
        //there are 3 images for bottom border,tags are 1,2,3
        if (img.tag==btnTag && [img isKindOfClass:[UIImageView class]]) {
            img.hidden=NO;
        }
        else if([img isKindOfClass:[UIImageView class]])
        {
            img.hidden=YES;
        }
    }
}

#pragma mark- Textfield delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark- Textview delegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
}

- (void)textViewDidEndEditing:(UITextView *)textView
{

}

- (void)textViewDidChange:(UITextView *)textView
{

}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
    }

    return YES;
}

#pragma mark- Table datasource & delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView==tblNew)
    {
        return arrList.count;
    }
    if (tableView==tblHot)
    {
        return arrList.count;
    }
    if (tableView==tblDistance)
    {
        return arrList.count;
    }

    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==tblNew)
    {
        NSDictionary *dict=[arrList objectAtIndex:indexPath.row];
        NSString *strImg=[dict valueForKey:@"floksImage"];
        if ([strImg length]==0) {
            
            return 415;
        }else{
           return 486;
        }
        
    }
    if (tableView==tblHot)
    {
        return 131;
    }
    if (tableView==tblDistance)
    {
        return 131;
    }
    return 0.0;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==tblNew)
    {
        NSDictionary *dict=[arrList objectAtIndex:indexPath.row];
        NSString *strImg=[dict valueForKey:@"floksImage"];
        if ([strImg length]==0) {
            NSString *strIdentifier=@"tcell";
            TreeCell *tCell=(TreeCell*)[tableView dequeueReusableCellWithIdentifier:strIdentifier];
            NSArray *nib=[[NSBundle mainBundle] loadNibNamed:@"TreeCell" owner:self options:nil];
            tCell=[nib objectAtIndex:0];
            NSLog(@"post value--%@",dict);
            tCell.lblFlokName.text=[dict valueForKey:@"title"];
           // [self colorWord:tCell.lblFlokName];
           // [tCell.lblFlokName setTextColor:[UIColor greenColor]];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textTapped:)];
              [tCell.lblFlokName addGestureRecognizer:tap];
            tCell.lblFlokName.editable =NO;
            tCell.lblStartTime.text=[NSString stringWithFormat:@"%@ %@",[self changeDateFormat:[dict valueForKey:@"start_date"] fullDate:YES],[dict valueForKey:@"start_time"]];
            
            NSString *time2=[self timerValue:[NSString stringWithFormat:@"%@ %@",[dict valueForKey:@"start_date"],[dict valueForKey:@"start_time"]]];
            tCell.lblName.text=[NSString stringWithFormat:@"%@",time2];
             tCell.lblTime.text=[self calculateStartTime:[NSString stringWithFormat:@"%@ %@",[dict valueForKey:@"start_date"],[dict valueForKey:@"start_time"]]];
            NSLog(@"start date-- %@",time2);
            if ([type isEqualToString:@"local"]) {
                NSString *fullName=[dict valueForKey:@"uploaded_by"];
                NSMutableArray * array = [[NSMutableArray alloc] initWithArray:[fullName componentsSeparatedByString:@" "]];
                NSString *Name=[array objectAtIndex:0];
                NSString *strTemp=[NSString stringWithFormat:@"%@ @%@",Name,[dict valueForKey:@"username"]];
                tCell.lblName.attributedText=[self setTextAttribute:strTemp Name:Name and:dict];
            }else{
                NSString *fullName=[dict valueForKey:@"uploaded_by"];
                NSString *strTemp=[NSString stringWithFormat:@"%@ @%@ .%@",[dict valueForKey:@"uploaded_by"],[dict valueForKey:@"username"],tCell.lblTime.text];
                tCell.lblName.attributedText=[self setTextAttribute:strTemp Name:fullName and:dict];
            }
            // tCell.lblDistance.text=[NSString stringWithFormat:@"%.01f miles",[[dict valueForKey:@"distance"] floatValue]];
            //tCell.lblTime.text=[dict valueForKey:@""];
            tCell.lblLikeCount.text=[NSString stringWithFormat:@"%@ Going" ,[dict valueForKey:@"likecount"]];
            //  tCell.lblDisLikeCount.text=[NSString stringWithFormat:@"%@ " ,[dict valueForKey:@"dislikecount"]];
            
            tCell.btnJoin.layer.cornerRadius=5.0;
            
            NSString *strType=[dict valueForKey:@"type"];
            if ([strType isEqualToString:@"social"]) {
                //tCell.vwReflok.hidden=NO;
            }else{
                // tCell.vwReflok.hidden=YES;
            }
            NSInteger status=[[dict valueForKey:@"isLikedByMe"] integerValue];
            if (status==0) {
                [tCell.btnLike setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
            }else{
                [tCell.btnLike setImage:[UIImage imageNamed:@"liked"] forState:UIControlStateNormal];
            }
            NSString *userImg=[dict valueForKey:@"uploaded_by_userImage"];
            
            if ([userImg length]==0) {
                tCell.imgUser.image=[UIImage imageNamed:@"no-profile"];
            }else{
                [tCell.indicator startAnimating];
                [self setImageWithurl:[dict valueForKey:@"uploaded_by_userImage"] andImageView:tCell.imgUser and:tCell.indicator];
                
            }
            NSArray *arrLike=[self checkIsLikeByme:[dict valueForKey:@"user_like"]];
            if (arrList.count>3) {
                NSArray *smallArray = [arrLike subarrayWithRange:NSMakeRange(0, 3)];
                NSString * result = [[smallArray valueForKey:@"description"] componentsJoinedByString:@","]
                ;
                int likecount=[[dict valueForKey:@"likecount"] intValue];
                likecount=likecount-3;
                tCell.lblLikeBy.text=[NSString stringWithFormat:@"%@ and %d others",result,likecount];
            }else{
                NSString * result = [[arrLike valueForKey:@"description"] componentsJoinedByString:@","];
                tCell.lblLikeBy.text=[NSString stringWithFormat:@"%@",result];
            }
            
            [self setValueToCell:tCell value:dict];
            
          //  ------------------ button action --------------------------------------
            
            tCell.btnProfile.tag=indexPath.row;
            tCell.btnShowMap.tag=indexPath.row;
            tCell.btnLike.tag=indexPath.row;
            tCell.btnMore.tag=indexPath.row;
           // tCell.btnJoin.tag=indexPath.row;
            
            NSString *user_Id=[dict valueForKey:@"user_id"];
            if ([userId isEqualToString:user_Id]) {
                
                [tCell.btnMore addTarget:self action:@selector(userMoreOption:) forControlEvents:UIControlEventTouchUpInside];
            }else{
                [tCell.btnMore addTarget:self action:@selector(otherUserMoreOption:) forControlEvents:UIControlEventTouchUpInside];
            }

            [tCell.btnProfile addTarget:self action:@selector(showOtherProfile:) forControlEvents:UIControlEventTouchUpInside];
            
            [tCell.btnLike addTarget:self action:@selector(flokLike:)forControlEvents:UIControlEventTouchUpInside];
            //
            [tCell.btnSetReminder addTarget:self action:@selector(setReminderAlert:)forControlEvents:UIControlEventTouchUpInside];
            
            [tCell.btnShowMap addTarget:self action:@selector(showAddressOnMap:)forControlEvents:UIControlEventTouchUpInside];
            
            [tCell.btnSetReminder addTarget:self action:@selector(userMoreOption:)forControlEvents:UIControlEventTouchUpInside];
            
            [tCell.btnJoin addTarget:self action:@selector(joinfolkTap:)forControlEvents:UIControlEventTouchUpInside];
            
            tCell.vwExpired.hidden=YES;
            tCell.selectionStyle=UITableViewCellSelectionStyleNone;
            return tCell;
        }else{
            NSString *strIdentifier=@"tcell";
            NewTreeCellTableViewCell *tCell=(NewTreeCellTableViewCell*)[tableView dequeueReusableCellWithIdentifier:strIdentifier];
            NSArray *nib=[[NSBundle mainBundle] loadNibNamed:@"NewTreeCellTableViewCell" owner:self options:nil];
            tCell=[nib objectAtIndex:0];
            
            tCell.lblFlokName.text=[dict valueForKey:@"title"];
            tCell.lblStartTime.text=[NSString stringWithFormat:@"%@ %@",[self changeDateFormat:[dict valueForKey:@"start_date"] fullDate:YES],[dict valueForKey:@"start_time"]];
           // [self colorWord:tCell.lblFlokName];
            //[tCell.lblFlokName setTextColor:[UIColor greenColor]];
          //  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textTapped:)];
           // [tCell.lblFlokName addGestureRecognizer:tap];
           // tCell.lblFlokName.editable =NO;
            
           /* NSString *tempAddress=[dict valueForKey:@"address"];
            NSArray *myArray = [tempAddress componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
            if (myArray.count>0) {
                tCell.lblAddress.text=[myArray objectAtIndex:0];
            }*/
            
             tCell.lblTime.text=[self calculateStartTime:[NSString stringWithFormat:@"%@ %@",[dict valueForKey:@"start_date"],[dict valueForKey:@"start_time"]]];
            
            
            NSString *time2=[self timerValue:[NSString stringWithFormat:@"%@ %@",[dict valueForKey:@"start_date"],[dict valueForKey:@"start_time"]]];
            tCell.lblName.text=[NSString stringWithFormat:@"%@",time2];
            
            NSLog(@"start date-- %@",time2);
            if ([type isEqualToString:@"local"]) {
                NSString *fullName=[dict valueForKey:@"uploaded_by"];
                NSMutableArray * array = [[NSMutableArray alloc] initWithArray:[fullName componentsSeparatedByString:@" "]];
                NSString *Name=[array objectAtIndex:0];
                NSString *strTemp=[NSString stringWithFormat:@"%@ @%@",Name,[dict valueForKey:@"username"]];
                tCell.lblName.attributedText=[self setTextAttribute:strTemp Name:Name and:dict];
            }else{
                NSString *fullName=[dict valueForKey:@"uploaded_by"];
                NSString *strTemp=[NSString stringWithFormat:@"%@ @%@ .%@",[dict valueForKey:@"uploaded_by"],[dict valueForKey:@"username"],tCell.lblTime.text];
                tCell.lblName.attributedText=[self setTextAttribute:strTemp Name:fullName and:dict];
            }
            tCell.imgPost.layer.borderColor=[[UIColor grayColor] CGColor];
            tCell.imgPost.layer.borderWidth=1.0f;
            tCell.btnJoin.layer.cornerRadius=5.0;
            // tCell.lblDistance.text=[NSString stringWithFormat:@"%.01f miles",[[dict valueForKey:@"distance"] floatValue]];
            //tCell.lblTime.text=[dict valueForKey:@""];
            tCell.lblLikeCount.text=[NSString stringWithFormat:@"%@ Going" ,[dict valueForKey:@"likecount"]];
            //  tCell.lblDisLikeCount.text=[NSString stringWithFormat:@"%@ " ,[dict valueForKey:@"dislikecount"]];
            
            NSString *strType=[dict valueForKey:@"type"];
            if ([strType isEqualToString:@"social"]) {
                //tCell.vwReflok.hidden=NO;
            }else{
                // tCell.vwReflok.hidden=YES;
            }
            tCell.vwExpired.hidden=YES;
            NSString *userImg=[dict valueForKey:@"uploaded_by_userImage"];
            
            if ([userImg length]==0) {
                tCell.imgProfile.image=[UIImage imageNamed:@"no-profile"];
            }else{
                [tCell.indicator startAnimating];
                [self setImageWithurl:[dict valueForKey:@"uploaded_by_userImage"] andImageView:tCell.imgProfile and:tCell.indicator];
            }
            
            [self setImageWithurl:[dict valueForKey:@"floksImage"] andImageView:tCell.imgPost and:tCell.indicator];
            
            NSInteger status=[[dict valueForKey:@"isLikedByMe"] integerValue];
            if (status==0) {
                [tCell.btnLike setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
            }else{
                [tCell.btnLike setImage:[UIImage imageNamed:@"liked"] forState:UIControlStateNormal];
            }
            
            [self setValueToCell:tCell value:dict];
            
            NSArray *arrLike=[self checkIsLikeByme:[dict valueForKey:@"user_like"]];
            if (arrList.count>3) {
                NSArray *smallArray = [arrLike subarrayWithRange:NSMakeRange(0, 3)];
                NSString * result = [[smallArray valueForKey:@"description"] componentsJoinedByString:@","]
                ;
                int likecount=[[dict valueForKey:@"likecount"] intValue];
                likecount=likecount-3;
                tCell.lblLikeBy.text=[NSString stringWithFormat:@"%@ and %d others",result,likecount];
            }else{
                NSString * result = [[arrLike valueForKey:@"description"] componentsJoinedByString:@","];
                tCell.lblLikeBy.text=[NSString stringWithFormat:@"%@",result];
            }
            
            //  ------------------ button action --------------------------------------
            
            tCell.btnProfile.tag=indexPath.row;
            tCell.btnShowMap.tag=indexPath.row;
            tCell.btnLike.tag=indexPath.row;
            tCell.btnMore.tag=indexPath.row;
            //tCell.btnJoin.tag=indexPath.row;
            
            NSString *user_Id=[dict valueForKey:@"user_id"];
            if ([userId isEqualToString:user_Id]) {
                
                [tCell.btnMore addTarget:self action:@selector(userMoreOption:) forControlEvents:UIControlEventTouchUpInside];
            }else{
                [tCell.btnMore addTarget:self action:@selector(otherUserMoreOption:) forControlEvents:UIControlEventTouchUpInside];
            }
            
            [tCell.btnProfile addTarget:self action:@selector(showOtherProfile:) forControlEvents:UIControlEventTouchUpInside];
            
            [tCell.btnLike addTarget:self action:@selector(flokLike:)forControlEvents:UIControlEventTouchUpInside];
            //
            [tCell.btnSetReminder addTarget:self action:@selector(setReminderAlert:)forControlEvents:UIControlEventTouchUpInside];
            
            [tCell.btnShowMap addTarget:self action:@selector(showAddressOnMap:)forControlEvents:UIControlEventTouchUpInside];
            
            [tCell.btnSetReminder addTarget:self action:@selector(userMoreOption:)forControlEvents:UIControlEventTouchUpInside];
            
            [tCell.btnJoin  addTarget:self action:@selector(joinfolkTap:)forControlEvents:UIControlEventTouchUpInside];
            
            tCell.selectionStyle=UITableViewCellSelectionStyleNone;
            return tCell;
        }
        

       


    }
    else if (tableView==tblHot)
    {
       // table_View=@"tblHot";
        NSString *strIdentifier=@"tcell";
        TreeCell *tCell=(TreeCell*)[tableView dequeueReusableCellWithIdentifier:strIdentifier];
        NSArray *nib=[[NSBundle mainBundle] loadNibNamed:@"TreeCell" owner:self options:nil];
        tCell=[nib objectAtIndex:0];
        NSDictionary *dict=[arrList objectAtIndex:indexPath.row];
        tCell.lblFlokName.text=[dict valueForKey:@"title"];
        [self colorWord:tCell.lblFlokName];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textTapped:)];
        [tCell.lblFlokName addGestureRecognizer:tap];
        tCell.lblFlokName.editable =NO;
        
        NSString *time2=[self timerValue:[NSString stringWithFormat:@"%@ %@",[dict valueForKey:@"start_date"],[dict valueForKey:@"start_time"]]];
        tCell.lblUserName.text=[NSString stringWithFormat:@"%@",time2];
        
        tCell.lblDistance.text=[NSString stringWithFormat:@"%.01f miles",[[dict valueForKey:@"distance"] floatValue]];
        //tCell.lblTime.text=[dict valueForKey:@""];
        tCell.lblLikeCount.text=[NSString stringWithFormat:@"%@ Going" ,[dict valueForKey:@"likecount"]];
        
        
        tCell.lblTime.text=[self calculateTime:[dict valueForKey:@"date"]];
        BOOL isReflok=[[dict valueForKey:@"isReFlokByMe"] intValue];
        if (isReflok) {
            tCell.imgReflok.image=[UIImage imageNamed:@"reflok_hover"];
            //[tCell.btnReflok setUserInteractionEnabled:NO];
        }else{
            tCell.imgReflok.image=[UIImage imageNamed:@"reflok"];
           // [tCell.btnReflok setUserInteractionEnabled:YES];
        }
        
        NSString *strType=[dict valueForKey:@"type"];
        if ([strType isEqualToString:@"social"]) {
            //tCell.vwReflok.hidden=NO;
        }else{
            //tCell.vwReflok.hidden=YES;
        }
        if ([type isEqualToString:@"local"]) {
            NSString *fullName=[dict valueForKey:@"uploaded_by"];
            NSMutableArray * array = [[NSMutableArray alloc] initWithArray:[fullName componentsSeparatedByString:@" "]];
            NSString *Name=[array objectAtIndex:0];
            NSString *strTemp=[NSString stringWithFormat:@"%@ @%@",Name,[dict valueForKey:@"username"]];
            tCell.lblName.attributedText=[self setTextAttribute:strTemp Name:Name and:dict];
        }else{
            NSString *fullName=[dict valueForKey:@"uploaded_by"];
            NSString *strTemp=[NSString stringWithFormat:@"%@ @%@",[dict valueForKey:@"uploaded_by"],[dict valueForKey:@"username"]];
            tCell.lblName.attributedText=[self setTextAttribute:strTemp Name:fullName and:dict];
        }
        
        NSString *userImg=[dict valueForKey:@"uploaded_by_userImage"];
        
        if ([userImg length]==0) {
        //    tCell.imgFlag.image=[UIImage imageNamed:@"no-profile"];
        }else{
            [tCell.indicator startAnimating];
          //  [self setImageWithurl:[dict valueForKey:@"uploaded_by_userImage"] andImageView:tCell.imgFlag and:tCell.indicator];
        }
        NSString *user_Id=[dict valueForKey:@"user_id"];
        if ([userId isEqualToString:user_Id]) {
            [tCell.btnProfile addTarget:self action:@selector(showOtherProfile:) forControlEvents:UIControlEventTouchUpInside];
        }else{
            [tCell.btnProfile addTarget:self action:@selector(showOtherProfile:) forControlEvents:UIControlEventTouchUpInside];
        }
        tCell.btnProfile.tag=indexPath.row;
        tCell.btnLike.tag=indexPath.row;
        tCell.btnEdit.tag=indexPath.row;
        tCell.btnDelete.tag=indexPath.row;
        
        [tCell.btnLike addTarget:self action:@selector(flokLike:)forControlEvents:UIControlEventTouchUpInside];

        
        if ([userId isEqualToString:[dict valueForKey:@"user_id"]]) {
            tCell.btnMsg.hidden=YES;
            tCell.MsgImg.hidden=YES;
            
            tCell.btnEdit.hidden=NO;
            tCell.btnDelete.hidden=NO;
            tCell.btnEditImg.hidden=NO;
            tCell.btnDeleteImg.hidden=NO;
            [tCell.btnDelete addTarget:self action:@selector(flokDelete:)forControlEvents:UIControlEventTouchUpInside];
            [tCell.btnEdit addTarget:self action:@selector(flokEdit:)forControlEvents:UIControlEventTouchUpInside];
        }else{
            tCell.btnEdit.hidden=YES;
            tCell.btnDelete.hidden=YES;
            tCell.btnEditImg.hidden=YES;
            tCell.btnDeleteImg.hidden=YES;
            [tCell.btnMsg addTarget:self action:@selector(messageAction:)forControlEvents:UIControlEventTouchUpInside];
            
            
        }
        
        if ([userId isEqualToString:[dict valueForKey:@"user_id"]]) {
            tCell.btnMsg.hidden=YES;
            tCell.MsgImg.hidden=YES;
            
            tCell.btnEdit.hidden=NO;
            tCell.btnDelete.hidden=NO;
            tCell.btnEditImg.hidden=NO;
            tCell.btnDeleteImg.hidden=NO;
            [tCell.btnDelete addTarget:self action:@selector(flokDelete:)forControlEvents:UIControlEventTouchUpInside];
            [tCell.btnEdit addTarget:self action:@selector(flokEdit:)forControlEvents:UIControlEventTouchUpInside];
        }else{
            tCell.btnEdit.hidden=YES;
            tCell.btnDelete.hidden=YES;
            tCell.btnEditImg.hidden=YES;
            tCell.btnDeleteImg.hidden=YES;
            [tCell.btnMsg addTarget:self action:@selector(messageAction:)forControlEvents:UIControlEventTouchUpInside];
            
            
        }
        tCell.vwExpired.hidden=YES;
        tCell.selectionStyle=UITableViewCellSelectionStyleNone;
        return tCell;

    }
    else if (tableView==tblDistance)
    {
        table_View=@"tblDistance";
        NSString *strIdentifier=@"tcell";
        TreeCell *tCell=(TreeCell*)[tableView dequeueReusableCellWithIdentifier:strIdentifier];
        NSArray *nib=[[NSBundle mainBundle] loadNibNamed:@"TreeCell" owner:self options:nil];
        tCell=[nib objectAtIndex:0];
        NSDictionary *dict=[arrList objectAtIndex:indexPath.row];
        tCell.lblFlokName.text=[dict valueForKey:@"title"];
        tCell.lblName.text=[dict valueForKey:@"uploaded_by"];
        
        NSString *time2=[self timerValue:[NSString stringWithFormat:@"%@ %@",[dict valueForKey:@"start_date"],[dict valueForKey:@"start_time"]]];
        tCell.lblUserName.text=[NSString stringWithFormat:@"%@",time2];
        
        tCell.lblDistance.text=[NSString stringWithFormat:@"%.01f miles",[[dict valueForKey:@"distance"] floatValue]];
        tCell.lblTime.text=[self calculateTime:[dict valueForKey:@"date"]];
        tCell.lblLikeCount.text=[NSString stringWithFormat:@"%@" ,[dict valueForKey:@"likecount"]];
        NSString *strType=[dict valueForKey:@"type"];
        if ([strType isEqualToString:@"social"]) {
           // tCell.vwReflok.hidden=NO;
        }else{
            //tCell.vwReflok.hidden=YES;
        }
        NSString *userImg=[dict valueForKey:@"uploaded_by_userImage"];
        
        if ([userImg length]==0) {
           // tCell.imgFlag.image=[UIImage imageNamed:@"no-profile"];
        }else{
            [tCell.indicator startAnimating];
          //  [self setImageWithurl:[dict valueForKey:@"uploaded_by_userImage"] andImageView:tCell.imgFlag and:tCell.indicator];
        }
        
        BOOL isReflok=[[dict valueForKey:@"isReFlokByMe"] intValue];
        if (isReflok) {
            tCell.imgReflok.image=[UIImage imageNamed:@"reflok_hover"];
        }else{
            tCell.imgReflok.image=[UIImage imageNamed:@"reflok"];
        }
        tCell.vwExpired.hidden=YES;
        NSString *user_Id=[dict valueForKey:@"user_id"];
        if ([userId isEqualToString:user_Id]) {
            [tCell.btnProfile addTarget:self action:@selector(showOtherProfile:) forControlEvents:UIControlEventTouchUpInside];
        }else{
            [tCell.btnProfile addTarget:self action:@selector(showOtherProfile:) forControlEvents:UIControlEventTouchUpInside];
        }
        tCell.btnProfile.tag=indexPath.row;
        
        tCell.btnLike.tag=indexPath.row;
       
        tCell.btnEdit.tag=indexPath.row;
        tCell.btnDelete.tag=indexPath.row;
        
        [tCell.btnLike addTarget:self action:@selector(flokLike:)forControlEvents:UIControlEventTouchUpInside];
        
        
        if ([userId isEqualToString:[dict valueForKey:@"user_id"]]) {
            tCell.btnMsg.hidden=YES;
            tCell.MsgImg.hidden=YES;
        }
        else{
            
          [tCell.btnMsg addTarget:self action:@selector(messageAction:)forControlEvents:UIControlEventTouchUpInside];
        }
        tCell.btnEdit.hidden=YES;
        tCell.btnDelete.hidden=YES;
        tCell.btnEditImg.hidden=YES;
        tCell.btnDeleteImg.hidden=YES;
        
        tCell.selectionStyle=UITableViewCellSelectionStyleNone;
        return tCell;

    }

    return nil;
}
      // Check flok access conditions

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict=[arrList objectAtIndex:indexPath.row];
    if ([userId isEqualToString:[dict valueForKey:@"user_id"]]) {
        OtherUserFlok *vc=(OtherUserFlok*)[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"OtherUserFlok"];
        vc.flokId=[dict valueForKey:@"id"];
        vc.distance=[dict valueForKey:@"distance"];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else{
        //int access_type=[[dict valueForKey:@"access"] intValue];
        //NSString *access_type1=[dict valueForKey:@"access"];
        BOOL isJoinByme=[[dict valueForKey:@"is_joined_by_me"] intValue];
        if (isJoinByme) {
            OtherUserFlok *vc=(OtherUserFlok*)[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"OtherUserFlok"];
            vc.flokId=[dict valueForKey:@"id"];
            vc.distance=[dict valueForKey:@"distance"];
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            OtherUserFlok *vc=(OtherUserFlok*)[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"OtherUserFlok"];
            vc.flokId=[dict valueForKey:@"id"];
            vc.distance=[dict valueForKey:@"distance"];
            [self.navigationController pushViewController:vc animated:YES];

            }
           
       // }
    }
}
-(void)showOtherProfile:(id)sender{
    
    UIButton *btn=(UIButton*)sender;
    [Global disableAfterClick:btn];
      NSDictionary *dic=[arrList objectAtIndex:[btn tag]];
    
       NSLog(@"dicjjjjjjjj-----%@",dic);
    
    NSString *userId100=[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    if([[dic objectForKey:@"user_id"] isEqualToString:userId100]){
    
        UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
       // self.tabBarController.tabBar.hidden = NO;
        MePage *vc=(MePage*)[storyboard instantiateViewControllerWithIdentifier:@"MePage"];
         vc.frompage=@"1";
        [self.navigationController pushViewController:vc animated:YES];
    

    }
    
    else{
    
    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    OtherUserViewController *vc=(OtherUserViewController*)[storyboard instantiateViewControllerWithIdentifier:@"OtherUserViewController"];
    vc.OtherUserdic=[arrList objectAtIndex:[btn tag]];
   // vc.OtherUserId=[dic valueForKey:@""];
    [self.navigationController pushViewController:vc animated:YES];
    
    }
}


-(IBAction)messageAction:(UIButton *)sender{
    
    UIButton *btn=(UIButton*)sender;
    [Global disableAfterClick:btn];
    
    id superView1 = sender.superview;
    while (superView1 && ![superView1 isKindOfClass:[UITableViewCell class]]) {
        superView1 = [superView1 superview];
    }
    
    TreeCell *cell=(TreeCell*)superView1;
    //int temp=[cell.lblLikeCount.text intValue]+1;
    NSIndexPath *indexPath;
    if ([table_View isEqualToString:@"tblNew"])
    {
        indexPath = [tblNew indexPathForCell:cell];
        
    }else if ([table_View isEqualToString:@"tblHot"])
    {
        indexPath = [tblHot indexPathForCell:cell];
    }
    else if ([table_View isEqualToString:@"tblDistance"])
    {
        indexPath = [tblDistance indexPathForCell:cell];
    }
    
    NSMutableDictionary *oldDic = [[NSMutableDictionary alloc] initWithDictionary:[arrList objectAtIndex:indexPath.row]];
    
    if(![userId isEqualToString:[oldDic valueForKey:@"user_id"]]){
        
        ChatViewController *vc=(ChatViewController*)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ChatViewController"];
        vc.dataDic=oldDic;
        vc.strFriendId=[oldDic valueForKey:@"user_id"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
-(IBAction)flokLike:(UIButton *)sender{
    

    UIButton *btn=(UIButton*)sender;
    [Global disableAfterClick:btn];

/*    CGRect frame=btn.frame;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.1f];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationBeginsFromCurrentState:YES];
    frame.size.height=frame.size.height+10;
    frame.size.width=frame.size.width+10;
    btn.frame=frame;
    [UIView commitAnimations];
    [self performSelector:@selector(changePlayerGameOnes:) withObject:nil afterDelay:0.1];*/
    
    
    id superView1 = sender.superview;
    while (superView1 && ![superView1 isKindOfClass:[UITableViewCell class]]) {
        
        superView1 = [superView1 superview];
    }
     
    TreeCell *cell=(TreeCell*)superView1;
    int temp=[cell.lblLikeCount.text intValue]+1;
    NSIndexPath *indexPath;

    if (segmentedControl.selectedSegmentIndex == 0) {
        indexPath = [tblNew indexPathForCell:cell];
    }else{
        indexPath = [tblHot indexPathForCell:cell];
    }
    NSString *strTime=[self getCurrentDate];
    //NSString *strTime=[self getLocateDate];
    
    NSMutableDictionary *oldDic = [[NSMutableDictionary alloc] initWithDictionary:[arrList objectAtIndex:indexPath.row]];
    NSInteger status=[[oldDic valueForKey:@"isLikedByMe"] integerValue];
    if (status==0) {
        cell.lblLikeCount.text=[NSString stringWithFormat:@"%@" ,[NSString stringWithFormat:@"%d",temp]];
        NSMutableDictionary *dic =[[NSMutableDictionary alloc] initWithDictionary:oldDic];
        int totalVote=[[dic valueForKey:@"likecount"] intValue]+1;
        [dic setObject:[NSString stringWithFormat:@"%d",totalVote ] forKey:@"likecount"];
        [dic setObject:[NSString stringWithFormat:@"%d",1 ] forKey:@"isLikedByMe"];
        [arrList replaceObjectAtIndex:indexPath.row withObject:dic];
        
        NSString *postid=[oldDic valueForKey:@"id"];
        NSString *user_Id=[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
        NSString *dataString=[NSString stringWithFormat:@"user_id=%@&flok_id=%@&date_time=%@",user_Id,postid,strTime];
        [[Global sharedInstance] setDelegate:(id)self];
        [[Global sharedInstance] serviceCall:dataString servicename:@"flok/like" serviceType:@"POST"];
    
    }
    
   
}
-(IBAction)showjoinedMember:(UIButton*)sender{
    
    UIButton *btn=(UIButton*)sender;
    [Global disableAfterClick:btn];
    
    NSDictionary *dict=[arrList objectAtIndex:btn.tag];
    int maxLimit=[[dict valueForKey:@"max_people"] intValue];
    int joined=[[dict valueForKey:@"already_joined_count"] intValue];
    BOOL isAbleToReport=[[dict valueForKey:@"isExpired"] boolValue];
    NSString *Flokker=[NSString stringWithFormat:@"Flokkers %d/%d",joined,maxLimit];
    BOOL isOP=NO;
    NSString *user_Id=[dict valueForKey:@"user_id"];
    if ([userId isEqualToString:user_Id]) {
        
        isOP=YES;
    }
    JoinedMemberViewController *vc=(JoinedMemberViewController*)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"JoinedMemberViewController"];
    vc.FlokId=[dict valueForKey:@"id"];
    vc.Flokker=Flokker;
    vc.isAbleToReport=isAbleToReport;
    vc.isOP=isOP;
    vc.isExpired=[[dict valueForKey:@"isExpired"] boolValue];
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)changePlayerGameOnes:(UIButton*)sender{
    
  /*  CGRect frame=sender.frame;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.20f];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationBeginsFromCurrentState:YES];
    frame.size.height=frame.size.height-10;
    frame.size.width=frame.size.width-10;
    sender.frame=frame;
    [UIView commitAnimations];*/
}
#pragma mark Flok join
- (IBAction)joinfolkTap:(UIButton*)sender {
    
    UIButton *btn=(UIButton*)sender;
    [Global disableAfterClick:btn];
    id superView1 = sender.superview;
    while (superView1 && ![superView1 isKindOfClass:[UITableViewCell class]]) {
        
        superView1 = [superView1 superview];
    }
    
    TreeCell *cell=(TreeCell*)superView1;
    int temp=[cell.lblLikeCount.text intValue]+1;
    NSIndexPath *indexPath;
    
    if (segmentedControl.selectedSegmentIndex == 0) {
        indexPath = [tblNew indexPathForCell:cell];
    }else{
        indexPath = [tblHot indexPathForCell:cell];
    }
    tempDic=[[NSMutableDictionary alloc] initWithDictionary:[arrList objectAtIndex:indexPath.row]];
    NSDictionary *DicFlok=[[NSMutableDictionary alloc] initWithDictionary:[arrList objectAtIndex:indexPath.row]];
    BOOL isFlokLimited = [DicFlok valueForKey:@""];
    int maxLimit=[[DicFlok valueForKey:@"max_people"] intValue];
    int joined=[[DicFlok valueForKey:@"already_joined_count"] intValue];
    //Flokker=[NSString stringWithFormat:@"Flokkers %d/%d",joined,maxLimit];
    //lblJoin.text=[NSString stringWithFormat:@"%d/%d",joined,maxLimit];
    // if (maxLimit>4) {
    
    /* int min=maxLimit/5;
     int middle=min*2;
     int half=min*3;
     int max=min*4;*/
    
    
    if (maxLimit==joined) {
        isFlokLimited=YES;
    }else{
        isFlokLimited=NO;
    }
    
    if (btn.tag==5) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                        message:@"Are you sure you want to leave?"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Yes", nil];
        [alert setTag:5];
        [alert show];
        
        teampCell=cell;
        
    }else{
        if (isFlokLimited==NO) {
            
            NSString *Access_string=[DicFlok valueForKey:@"access"];
            if([Access_string isEqualToString:@"1"]||[Access_string isEqualToString:@"request based"]){
                
                BOOL access_type=[[DicFlok valueForKey:@"is_access"] boolValue];
                if (access_type==1) {
                    NSString *strTime=[self getCurrentDate];
                    NSString *dataString=[NSString stringWithFormat:@"flok_id=%@&user_id=%@&date_time=%@",[DicFlok valueForKey:@"id"],userId,strTime];
                    [[Global sharedInstance] setDelegate:(id)self];
                    [[Global sharedInstance] serviceCall:dataString servicename:@"flok/joinFlok" serviceType:@"POST"];
                    
                    [Global showOnlyAlert:@"" :@"You have successfully joined."];
                }else{
                    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"This flok is request-based" message:@"Do you want to request to join? Your profile will be submitted to the poster." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                    [alert setTag:2];
                    [alert show];
                    
                }
            }else{
                
                NSString *strTime=[self getCurrentDate];
                NSString *dataString=[NSString stringWithFormat:@"flok_id=%@&user_id=%@&date_time=%@",[tempDic valueForKey:@"id"],userId,strTime];
                [[Global sharedInstance] setDelegate:(id)self];
                [[Global sharedInstance] serviceCall:dataString servicename:@"flok/joinFlok" serviceType:@"POST"];
                
                [cell.btnJoin setTitle:@"Leave Flok" forState:UIControlStateNormal];
                [cell.btnJoin setTag:5];
                
                //  lblLocation.text=[DicFlok valueForKey:@"address"];
                //  btnShowMap.hidden=NO;
                //  vwHideMap.hidden=YES;
                //  isRecentJoin=YES;
                [Global showOnlyAlert:@"" :@"You have successfully joined."];
            }
        }else{
            [Global showOnlyAlert:@"Sorry" :@"Flok has reached its limit."];
        }
        
    }
    
}

- (IBAction)showJoinMember:(UIButton*)sender {
    
    NSDictionary *DicFlok=[[NSMutableDictionary alloc] initWithDictionary:[arrList objectAtIndex:sender.tag]];
    NSString *user_Id=[DicFlok valueForKey:@"user_id"];
    BOOL isJoinByme=[[DicFlok valueForKey:@"is_joined_by_me"] intValue];
    if ([userId isEqualToString:user_Id]) {
        UIButton *btn=(UIButton*)sender;
        [Global disableAfterClick:btn];
        NSString *joinMember=[NSString stringWithFormat:@"%@",[DicFlok valueForKey:@"already_joined_count"]];
        if (![joinMember isEqualToString:@" "]) {
            JoinedMemberViewController *vc=(JoinedMemberViewController*)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"JoinedMemberViewController"];
            //        vc.FlokId=[DicFlok valueForKey:@"id"];
            //        vc.Flokker=Flokker;
            //        vc.isAbleToReport=isAbleToReport;
            //        vc.isOP=isOP;
            vc.isExpired=[[DicFlok valueForKey:@"isExpired"] boolValue];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else {
        UIButton *btn=(UIButton*)sender;
        [Global disableAfterClick:btn];
        NSString *joinMember=[NSString stringWithFormat:@"%@",[DicFlok valueForKey:@"already_joined_count"]];
        if (![joinMember isEqualToString:@"0"]) {
            JoinedMemberViewController *vc=(JoinedMemberViewController*)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"JoinedMemberViewController"];
            // vc.FlokId=[DicFlok valueForKey:@"id"];
            //  vc.isAbleToReport=isAbleToReport;
            //  vc.isOP=isOP;
            //  vc.Flokker=Flokker;
            //  vc.isExpired=[[DicFlok valueForKey:@"isExpired"] boolValue];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    
}



#pragma mark WebServiceCallDeleGate Methods

-(void)webserviceCallFailOrError : (NSString *)errorMessage withFlag : (NSString*)serviceName{
    
    [Global showOnlyAlert:@"Error" :errorMessage ];
     [refreshControl endRefreshing];
     [refreshControlHot endRefreshing];
}
-(void)WebServiceCallFinishWithData : (NSDictionary *)data withFlag : (NSString*)serviceName{
     [refreshControl endRefreshing];
     [refreshControlHot endRefreshing];
    if([serviceName isEqualToString:@"flok/listFlok"])
    {
        
        if ([[data valueForKey:@"Ack"] intValue]==1) {
            
            arrList=[[NSMutableArray alloc] initWithArray:[data valueForKey:@"allFloks"]];
            NSDictionary *dict=[[NSDictionary alloc] initWithDictionary:[arrList firstObject]];
            NSString *tempLastId=[dict valueForKey:@"id"];
            if (isNewUpdate==YES) {
                if ([tempLastId length]!=0) {
                    if (![tempLastId isEqualToString:lastId]) {
                        [self changeTabBarIcon];
                        isNewUpdate=NO;
                        lastId=[dict valueForKey:@"id"];
                        return;
                    }   
                }
                
            }else{
                lastId=[dict valueForKey:@"id"];
                
                if (arrList.count >0) {
                    vwPost.hidden=YES;
                    tblNew.hidden=NO;
                    tblHot.hidden=NO;
                }else{
                    vwPost.hidden=NO;
                    tblNew.hidden=YES;
                    tblHot.hidden=YES;
                }
                if (segmentedControl.selectedSegmentIndex == 0) {
                    type=@"local";
                    // miles=@"50";
                    [tblNew reloadData];
                }
                else{
                    type=@"social";
                    // miles=@"15000";
                    [tblHot reloadData];
                }
                
            }
            
            
        }
        else{
            vwPost.hidden=NO;  //
            [tblNew reloadData];
            if (segmentedControl.selectedSegmentIndex == 0) {
                tblNew.hidden=YES;
            
            }
            else{
                tblHot.hidden=YES;
            }
            //[Global showOnlyAlert:@"Flok!" :[data valueForKey:@"msg"]];
            return ;
            
        }
        
    }else if([serviceName isEqualToString:@"flok/hottest"])
    {
        
        if ([[data valueForKey:@"Ack"] intValue]==1) {
           
            arrList=[[NSMutableArray alloc] initWithArray:[data valueForKey:@"allFloks"]];
            if (arrList.count >0) {
                vwPost.hidden=YES;
                tblNew.hidden=NO;
                tblHot.hidden=NO;
            }else{
                vwPost.hidden=NO;  //
                tblNew.hidden=YES;
                tblHot.hidden=YES;
            }
            if (segmentedControl.selectedSegmentIndex == 0) {
                type=@"local";
                // miles=@"50";
                [tblNew reloadData];
            }
            else{
                type=@"social";
                // miles=@"15000";
                [tblHot reloadData];
            }
           // [tblNew reloadData];
        }
        else{
            arrList=[[NSMutableArray alloc] init];
            [tblNew reloadData];
            vwPost.hidden=NO;  //
            if (segmentedControl.selectedSegmentIndex == 0) {
                tblNew.hidden=YES;
                
            }
            else{
                tblHot.hidden=YES;
            }
           // [Global showOnlyAlert:@"Flok!" :[data valueForKey:@"msg"]];
            return ;
            
        }
        
    }else if([serviceName isEqualToString:@"flok/listFlokByDistance"])
    {
        
        if ([[data valueForKey:@"Ack"] intValue]==1) {
           
            arrList=[[NSMutableArray alloc] initWithArray:[data valueForKey:@"allFloks"]];
            if (arrList.count >0) {
                vwPost.hidden=YES;
                tblNew.hidden=NO;
                tblHot.hidden=NO;
            }else{
                vwPost.hidden=NO; //
                tblNew.hidden=YES;
                tblHot.hidden=YES;
            }
            if (segmentedControl.selectedSegmentIndex == 0) {
                type=@"local";
                // miles=@"50";
                [tblNew reloadData];
            }
            else{
                type=@"social";
                // miles=@"15000";
                [tblHot reloadData];
            }
        }
        else{
          //  [Global showOnlyAlert:@"Flok!" :[data valueForKey:@"msg"]];
            arrList=[[NSMutableArray alloc] init];
            [tblNew reloadData];
            vwPost.hidden=NO;  //
            if (segmentedControl.selectedSegmentIndex == 0) {
                tblNew.hidden=YES;
                
            }
            else{
                tblHot.hidden=YES;
            }
            return ;
            
        }
        
    }else if ([serviceName isEqualToString:@"flok/deleteFlok"]){
        
        if ([[data valueForKey:@"Ack"] intValue]==1) {
            
            if (segmentedControl.selectedSegmentIndex == 0) {
                [tblNew beginUpdates];
                [arrList removeObject:tempDic];
                [tblNew deleteRowsAtIndexPaths:[NSArray arrayWithObject:tempIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [tblNew endUpdates];
            }else{
                [tblHot beginUpdates];
                [arrList removeObject:tempDic];
                [tblHot deleteRowsAtIndexPaths:[NSArray arrayWithObject:tempIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [tblHot endUpdates];
            }
        }
        
    }else if([serviceName isEqualToString:@"users/userprofile"])
    {
        NSLog(@"userprofile----%@",data);
        if ([[data valueForKey:@"Ack"] intValue]==1) {
            
            NSDictionary *DicFlok=[data valueForKey:@"UserDetails"];
            AppDelegate *app= (AppDelegate *)[UIApplication sharedApplication].delegate;
            app.profileDic=DicFlok;
            
        }
    }else if([serviceName isEqualToString:@"users/leaveFlok"])
    {
        //if ([[data valueForKey:@"Ack"] intValue]==1) {
         
            
            [teampCell.btnJoin setTitle:@"Join" forState:UIControlStateNormal];
            [teampCell.btnJoin setTag:4];
       // }
    }
    
    
}

#pragma mark Save image

-(void)setImageWithurl:(NSString*)url andImageView:(UIImageView*)imgview and:(UIActivityIndicatorView *)loder{
    [loder startAnimating];
    NSString* imageName=[url lastPathComponent];
    NSString *docDir=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString *tempFolderPath = [docDir stringByAppendingPathComponent:@"tmp"];
    [[NSFileManager defaultManager] createDirectoryAtPath:tempFolderPath withIntermediateDirectories:YES attributes:nil error:NULL];
    NSString  *FilePath = [NSString stringWithFormat:@"%@/%@",tempFolderPath,imageName];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:FilePath];
    if (fileExists)
    {
        imgview.image=[UIImage imageWithContentsOfFile:FilePath];
        [loder stopAnimating];
    }
    else
    {
        [WebImageOperations processImageDataWithURLString:url andBlock:^(NSData *imageData)
         {
             imgview.image=[UIImage imageWithData:imageData];
             [imageData writeToFile:FilePath atomically:YES];
             [loder stopAnimating];
             
             
         }];
    }
    
}


-(NSString*)calculateTime:(NSString*)time{
    if ([time isEqualToString:@"0000-00-00 00:00:00"]) {
        return @"";
    }
    NSString *gmtDateString =[NSString stringWithFormat:@"%@",time]; //@"29/10/2015 00:01";
    
    NSDateFormatter *df = [NSDateFormatter new];
    //[df setDateFormat:@"dd/MM/yyyy HH:mm"];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //[df setDateFormat:@"MM-dd-yyyy HH:mm:ss"];
    //Create the date assuming the given string is in GMT
    df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDate *date = [df dateFromString:gmtDateString];
    if (!date) {
        return @"";
    }
    
    //Create a date string in the local timezone
    df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:[NSTimeZone localTimeZone].secondsFromGMT];
    NSString *localDateString = [df stringFromDate:date];
    
    df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDate *date1 = [df dateFromString:localDateString];
    
    NSDateComponentsFormatter *formatter = [[NSDateComponentsFormatter alloc] init];
    formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleFull;
    
    //NSDate *now = [NSDate date];
    
    NSDate* sourceDate = [NSDate date];
    
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    NSDate* now = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate] ;
    
    
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitWeekOfMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond)
                                               fromDate:date1
                                                 toDate:now
                                                options:0];
    
    if (components.year > 0) {
        formatter.allowedUnits = NSCalendarUnitYear;
    } else if (components.month > 0) {
        formatter.allowedUnits = NSCalendarUnitMonth;
    } else if (components.weekOfMonth > 0) {
        formatter.allowedUnits = NSCalendarUnitWeekOfMonth;
    } else if (components.day > 0) {
        formatter.allowedUnits = NSCalendarUnitDay;
    } else if (components.hour > 0) {
        formatter.allowedUnits = NSCalendarUnitHour;
    } else if (components.minute > 0) {
        formatter.allowedUnits = NSCalendarUnitMinute;
    } else {
        formatter.allowedUnits = NSCalendarUnitSecond;
        // return @"0 minute";
    }
    
    NSString *formatString = NSLocalizedString(@"%@ ago", @"Used to say how much time has passed. e.g. '2 hr ago'");
    NSLog(@"%@",[NSString stringWithFormat:formatString, [formatter stringFromDateComponents:components]]);
    return [NSString stringWithFormat:formatString, [formatter stringFromDateComponents:components]];
    
}

#pragma mark alertView deleget

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==5) {
        
        if (buttonIndex==1) {
            
            NSString *dataString=[NSString stringWithFormat:@"flok_id=%@&user_id=%@",[tempDic valueForKey:@"id"],userId];
            [[Global sharedInstance] setDelegate:(id)self];
            [[Global sharedInstance] serviceCall:dataString servicename:@"users/leaveFlok" serviceType:@"POST"];
            
        }
    }else if(alertView.tag==6){
        
        if (buttonIndex==1) {
            
            userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
            NSString *dataString=[NSString stringWithFormat:@"user_id=%@&flok_id=%@",userId,[tempDic valueForKey:@"id"]];
            [[Global sharedInstance] setDelegate:(id)self];
            [[Global sharedInstance] serviceCall:dataString servicename:@"flok/deleteFlok" serviceType:@"POST"];
            
            
        }
    }
    
}

#pragma mark - ActionSheet


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (actionSheet.tag==5) {
        
        if(buttonIndex == 0)
        {
            
        }
        else if(buttonIndex == 1)
        {
            
        }
    }else{
        if(buttonIndex == 0)
        {
            [self chatTap:self];
        }
        else if(buttonIndex == 1)
        {
            
        }else if(buttonIndex == 2)
        {
            [self reportFlokAction:self];
            
        }
        
        
    }
    
}


- (void)colorWord:(UITextView *)lblText {
    NSRange range;
    NSRange range1=[lblText.text rangeOfString:lblText.text];;
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc]initWithString:lblText.text];
    NSArray *words=[lblText.text componentsSeparatedByString:@" "];
   // UIFont *fontText = [UIFont boldSystemFontOfSize:14];
   // NSDictionary *dictBoldText = [NSDictionary dictionaryWithObjectsAndKeys:fontText, NSFontAttributeName, nil];
    [string setAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue"size:12.0]}
                    range:range1];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:range1];
    
    for (NSString *word in words) {
        if ([word hasPrefix:@"#"]) {
            range=[lblText.text rangeOfString:word];
            [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:77.0/255.0 green:171.0/255.0 blue:231.0/255.0 alpha:1] range:range];
            }
    }
    
    [lblText setAttributedText:string];
    
}
- (void)textTapped:(UITapGestureRecognizer *)recognizer
{
    
    UITextView *textView =  (UITextView *)recognizer.view;
    [self getHashTag:textView];
    CGPoint location = [recognizer locationInView:textView];
    NSLog(@"Tap Gesture Coordinates: %.2f %.2f -- %@", location.x, location.y,textView.text);
    
    CGPoint position = CGPointMake(location.x, location.y);
    //get location in text from textposition at point
    UITextPosition *tapPosition = [textView closestPositionToPoint:position];
    
    //fetch the word at this position (or nil, if not available)
    UITextRange *textRange = [textView.tokenizer rangeEnclosingPosition:tapPosition withGranularity:UITextGranularityWord inDirection:UITextLayoutDirectionRight];
    NSString *tappedSentence =[NSString stringWithFormat:@"%@",[textView textInRange:textRange]];//;
  //  NSString *tappedSentence2 = [textView lineAtPosition:CGPointMake(location.x, location.y)];
    NSLog(@"selected :%@ -- %@ ",tappedSentence,tapPosition);
    
    for (int i=0; i<arrHashtag.count; i++) {
        NSString *str=[NSString stringWithFormat:@"%@",[arrHashtag objectAtIndex:i]];
        str=[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([str isEqualToString:tappedSentence]) {
            [self goToOtherPage:tappedSentence];
            return;
        }
    }
    CGPoint point;
    NSIndexPath *theIndexPath;
     if (segmentedControl.selectedSegmentIndex == 0) {
         point = [recognizer locationInView:tblNew];
         theIndexPath= [tblNew indexPathForRowAtPoint:point];
     }else{
         point = [recognizer locationInView:tblHot];
         theIndexPath= [tblHot indexPathForRowAtPoint:point];
     }
    
    
    NSDictionary *dict=[arrList objectAtIndex:theIndexPath.row];
    if ([userId isEqualToString:[dict valueForKey:@"user_id"]]) {
        OtherUserFlok *vc=(OtherUserFlok*)[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"OtherUserFlok"];
        vc.flokId=[dict valueForKey:@"id"];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else{
       // int access_type=[[dict valueForKey:@"access"] intValue];
       // NSString *access_type1=[dict valueForKey:@"access"];
        BOOL isJoinByme=[[dict valueForKey:@"is_joined_by_me"] intValue];
        if (isJoinByme) {
            OtherUserFlok *vc=(OtherUserFlok*)[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"OtherUserFlok"];
            vc.flokId=[dict valueForKey:@"id"];
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            OtherUserFlok *vc=(OtherUserFlok*)[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"OtherUserFlok"];
            vc.flokId=[dict valueForKey:@"id"];
            [self.navigationController pushViewController:vc animated:YES];
            
        }
    
    }
}

- (void)getHashTag:(UITextView *)textView{
    arrHashtag=[[NSMutableArray alloc ] init];
    NSRange range;
   // NSMutableAttributedString * string = [[NSMutableAttributedString alloc]initWithString:textView.text];
    NSArray *words=[textView.text componentsSeparatedByString:@" "];

    for (NSString *word in words) {
        if ([word hasPrefix:@"#"]) {
            range=[textView.text rangeOfString:word];
            NSString *string1 = [textView.text substringWithRange:NSMakeRange(range.location+1, range.length)];
            [arrHashtag addObject:string1];
        }
    }
    
    NSLog(@"arrHastag value-- %@",arrHashtag);
}


-(void)goToOtherPage:(NSString*)hashTag{
    
    HashTagFeed *vc=(HashTagFeed*)[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"HashTagFeed"];
    vc.hashtag=hashTag;
    [self.navigationController pushViewController:vc animated:YES];
}

-(NSString *)getLocateDate{
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *time=[dateFormatter stringFromDate:[NSDate date]];
    NSLog(@"%@",[dateFormatter stringFromDate:[NSDate date]]);
    return time;
    
}
-(NSMutableAttributedString*)setTextAttribute:(NSString*)strTemp Name:(NSString*)name and:(NSDictionary*)dict{
    
   // NSString *fullName=[dict valueForKey:@"uploaded_by"];
    
    NSString *userName=[NSString stringWithFormat:@"@%@",[dict valueForKey:@"username"]];
    NSString *time=[self calculateTime:[dict valueForKey:@"date"]];
    NSRange range1 = [strTemp rangeOfString:name];
    
    NSRange range2 = [strTemp rangeOfString:userName];
    NSRange range3 = [strTemp rangeOfString:time];
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:strTemp];
    
    [attributedText setAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:13.0]}
                            range:range1];
     [attributedText setAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica"size:11.0]} range:range2];
    [attributedText setAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica"size:11.0]}
                            range:range3];
    
    [attributedText addAttribute:NSForegroundColorAttributeName
                           value:[UIColor blackColor]
                           range:range1];
    
    [attributedText addAttribute:NSForegroundColorAttributeName
                           value:[UIColor grayColor]
                           range:range3];
    
    [attributedText addAttribute:NSForegroundColorAttributeName
                           value:[UIColor grayColor]
                           range:range2];
    
    return attributedText;
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if(item.tag==1)
    {
        NSLog(@"tab bar selected ");//your code
    }
    else
    {
        //your code
    }
}
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    
    if ([viewController isKindOfClass:[TreePage class]])
    {
      
       [self updateScreen:self];
        isNewUpdate=NO;
        if (feed_state==1) {
            [self newflok:self];
        }else if (feed_state==2) {
            [self hottestFlok:self];
        }else if (feed_state==3) {
            [self distanceFlok:self];
        }
    }

    
   // [self changeTabBarIconNormal];
    
    NSLog(@"tab bar selected ");
}
-(void)changeTabBarIcon{
   
    
   // UIStoryboard *storyboard= [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    ///UIViewController *myVC = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
   // UITabBarController *tabBarController = (UITabBarController *)myVC;
    
    UITabBar *tabBar=self.tabBarController.tabBar;
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:0];
    
     [tabBarItem1 setImage:[[UIImage imageNamed:@"tree-grey-round"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
     tabBarItem1.selectedImage = [[UIImage imageNamed:@"tree-orange-round"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    
    
}
-(void)changeTabBarIconNormal{
    
    UIStoryboard *storyboard;
    UIViewController *myVC;
    storyboard= [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    myVC = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    //UITabBarController *tabBarController = (UITabBarController *)myVC;
    
    UITabBar *tabBar=self.tabBarController.tabBar;
    // UITabBar *tabBar=tabBarController.tabBar;
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:0];
    
    [tabBarItem1 setImage:[[UIImage imageNamed:@"tree-grey"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    tabBarItem1.selectedImage = [[UIImage imageNamed:@"tree-orange"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
}

-(void)changeNotificationTabBarIcon{
    
    //UIStoryboard *storyboard= [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    //UIViewController *myVC = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    //UITabBarController *tabBarController = (UITabBarController *)myVC;
    
    UITabBar *tabBar=self.tabBarController.tabBar;;
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:1];
    
    [tabBarItem1 setImage:[[UIImage imageNamed:@"notification-grey-round"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    tabBarItem1.selectedImage = [[UIImage imageNamed:@"notification-orange-round"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
}

-(void)changeMessageTabBarIcon{
    
    //UIStoryboard *storyboard= [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    //UIViewController *myVC = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    //UITabBarController *tabBarController = (UITabBarController *)myVC;
    
    UITabBar *tabBar=self.tabBarController.tabBar;
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:2];
    
    [tabBarItem1 setImage:[[UIImage imageNamed:@"message-grey-round"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    tabBarItem1.selectedImage = [[UIImage imageNamed:@"message-orange-round"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];

}
-(NSString *)timerValue: (NSString *)time
{
    NSArray *myArray = [time componentsSeparatedByString:@"/"];
    NSArray *Array = [[myArray objectAtIndex:2] componentsSeparatedByString:@" "];
    if(Array.count>2){
        time=[NSString stringWithFormat:@"%@-%@-%@ %@ %@",[Array objectAtIndex:0],[myArray objectAtIndex:0],[myArray objectAtIndex:1],[Array objectAtIndex:1],[Array objectAtIndex:2]];
    }else
    {
        return  @"Expired";
    }
    time=[NSString stringWithFormat:@"%@-%@-%@ %@ %@",[Array objectAtIndex:0],[myArray objectAtIndex:0],[myArray objectAtIndex:1],[Array objectAtIndex:1],[Array objectAtIndex:2]];
    NSDateFormatter *df=[NSDateFormatter new];
    //[df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [df setDateFormat:@"yyyy-MM-dd hh:mm a"];
     NSString *gmtDateString =[NSString stringWithFormat:@"%@",time];
    NSDate *date = [df dateFromString:gmtDateString];
    
    NSInteger timeUntilEnd = (NSInteger)[[df dateFromString:time] timeIntervalSinceDate:[NSDate date]];
    if (timeUntilEnd <= 0) {
        return  @"Happening Now!";
    }
    else {
       
        df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:[NSTimeZone localTimeZone].secondsFromGMT];
        NSString *localDateString = [df stringFromDate:date];
        
        df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        NSDate *date1 = [df dateFromString:localDateString];
        
        NSDateComponentsFormatter *formatter = [[NSDateComponentsFormatter alloc] init];
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleFull;
        
        NSDateComponentsFormatter *formatter2 = [[NSDateComponentsFormatter alloc] init];
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleFull;
        
        //NSDate *now = [NSDate date];
        
        NSDate* sourceDate = [NSDate date];
        
        NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
        
        NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
        NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
        NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
        
        NSDate* now = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate] ;
        
        //NSCalendar *calendar = [NSCalendar currentCalendar];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [calendar components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitWeekOfMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond)
                                                   fromDate:now
                                                     toDate:date1
                                                    options:0];
        
        NSString *intervalTime;
        
        if (components.year > 0) {
            formatter.allowedUnits = NSCalendarUnitYear;
        } else if (components.month > 0) {
            formatter.allowedUnits = NSCalendarUnitMonth;
            intervalTime=[formatter stringFromDateComponents:components];
        } else if (components.weekOfMonth > 0) {
            formatter.allowedUnits = NSCalendarUnitWeekOfMonth;
             intervalTime=[formatter stringFromDateComponents:components];
        } else if (components.day > 0) {
            formatter.allowedUnits = NSCalendarUnitDay;
            
            NSInteger hour = [components hour];
            if(hour>1){
                 intervalTime=[NSString stringWithFormat:@"%@ %ld hours",[formatter stringFromDateComponents:components] ,(long)[components hour]];
            }else{
                 intervalTime=[NSString stringWithFormat:@"%@ %ld hour",[formatter stringFromDateComponents:components] ,(long)[components hour]];
                
            }
           
        } else if (components.hour > 0) {
            formatter.allowedUnits = NSCalendarUnitHour;
            NSInteger minute = [components minute];
            
            if (minute>1) {
                 intervalTime=[NSString stringWithFormat:@"%@ %ld minutes",[formatter stringFromDateComponents:components] ,[components minute]];
            }else{
              intervalTime=[NSString stringWithFormat:@"%@ %ld minute",[formatter stringFromDateComponents:components] ,[components minute]];
            }
           
            
        } else if (components.minute > 0) {
            formatter.allowedUnits = NSCalendarUnitMinute;
             intervalTime=[formatter stringFromDateComponents:components];
        } else {
            formatter.allowedUnits = NSCalendarUnitSecond;
             intervalTime=[formatter stringFromDateComponents:components];
            // return @"0 minute";
        }
        
        NSString *formatString = NSLocalizedString(@"%@", @"Used to say how much time has passed. e.g. '2 hr ago'");
        NSLog(@"%@",[NSString stringWithFormat:formatString, [formatter stringFromDateComponents:components]]);
      //  NSLog(@"start date-- %@ %@",[NSString stringWithFormat:formatString, [formatter stringFromDateComponents:components] ,[components month]]);
        
        
       // return [NSString stringWithFormat:formatString, [formatter stringFromDateComponents:components]];
        
        return [NSString stringWithFormat:@"Starts in %@!",intervalTime];
    }
}

-(NSString*)calculateStartTime:(NSString*)time{
    if ([time isEqualToString:@"0000-00-00 00:00:00"]) {
        return @"";
    }
    
    NSArray *myArray = [time componentsSeparatedByString:@"/"];
    NSArray *Array = [[myArray objectAtIndex:2] componentsSeparatedByString:@" "];
    time=[NSString stringWithFormat:@"%@-%@-%@ %@ %@",[Array objectAtIndex:0],[myArray objectAtIndex:0],[myArray objectAtIndex:1],[Array objectAtIndex:1],[Array objectAtIndex:2]];
    NSString *gmtDateString =[NSString stringWithFormat:@"%@",time]; //@"29/10/2015 00:01";
   // time=@"2017-04-11 12:05 PM";
    NSDateFormatter *df = [NSDateFormatter new];
    //[df setDateFormat:@"dd/MM/yyyy HH:mm"];
    [df setDateFormat:@"yyyy-MM-dd hh:mm a"];
    //[df setDateFormat:@"MM-dd-yyyy HH:mm:ss"];
    //Create the date assuming the given string is in GMT
    df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDate *date = [df dateFromString:gmtDateString];
    
    if (!date) {
        return @"";
    }
    
    //Create a date string in the local timezone
    df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:[NSTimeZone localTimeZone].secondsFromGMT];
    NSString *localDateString = [df stringFromDate:date];
    
    df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDate *date1 = [df dateFromString:localDateString];
    
    NSDateComponentsFormatter *formatter = [[NSDateComponentsFormatter alloc] init];
    formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleFull;
    
    //NSDate *now = [NSDate date];
    
    NSDate* sourceDate = [NSDate date];
    
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    NSDate* now = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate] ;
    
    //NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitWeekOfMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond)
                                               fromDate:now
                                                 toDate:date1
                                                options:0];
    
    if (components.year > 0) {
        formatter.allowedUnits = NSCalendarUnitYear;
    } else if (components.month > 0) {
        formatter.allowedUnits = NSCalendarUnitMonth;
    } else if (components.weekOfMonth > 0) {
        formatter.allowedUnits = NSCalendarUnitWeekOfMonth;
    } else if (components.day > 0) {
        formatter.allowedUnits = NSCalendarUnitDay;
    } else if (components.hour > 0) {
        formatter.allowedUnits = NSCalendarUnitHour;
    } else if (components.minute > 0) {
        formatter.allowedUnits = NSCalendarUnitMinute;
    } else {
        formatter.allowedUnits = NSCalendarUnitSecond;
        // return @"0 minute";
    }
    
    NSString *formatString = NSLocalizedString(@"%@", @"Used to say how much time has passed. e.g. '2 hr ago'");
    NSLog(@"%@",[NSString stringWithFormat:formatString, [formatter stringFromDateComponents:components]]);
    NSLog(@"start date-- %@",[NSString stringWithFormat:formatString, [formatter stringFromDateComponents:components]]);
    return [NSString stringWithFormat:formatString, [formatter stringFromDateComponents:components]];
    
}
-(NSString *)getCurrentDate{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:gmt];
    NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
    return timeStamp;
}


-(void)serviceCall:(NSString *)dataString servicename:(NSString *)serviceName serviceType:(NSString*)serviceType
{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        [SVProgressHUD dismiss];
        [Global showNetworkError];
        return;
    }
    if ([serviceName isEqualToString:@"flok/getChatMsg"] ||[serviceName isEqualToString:@"flok/sendChat"]) {
        
        
    }else{
        //  [SVProgressHUD showWithStatus:@"Please wait.."];
    }
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setAllowsCellularAccess:YES];
    [sessionConfiguration setHTTPAdditionalHeaders:@{ @"Accept" : @"application/json" }];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    NSURL *url;
    if ([serviceType isEqualToString:@"POST"])
    {
        url=[NSURL URLWithString:[NSString stringWithFormat:@"http://api.unifonic.com/rest/Messages/Send"]];
        
    }
    NSLog(@"complete url: >>> %@",url);
    NSLog(@"datastring: >>> %@",dataString);
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:1200000000000000];
    if ([serviceType isEqualToString:@"POST"])
    {
        request.HTTPBody = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    }
    request.HTTPMethod = serviceType;
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                          {
                                              if(error)
                                              {
                                                  NSLog(@"%@",[NSString stringWithFormat:@"Connection failed.: %@.", [error description]]);
                                                  
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      
                                                      [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
                                                      [SVProgressHUD dismiss];
                                                      
                                                  });
                                                  return;
                                              }
                                              NSArray * cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:request.URL];
                                              for (NSHTTPCookie * cookie in cookies)
                                              {
                                                  NSLog(@"%@=%@", cookie.name, cookie.value);
                                              }
                                              
                                              // Update the View
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
                                                  [SVProgressHUD dismiss];
                                                  
                                                  /* NSString *strReturn=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];*/
                                                  NSDictionary *tdict=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                                                  NSDictionary *dict=[Global cleanJsonToObject:tdict];
                                                  
                                                  if (dict.count>0) {
                                                      
                                                      
                                                  }else{
                                                      
                                                      
                                                      
                                                  }
                                                  
                                                  
                                                  
                                              });
                                          }];
    
    // Initiate the Request
    [postDataTask resume];
    
}


-(void) addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage
{
    UITabBar *tabBar = self.tabBarController.tabBar;
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    button.frame = CGRectMake(0.0, 0.0, 60, 60);
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    
    CGFloat heightDifference = 60 - tabBar.frame.size.height;
    if (heightDifference < 0)
        button.center =tabBar.center;
    else
    {
        CGPoint center =tabBar.center;
        center.y = center.y - heightDifference/2.0;
        button.center = center;
    }
    
    [self.view addSubview:button];
}
-(void)setValueToCell:(UITableViewCell*)tcell value:(NSDictionary*)dict{
    
    NSString *strImg=[dict valueForKey:@"floksImage"];
    BOOL isJoinByme=[[dict valueForKey:@"is_joined_by_me"] intValue];
    BOOL alreadyJoin=[[dict valueForKey:@"already_joined_count"] intValue];
    BOOL isAccess=[[dict valueForKey:@"is_access"] intValue];
    NSString *Access_string=[dict valueForKey:@"access"];
    
    if ([strImg length]==0) {
        
        TreeCell *cell=(TreeCell*)tcell;
        if (isJoinByme==YES) {
            if (isAccess==YES) {
                [cell.btnJoin setTitle:@"Leave Flok" forState:UIControlStateNormal];
                [cell.btnJoin setTag:5];
                
                NSString *tempAddress=[dict valueForKey:@"address"];
                NSArray *myArray = [tempAddress componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
                if (myArray.count>0) {
                    cell.lblAddress.text=[myArray objectAtIndex:0];
                }
                cell.btnShowMap.hidden=NO;
                
                if([Access_string isEqualToString:@"1"]||[Access_string isEqualToString:@"request based"]){
                    //lblRequest.hidden=NO;
                }else{
                    //lblRequest.hidden=YES;
                }
                
            }
        }else{
            if([Access_string isEqualToString:@"1"]||[Access_string isEqualToString:@"request based"]){
                
                if (isAccess==YES) {
                    [cell.btnJoin setTitle:@"Join" forState:UIControlStateNormal];
                    [cell.btnJoin setFrame:CGRectMake(self.view.frame.size.width-100, cell.btnJoin.frame.origin.y,90,cell.btnJoin.frame.size.height)];
                    cell.btnJoin.titleLabel.font = [UIFont systemFontOfSize:15.0];
                }else{
                    [cell.btnJoin setTitle:@"Request to Join" forState:UIControlStateNormal];
                    [cell.btnJoin setFrame:CGRectMake(self.view.frame.size.width-120, cell.btnJoin.frame.origin.y,110,cell.btnJoin.frame.size.height)];
                    cell.btnJoin.titleLabel.font = [UIFont systemFontOfSize:13.0];
                }
            }
        }
        
        int maxLimit=[[dict valueForKey:@"max_people"] intValue];
        int joined=[[dict valueForKey:@"already_joined_count"] intValue];
        BOOL isFlokLimited;
        if (maxLimit>4) {
            int min=maxLimit/5;
            int middle=min*2;
            int half=min*3;
            int max=min*4;
            if (maxLimit==joined) {
                isFlokLimited=YES;
            }else{
                isFlokLimited=NO;
            }
            if (joined==0){
                [cell.imgTree setImage:[UIImage imageNamed:@"tree-1"]];
            }else if (joined>0 && joined<min) {
                [cell.imgTree setImage:[UIImage imageNamed:@"lowLimit"]];
                
            }else if (joined>=min && joined<middle) {
                [cell.imgTree setImage:[UIImage imageNamed:@"middle"] ];
            }
            else if (joined>=middle && joined<half){
                //imgLimit.image=[UIImage imageNamed:@"halfLimit"];
                [cell.imgTree setImage:[UIImage imageNamed:@"halfLimit-1"]];
            }else if (joined>=half && joined<max){
               
                [cell.imgTree setImage:[UIImage imageNamed:@"maxLimit"]];
            }else if (joined>=max && joined<maxLimit){
                //imgLimit.image=[UIImage imageNamed:@"maxLimit"];
                [cell.imgTree setImage:[UIImage imageNamed:@"maxFull"] ];
            }
            else if(joined==maxLimit){
                // imgLimit.image=[UIImage imageNamed:@"fulLimit"];
                [cell.imgTree setImage:[UIImage imageNamed:@"fullLimit-1"]];
            }
        }
        
    }else{
        NewTreeCellTableViewCell *cell=(NewTreeCellTableViewCell*)tcell;
        
        if (isJoinByme==YES) {
            if (isAccess==YES) {
                [cell.btnJoin setTitle:@"Leave Flok" forState:UIControlStateNormal];
                [cell.btnJoin setTag:5];
                
                NSString *tempAddress=[dict valueForKey:@"address"];
                NSArray *myArray = [tempAddress componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
                if (myArray.count>0) {
                    cell.lblAddress.text=[myArray objectAtIndex:0];
                }
                cell.btnShowMap.hidden=NO;
                
                if([Access_string isEqualToString:@"1"]||[Access_string isEqualToString:@"request based"]){
                    //lblRequest.hidden=NO;
                }else{
                    //lblRequest.hidden=YES;
                }
                
            }
        }else{
            if([Access_string isEqualToString:@"1"]||[Access_string isEqualToString:@"request based"]){
                
                if (isAccess==YES) {
                    [cell.btnJoin setTitle:@"Join" forState:UIControlStateNormal];
                    [cell.btnJoin setFrame:CGRectMake(self.view.frame.size.width-100, cell.btnJoin.frame.origin.y,90,cell.btnJoin.frame.size.height)];
                    cell.btnJoin.titleLabel.font = [UIFont systemFontOfSize:15.0];
                }else{
                    [cell.btnJoin setTitle:@"Request to Join" forState:UIControlStateNormal];
                    [cell.btnJoin setFrame:CGRectMake(self.view.frame.size.width-120, cell.btnJoin.frame.origin.y,110,cell.btnJoin.frame.size.height)];
                    cell.btnJoin.titleLabel.font = [UIFont systemFontOfSize:13.0];
                }
            }
        }
        
        int maxLimit=[[dict valueForKey:@"max_people"] intValue];
        int joined=[[dict valueForKey:@"already_joined_count"] intValue];
        BOOL isFlokLimited;
        if (maxLimit>4) {
            int min=maxLimit/5;
            int middle=min*2;
            int half=min*3;
            int max=min*4;
            if (maxLimit==joined) {
                isFlokLimited=YES;
            }else{
                isFlokLimited=NO;
            }
            if (joined==0){
                [cell.imgTree setImage:[UIImage imageNamed:@"tree-1"]];
            }else if (joined>0 && joined<min) {
                [cell.imgTree setImage:[UIImage imageNamed:@"lowLimit"]];
                
            }else if (joined>=min && joined<middle) {
                [cell.imgTree setImage:[UIImage imageNamed:@"middle"] ];
            }
            else if (joined>=middle && joined<half){
                //imgLimit.image=[UIImage imageNamed:@"halfLimit"];
                [cell.imgTree setImage:[UIImage imageNamed:@"halfLimit-1"]];
            }else if (joined>=half && joined<max){
                
                [cell.imgTree setImage:[UIImage imageNamed:@"maxLimit"]];
            }else if (joined>=max && joined<maxLimit){
                //imgLimit.image=[UIImage imageNamed:@"maxLimit"];
                [cell.imgTree setImage:[UIImage imageNamed:@"maxFull"] ];
            }
            else if(joined==maxLimit){
                // imgLimit.image=[UIImage imageNamed:@"fulLimit"];
                [cell.imgTree setImage:[UIImage imageNamed:@"fullLimit-1"]];
            }
        }
    }
        
    
        
    
    
    
}
-(NSString*)changeDateFormat:(NSString*)dateString fullDate:(BOOL)isFull{
    
    // NSString *dateString = @"11-13-2013";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSDate *date = [dateFormatter dateFromString:dateString];
    NSString *newDateString;
    if (isFull==YES) {
        [dateFormatter setDateFormat:@"EEEE ,MMMM dd,"];
        newDateString= [dateFormatter stringFromDate:date];
    }else{
        [dateFormatter setDateFormat:@"EEEE ,MMM dd,"];
        newDateString= [dateFormatter stringFromDate:date];
    }
    
    return newDateString;
}

-(NSMutableArray*)checkIsLikeByme:(NSArray*)arr{
    
    NSInteger max;
    if (arr.count>3) {
        max=3;
    }else{
        max=arr.count;
    }
    NSMutableArray *arrReturn=[[NSMutableArray alloc] init];
    for (int i=0; i<max; i++) {
        NSDictionary *dict=[arr objectAtIndex:i];
        NSString *uid=[dict valueForKey:@"user_id"];
        if ([uid isEqualToString:userId]) {
            [arrReturn addObject:@"You"];
        }else{
            [arrReturn addObject:[dict valueForKey:@"user_name"]];
        }
    }
    return arrReturn;
}
@end
