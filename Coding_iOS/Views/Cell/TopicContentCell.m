//
//  TopicContentCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-27.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kTopicContentCell_FontTitle [UIFont boldSystemFontOfSize:18]
#define kTopicContentCell_FontContent [UIFont systemFontOfSize:15]

#import "TopicContentCell.h"
#import "WebContentManager.h"

#import "Coding_NetAPIManager.h"


@interface TopicContentCell () <UIWebViewDelegate>

@property (strong, nonatomic) UIImageView *userIconView;
@property (strong, nonatomic) UILabel *titleLabel, *timeLabel, *commentCountLabel;
@property (strong, nonatomic) UIButton *commentBtn, *deleteBtn;
@property (strong, nonatomic) UIWebView *webContentView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

//@property (strong, nonatomic) ProjectTagsView *tagsView;
//@property (strong, nonatomic) UIView *lineView;

@end

@implementation TopicContentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        if (!_userIconView) {
            _userIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, 20, 20)];
            [_userIconView doCircleFrame];
            [self.contentView addSubview:_userIconView];
        }
        CGFloat curWidth = kScreen_Width - 2 * kPaddingLeftWidth;
        if (!_titleLabel) {
            _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 15,  curWidth, 30)];
            _titleLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
            _titleLabel.font = kTopicContentCell_FontTitle;
            [self.contentView addSubview:_titleLabel];
        }
        if (!_timeLabel) {
            _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth +25, 0, curWidth, 20)];
            _timeLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            _timeLabel.font = [UIFont systemFontOfSize:12];
            [self.contentView addSubview:_timeLabel];
        }
//        if (!_tagsView) {
//            _tagsView = [ProjectTagsView viewWithTags:nil];
//            @weakify(self);
//            _tagsView.addTagBlock = ^(){
//                @strongify(self);
//                [self addtitleBtnClick];
//            };
//            _tagsView.deleteTagBlock = ^(ProjectTag *curTag){
//                @strongify(self);
//                [self deleteTag:curTag];
//            };
//            [self.contentView addSubview:_tagsView];
//        }
//        if (!_lineView) {
//            _lineView = [[UIView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, curWidth, 1)];
//            _lineView.backgroundColor = kColorTableSectionBg;
//            [self.contentView addSubview:_lineView];
//        }
        if (!self.webContentView) {
            self.webContentView = [[UIWebView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, curWidth, 1)];
            self.webContentView.delegate = self;
            self.webContentView.scrollView.scrollEnabled = NO;
            self.webContentView.scrollView.scrollsToTop = NO;
            self.webContentView.scrollView.bounces = NO;
            self.webContentView.backgroundColor = [UIColor clearColor];
            self.webContentView.opaque = NO;
            [self.contentView addSubview:self.webContentView];
        }
        if (!_activityIndicator) {
            _activityIndicator = [[UIActivityIndicatorView alloc]
                                  initWithActivityIndicatorStyle:
                                  UIActivityIndicatorViewStyleGray];
            _activityIndicator.hidesWhenStopped = YES;
            [self.contentView addSubview:_activityIndicator];
            [_activityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self.contentView);
            }];
        }
        
        if (!_commentCountLabel) {
            _commentCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, 120, 20)];
            _commentCountLabel.textColor = [UIColor colorWithHexString:@"0x99999999"];
            _commentCountLabel.font = [UIFont systemFontOfSize:12];
            [self.contentView addSubview:_commentCountLabel];
        }
        if (!_commentBtn) {
            _commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            _commentBtn.frame = CGRectMake(kScreen_Width - kPaddingLeftWidth - 50, 0, 50, 25);
            [_commentBtn setImage:[UIImage imageNamed:@"tweet_comment_btn"] forState:UIControlStateNormal];
            [self.commentBtn addTarget:self action:@selector(commentBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_commentBtn];
        }
        
        if (!self.deleteBtn) {
            self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.deleteBtn.frame = CGRectMake(kScreen_Width - kPaddingLeftWidth - 50 - 50, 0, 50, 25);
            [self.deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
            [self.deleteBtn setTitleColor:[UIColor colorWithHexString:@"0x3bbd79"] forState:UIControlStateNormal];
            [self.deleteBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
            self.deleteBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
            [self.deleteBtn addTarget:self action:@selector(deleteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:self.deleteBtn];
        }
        
    }
    return self;
}







- (NSMutableAttributedString *)getAttributedTimeText{
//    NSString *nameStr = [NSString stringWithFormat:@"%@", _curTopic.owner.name];
//    NSString *timeStr = [NSString stringWithFormat:@" 发布于 %@  ", [_curTopic.created_at stringDisplay_HHmm]];
//    NSString *numStr = [NSString stringWithFormat:@"#%@", _curTopic.number.stringValue];
//    NSString *displayStr = [NSString stringWithFormat:@"%@%@%@", nameStr, timeStr, numStr];
//    
//    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:displayStr];
//    [attrString addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12],
//                                NSForegroundColorAttributeName : [UIColor colorWithHexString:@"0x222222"]}
//                        range:[displayStr rangeOfString:nameStr]];
//    [attrString addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12],
//                                NSForegroundColorAttributeName : [UIColor colorWithHexString:@"0x222222"]}
//                        range:[displayStr rangeOfString:numStr]];
//    
//    [attrString addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12],
//                                NSForegroundColorAttributeName : [UIColor colorWithHexString:@"0x999999"]}
//                        range:[displayStr rangeOfString:timeStr]];
//    return  attrString;
    return nil;
}

+ (CGFloat)cellHeightWithObj:(id)obj
{
    CGFloat cellHeight = 0;
//    if ([obj isKindOfClass:[ProjectTopic class]]) {
//        ProjectTopic *topic = (ProjectTopic *)obj;
//        CGFloat curWidth = kScreen_Width -2*kPaddingLeftWidth;
//        cellHeight += 8 + [topic.title getHeightWithFont:kTopicContentCell_FontTitle constrainedToSize:CGSizeMake(curWidth, CGFLOAT_MAX)] + 16 + 20;
//        
//        //cellHeight += [ProjectTagsView getHeightForTags:topic.labels];
//        cellHeight += topic.contentHeight;
//        cellHeight += 25 + 25 + 5;
//    }
    return cellHeight;
}

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *strLink = request.URL.absoluteString;
    DebugLog(@"strLink=[%@]", strLink);
    if ([strLink rangeOfString:@"about:blank"].location != NSNotFound) {
        return YES;
    } else {
        if (_loadRequestBlock) {
            _loadRequestBlock(request);
        }
        return NO;
    }
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [_activityIndicator startAnimating];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self refreshwebContentView];
    [_activityIndicator stopAnimating];
    CGFloat scrollHeight = MIN(webView.scrollView.contentSize.height, 10*kScreen_Height);
//    if (ABS(scrollHeight - _curTopic.contentHeight) > 5) {
//        NSLog(@"scrollHeight: %.2f, contentHeight: %.2f, (scrollHeight - contentHeight): %.2f", scrollHeight, _curTopic.contentHeight, (scrollHeight - _curTopic.contentHeight));
//        webView.scalesPageToFit = YES;
//        _curTopic.contentHeight = scrollHeight;
//        if (_cellHeightChangedBlock) {
//            _cellHeightChangedBlock();
//        }
//    }
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [_activityIndicator stopAnimating];
    if([error code] == NSURLErrorCancelled)
        return;
    else
        DebugLog(@"%@", error.description);
}

- (void)refreshwebContentView
{
    if (_webContentView) {
        //        NSString *js = @"window.onload = function(){ document.body.style.backgroundColor = '#333333';}";
        //        [_webContentView stringByEvaluatingJavaScriptFromString:js];
        //修改服务器页面的meta的值
        NSString *meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no\"", CGRectGetWidth(_webContentView.frame)];
        [_webContentView stringByEvaluatingJavaScriptFromString:meta];
    }
}

#pragma mark - click
- (void)addtitleBtnClick
{
    if (_addLabelBlock) {
        _addLabelBlock();
    }
}

#pragma mark Btn M
- (void)commentBtnClicked:(id)sender{
    __weak typeof(self) weakSelf = self;
//    if (_commentTopicBlock) {
//        _commentTopicBlock(_curTopic, weakSelf);
//    }
}

- (void)deleteBtnClicked:(id)sender{
    __weak typeof(self) weakSelf = self;
//    if (_deleteTopicBlock) {
//        _deleteTopicBlock(weakSelf.curTopic);
//    }
}

@end
