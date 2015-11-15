//
//  Coding_NetAPIManager.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-7-30.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "Coding_NetAPIManager.h"
#import "JDStatusBarNotification.h"
#import "UnReadManager.h"
#import <NYXImagesKit/NYXImagesKit.h>
#import <MMMarkdown/MMMarkdown.h>
#import "MBProgressHUD+Add.h"

@implementation Coding_NetAPIManager
+ (instancetype)sharedManager {
    static Coding_NetAPIManager *shared_manager = nil;
    static dispatch_once_t pred;
	dispatch_once(&pred, ^{
        shared_manager = [[self alloc] init];
    });
	return shared_manager;
}
#pragma mark UnRead
- (void)request_UnReadCountWithBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/user/unread-count" withParams:nil withMethodType:Get autoShowError:NO andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Notification label:@"Tab首页的红点通知"];
            
            id resultData = [data valueForKeyPath:@"data"];
            block(resultData, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_UnReadNotificationsWithBlock:(void (^)(id data, NSError *error))block{
    NSMutableDictionary *notificationDict = [[NSMutableDictionary alloc] init];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/notification/unread-count" withParams:@{@"type" : [NSNumber numberWithInteger:0]} withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
//            @我的
            [notificationDict setObject:[data valueForKeyPath:@"data"] forKey:kUnReadKey_notification_AT];
            [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/notification/unread-count" withParams:@{@"type" : [NSArray arrayWithObjects:[NSNumber numberWithInteger:1], [NSNumber numberWithInteger:2], nil]} withMethodType:Get andBlock:^(id dataComment, NSError *errorComment) {
                if (dataComment) {
//                    评论
                    [notificationDict setObject:[dataComment valueForKeyPath:@"data"] forKey:kUnReadKey_notification_Comment];
                    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/notification/unread-count" withParams:@{@"type" : [NSNumber numberWithInteger:4]} withMethodType:Get andBlock:^(id dataSystem, NSError *errorSystem) {
                        if (dataSystem) {
//                            系统
                            [MobClick event:kUmeng_Event_Request_Notification label:@"消息页面的红点通知"];

                            [notificationDict setObject:[dataSystem valueForKeyPath:@"data"] forKey:kUnReadKey_notification_System];
                            block(notificationDict, nil);
                        }else{
                            block(nil, errorSystem);
                        }
                    }];
                }else{
                    block(nil, errorComment);
                }
            }];
        }else{
            block(nil, error);
        }
    }];
}
#pragma mark Login
- (void)request_Login_With2FA:(NSString *)otpCode andBlock:(void (^)(id data, NSError *error))block{
    if (otpCode.length <= 0) {
        return;
    }
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/check_two_factor_auth_code" withParams:@{@"code" : otpCode} withMethodType:Post andBlock:^(id data, NSError *error) {
        id resultData = [data valueForKeyPath:@"data"];
        if (resultData) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"登录_2FA码"];

            User *curLoginUser = [NSObject objectOfClass:@"User" fromJSON:resultData];
            if (curLoginUser) {
                [Login doLogin:resultData];
            }
            block(curLoginUser, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_Login_WithParams:(id)params andBlock:(void (^)(id data, NSError *error))block{
    NSString *path = @"api/login";
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Post autoShowError:NO andBlock:^(id data, NSError *error) {
        id resultData = [data valueForKeyPath:@"data"];
        if (resultData) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"登录_密码"];

            User *curLoginUser = [NSObject objectOfClass:@"User" fromJSON:resultData];
            if (curLoginUser) {
                [Login doLogin:resultData];
            }
            block(curLoginUser, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_Register_WithParams:(id)params andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/register" withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        id resultData = [data valueForKeyPath:@"data"];
        if (resultData) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"注册"];

            User *curLoginUser = [NSObject objectOfClass:@"User" fromJSON:resultData];
            if (curLoginUser) {
                [Login doLogin:resultData];
            }
            block(curLoginUser, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_CaptchaNeededWithPath:(NSString *)path andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path  withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"是否需要验证码"];

            id resultData = [data valueForKeyPath:@"data"];
            block(resultData, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_SendMailToPath:(NSString *)path email:(NSString *)email j_captcha:(NSString *)j_captcha andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:@{@"email": email, @"j_captcha": j_captcha} withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"发激活or重置密码邮件"];

            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_SetPasswordToPath:(NSString *)path params:(NSDictionary *)params andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"激活or重置密码"];

            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}


- (void)request_PostCommentWithPath:(NSString *)path params:(NSDictionary *)params andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"LineNote_评论_添加"];

            NSString *noteable_type = [params objectForKey:@"noteable_type"];
            if ([noteable_type isEqualToString:@"MergeRequestBean"] ||
                [noteable_type isEqualToString:@"PullRequestBean"] ||
                [noteable_type isEqualToString:@"Commit"]) {
//                id resultData = [data valueForKeyPath:@"data"];
//                ProjectLineNote *note = [NSObject objectOfClass:@"ProjectLineNote" fromJSON:resultData];
//                block(note, nil);
            }else{
                block(data, nil);
            }
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_DeleteLineNote:(NSNumber *)lineNoteId inProject:(NSString *)projectName ofUser:(NSString *)userGK andBlock:(void (^)(id data, NSError *error))block{
    NSString *path = [NSString stringWithFormat:@"api/user/%@/project/%@/git/line_notes/%@", userGK, projectName, lineNoteId.stringValue];
    [self request_DeleteLineNoteWithPath:path andBlock:block];
}

- (void)request_DeleteLineNoteWithPath:(NSString *)path andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Delete andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"LineNote_评论_删除"];
            
            block(data, nil);
            
        }else{
            block(nil, error);
        }
    }];
}



#pragma mark Tweet
- (void)request_Tweets_WithObj:(Tweets *)tweets andBlock:(void (^)(id data, NSError *error))block{
    tweets.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[tweets toPath] withParams:[tweets toParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        tweets.isLoading = NO;
        
        if (data) {
            [MobClick event:kUmeng_Event_Request_RootList label:@"冒泡_列表"];

            [NSObject saveResponseData:data toPath:[tweets localResponsePath]];
            id resultData = [data valueForKeyPath:@"data"];
            NSArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"Tweet"];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_Tweet_DoLike_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[tweet toDoLikePath] withParams:nil withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"冒泡_点赞"];

            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_Tweet_DoComment_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[tweet toDoCommentPath] withParams:[tweet toDoCommentParams] withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"冒泡_评论_添加"];

            id resultData = [data valueForKeyPath:@"data"];
            Comment *comment = [NSObject objectOfClass:@"Comment" fromJSON:resultData];
            block(comment, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_Tweet_DoTweet_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block{
    if (tweet.tweetImages && tweet.tweetImages.count > 0) {
        /**
         *  冒泡多张一起发送，不显示进度条
         */
        [NSObject showStatusBarQueryStr:@"正在发送冒泡"];
        for (int i=0; i < tweet.tweetImages.count; i++) {
            TweetImage *imageItem = [tweet.tweetImages objectAtIndex:i];
            if (imageItem.uploadState == TweetImageUploadStateInit) {
                imageItem.uploadState = TweetImageUploadStateIng;
                [self uploadTweetImage:imageItem.image doneBlock:^(NSString *imagePath, NSError *error) {
                    if (imagePath) {
                        imageItem.uploadState = TweetImageUploadStateSuccess;
                        imageItem.imageStr = [NSString stringWithFormat:@" ![图片](%@) ", imagePath];
                    }else{
                        [NSObject showStatusBarError:error];
                        imageItem.uploadState = TweetImageUploadStateFail;
                        imageItem.imageStr = [NSString stringWithFormat:@" ![图片]() "];
                        block(nil, error);
                        return ;
                    }
                    if ([tweet isAllImagesHaveDone]) {
                        [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/tweet" withParams:[tweet toDoTweetParams] withMethodType:Post andBlock:^(id data, NSError *error) {
                            if (data) {
                                [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"冒泡_添加_有图"];

                                id resultData = [data valueForKeyPath:@"data"];
                                Tweet *tweet = [NSObject objectOfClass:@"Tweet" fromJSON:resultData];
                                [NSObject showStatusBarSuccessStr:@"冒泡发送成功"];
                                block(tweet, nil);
                            }else{
                                [NSObject showStatusBarError:error];
                                block(nil, error);
                            }
                        }];
                    }
                } progerssBlock:^(CGFloat progressValue) {
                    DebugLog(@"progressValue %d : %.2f", i, progressValue);
                }];
            }
        }
//        -----------------

    }else{
        [NSObject showStatusBarQueryStr:@"正在发送冒泡"];
        [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/tweet" withParams:[tweet toDoTweetParams] withMethodType:Post andBlock:^(id data, NSError *error) {
            if (data) {
                [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"冒泡_添加_无图"];

                id resultData = [data valueForKeyPath:@"data"];
                Tweet *tweet = [NSObject objectOfClass:@"Tweet" fromJSON:resultData];
                [NSObject showStatusBarSuccessStr:@"冒泡发送成功"];
                block(tweet, nil);
            }else{
                [NSObject showStatusBarError:error];
                block(nil, error);
            }
        }];
    }
}

- (void)request_Tweet_Likers_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block{
    tweet.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[tweet toLikersPath] withParams:[tweet toLikersParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        tweet.isLoading = NO;
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"冒泡_点赞的人_列表"];

            id resultData = [data valueForKeyPath:@"data"];
            resultData = [resultData valueForKeyPath:@"list"];
            NSArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"User"];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_Tweet_Comments_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block{
    tweet.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[tweet toCommentsPath] withParams:[tweet toCommentsParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        tweet.isLoading = NO;
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"冒泡_评论_列表"];

            id resultData = [data valueForKeyPath:@"data"];
            if ([resultData isKindOfClass:[NSDictionary class]]) {
                resultData = [resultData valueForKeyPath:@"list"];
            }
            NSArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"Comment"];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_Tweet_Delete_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[tweet toDeletePath] withParams:nil withMethodType:Delete andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"冒泡_删除"];

            [NSObject showHudTipStr:@"删除成功"];
            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_TweetComment_Delete_WithTweet:(Tweet *)tweet andComment:(Comment *)comment andBlock:(void (^)(id data, NSError *error))block{
    NSString *path = [NSString stringWithFormat:@"api/tweet/%d/comment/%d", tweet.id.intValue, comment.id.intValue];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Delete andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"冒泡_评论_删除"];

            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_Tweet_Detail_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[tweet toDetailPath] withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"冒泡_详情"];

            id resultData = [data valueForKeyPath:@"data"];
            Tweet *resultA = [NSObject objectOfClass:@"Tweet" fromJSON:resultData];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_PublicTweetsWithTopic:(NSInteger)topicID andBlock:(void (^)(id data, NSError *error))block {
    //TODO psy lastid，是否要做分页
    NSString *path = [NSString stringWithFormat:@"api/public_tweets/topic/%ld",(long)topicID];
    NSDictionary *params = @{
                             @"type" : @"topic",
                             @"sort" : @"new"
                             };
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"话题_冒泡列表"];
            
            id resultData = [data valueForKeyPath:@"data"];
            NSArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"Tweet"];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}

#pragma mark User
- (void)request_UserInfo_WithObj:(User *)curUser andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curUser toUserInfoPath] withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_RootList label:@"用户信息"];

            id resultData = [data valueForKeyPath:@"data"];
            User *user = [NSObject objectOfClass:@"User" fromJSON:resultData];
            if (user.id.intValue == [Login curLoginUser].id.intValue) {
                [Login doLogin:resultData];
            }
            block(user, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_ResetPassword_WithObj:(User *)curUser andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curUser toResetPasswordPath] withParams:[curUser toResetPasswordParams] withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"重置密码"];

            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_FollowersOrFriends_WithObj:(Users *)curUsers andBlock:(void (^)(id data, NSError *error))block{
    curUsers.isLoading = YES;
    NSString *path = [curUsers toPath];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:[curUsers toParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        curUsers.isLoading = NO;
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"关注or粉丝列表"];

            id resultData = [data valueForKeyPath:@"data"];
            
            if ([path hasSuffix:@"friends"] && resultData) {//AT某人时的列表数据，要保存在本地
                User *loginUser = [Login curLoginUser];
                if (loginUser) {
                    [NSObject saveResponseData:resultData toPath:[loginUser localFriendsPath]];
                }
            }
            
            //处理数据
            NSObject *resultA = nil;
            if ([path hasSuffix:@"stargazers"] || [path hasSuffix:@"watchers"]) {
                resultA = [NSArray arrayFromJSON:resultData ofObjects:@"User"];
            }else{
                resultA = [NSObject objectOfClass:@"Users" fromJSON:resultData];
            }
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_FollowedOrNot_WithObj:(User *)curUser andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curUser toFllowedOrNotPath] withParams:[curUser toFllowedOrNotParams] withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"关注某人"];

            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_UserJobArrayWithBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/options/jobs" withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"个人信息_职位列表"];

            id resultData = [data valueForKeyPath:@"data"];
            block(resultData, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_UserTagArrayWithBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/tagging/user_tag_list" withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"个人信息_个性标签列表"];

            id resultData = [data valueForKeyPath:@"data"];
            NSArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"Tag"];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_UpdateUserInfo_WithObj:(User *)curUser andBlock:(void (^)(id data, NSError *error))block{
    [NSObject showStatusBarQueryStr:@"正在修改个人信息"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curUser toUpdateInfoPath] withParams:[curUser toUpdateInfoParams] withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"个人信息_修改"];

            [NSObject showStatusBarSuccessStr:@"个人信息修改成功"];
            id resultData = [data valueForKeyPath:@"data"];
            User *user = [NSObject objectOfClass:@"User" fromJSON:resultData];
            if (user) {
                [Login doLogin:resultData];
            }
            block(user, nil);
        }else{
            [NSObject showStatusBarError:error];
            block(nil, error);
        }
    }];
}



#pragma mark Message
- (void)request_PrivateMessages:(PrivateMessages *)priMsgs andBlock:(void (^)(id data, NSError *error))block{
    priMsgs.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[priMsgs toPath] withParams:[priMsgs toParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        priMsgs.isLoading = NO;
        if (data) {
            if (priMsgs.curFriend) {
                [MobClick event:kUmeng_Event_Request_Get label:@"私信_列表"];
            }else{
                [MobClick event:kUmeng_Event_Request_RootList label:@"会话列表"];
            }

            id resultA = [PrivateMessages analyzeResponseData:data];
            block(resultA, nil);
            
            if (priMsgs.curFriend && priMsgs.curFriend.global_key) {//标记为已读
                [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"api/message/conversations/%@/read", priMsgs.curFriend.global_key] withParams:nil withMethodType:Post autoShowError:NO andBlock:^(id data, NSError *error) {
                    if (data) {
                        [[UnReadManager shareManager] updateUnRead];
                    }
                }];
            }
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_Fresh_PrivateMessages:(PrivateMessages *)priMsgs andBlock:(void (^)(id data, NSError *error))block{
    priMsgs.isPolling = YES;
    __weak PrivateMessages *weakMsgs = priMsgs;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[priMsgs toPollPath] withParams:[priMsgs toPollParams] withMethodType:Get autoShowError:NO andBlock:^(id data, NSError *error) {
        __strong PrivateMessages *strongMsgs = weakMsgs;
        strongMsgs.isPolling = NO;
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"私信_轮询"];

            id resultData = [data valueForKeyPath:@"data"];
            NSArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"PrivateMessage"];
            
            {//标记为已读
                NSString *myGK = [Login curLoginUser].global_key;
                [resultA enumerateObjectsUsingBlock:^(PrivateMessage *obj, NSUInteger idx, BOOL *stop) {
                    if (idx == 0) {
                        [priMsgs freshLastId:obj.id];
                    }
                    if (obj.sender.global_key.length > 0 && ![obj.sender.global_key isEqualToString:myGK]) {
                        *stop = YES;
                        [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"api/message/conversations/%@/read", obj.sender.global_key] withParams:nil withMethodType:Post autoShowError:NO andBlock:^(id data, NSError *error) {
                            DebugLog(@"request_Fresh_PrivateMessages Mark Sucess");
                        }];
                    }
                }];
            }
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_SendPrivateMessage:(PrivateMessage *)nextMsg andBlock:(void (^)(id data, NSError *error))block{
    nextMsg.sendStatus = PrivateMessageStatusSending;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[nextMsg toSendPath] withParams:[nextMsg toSendParams] withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"私信_发送_(有图和无图)"];

            id resultData = [data valueForKeyPath:@"data"];
            PrivateMessage *resultA = [NSObject objectOfClass:@"PrivateMessage" fromJSON:resultData];
            nextMsg.sendStatus = PrivateMessageStatusSendSucess;
            block(resultA, nil);
        }else{
            nextMsg.sendStatus = PrivateMessageStatusSendFail;
            block(nil, error);
        }
    }];
}

- (void)request_SendPrivateMessage:(PrivateMessage *)nextMsg andBlock:(void (^)(id data, NSError *error))block progerssBlock:(void (^)(CGFloat progressValue))progress{
    nextMsg.sendStatus = PrivateMessageStatusSending;
    if (nextMsg.nextImg && (!nextMsg.extra || nextMsg.extra.length <= 0)) {
        [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"私信_发送_有图"];
//        先上传图片
        [self uploadTweetImage:nextMsg.nextImg doneBlock:^(NSString *imagePath, NSError *error) {
            if (imagePath) {
//                上传成功后，发送私信
                nextMsg.extra = imagePath;
                [self request_SendPrivateMessage:nextMsg andBlock:block];
            }else{
                nextMsg.sendStatus = PrivateMessageStatusSendFail;
                block(nil, error);
            }
        } progerssBlock:^(CGFloat progressValue) {
        }];
    } else if (nextMsg.voiceMedia) {
        [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"私信_发送_语音"];
        [[CodingNetAPIClient sharedJsonClient] uploadVoice:nextMsg.voiceMedia.file withPath:@"api/message/send_voice" withParams:[nextMsg toSendParams] andBlock:^(id data, NSError *error) {
            if (data) {
                id resultData = [data valueForKeyPath:@"data"];
                PrivateMessage *result = [NSObject objectOfClass:@"PrivateMessage" fromJSON:resultData];
                nextMsg.sendStatus = PrivateMessageStatusSendSucess;
                block(result, nil);
            }else{
                nextMsg.sendStatus = PrivateMessageStatusSendFail;
                block(nil, error);
            }
        }];
    } else {
//        发送私信
        [self request_SendPrivateMessage:nextMsg andBlock:block];
    }
}

- (void)request_playedPrivateMessage:(PrivateMessage *)pm {
    NSString *path = [NSString stringWithFormat:@"/api/message/conversations/%@/play", pm.id];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Post autoShowError:NO andBlock:^(id data, NSError *error) {
        DebugLog(@"request_playedPrivateMessage Mark Sucess");
    }];
}

- (void)request_CodingTips:(CodingTips *)curTips andBlock:(void (^)(id data, NSError *error))block{
    curTips.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curTips toTipsPath] withParams:[curTips toTipsParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        curTips.isLoading = NO;
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"消息通知_列表"];

            id resultData = [data valueForKeyPath:@"data"];
            CodingTips *resultA = [NSObject objectOfClass:@"CodingTips" fromJSON:resultData];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_markReadWithCodingTips:(CodingTips *)curTips andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/notification/mark-read" withParams:[curTips toMarkReadParams] withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"消息通知_标记某类型全部为已读"];

            block(data, nil);
            [[UnReadManager shareManager] updateUnRead];
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_markReadWithCodingTipIdStr:(NSString *)tipIdStr andBlock:(void (^)(id data, NSError *error))block{
    if (tipIdStr.length <= 0) {
        return;
    }
    NSDictionary *params = @{@"id" : tipIdStr};
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/notification/mark-read" withParams:params withMethodType:Post autoShowError:NO andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"消息通知_标记某条消息为已读"];

            block(data, nil);
            [[UnReadManager shareManager] updateUnRead];
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_DeletePrivateMessage:(PrivateMessage *)curMsg andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curMsg toDeletePath] withParams:nil withMethodType:Delete andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"私信_删除"];

            block(curMsg, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_DeletePrivateMessagesWithObj:(PrivateMessage *)curObj andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curObj.friend toDeleteConversationPath] withParams:nil withMethodType:Delete andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"会话_删除"];

            block(curObj, nil);
        }else{
            block(nil, error);
        }
    }];
}


#pragma mark Image
- (void)uploadTweetImage:(UIImage *)image
               doneBlock:(void (^)(NSString *imagePath, NSError *error))done
           progerssBlock:(void (^)(CGFloat progressValue))progress{
    if (!image) {
        done(nil, [NSError errorWithDomain:@"DATA EMPTY" code:0 userInfo:@{NSLocalizedDescriptionKey : @"有张照片没有读取成功"}]);
        return;
    }
    [[CodingNetAPIClient sharedJsonClient] uploadImage:image path:@"api/tweet/insert_image" name:@"tweetImg" successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *reslutString = [responseObject objectForKey:@"data"];
        DebugLog(@"%@", reslutString);
        done(reslutString, nil);
    } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        done(nil, error);
    } progerssBlock:^(CGFloat progressValue) {
        progress(progressValue);
    }];
}
- (void)request_UpdateUserIconImage:(UIImage *)image
                       successBlock:(void (^)(id responseObj))success
                       failureBlock:(void (^)(NSError *error))failure
                      progerssBlock:(void (^)(CGFloat progressValue))progress{
    if (!image) {
        [NSObject showHudTipStr:@"读图失败"];
        return;
    }
    [NSObject showStatusBarQueryStr:@"正在上传头像"];
    CGSize maxSize = CGSizeMake(800, 800);
    if (image.size.width > maxSize.width || image.size.height > maxSize.height) {
        image = [image scaleToSize:maxSize usingMode:NYXResizeModeAspectFit];
    }
    [[CodingNetAPIClient sharedJsonClient] uploadImage:image path:@"api/user/avatar?update=1" name:@"file" successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"个人信息_更换头像"];

        [NSObject showStatusBarSuccessStr:@"上传头像成功"];
        id resultData = [responseObject valueForKeyPath:@"data"];
        success(resultData);
    } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
        [NSObject showStatusBarError:error];
    } progerssBlock:progress];
}

- (void)loadImageWithPath:(NSString *)imageUrlStr completeBlock:(void (^)(UIImage *image, NSError *error))block{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrlStr]];
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [MobClick event:kUmeng_Event_Request_Get label:@"下载验证码"];

        DebugLog(@"Response: %@", responseObject);
        block(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DebugLog(@"Image error: %@", error);
        block(nil, error);
    }];
    [requestOperation start];
}
#pragma mark Other
- (void)request_Users_WithSearchString:(NSString *)searchStr andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/user/search" withParams:@{@"key" : searchStr} withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"搜索用户"];

            id resultData = [data valueForKeyPath:@"data"];
            NSMutableArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"User"];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_Users_WithTopicID:(NSInteger)topicID andBlock:(void (^)(id data, NSError *error))block {
    NSString *path = [NSString stringWithFormat:@"api/tweet_topic/%ld/hot_joined",(long)topicID];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"话题_热门参与者"];

            id resultData = [data valueForKeyPath:@"data"];
            NSMutableArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"User"];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_JoinedUsers_WithTopicID:(NSInteger)topicID page:(NSInteger)page andBlock:(void (^)(id data, NSError *error))block {
    NSString *path = [NSString stringWithFormat:@"api/tweet_topic/%ld/joined",(long)topicID];
    NSDictionary *params = @{
                             @"page":@(page),
                             @"pageSize":@(100)
                             };
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"话题_全部参与者"];

            id resultData = data[@"data"][@"list"];
            NSMutableArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"User"];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}



- (NSString *)localMDHtmlStr_WithMDStr:(NSString *)mdStr{
    NSError  *error = nil;
    NSString *htmlStr;
    @try {
        htmlStr = [MMMarkdown HTMLStringWithMarkdown:mdStr error:&error];
    }
    @catch (NSException *exception) {
        htmlStr = @"加载失败！";
    }
    if (error) {
        htmlStr = @"加载失败！";
    }
    return htmlStr;
}

- (void)request_VerifyTypeWithBlock:(void (^)(VerifyType type, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/user/2fa/method" withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"高危操作_获取校验类型"];

            VerifyType type = VerifyTypeUnknow;
            NSString *typeStr = [data valueForKey:@"data"];
            if ([typeStr isEqualToString:@"password"]) {
                type = VerifyTypePassword;
            }else if ([typeStr isEqualToString:@"totp"]){
                type = VerifyTypeTotp;
            }
            block(type, nil);
        }else{
            block(VerifyTypeUnknow, error);
        }
    }];
}

#pragma mark -
#pragma mark Topic HotKey

- (void)request_TopicHotkeyWithBlock:(void (^)(id data, NSError *error))block {

    NSString *path = @"/api/tweet_topic/hot?page=1&pageSize=20";
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        
        if(data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"话题_热门话题_Key"];

            id resultData = [data valueForKey:@"data"];
            block(resultData, nil);
        }else {
        
            block(nil, error);
        }
    }];
}

#pragma mark - topic
- (void)request_TopicAdlistWithBlock:(void (^)(id data, NSError *error))block {
    NSString *path = @"/api/tweet_topic/marketing_ad";
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if(data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"话题_Banner"];

            id resultData = [data valueForKey:@"data"];
            block(resultData, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_HotTopiclistWithBlock:(void (^)(id data, NSError *error))block {
        NSString *path = @"/api/tweet_topic/hot";
        [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
            if(data) {
                [MobClick event:kUmeng_Event_Request_Get label:@"话题_热门话题_榜单"];

                id resultData = [data valueForKey:@"data"];
                block(resultData, nil);
                
            }else {
                block(nil, error);
            }
        }];
}

- (void)request_Tweet_WithSearchString:(NSString *)strSearch andPage:(NSInteger)page andBlock:(void (^)(id data, NSError *error))block {

    NSString *path = [NSString stringWithFormat:@"/api/search/quick?q=%@&page=%d", strSearch, (int)page];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
       
        if(data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"冒泡_搜索"];

            id resultData = [(NSDictionary *)[data valueForKey:@"data"] objectForKey:@"tweets"];
            block(resultData, nil);
        }else {
        
            block(nil, error);
        }
    }];

}

- (void)request_TopicDetailsWithTopicID:(NSInteger)topicID block:(void (^)(id data, NSError *error))block {
    NSString *path = [NSString stringWithFormat:@"/api/tweet_topic/%ld",(long)topicID];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if(data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"话题_详情"];

            id resultData = data[@"data"];
            block(resultData, nil);
        }else {
            
            block(nil, error);
        }
    }];
}

- (void)request_TopTweetWithTopicID:(NSInteger)topicID block:(void (^)(id data, NSError *error))block {
    NSString *path = [NSString stringWithFormat:@"api/public_tweets/topic/%ld/top",(long)topicID];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if(data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"话题_热门冒泡列表"];

            id resultData = data[@"data"];
            Tweet *tweet =[NSObject objectOfClass:@"Tweet" fromJSON:resultData];
            block(tweet, nil);
        }else {
            
            block(nil, error);
        }
    }];
}


- (void)request_JoinedTopicsWithUserGK:(NSString *)userGK page:(NSInteger)page block:(void (^)(id data, BOOL hasMoreData, NSError *error))block {
    NSString *path = [[NSString stringWithFormat:@"api/user/%@/tweet_topic/joined",userGK] stringByAppendingString:[NSString stringWithFormat:@"?page=%d&extraInfo=1", (int)page]];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if(data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"话题_我参与的"];

            id resultData = data[@"data"];
            BOOL hasMoreData = [resultData[@"totalPage"] intValue] - [resultData[@"page"] intValue];
            block(resultData, hasMoreData, nil);
        }else {
            block(nil, NO, error);
        }
    }];
}

- (void)request_WatchedTopicsWithUserGK:(NSString *)userGK page:(NSInteger)page block:(void (^)(id data, BOOL hasMoreData, NSError *error))block {
    NSString *path = [[NSString stringWithFormat:@"/api/user/%@/tweet_topic/watched",userGK] stringByAppendingString:[NSString stringWithFormat:@"?page=%d&extraInfo=1", (int)page]];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if(data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"话题_我关注的"];

            id resultData = data[@"data"];
            BOOL hasMoreData = [resultData[@"totalPage"] intValue] - [resultData[@"page"] intValue];
            block(resultData, hasMoreData, nil);
        }else {
            block(nil, NO, error);
        }
    }];
}

- (void)request_Topic_DoWatch_WithUrl:(NSString *)url andBlock:(void (^)(id data, NSError *error))block{
    
    BOOL isUnwatched = [url hasSuffix:@"unwatch"];
    NetworkMethod method = isUnwatched ? Delete : Post;
    
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:url withParams:nil withMethodType:method andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"话题_关注"];

            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_BannersWithBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/banner/type/app" withParams:nil withMethodType:Get autoShowError:NO andBlock:^(id data, NSError *error) {
        if (data) {
            [MobClick event:kUmeng_Event_Request_Get label:@"冒泡列表_Banner"];

            data = [data valueForKey:@"data"];
            NSArray *resultA = [NSArray arrayFromJSON:data ofObjects:@"CodingBanner"];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}
@end