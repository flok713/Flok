//
//  NewTreeCellTableViewCell.h
//  Flok
//
//  Created by Ritwik Ghosh on 10/07/2017.
//  Copyright © 2017 Ajeet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewTreeCellTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property(nonatomic,strong) IBOutlet UIImageView *imgTree;
@property (weak, nonatomic) IBOutlet UIImageView *imgProfile;
@property (weak, nonatomic) IBOutlet UIImageView *imgPost;
@property (weak, nonatomic) IBOutlet UIImageView *imgFire;
@property (weak, nonatomic) IBOutlet UIButton *btnJoin;
@property (weak, nonatomic) IBOutlet UIButton *btnProfile;
@property(nonatomic,strong) IBOutlet UIButton *btnLike;
@property(nonatomic,strong) IBOutlet UIButton *btnMsg;
@property(nonatomic,strong) IBOutlet UIButton *btnMore;
@property (weak, nonatomic) IBOutlet UIButton *btnShowLiked;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property(nonatomic,strong) IBOutlet UILabel *lblStartTime;
@property (weak, nonatomic) IBOutlet UILabel *lblAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UILabel *lblCommentCount;
@property (weak, nonatomic) IBOutlet UITextView *tvComment;
@property (weak, nonatomic) IBOutlet UITextView *lblFlokName;
@property (weak, nonatomic) IBOutlet UILabel *lblLikeCount;
@property (weak, nonatomic) IBOutlet UILabel *lblLike;
@property(nonatomic,strong) IBOutlet UILabel *lblLikeBy;
@property (weak, nonatomic) IBOutlet UIButton *btnSetReminder;
@property (weak, nonatomic) IBOutlet UIButton *btnShowMap;
@property(nonatomic,strong) IBOutlet UIView *vwExpired;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@end
