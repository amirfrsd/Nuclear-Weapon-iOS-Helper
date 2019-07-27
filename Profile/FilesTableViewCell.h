//
//  FilesTableViewCell.h
//  Profile
//
//  Created by Apple on 7/21/19.
//  Copyright © 2019 Amir Farsad. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FilesTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *fileIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *certNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *expireDateLabel;
@property (weak, nonatomic) IBOutlet UIButton *installBtnOutlet;

@end

NS_ASSUME_NONNULL_END
